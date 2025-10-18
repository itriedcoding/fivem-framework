-- Advanced Player Management System - Server Side
-- Ultra Edition Feature

local Framework = AdvancedFiveMFramework

-- Player Management System
Framework.PlayerManagement = {}

-- Player Data Structure
Framework.PlayerManagement.PlayerData = {
    identifier = "",
    name = "",
    firstname = "",
    lastname = "",
    dateofbirth = "",
    sex = "m",
    height = 0,
    money = 5000,
    bank = 0,
    black_money = 0,
    job = "unemployed",
    job_grade = 0,
    job_label = "Unemployed",
    group = "user",
    permissions = {},
    inventory = {},
    loadout = {},
    position = {x = 0.0, y = 0.0, z = 0.0},
    metadata = {},
    last_seen = 0,
    created_at = 0,
    updated_at = 0
}

-- Player States
Framework.PlayerManagement.PlayerStates = {
    CONNECTING = "connecting",
    CONNECTED = "connected",
    LOADING = "loading",
    LOADED = "loaded",
    DISCONNECTING = "disconnecting",
    DISCONNECTED = "disconnected"
}

-- Player Management Functions
Framework.PlayerManagement.GetPlayer = function(playerId)
    return Framework.Server.State.Players[playerId]
end

Framework.PlayerManagement.GetPlayerByIdentifier = function(identifier)
    for playerId, playerData in pairs(Framework.Server.State.Players) do
        if playerData.identifier == identifier then
            return playerId, playerData
        end
    end
    return nil, nil
end

Framework.PlayerManagement.GetPlayerByName = function(name)
    for playerId, playerData in pairs(Framework.Server.State.Players) do
        if playerData.name == name then
            return playerId, playerData
        end
    end
    return nil, nil
end

Framework.PlayerManagement.SetPlayerData = function(playerId, data)
    if Framework.Server.State.Players[playerId] then
        Framework.Server.State.Players[playerId] = Framework.Utils.Table.Merge(Framework.Server.State.Players[playerId], data)
        Framework.Server.State.Players[playerId].updated_at = os.time()
    end
end

Framework.PlayerManagement.GetPlayerData = function(playerId, key)
    local playerData = Framework.Server.State.Players[playerId]
    if playerData then
        if key then
            return playerData[key]
        else
            return playerData
        end
    end
    return nil
end

-- Player Registration
Framework.PlayerManagement.RegisterPlayer = function(playerId, identifier, name)
    local playerData = Framework.Utils.Table.DeepCopy(Framework.PlayerManagement.PlayerData)
    
    playerData.identifier = identifier
    playerData.name = name
    playerData.firstname = name:split(" ")[1] or name
    playerData.lastname = name:split(" ")[2] or ""
    playerData.dateofbirth = os.date("%Y-%m-%d", os.time() - (math.random(18, 65) * 365 * 24 * 60 * 60))
    playerData.sex = math.random(1, 2) == 1 and "m" or "f"
    playerData.height = math.random(150, 200)
    playerData.created_at = os.time()
    playerData.updated_at = os.time()
    playerData.last_seen = os.time()
    
    Framework.Server.State.Players[playerId] = playerData
    
    -- Save to database
    Framework.PlayerManagement.SavePlayer(playerId)
    
    Framework.Logging.Info("Player registered: " .. name .. " (ID: " .. playerId .. ")")
    return playerData
end

-- Player Loading
Framework.PlayerManagement.LoadPlayer = function(playerId, identifier)
    Framework.Server.Database.Fetch(
        "SELECT * FROM players WHERE identifier = ?",
        {identifier},
        function(result)
            if result and result[1] then
                local playerData = json.decode(result[1].data)
                Framework.Server.State.Players[playerId] = playerData
                Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:PlayerLoaded", playerData)
                Framework.Logging.Info("Player loaded: " .. playerId)
            else
                -- Register new player
                local name = GetPlayerName(playerId)
                local playerData = Framework.PlayerManagement.RegisterPlayer(playerId, identifier, name)
                Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:PlayerLoaded", playerData)
            end
        end
    )
end

-- Player Saving
Framework.PlayerManagement.SavePlayer = function(playerId)
    local playerData = Framework.Server.State.Players[playerId]
    if playerData then
        playerData.last_seen = os.time()
        playerData.updated_at = os.time()
        
        Framework.Server.Database.Execute(
            "INSERT INTO players (identifier, data, last_seen) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE data = ?, last_seen = ?",
            {playerData.identifier, json.encode(playerData), playerData.last_seen, json.encode(playerData), playerData.last_seen},
            function(result)
                if result then
                    Framework.Logging.Debug("Player saved: " .. playerId)
                else
                    Framework.Logging.Error("Failed to save player: " .. playerId)
                end
            end
        )
    end
end

-- Player Kicking
Framework.PlayerManagement.KickPlayer = function(playerId, reason)
    reason = reason or "You have been kicked from the server"
    DropPlayer(playerId, reason)
    Framework.Logging.Info("Player kicked: " .. playerId .. " (Reason: " .. reason .. ")")
end

-- Player Banning
Framework.PlayerManagement.BanPlayer = function(playerId, reason, duration)
    reason = reason or "You have been banned from the server"
    duration = duration or 0 -- 0 = permanent
    
    local playerData = Framework.PlayerManagement.GetPlayer(playerId)
    if playerData then
        -- Add to ban list
        Framework.Server.Database.Execute(
            "INSERT INTO bans (identifier, reason, duration, banned_at) VALUES (?, ?, ?, ?)",
            {playerData.identifier, reason, duration, os.time()},
            function(result)
                if result then
                    Framework.PlayerManagement.KickPlayer(playerId, reason)
                    Framework.Logging.Info("Player banned: " .. playerId .. " (Reason: " .. reason .. ", Duration: " .. duration .. ")")
                end
            end
        )
    end
end

-- Player Unbanning
Framework.PlayerManagement.UnbanPlayer = function(identifier)
    Framework.Server.Database.Execute(
        "DELETE FROM bans WHERE identifier = ?",
        {identifier},
        function(result)
            if result then
                Framework.Logging.Info("Player unbanned: " .. identifier)
            end
        end
    )
end

-- Check if Player is Banned
Framework.PlayerManagement.IsPlayerBanned = function(identifier)
    local isBanned = false
    Framework.Server.Database.Fetch(
        "SELECT * FROM bans WHERE identifier = ? AND (duration = 0 OR banned_at + duration > ?)",
        {identifier, os.time()},
        function(result)
            if result and result[1] then
                isBanned = true
            end
        end
    )
    return isBanned
end

-- Player Permissions
Framework.PlayerManagement.HasPermission = function(playerId, permission)
    local playerData = Framework.PlayerManagement.GetPlayer(playerId)
    if playerData then
        local permissions = playerData.permissions or {}
        return permissions[permission] == true or playerData.group == "admin"
    end
    return false
end

Framework.PlayerManagement.AddPermission = function(playerId, permission)
    local playerData = Framework.PlayerManagement.GetPlayer(playerId)
    if playerData then
        if not playerData.permissions then
            playerData.permissions = {}
        end
        playerData.permissions[permission] = true
        Framework.PlayerManagement.SetPlayerData(playerId, {permissions = playerData.permissions})
    end
end

Framework.PlayerManagement.RemovePermission = function(playerId, permission)
    local playerData = Framework.PlayerManagement.GetPlayer(playerId)
    if playerData and playerData.permissions then
        playerData.permissions[permission] = nil
        Framework.PlayerManagement.SetPlayerData(playerId, {permissions = playerData.permissions})
    end
end

-- Player Groups
Framework.PlayerManagement.SetPlayerGroup = function(playerId, group)
    Framework.PlayerManagement.SetPlayerData(playerId, {group = group})
    Framework.Logging.Info("Player group changed: " .. playerId .. " -> " .. group)
end

Framework.PlayerManagement.GetPlayerGroup = function(playerId)
    local playerData = Framework.PlayerManagement.GetPlayer(playerId)
    return playerData and playerData.group or "user"
end

-- Player Metadata
Framework.PlayerManagement.SetPlayerMetadata = function(playerId, key, value)
    local playerData = Framework.PlayerManagement.GetPlayer(playerId)
    if playerData then
        if not playerData.metadata then
            playerData.metadata = {}
        end
        playerData.metadata[key] = value
        Framework.PlayerManagement.SetPlayerData(playerId, {metadata = playerData.metadata})
    end
end

Framework.PlayerManagement.GetPlayerMetadata = function(playerId, key)
    local playerData = Framework.PlayerManagement.GetPlayer(playerId)
    if playerData and playerData.metadata then
        return playerData.metadata[key]
    end
    return nil
end

-- Player Statistics
Framework.PlayerManagement.GetPlayerStats = function(playerId)
    local playerData = Framework.PlayerManagement.GetPlayer(playerId)
    if playerData then
        return {
            playtime = os.time() - playerData.created_at,
            last_seen = playerData.last_seen,
            money = playerData.money,
            bank = playerData.bank,
            job = playerData.job,
            group = playerData.group,
            level = playerData.metadata and playerData.metadata.level or 1,
            experience = playerData.metadata and playerData.metadata.experience or 0
        }
    end
    return nil
end

-- Event Handlers
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local playerId = source
    local identifiers = GetPlayerIdentifiers(playerId)
    local identifier = identifiers[1]
    
    if not identifier then
        setKickReason("No identifier found")
        CancelEvent()
        return
    end
    
    -- Check if player is banned
    if Framework.PlayerManagement.IsPlayerBanned(identifier) then
        setKickReason("You are banned from this server")
        CancelEvent()
        return
    end
    
    -- Load player data
    Framework.PlayerManagement.LoadPlayer(playerId, identifier)
end)

AddEventHandler('playerDropped', function(reason)
    local playerId = source
    local playerData = Framework.PlayerManagement.GetPlayer(playerId)
    
    if playerData then
        -- Save player data
        Framework.PlayerManagement.SavePlayer(playerId)
        
        -- Remove from state
        Framework.Server.State.Players[playerId] = nil
        
        Framework.Logging.Info("Player disconnected: " .. playerId .. " (Reason: " .. reason .. ")")
    end
end)

-- Commands
RegisterCommand('kick', function(source, args)
    local playerId = tonumber(args[1])
    local reason = table.concat(args, " ", 2) or "No reason provided"
    
    if playerId and playerId ~= source then
        Framework.PlayerManagement.KickPlayer(playerId, reason)
    end
end, true)

RegisterCommand('ban', function(source, args)
    local playerId = tonumber(args[1])
    local duration = tonumber(args[2]) or 0
    local reason = table.concat(args, " ", 3) or "No reason provided"
    
    if playerId and playerId ~= source then
        Framework.PlayerManagement.BanPlayer(playerId, reason, duration)
    end
end, true)

RegisterCommand('unban', function(source, args)
    local identifier = args[1]
    if identifier then
        Framework.PlayerManagement.UnbanPlayer(identifier)
    end
end, true)

RegisterCommand('setgroup', function(source, args)
    local playerId = tonumber(args[1])
    local group = args[2]
    
    if playerId and group then
        Framework.PlayerManagement.SetPlayerGroup(playerId, group)
    end
end, true)

RegisterCommand('playerinfo', function(source, args)
    local playerId = tonumber(args[1]) or source
    local playerData = Framework.PlayerManagement.GetPlayer(playerId)
    
    if playerData then
        local stats = Framework.PlayerManagement.GetPlayerStats(playerId)
        print("Player Info:")
        print("Name: " .. playerData.name)
        print("Identifier: " .. playerData.identifier)
        print("Group: " .. playerData.group)
        print("Job: " .. playerData.job)
        print("Money: $" .. playerData.money)
        print("Bank: $" .. playerData.bank)
        print("Playtime: " .. math.floor(stats.playtime / 3600) .. " hours")
    end
end, false)

-- Callbacks
Framework.Callbacks.Register('AdvancedFiveMFramework:GetPlayerData', function(source)
    return Framework.PlayerManagement.GetPlayerData(source)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:SetPlayerData', function(source, data)
    Framework.PlayerManagement.SetPlayerData(source, data)
    return true
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:GetPlayerStats', function(source)
    return Framework.PlayerManagement.GetPlayerStats(source)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:HasPermission', function(source, permission)
    return Framework.PlayerManagement.HasPermission(source, permission)
end)

-- Initialize Database Tables
Citizen.CreateThread(function()
    -- Players table
    Framework.Server.Database.Execute([[
        CREATE TABLE IF NOT EXISTS players (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(255) UNIQUE NOT NULL,
            data LONGTEXT,
            last_seen INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]], {}, function(result)
        if result then
            Framework.Logging.Info("Players table created/verified")
        end
    end)
    
    -- Bans table
    Framework.Server.Database.Execute([[
        CREATE TABLE IF NOT EXISTS bans (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(255) NOT NULL,
            reason TEXT,
            duration INT DEFAULT 0,
            banned_at INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]], {}, function(result)
        if result then
            Framework.Logging.Info("Bans table created/verified")
        end
    end)
    
    Framework.Logging.Info("Player Management System initialized")
end)