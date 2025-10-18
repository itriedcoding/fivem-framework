-- Advanced Economy System - Client Side
-- Ultra Edition Feature

local Framework = AdvancedFiveMFramework

-- Client-side Economy System
Framework.Client.Economy = {}

-- Economy State
Framework.Client.Economy.State = {
    Money = {
        cash = 0,
        bank = 0,
        black_money = 0
    },
    Loans = {},
    Investments = {},
    Transactions = {},
    IsBankOpen = false,
    IsATMOpen = false
}

-- Initialize Economy
Framework.Client.Economy.Initialize = function()
    Framework.Logging.Info("Initializing client economy system...")
    
    -- Initialize economy state
    Framework.Client.Economy.State = {
        Money = {cash = 0, bank = 0, black_money = 0},
        Loans = {},
        Investments = {},
        Transactions = {},
        IsBankOpen = false,
        IsATMOpen = false
    }
    
    Framework.Logging.Info("Client economy system initialized")
end

-- Get Money
Framework.Client.Economy.GetMoney = function(account)
    return Framework.Client.Economy.State.Money[account or "cash"] or 0
end

-- Set Money
Framework.Client.Economy.SetMoney = function(account, amount)
    Framework.Client.Economy.State.Money[account or "cash"] = amount
end

-- Update Money Display
Framework.Client.Economy.UpdateDisplay = function()
    local cash = Framework.Client.Economy.GetMoney("cash")
    local bank = Framework.Client.Economy.GetMoney("bank")
    
    -- Update HUD
    Framework.Events.Trigger("AdvancedFiveMFramework:UpdateMoneyDisplay", cash, bank)
end

-- Show Money
Framework.Client.Economy.ShowMoney = function(cash, bank)
    Framework.Client.Economy.SetMoney("cash", cash)
    Framework.Client.Economy.SetMoney("bank", bank)
    Framework.Client.Economy.UpdateDisplay()
end

-- Open Bank
Framework.Client.Economy.OpenBank = function()
    if not Framework.Client.Economy.State.IsBankOpen then
        Framework.Client.Economy.State.IsBankOpen = true
        SetNuiFocus(true, true)
        
        SendNUIMessage({
            type = "openBank",
            data = {
                cash = Framework.Client.Economy.GetMoney("cash"),
                bank = Framework.Client.Economy.GetMoney("bank"),
                loans = Framework.Client.Economy.State.Loans,
                investments = Framework.Client.Economy.State.Investments,
                transactions = Framework.Client.Economy.State.Transactions
            }
        })
        
        Framework.Logging.Info("Bank opened")
    end
end

-- Close Bank
Framework.Client.Economy.CloseBank = function()
    if Framework.Client.Economy.State.IsBankOpen then
        Framework.Client.Economy.State.IsBankOpen = false
        SetNuiFocus(false, false)
        
        SendNUIMessage({
            type = "closeBank"
        })
        
        Framework.Logging.Info("Bank closed")
    end
end

-- Open ATM
Framework.Client.Economy.OpenATM = function()
    if not Framework.Client.Economy.State.IsATMOpen then
        Framework.Client.Economy.State.IsATMOpen = true
        SetNuiFocus(true, true)
        
        SendNUIMessage({
            type = "openATM",
            data = {
                cash = Framework.Client.Economy.GetMoney("cash"),
                bank = Framework.Client.Economy.GetMoney("bank")
            }
        })
        
        Framework.Logging.Info("ATM opened")
    end
end

-- Close ATM
Framework.Client.Economy.CloseATM = function()
    if Framework.Client.Economy.State.IsATMOpen then
        Framework.Client.Economy.State.IsATMOpen = false
        SetNuiFocus(false, false)
        
        SendNUIMessage({
            type = "closeATM"
        })
        
        Framework.Logging.Info("ATM closed")
    end
end

-- Deposit Money
Framework.Client.Economy.Deposit = function(amount)
    Framework.Callbacks.Trigger('AdvancedFiveMFramework:Deposit', amount, "Bank Deposit", function(success)
        if success then
            Framework.Client.UI.ShowNotification("Deposited $" .. amount, "success")
            Framework.Client.Economy.UpdateDisplay()
        else
            Framework.Client.UI.ShowNotification("Deposit failed", "error")
        end
    end)
end

-- Withdraw Money
Framework.Client.Economy.Withdraw = function(amount)
    Framework.Callbacks.Trigger('AdvancedFiveMFramework:Withdraw', amount, "Bank Withdrawal", function(success)
        if success then
            Framework.Client.UI.ShowNotification("Withdrew $" .. amount, "success")
            Framework.Client.Economy.UpdateDisplay()
        else
            Framework.Client.UI.ShowNotification("Withdrawal failed", "error")
        end
    end)
end

-- Transfer Money
Framework.Client.Economy.Transfer = function(targetId, amount, account)
    Framework.Callbacks.Trigger('AdvancedFiveMFramework:TransferMoney', targetId, amount, account or "money", "Money Transfer", function(success)
        if success then
            Framework.Client.UI.ShowNotification("Transferred $" .. amount, "success")
            Framework.Client.Economy.UpdateDisplay()
        else
            Framework.Client.UI.ShowNotification("Transfer failed", "error")
        end
    end)
end

-- Request Loan
Framework.Client.Economy.RequestLoan = function(amount, duration)
    Framework.Callbacks.Trigger('AdvancedFiveMFramework:RequestLoan', amount, 0.05, duration, function(success)
        if success then
            Framework.Client.UI.ShowNotification("Loan approved for $" .. amount, "success")
            Framework.Client.Economy.UpdateDisplay()
        else
            Framework.Client.UI.ShowNotification("Loan denied", "error")
        end
    end)
end

-- Invest Money
Framework.Client.Economy.Invest = function(amount, investmentType)
    Framework.Callbacks.Trigger('AdvancedFiveMFramework:Invest', amount, investmentType, function(success)
        if success then
            Framework.Client.UI.ShowNotification("Invested $" .. amount .. " in " .. investmentType, "success")
            Framework.Client.Economy.UpdateDisplay()
        else
            Framework.Client.UI.ShowNotification("Investment failed", "error")
        end
    end)
end

-- Get Economy Statistics
Framework.Client.Economy.GetStats = function()
    Framework.Callbacks.Trigger('AdvancedFiveMFramework:GetEconomyStats', function(stats)
        if stats then
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
            
            Framework.Client.UI.ShowNotification(message, "info", 10000)
        end
    end)
end

-- Event Handlers
AddEventHandler('AdvancedFiveMFramework:MoneyChanged', function(account, amount)
    Framework.Client.Economy.SetMoney(account, amount)
    Framework.Client.Economy.UpdateDisplay()
    Framework.Logging.Info("Money changed - " .. account .. ": $" .. amount)
end)

AddEventHandler('AdvancedFiveMFramework:ShowMoney', function(cash, bank)
    Framework.Client.Economy.ShowMoney(cash, bank)
end)

-- Commands
RegisterCommand('bank', function()
    Framework.Client.Economy.OpenBank()
end, false)

RegisterCommand('atm', function()
    Framework.Client.Economy.OpenATM()
end, false)

RegisterCommand('money', function()
    local cash = Framework.Client.Economy.GetMoney("cash")
    local bank = Framework.Client.Economy.GetMoney("bank")
    Framework.Client.UI.ShowNotification("Cash: $" .. cash .. " | Bank: $" .. bank, "info")
end, false)

RegisterCommand('deposit', function(source, args)
    local amount = tonumber(args[1])
    if amount and amount > 0 then
        Framework.Client.Economy.Deposit(amount)
    end
end, false)

RegisterCommand('withdraw', function(source, args)
    local amount = tonumber(args[1])
    if amount and amount > 0 then
        Framework.Client.Economy.Withdraw(amount)
    end
end, false)

RegisterCommand('transfer', function(source, args)
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    if targetId and amount and amount > 0 then
        Framework.Client.Economy.Transfer(targetId, amount)
    end
end, false)

RegisterCommand('loan', function(source, args)
    local amount = tonumber(args[1])
    local duration = tonumber(args[2]) or 86400
    if amount and amount > 0 then
        Framework.Client.Economy.RequestLoan(amount, duration)
    end
end, false)

RegisterCommand('invest', function(source, args)
    local amount = tonumber(args[1])
    local investmentType = args[2] or "stocks"
    if amount and amount > 0 then
        Framework.Client.Economy.Invest(amount, investmentType)
    end
end, false)

RegisterCommand('economy', function()
    Framework.Client.Economy.GetStats()
end, false)

-- NUI Callbacks
RegisterNUICallback('closeBank', function(data, cb)
    Framework.Client.Economy.CloseBank()
    cb('ok')
end)

RegisterNUICallback('closeATM', function(data, cb)
    Framework.Client.Economy.CloseATM()
    cb('ok')
end)

RegisterNUICallback('bankAction', function(data, cb)
    local action = data.action
    local params = data.params or {}
    
    if action == 'deposit' then
        Framework.Client.Economy.Deposit(params.amount)
    elseif action == 'withdraw' then
        Framework.Client.Economy.Withdraw(params.amount)
    elseif action == 'transfer' then
        Framework.Client.Economy.Transfer(params.targetId, params.amount, params.account)
    elseif action == 'loan' then
        Framework.Client.Economy.RequestLoan(params.amount, params.duration)
    elseif action == 'invest' then
        Framework.Client.Economy.Invest(params.amount, params.type)
    end
    
    cb('ok')
end)

RegisterNUICallback('atmAction', function(data, cb)
    local action = data.action
    local params = data.params or {}
    
    if action == 'deposit' then
        Framework.Client.Economy.Deposit(params.amount)
    elseif action == 'withdraw' then
        Framework.Client.Economy.Withdraw(params.amount)
    elseif action == 'balance' then
        local cash = Framework.Client.Economy.GetMoney("cash")
        local bank = Framework.Client.Economy.GetMoney("bank")
        Framework.Client.UI.ShowNotification("Cash: $" .. cash .. " | Bank: $" .. bank, "info")
    end
    
    cb('ok')
end)

-- Initialize
Citizen.CreateThread(function()
    Framework.Client.Economy.Initialize()
end)