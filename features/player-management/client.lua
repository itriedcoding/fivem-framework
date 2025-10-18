-- Advanced Player Management System - Client Side
-- Ultra Edition Feature

local Framework = AdvancedFiveMFramework

-- Client-side Player Management
Framework.Client.PlayerManagement = {}

-- Player Data
Framework.Client.PlayerManagement.PlayerData = {}
Framework.Client.PlayerManagement.IsLoaded = false

-- Initialize Player Management
Framework.Client.PlayerManagement.Initialize = function()
    Framework.Logging.Info("Initializing client player management...")
    
    -- Initialize player data
    Framework.Client.PlayerManagement.PlayerData = {}
    Framework.Client.PlayerManagement.IsLoaded = false
    
    Framework.Logging.Info("Client player management initialized")
end

-- Get Player Data
Framework.Client.PlayerManagement.GetData = function(key)
    if key then
        return Framework.Client.PlayerManagement.PlayerData[key]
    else
        return Framework.Client.PlayerManagement.PlayerData
    end
end

-- Set Player Data
Framework.Client.PlayerManagement.SetData = function(data)
    Framework.Client.PlayerManagement.PlayerData = Framework.Utils.Table.Merge(Framework.Client.PlayerManagement.PlayerData, data)
end

-- Update Player Data
Framework.Client.PlayerManagement.UpdateData = function(key, value)
    Framework.Client.PlayerManagement.PlayerData[key] = value
end

-- Get Player Stats
Framework.Client.PlayerManagement.GetStats = function()
    local playerData = Framework.Client.PlayerManagement.GetData()
    if playerData then
        return {
            name = playerData.name,
            identifier = playerData.identifier,
            group = playerData.group,
            job = playerData.job,
            grade = playerData.job_grade,
            money = playerData.money,
            bank = playerData.bank,
            level = playerData.metadata and playerData.metadata.level or 1,
            experience = playerData.metadata and playerData.metadata.experience or 0,
            playtime = os.time() - (playerData.created_at or os.time())
        }
    end
    return nil
end

-- Show Player Info
Framework.Client.PlayerManagement.ShowInfo = function()
    local stats = Framework.Client.PlayerManagement.GetStats()
    if stats then
        local info = string.format(
            "Name: %s\n" ..
            "Group: %s\n" ..
            "Job: %s (Grade: %d)\n" ..
            "Money: $%d\n" ..
            "Bank: $%d\n" ..
            "Level: %d\n" ..
            "Experience: %d\n" ..
            "Playtime: %d hours",
            stats.name,
            stats.group,
            stats.job,
            stats.grade,
            stats.money,
            stats.bank,
            stats.level,
            stats.experience,
            math.floor(stats.playtime / 3600)
        )
        
        Framework.Client.UI.ShowNotification(info, "info", 10000)
    end
end

-- Event Handlers
AddEventHandler('AdvancedFiveMFramework:PlayerLoaded', function(playerData)
    Framework.Client.PlayerManagement.SetData(playerData)
    Framework.Client.PlayerManagement.IsLoaded = true
    
    Framework.Logging.Info("Player data loaded: " .. playerData.name)
    
    -- Trigger player loaded event
    TriggerEvent('AdvancedFiveMFramework:ClientPlayerLoaded', playerData)
end)

AddEventHandler('AdvancedFiveMFramework:PlayerDataUpdated', function(data)
    Framework.Client.PlayerManagement.SetData(data)
    Framework.Logging.Info("Player data updated")
end)

-- Commands
RegisterCommand('playerinfo', function()
    Framework.Client.PlayerManagement.ShowInfo()
end, false)

RegisterCommand('stats', function()
    Framework.Client.PlayerManagement.ShowInfo()
end, false)

-- Initialize
Citizen.CreateThread(function()
    Framework.Client.PlayerManagement.Initialize()
end)