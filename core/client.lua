-- Advanced FiveM Framework - Client Side
-- Ultra Edition with 40+ Features

local Framework = AdvancedFiveMFramework

-- Client-side Framework Extension
Framework.Client = {}

-- Client Configuration
Framework.Client.Config = {
    ResourceName = GetCurrentResourceName(),
    Debug = true,
    UI = {
        Enabled = true,
        Position = {x = 0.0, y = 0.0},
        Scale = 1.0,
        Theme = "dark"
    },
    Notifications = {
        Enabled = true,
        Position = "top-right",
        Duration = 5000
    },
    HUD = {
        Enabled = true,
        ShowMoney = true,
        ShowJob = true,
        ShowTime = true,
        ShowWeather = true
    }
}

-- Client State
Framework.Client.State = {
    PlayerData = {},
    IsLoaded = false,
    IsLoggedIn = false,
    CurrentJob = "unemployed",
    CurrentGrade = 0,
    Money = {
        cash = 0,
        bank = 0,
        black_money = 0
    },
    Inventory = {},
    Vehicles = {},
    Properties = {},
    Phone = {
        number = "",
        contacts = {},
        messages = {},
        calls = {}
    },
    Settings = {
        ui_scale = 1.0,
        theme = "dark",
        notifications = true,
        hud = true
    }
}

-- UI System
Framework.Client.UI = {}

-- Initialize UI
Framework.Client.UI.Initialize = function()
    Framework.Logging.Info("Initializing client UI...")
    
    -- Set NUI focus
    SetNuiFocus(false, false)
    
    -- Initialize HUD
    if Framework.Client.Config.HUD.Enabled then
        Framework.Client.UI.InitializeHUD()
    end
    
    -- Initialize notifications
    if Framework.Client.Config.Notifications.Enabled then
        Framework.Client.UI.InitializeNotifications()
    end
    
    Framework.Logging.Info("Client UI initialized successfully")
end

-- Initialize HUD
Framework.Client.UI.InitializeHUD = function()
    Citizen.CreateThread(function()
        while true do
            if Framework.Client.State.IsLoaded and Framework.Client.Config.HUD.Enabled then
                -- Draw HUD elements
                Framework.Client.UI.DrawHUD()
            end
            Citizen.Wait(0)
        end
    end)
end

-- Draw HUD
Framework.Client.UI.DrawHUD = function()
    local playerData = Framework.Client.State.PlayerData
    local money = Framework.Client.State.Money
    local job = Framework.Client.State.CurrentJob
    local grade = Framework.Client.State.CurrentGrade
    
    -- Money display
    if Framework.Client.Config.HUD.ShowMoney then
        SetTextFont(4)
        SetTextProportional(1)
        SetTextScale(0.0, 0.5)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString("Cash: $" .. Framework.Utils.Math.Round(money.cash, 0))
        DrawText(0.015, 0.015)
        
        SetTextEntry("STRING")
        AddTextComponentString("Bank: $" .. Framework.Utils.Math.Round(money.bank, 0))
        DrawText(0.015, 0.045)
    end
    
    -- Job display
    if Framework.Client.Config.HUD.ShowJob then
        SetTextFont(4)
        SetTextProportional(1)
        SetTextScale(0.0, 0.4)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString("Job: " .. Framework.Utils.String.Capitalize(job) .. " (Grade: " .. grade .. ")")
        DrawText(0.015, 0.075)
    end
    
    -- Time display
    if Framework.Client.Config.HUD.ShowTime then
        local hour = GetClockHours()
        local minute = GetClockMinutes()
        local timeString = string.format("%02d:%02d", hour, minute)
        
        SetTextFont(4)
        SetTextProportional(1)
        SetTextScale(0.0, 0.5)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString("Time: " .. timeString)
        DrawText(0.85, 0.015)
    end
end

-- Initialize Notifications
Framework.Client.UI.InitializeNotifications = function()
    -- Notification system will be implemented here
    Framework.Logging.Info("Notification system initialized")
end

-- Show Notification
Framework.Client.UI.ShowNotification = function(message, type, duration)
    type = type or "info"
    duration = duration or Framework.Client.Config.Notifications.Duration
    
    -- Simple notification implementation
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
    
    Framework.Logging.Info("Notification: " .. message)
end

-- Phone System
Framework.Client.Phone = {}

-- Initialize Phone
Framework.Client.Phone.Initialize = function()
    Framework.Logging.Info("Initializing phone system...")
    
    -- Generate phone number if not exists
    if not Framework.Client.State.Phone.number or Framework.Client.State.Phone.number == "" then
        Framework.Client.State.Phone.number = Framework.Client.Phone.GenerateNumber()
    end
    
    Framework.Logging.Info("Phone system initialized with number: " .. Framework.Client.State.Phone.number)
end

-- Generate Phone Number
Framework.Client.Phone.GenerateNumber = function()
    local number = ""
    for i = 1, 10 do
        number = number .. math.random(0, 9)
    end
    return number
end

-- Open Phone
Framework.Client.Phone.Open = function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "openPhone",
        data = {
            number = Framework.Client.State.Phone.number,
            contacts = Framework.Client.State.Phone.contacts,
            messages = Framework.Client.State.Phone.messages,
            calls = Framework.Client.State.Phone.calls
        }
    })
end

-- Close Phone
Framework.Client.Phone.Close = function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "closePhone"
    })
end

-- Inventory System
Framework.Client.Inventory = {}

-- Initialize Inventory
Framework.Client.Inventory.Initialize = function()
    Framework.Logging.Info("Initializing inventory system...")
    
    -- Initialize inventory state
    Framework.Client.State.Inventory = {
        items = {},
        weight = 0,
        maxWeight = 50
    }
    
    Framework.Logging.Info("Inventory system initialized")
end

-- Open Inventory
Framework.Client.Inventory.Open = function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "openInventory",
        data = Framework.Client.State.Inventory
    })
end

-- Close Inventory
Framework.Client.Inventory.Close = function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "closeInventory"
    })
end

-- Vehicle System
Framework.Client.Vehicles = {}

-- Initialize Vehicle System
Framework.Client.Vehicles.Initialize = function()
    Framework.Logging.Info("Initializing vehicle system...")
    
    -- Initialize vehicle state
    Framework.Client.State.Vehicles = {
        owned = {},
        current = nil,
        spawned = {}
    }
    
    Framework.Logging.Info("Vehicle system initialized")
end

-- Spawn Vehicle
Framework.Client.Vehicles.Spawn = function(model, coords, heading)
    local playerPed = PlayerPedId()
    local vehicle = CreateVehicle(GetHashKey(model), coords.x, coords.y, coords.z, heading or 0.0, true, false)
    
    if DoesEntityExist(vehicle) then
        SetPedIntoVehicle(playerPed, vehicle, -1)
        Framework.Client.State.Vehicles.current = vehicle
        Framework.Client.State.Vehicles.spawned[vehicle] = {
            model = model,
            coords = coords,
            heading = heading
        }
        
        Framework.Logging.Info("Vehicle spawned: " .. model)
        return vehicle
    else
        Framework.Logging.Error("Failed to spawn vehicle: " .. model)
        return nil
    end
end

-- Delete Vehicle
Framework.Client.Vehicles.Delete = function(vehicle)
    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
        Framework.Client.State.Vehicles.spawned[vehicle] = nil
        if Framework.Client.State.Vehicles.current == vehicle then
            Framework.Client.State.Vehicles.current = nil
        end
        Framework.Logging.Info("Vehicle deleted")
    end
end

-- Property System
Framework.Client.Properties = {}

-- Initialize Property System
Framework.Client.Properties.Initialize = function()
    Framework.Logging.Info("Initializing property system...")
    
    -- Initialize property state
    Framework.Client.State.Properties = {
        owned = {},
        current = nil,
        nearby = {}
    }
    
    Framework.Logging.Info("Property system initialized")
end

-- Enter Property
Framework.Client.Properties.Enter = function(propertyId)
    Framework.Logging.Info("Entering property: " .. propertyId)
    -- Property entry logic will be implemented here
end

-- Exit Property
Framework.Client.Properties.Exit = function()
    Framework.Logging.Info("Exiting property")
    -- Property exit logic will be implemented here
end

-- Event Handlers
-- Player Data Loaded
AddEventHandler('AdvancedFiveMFramework:PlayerDataLoaded', function(playerData)
    Framework.Client.State.PlayerData = playerData
    Framework.Client.State.IsLoaded = true
    Framework.Client.State.IsLoggedIn = true
    
    -- Update money
    Framework.Client.State.Money = {
        cash = playerData.money or 0,
        bank = playerData.bank or 0,
        black_money = playerData.black_money or 0
    }
    
    -- Update job
    Framework.Client.State.CurrentJob = playerData.job or "unemployed"
    Framework.Client.State.CurrentGrade = playerData.grade or 0
    
    Framework.Logging.Info("Player data loaded successfully")
end)

-- Money Changed
AddEventHandler('AdvancedFiveMFramework:MoneyChanged', function(account, amount)
    Framework.Client.State.Money[account] = amount
    Framework.Logging.Info("Money changed - " .. account .. ": $" .. amount)
end)

-- Job Changed
AddEventHandler('AdvancedFiveMFramework:JobChanged', function(job, grade)
    Framework.Client.State.CurrentJob = job
    Framework.Client.State.CurrentGrade = grade
    Framework.Logging.Info("Job changed to: " .. job .. " (Grade: " .. grade .. ")")
end)

-- Commands
-- Phone Command
RegisterCommand('phone', function()
    Framework.Client.Phone.Open()
end, false)

-- Inventory Command
RegisterCommand('inventory', function()
    Framework.Client.Inventory.Open()
end, false)

-- Vehicle Commands
RegisterCommand('spawncar', function(source, args)
    local model = args[1] or "adder"
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    Framework.Client.Vehicles.Spawn(model, coords, heading)
end, false)

RegisterCommand('deletecar', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        Framework.Client.Vehicles.Delete(vehicle)
    end
end, false)

-- Property Commands
RegisterCommand('enterproperty', function(source, args)
    local propertyId = args[1]
    if propertyId then
        Framework.Client.Properties.Enter(propertyId)
    end
end, false)

RegisterCommand('exitproperty', function()
    Framework.Client.Properties.Exit()
end, false)

-- NUI Callbacks
-- Close Phone
RegisterNUICallback('closePhone', function(data, cb)
    Framework.Client.Phone.Close()
    cb('ok')
end)

-- Close Inventory
RegisterNUICallback('closeInventory', function(data, cb)
    Framework.Client.Inventory.Close()
    cb('ok')
end)

-- Phone Actions
RegisterNUICallback('phoneAction', function(data, cb)
    local action = data.action
    local params = data.params or {}
    
    if action == 'call' then
        Framework.Logging.Info("Calling: " .. params.number)
    elseif action == 'message' then
        Framework.Logging.Info("Sending message to: " .. params.number)
    elseif action == 'addContact' then
        Framework.Logging.Info("Adding contact: " .. params.name .. " - " .. params.number)
    end
    
    cb('ok')
end)

-- Inventory Actions
RegisterNUICallback('inventoryAction', function(data, cb)
    local action = data.action
    local params = data.params or {}
    
    if action == 'use' then
        Framework.Logging.Info("Using item: " .. params.item)
    elseif action == 'drop' then
        Framework.Logging.Info("Dropping item: " .. params.item)
    elseif action == 'give' then
        Framework.Logging.Info("Giving item: " .. params.item .. " to " .. params.target)
    end
    
    cb('ok')
end)

-- Initialize Framework
Citizen.CreateThread(function()
    -- Wait for player to spawn
    while not NetworkIsPlayerActive(PlayerId()) do
        Citizen.Wait(100)
    end
    
    -- Initialize systems
    Framework.Client.UI.Initialize()
    Framework.Client.Phone.Initialize()
    Framework.Client.Inventory.Initialize()
    Framework.Client.Vehicles.Initialize()
    Framework.Client.Properties.Initialize()
    
    -- Request player data from server
    Framework.Callbacks.Trigger('AdvancedFiveMFramework:GetPlayerData', function(playerData)
        if playerData then
            TriggerEvent('AdvancedFiveMFramework:PlayerDataLoaded', playerData)
        end
    end)
    
    Framework.Logging.Info("Advanced FiveM Framework Client initialized successfully")
end)

-- Export functions
exports('GetPlayerData', function() return Framework.Client.State.PlayerData end)
exports('GetEconomyData', function() return Framework.Client.State.Money end)
exports('GetServerStats', function() return Framework.Client.State end)
exports('TriggerEvent', Framework.Events.Trigger)
exports('RegisterCallback', Framework.Callbacks.Register)