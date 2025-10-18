-- Advanced Economy System - Server Side
-- Ultra Edition Feature

local Framework = AdvancedFiveMFramework

-- Economy System
Framework.Economy = {}

-- Economy Configuration
Framework.Economy.Config = {
    StartingMoney = 5000,
    StartingBank = 0,
    MaxMoney = 999999999,
    MaxBank = 999999999,
    InterestRate = 0.01, -- 1% per day
    TaxRate = 0.1, -- 10% tax
    InflationRate = 0.001, -- 0.1% per hour
    DeflationRate = 0.0005, -- 0.05% per hour
    MarketVolatility = 0.05, -- 5% volatility
    EconomicEvents = {
        {name = "Market Crash", effect = -0.2, duration = 3600, probability = 0.01},
        {name = "Economic Boom", effect = 0.15, duration = 7200, probability = 0.02},
        {name = "Inflation Spike", effect = 0.1, duration = 1800, probability = 0.03},
        {name = "Deflation", effect = -0.05, duration = 2400, probability = 0.02}
    }
}

-- Economy State
Framework.Economy.State = {
    Inflation = 0,
    Deflation = 0,
    MarketValue = 1.0,
    ActiveEvents = {},
    LastUpdate = os.time(),
    TotalMoney = 0,
    TotalBank = 0,
    Transactions = 0,
    AverageTransaction = 0
}

-- Money Management
Framework.Economy.GetMoney = function(playerId, account)
    local playerData = Framework.Server.Players.GetData(playerId)
    if playerData then
        return playerData[account or "money"] or 0
    end
    return 0
end

Framework.Economy.SetMoney = function(playerId, amount, account)
    local playerData = Framework.Server.Players.GetData(playerId)
    if playerData then
        amount = Framework.Utils.Math.Clamp(amount, 0, Framework.Economy.Config.MaxMoney)
        Framework.Server.Players.SetData(playerId, {[account or "money"] = amount})
        Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:MoneyChanged", account or "money", amount)
        return amount
    end
    return 0
end

Framework.Economy.AddMoney = function(playerId, amount, account, reason)
    local currentAmount = Framework.Economy.GetMoney(playerId, account)
    local newAmount = currentAmount + amount
    local finalAmount = Framework.Economy.SetMoney(playerId, newAmount, account)
    
    -- Log transaction
    Framework.Economy.LogTransaction(playerId, amount, account, reason, "add")
    
    return finalAmount
end

Framework.Economy.RemoveMoney = function(playerId, amount, account, reason)
    local currentAmount = Framework.Economy.GetMoney(playerId, account)
    if currentAmount >= amount then
        local newAmount = currentAmount - amount
        local finalAmount = Framework.Economy.SetMoney(playerId, newAmount, account)
        
        -- Log transaction
        Framework.Economy.LogTransaction(playerId, amount, account, reason, "remove")
        
        return true, finalAmount
    else
        return false, currentAmount
    end
end

Framework.Economy.TransferMoney = function(fromPlayerId, toPlayerId, amount, account, reason)
    local success, newAmount = Framework.Economy.RemoveMoney(fromPlayerId, amount, account, reason)
    
    if success then
        Framework.Economy.AddMoney(toPlayerId, amount, account, reason)
        return true
    else
        return false
    end
end

-- Bank System
Framework.Economy.GetBankBalance = function(playerId)
    return Framework.Economy.GetMoney(playerId, "bank")
end

Framework.Economy.SetBankBalance = function(playerId, amount)
    return Framework.Economy.SetMoney(playerId, amount, "bank")
end

Framework.Economy.Deposit = function(playerId, amount, reason)
    local cashAmount = Framework.Economy.GetMoney(playerId, "money")
    if cashAmount >= amount then
        Framework.Economy.RemoveMoney(playerId, amount, "money", reason or "Bank Deposit")
        Framework.Economy.AddMoney(playerId, amount, "bank", reason or "Bank Deposit")
        return true
    else
        return false
    end
end

Framework.Economy.Withdraw = function(playerId, amount, reason)
    local bankAmount = Framework.Economy.GetBankBalance(playerId)
    if bankAmount >= amount then
        Framework.Economy.RemoveMoney(playerId, amount, "bank", reason or "Bank Withdrawal")
        Framework.Economy.AddMoney(playerId, amount, "money", reason or "Bank Withdrawal")
        return true
    else
        return false
    end
end

-- Loan System
Framework.Economy.RequestLoan = function(playerId, amount, interestRate, duration)
    local playerData = Framework.Server.Players.GetData(playerId)
    if playerData then
        local loanData = {
            amount = amount,
            interestRate = interestRate or 0.05,
            duration = duration or 86400, -- 24 hours
            startTime = os.time(),
            paidAmount = 0,
            status = "active"
        }
        
        -- Add loan to player data
        if not playerData.loans then
            playerData.loans = {}
        end
        table.insert(playerData.loans, loanData)
        
        -- Give money to player
        Framework.Economy.AddMoney(playerId, amount, "bank", "Loan")
        
        Framework.Server.Players.SetData(playerId, {loans = playerData.loans})
        return true
    end
    return false
end

Framework.Economy.PayLoan = function(playerId, loanId, amount)
    local playerData = Framework.Server.Players.GetData(playerId)
    if playerData and playerData.loans then
        local loan = playerData.loans[loanId]
        if loan and loan.status == "active" then
            local bankBalance = Framework.Economy.GetBankBalance(playerId)
            if bankBalance >= amount then
                Framework.Economy.RemoveMoney(playerId, amount, "bank", "Loan Payment")
                loan.paidAmount = loan.paidAmount + amount
                
                if loan.paidAmount >= loan.amount then
                    loan.status = "paid"
                end
                
                Framework.Server.Players.SetData(playerId, {loans = playerData.loans})
                return true
            end
        end
    end
    return false
end

-- Investment System
Framework.Economy.Invest = function(playerId, amount, investmentType)
    local bankBalance = Framework.Economy.GetBankBalance(playerId)
    if bankBalance >= amount then
        Framework.Economy.RemoveMoney(playerId, amount, "bank", "Investment")
        
        local investment = {
            type = investmentType,
            amount = amount,
            startTime = os.time(),
            returnRate = Framework.Economy.GetInvestmentReturnRate(investmentType),
            status = "active"
        }
        
        local playerData = Framework.Server.Players.GetData(playerId)
        if not playerData.investments then
            playerData.investments = {}
        end
        table.insert(playerData.investments, investment)
        
        Framework.Server.Players.SetData(playerId, {investments = playerData.investments})
        return true
    end
    return false
end

Framework.Economy.GetInvestmentReturnRate = function(investmentType)
    local rates = {
        stocks = 0.08, -- 8% annual return
        bonds = 0.03,  -- 3% annual return
        crypto = 0.15, -- 15% annual return (high risk)
        real_estate = 0.06, -- 6% annual return
        commodities = 0.04 -- 4% annual return
    }
    return rates[investmentType] or 0.05
end

-- Tax System
Framework.Economy.CalculateTax = function(amount, taxType)
    local taxRates = {
        income = 0.1, -- 10% income tax
        sales = 0.08, -- 8% sales tax
        property = 0.05, -- 5% property tax
        luxury = 0.15 -- 15% luxury tax
    }
    
    local rate = taxRates[taxType] or 0.1
    return amount * rate
end

Framework.Economy.CollectTax = function(playerId, amount, taxType)
    local tax = Framework.Economy.CalculateTax(amount, taxType)
    local success = Framework.Economy.RemoveMoney(playerId, tax, "money", "Tax Payment")
    return success, tax
end

-- Economic Events
Framework.Economy.ProcessEconomicEvents = function()
    local currentTime = os.time()
    
    -- Check for new events
    for _, event in pairs(Framework.Economy.Config.EconomicEvents) do
        if math.random() < event.probability then
            table.insert(Framework.Economy.State.ActiveEvents, {
                name = event.name,
                effect = event.effect,
                endTime = currentTime + event.duration,
                startTime = currentTime
            })
            
            Framework.Logging.Info("Economic event triggered: " .. event.name)
        end
    end
    
    -- Process active events
    for i = #Framework.Economy.State.ActiveEvents, 1, -1 do
        local event = Framework.Economy.State.ActiveEvents[i]
        if currentTime >= event.endTime then
            table.remove(Framework.Economy.State.ActiveEvents, i)
            Framework.Logging.Info("Economic event ended: " .. event.name)
        end
    end
    
    -- Update economy state
    Framework.Economy.UpdateEconomyState()
end

Framework.Economy.UpdateEconomyState = function()
    local currentTime = os.time()
    local timeDiff = currentTime - Framework.Economy.State.LastUpdate
    
    -- Calculate total effect of active events
    local totalEffect = 0
    for _, event in pairs(Framework.Economy.State.ActiveEvents) do
        totalEffect = totalEffect + event.effect
    end
    
    -- Update inflation/deflation
    Framework.Economy.State.Inflation = Framework.Economy.State.Inflation + (Framework.Economy.Config.InflationRate * timeDiff / 3600)
    Framework.Economy.State.Deflation = Framework.Economy.State.Deflation + (Framework.Economy.Config.DeflationRate * timeDiff / 3600)
    
    -- Update market value
    Framework.Economy.State.MarketValue = Framework.Economy.State.MarketValue * (1 + totalEffect + Framework.Economy.State.Inflation - Framework.Economy.State.Deflation)
    
    Framework.Economy.State.LastUpdate = currentTime
end

-- Transaction Logging
Framework.Economy.LogTransaction = function(playerId, amount, account, reason, type)
    Framework.Server.Database.Execute(
        "INSERT INTO economy_transactions (player_id, amount, account, reason, type, timestamp) VALUES (?, ?, ?, ?, ?, ?)",
        {playerId, amount, account or "money", reason or "Unknown", type, os.time()},
        function(result)
            if result then
                Framework.Economy.State.Transactions = Framework.Economy.State.Transactions + 1
                Framework.Economy.State.TotalMoney = Framework.Economy.State.TotalMoney + amount
                Framework.Economy.State.AverageTransaction = Framework.Economy.State.TotalMoney / Framework.Economy.State.Transactions
            end
        end
    )
end

-- Get Economy Statistics
Framework.Economy.GetStatistics = function()
    return {
        inflation = Framework.Economy.State.Inflation,
        deflation = Framework.Economy.State.Deflation,
        marketValue = Framework.Economy.State.MarketValue,
        activeEvents = Framework.Economy.State.ActiveEvents,
        totalTransactions = Framework.Economy.State.Transactions,
        averageTransaction = Framework.Economy.State.AverageTransaction,
        totalMoney = Framework.Economy.State.TotalMoney,
        totalBank = Framework.Economy.State.TotalBank
    }
end

-- Commands
RegisterCommand('money', function(source, args)
    local playerId = source
    local cash = Framework.Economy.GetMoney(playerId, "money")
    local bank = Framework.Economy.GetBankBalance(playerId)
    
    Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:ShowMoney", cash, bank)
end, false)

RegisterCommand('deposit', function(source, args)
    local playerId = source
    local amount = tonumber(args[1])
    
    if amount and amount > 0 then
        if Framework.Economy.Deposit(playerId, amount, "Bank Deposit") then
            Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:ShowNotification", "Deposited $" .. amount, "success")
        else
            Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:ShowNotification", "Insufficient funds", "error")
        end
    end
end, false)

RegisterCommand('withdraw', function(source, args)
    local playerId = source
    local amount = tonumber(args[1])
    
    if amount and amount > 0 then
        if Framework.Economy.Withdraw(playerId, amount, "Bank Withdrawal") then
            Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:ShowNotification", "Withdrew $" .. amount, "success")
        else
            Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:ShowNotification", "Insufficient bank balance", "error")
        end
    end
end, false)

RegisterCommand('transfer', function(source, args)
    local playerId = source
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    
    if targetId and amount and amount > 0 then
        if Framework.Economy.TransferMoney(playerId, targetId, amount, "money", "Money Transfer") then
            Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:ShowNotification", "Transferred $" .. amount, "success")
            Framework.Events.TriggerClient(targetId, "AdvancedFiveMFramework:ShowNotification", "Received $" .. amount, "success")
        else
            Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:ShowNotification", "Transfer failed", "error")
        end
    end
end, false)

RegisterCommand('loan', function(source, args)
    local playerId = source
    local amount = tonumber(args[1])
    local duration = tonumber(args[2]) or 86400
    
    if amount and amount > 0 then
        if Framework.Economy.RequestLoan(playerId, amount, 0.05, duration) then
            Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:ShowNotification", "Loan approved for $" .. amount, "success")
        else
            Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:ShowNotification", "Loan denied", "error")
        end
    end
end, false)

RegisterCommand('invest', function(source, args)
    local playerId = source
    local amount = tonumber(args[1])
    local investmentType = args[2] or "stocks"
    
    if amount and amount > 0 then
        if Framework.Economy.Invest(playerId, amount, investmentType) then
            Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:ShowNotification", "Invested $" .. amount .. " in " .. investmentType, "success")
        else
            Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:ShowNotification", "Investment failed", "error")
        end
    end
end, false)

RegisterCommand('economy', function(source, args)
    local playerId = source
    local stats = Framework.Economy.GetStatistics()
    
    local message = string.format(
        "Economy Statistics:\n" ..
        "Inflation: %.2f%%\n" ..
        "Deflation: %.2f%%\n" ..
        "Market Value: %.2f\n" ..
        "Active Events: %d\n" ..
        "Total Transactions: %d\n" ..
        "Average Transaction: $%.2f",
        stats.inflation * 100,
        stats.deflation * 100,
        stats.marketValue,
        #stats.activeEvents,
        stats.totalTransactions,
        stats.averageTransaction
    )
    
    Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:ShowNotification", message, "info")
end, false)

-- Callbacks
Framework.Callbacks.Register('AdvancedFiveMFramework:GetMoney', function(source, account)
    return Framework.Economy.GetMoney(source, account)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:AddMoney', function(source, amount, account, reason)
    return Framework.Economy.AddMoney(source, amount, account, reason)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:RemoveMoney', function(source, amount, account, reason)
    return Framework.Economy.RemoveMoney(source, amount, account, reason)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:TransferMoney', function(source, targetId, amount, account, reason)
    return Framework.Economy.TransferMoney(source, targetId, amount, account, reason)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:GetBankBalance', function(source)
    return Framework.Economy.GetBankBalance(source)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:Deposit', function(source, amount, reason)
    return Framework.Economy.Deposit(source, amount, reason)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:Withdraw', function(source, amount, reason)
    return Framework.Economy.Withdraw(source, amount, reason)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:GetEconomyStats', function(source)
    return Framework.Economy.GetStatistics()
end)

-- Initialize Economy System
Citizen.CreateThread(function()
    -- Create database tables
    Framework.Server.Database.Execute([[
        CREATE TABLE IF NOT EXISTS economy_transactions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            player_id INT,
            amount DECIMAL(10,2),
            account VARCHAR(50),
            reason VARCHAR(255),
            type VARCHAR(20),
            timestamp INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]], {}, function(result)
        if result then
            Framework.Logging.Info("Economy transactions table created/verified")
        end
    end)
    
    -- Start economy processing
    Citizen.CreateThread(function()
        while true do
            Framework.Economy.ProcessEconomicEvents()
            Citizen.Wait(60000) -- Process every minute
        end
    end)
    
    Framework.Logging.Info("Economy System initialized")
end)