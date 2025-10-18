-- Advanced FiveM Framework - Server Side
-- Ultra Edition with 40+ Features

local Framework = AdvancedFiveMFramework

-- Server-side Framework Extension
Framework.Server = {}

-- Server Configuration
Framework.Server.Config = {
    MaxPlayers = 128,
    TickRate = 64,
    ResourceName = GetCurrentResourceName(),
    ServerName = "Advanced FiveM Server",
    ServerDescription = "Ultra Advanced FiveM Framework with 40+ Features",
    ServerWebsite = "https://your-domain.com",
    ServerDiscord = "https://discord.gg/your-server",
    ServerVersion = "2.0.0"
}

-- Server State
Framework.Server.State = {
    Players = {},
    OnlinePlayers = 0,
    ServerStartTime = os.time(),
    Uptime = 0,
    Performance = {
        CPU = 0,
        Memory = 0,
        Network = 0
    },
    Statistics = {
        TotalConnections = 0,
        TotalDisconnections = 0,
        PeakPlayers = 0,
        AveragePlayers = 0
    }
}

-- Database Connection
Framework.Server.Database = {}

-- Initialize Database
Framework.Server.Database.Initialize = function()
    Framework.Logging.Info("Initializing database connection...")
    
    -- Database configuration
    local dbConfig = Framework.Config.Database
    
    -- Create database connection
    if dbConfig.Type == "mysql" then
        Framework.Server.Database.Connection = MySQL
        Framework.Server.Database.Connection.Async = {}
        Framework.Server.Database.Connection.Sync = {}
        
        -- Initialize MySQL
        Framework.Server.Database.Connection.Async.ready = false
        Framework.Server.Database.Connection.Sync.ready = false
        
        -- Test connection
        Framework.Server.Database.TestConnection()
    elseif dbConfig.Type == "postgresql" then
        -- PostgreSQL implementation
        Framework.Logging.Info("PostgreSQL support coming soon...")
    elseif dbConfig.Type == "sqlite" then
        -- SQLite implementation
        Framework.Logging.Info("SQLite support coming soon...")
    end
    
    Framework.Logging.Info("Database initialized successfully")
end

-- Test Database Connection
Framework.Server.Database.TestConnection = function()
    if Framework.Server.Database.Connection then
        Framework.Server.Database.Connection.Async.execute("SELECT 1", {}, function(result)
            if result then
                Framework.Server.Database.Connection.Async.ready = true
                Framework.Logging.Info("Database connection test successful")
            else
                Framework.Logging.Error("Database connection test failed")
            end
        end)
    end
end

-- Execute Database Query
Framework.Server.Database.Execute = function(query, params, callback)
    if Framework.Server.Database.Connection and Framework.Server.Database.Connection.Async.ready then
        Framework.Server.Database.Connection.Async.execute(query, params or {}, callback)
    else
        Framework.Logging.Error("Database not ready for query: " .. query)
        if callback then callback(false) end
    end
end

-- Fetch Database Results
Framework.Server.Database.Fetch = function(query, params, callback)
    if Framework.Server.Database.Connection and Framework.Server.Database.Connection.Async.ready then
        Framework.Server.Database.Connection.Async.fetchAll(query, params or {}, callback)
    else
        Framework.Logging.Error("Database not ready for fetch: " .. query)
        if callback then callback({}) end
    end
end

-- Player Management
Framework.Server.Players = {}

-- Get Player Data
Framework.Server.Players.GetData = function(playerId)
    return Framework.Server.State.Players[playerId] or {}
end

-- Set Player Data
Framework.Server.Players.SetData = function(playerId, data)
    if Framework.Server.State.Players[playerId] then
        Framework.Server.State.Players[playerId] = Framework.Utils.Table.Merge(Framework.Server.State.Players[playerId], data)
    else
        Framework.Server.State.Players[playerId] = data
    end
end

-- Save Player Data
Framework.Server.Players.SaveData = function(playerId)
    local playerData = Framework.Server.Players.GetData(playerId)
    if playerData and playerData.identifier then
        Framework.Server.Database.Execute(
            "INSERT INTO players (identifier, data, last_seen) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE data = ?, last_seen = ?",
            {playerData.identifier, json.encode(playerData), os.time(), json.encode(playerData), os.time()},
            function(result)
                if result then
                    Framework.Logging.Debug("Player data saved for: " .. playerId)
                else
                    Framework.Logging.Error("Failed to save player data for: " .. playerId)
                end
            end
        )
    end
end

-- Load Player Data
Framework.Server.Players.LoadData = function(playerId, identifier)
    Framework.Server.Database.Fetch(
        "SELECT * FROM players WHERE identifier = ?",
        {identifier},
        function(result)
            if result and result[1] then
                local playerData = json.decode(result[1].data)
                Framework.Server.Players.SetData(playerId, playerData)
                Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:PlayerDataLoaded", playerData)
                Framework.Logging.Debug("Player data loaded for: " .. playerId)
            else
                -- Create new player data
                local newPlayerData = {
                    identifier = identifier,
                    name = GetPlayerName(playerId),
                    money = 5000,
                    bank = 0,
                    job = "unemployed",
                    grade = 0,
                    group = "user",
                    created_at = os.time(),
                    last_seen = os.time()
                }
                Framework.Server.Players.SetData(playerId, newPlayerData)
                Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:PlayerDataLoaded", newPlayerData)
                Framework.Logging.Debug("New player data created for: " .. playerId)
            end
        end
    )
end

-- Economy System
Framework.Server.Economy = {}

-- Get Player Money
Framework.Server.Economy.GetMoney = function(playerId, account)
    local playerData = Framework.Server.Players.GetData(playerId)
    return playerData[account or "money"] or 0
end

-- Add Money
Framework.Server.Economy.AddMoney = function(playerId, amount, account, reason)
    local playerData = Framework.Server.Players.GetData(playerId)
    local currentAmount = playerData[account or "money"] or 0
    local newAmount = currentAmount + amount
    
    Framework.Server.Players.SetData(playerId, {[account or "money"] = newAmount})
    
    -- Log transaction
    Framework.Server.Economy.LogTransaction(playerId, amount, account, reason, "add")
    
    -- Notify player
    Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:MoneyChanged", account or "money", newAmount)
    
    return newAmount
end

-- Remove Money
Framework.Server.Economy.RemoveMoney = function(playerId, amount, account, reason)
    local playerData = Framework.Server.Players.GetData(playerId)
    local currentAmount = playerData[account or "money"] or 0
    
    if currentAmount >= amount then
        local newAmount = currentAmount - amount
        Framework.Server.Players.SetData(playerId, {[account or "money"] = newAmount})
        
        -- Log transaction
        Framework.Server.Economy.LogTransaction(playerId, amount, account, reason, "remove")
        
        -- Notify player
        Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:MoneyChanged", account or "money", newAmount)
        
        return true, newAmount
    else
        return false, currentAmount
    end
end

-- Transfer Money
Framework.Server.Economy.TransferMoney = function(fromPlayerId, toPlayerId, amount, account, reason)
    local success, newAmount = Framework.Server.Economy.RemoveMoney(fromPlayerId, amount, account, reason)
    
    if success then
        Framework.Server.Economy.AddMoney(toPlayerId, amount, account, reason)
        return true
    else
        return false
    end
end

-- Log Transaction
Framework.Server.Economy.LogTransaction = function(playerId, amount, account, reason, type)
    Framework.Server.Database.Execute(
        "INSERT INTO economy_transactions (player_id, amount, account, reason, type, timestamp) VALUES (?, ?, ?, ?, ?, ?)",
        {playerId, amount, account or "money", reason or "Unknown", type, os.time()},
        function(result)
            if result then
                Framework.Logging.Debug("Transaction logged for player: " .. playerId)
            end
        end
    )
end

-- Job System
Framework.Server.Jobs = {}

-- Get Player Job
Framework.Server.Jobs.GetJob = function(playerId)
    local playerData = Framework.Server.Players.GetData(playerId)
    return playerData.job or "unemployed", playerData.grade or 0
end

-- Set Player Job
Framework.Server.Jobs.SetJob = function(playerId, job, grade)
    Framework.Server.Players.SetData(playerId, {job = job, grade = grade or 0})
    Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:JobChanged", job, grade)
    Framework.Logging.Info("Player " .. playerId .. " job changed to: " .. job .. " (Grade: " .. (grade or 0) .. ")")
end

-- Get Job Data
Framework.Server.Jobs.GetJobData = function(job)
    local jobs = {
        unemployed = {label = "Unemployed", grades = {{name = "Freelancer", payment = 0}}},
        police = {label = "Police", grades = {{name = "Recruit", payment = 500}, {name = "Officer", payment = 750}, {name = "Sergeant", payment = 1000}, {name = "Lieutenant", payment = 1250}, {name = "Captain", payment = 1500}}},
        ambulance = {label = "Ambulance", grades = {{name = "Recruit", payment = 500}, {name = "Paramedic", payment = 750}, {name = "Doctor", payment = 1000}, {name = "Chief", payment = 1250}}},
        mechanic = {label = "Mechanic", grades = {{name = "Recruit", payment = 400}, {name = "Mechanic", payment = 600}, {name = "Senior", payment = 800}, {name = "Boss", payment = 1000}}},
        taxi = {label = "Taxi", grades = {{name = "Driver", payment = 300}, {name = "Senior", payment = 500}, {name = "Boss", payment = 700}}},
        delivery = {label = "Delivery", grades = {{name = "Driver", payment = 250}, {name = "Senior", payment = 400}, {name = "Boss", payment = 600}}},
        trucker = {label = "Trucker", grades = {{name = "Driver", payment = 350}, {name = "Senior", payment = 550}, {name = "Boss", payment = 750}}},
        farmer = {label = "Farmer", grades = {{name = "Worker", payment = 300}, {name = "Senior", payment = 500}, {name = "Boss", payment = 700}}},
        miner = {label = "Miner", grades = {{name = "Worker", payment = 400}, {name = "Senior", payment = 600}, {name = "Boss", payment = 800}}},
        fisherman = {label = "Fisherman", grades = {{name = "Worker", payment = 300}, {name = "Senior", payment = 500}, {name = "Boss", payment = 700}}},
        lumberjack = {label = "Lumberjack", grades = {{name = "Worker", payment = 350}, {name = "Senior", payment = 550}, {name = "Boss", payment = 750}}},
        hunter = {label = "Hunter", grades = {{name = "Worker", payment = 400}, {name = "Senior", payment = 600}, {name = "Boss", payment = 800}}},
        chef = {label = "Chef", grades = {{name = "Cook", payment = 400}, {name = "Chef", payment = 600}, {name = "Head Chef", payment = 800}}},
        bartender = {label = "Bartender", grades = {{name = "Worker", payment = 300}, {name = "Senior", payment = 500}, {name = "Boss", payment = 700}}},
        reporter = {label = "Reporter", grades = {{name = "Intern", payment = 400}, {name = "Reporter", payment = 600}, {name = "Editor", payment = 800}}},
        lawyer = {label = "Lawyer", grades = {{name = "Intern", payment = 500}, {name = "Lawyer", payment = 800}, {name = "Partner", payment = 1200}}}
    }
    
    return jobs[job] or jobs.unemployed
end

-- Performance Monitoring
Framework.Server.Performance = {}

-- Update Performance Metrics
Framework.Server.Performance.Update = function()
    -- Update uptime
    Framework.Server.State.Uptime = os.time() - Framework.Server.State.ServerStartTime
    
    -- Update player count
    Framework.Server.State.OnlinePlayers = #GetPlayers()
    
    -- Update peak players
    if Framework.Server.State.OnlinePlayers > Framework.Server.State.Statistics.PeakPlayers then
        Framework.Server.State.Statistics.PeakPlayers = Framework.Server.State.OnlinePlayers
    end
    
    -- Update average players (simplified calculation)
    local totalTime = Framework.Server.State.Uptime
    local totalPlayers = Framework.Server.State.Statistics.TotalConnections
    Framework.Server.State.Statistics.AveragePlayers = totalTime > 0 and (totalPlayers / totalTime) or 0
end

-- Event Handlers
-- Player Connecting
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local playerId = source
    local identifier = GetPlayerIdentifiers(playerId)[1]
    
    Framework.Logging.Info("Player connecting: " .. name .. " (ID: " .. playerId .. ")")
    
    -- Load player data
    Framework.Server.Players.LoadData(playerId, identifier)
    
    -- Update statistics
    Framework.Server.State.Statistics.TotalConnections = Framework.Server.State.Statistics.TotalConnections + 1
end)

-- Player Dropped
AddEventHandler('playerDropped', function(reason)
    local playerId = source
    local playerData = Framework.Server.Players.GetData(playerId)
    
    Framework.Logging.Info("Player dropped: " .. playerId .. " (Reason: " .. reason .. ")")
    
    -- Save player data
    if playerData then
        Framework.Server.Players.SaveData(playerId)
    end
    
    -- Remove from state
    Framework.Server.State.Players[playerId] = nil
    
    -- Update statistics
    Framework.Server.State.Statistics.TotalDisconnections = Framework.Server.State.Statistics.TotalDisconnections + 1
end)

-- Player Loaded
AddEventHandler('AdvancedFiveMFramework:PlayerLoaded', function()
    local playerId = source
    Framework.Logging.Info("Player loaded: " .. playerId)
end)

-- Callbacks
-- Get Player Data
Framework.Callbacks.Register('AdvancedFiveMFramework:GetPlayerData', function(source)
    return Framework.Server.Players.GetData(source)
end)

-- Get Server Stats
Framework.Callbacks.Register('AdvancedFiveMFramework:GetServerStats', function(source)
    return {
        onlinePlayers = Framework.Server.State.OnlinePlayers,
        maxPlayers = Framework.Server.Config.MaxPlayers,
        uptime = Framework.Server.State.Uptime,
        statistics = Framework.Server.State.Statistics
    }
end)

-- Add Money
Framework.Callbacks.Register('AdvancedFiveMFramework:AddMoney', function(source, amount, account, reason)
    return Framework.Server.Economy.AddMoney(source, amount, account, reason)
end)

-- Remove Money
Framework.Callbacks.Register('AdvancedFiveMFramework:RemoveMoney', function(source, amount, account, reason)
    return Framework.Server.Economy.RemoveMoney(source, amount, account, reason)
end)

-- Transfer Money
Framework.Callbacks.Register('AdvancedFiveMFramework:TransferMoney', function(source, targetId, amount, account, reason)
    return Framework.Server.Economy.TransferMoney(source, targetId, amount, account, reason)
end)

-- Set Job
Framework.Callbacks.Register('AdvancedFiveMFramework:SetJob', function(source, job, grade)
    Framework.Server.Jobs.SetJob(source, job, grade)
    return true
end)

-- Get Job Data
Framework.Callbacks.Register('AdvancedFiveMFramework:GetJobData', function(source, job)
    return Framework.Server.Jobs.GetJobData(job)
end)

-- Initialize Framework
Citizen.CreateThread(function()
    -- Initialize database
    Framework.Server.Database.Initialize()
    
    -- Create database tables
    Framework.Server.Database.Execute([[
        CREATE TABLE IF NOT EXISTS players (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(255) UNIQUE NOT NULL,
            data LONGTEXT,
            last_seen INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]], {}, function(result)
        if result then
            Framework.Logging.Info("Players table created/verified")
        end
    end)
    
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
    
    -- Start performance monitoring
    Citizen.CreateThread(function()
        while true do
            Framework.Server.Performance.Update()
            Citizen.Wait(5000) -- Update every 5 seconds
        end
    end)
    
    Framework.Logging.Info("Advanced FiveM Framework Server initialized successfully")
end)

-- Export functions
exports('GetPlayerData', Framework.Server.Players.GetData)
exports('GetEconomyData', Framework.Server.Economy.GetMoney)
exports('GetServerStats', function() return Framework.Server.State end)
exports('TriggerEvent', Framework.Events.Trigger)
exports('RegisterCallback', Framework.Callbacks.Register)