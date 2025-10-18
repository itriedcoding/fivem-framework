-- Advanced Job System - Client Side
-- Ultra Edition Feature

local Framework = AdvancedFiveMFramework

-- Client-side Job System
Framework.Client.Jobs = {}

-- Job State
Framework.Client.Jobs.State = {
    CurrentJob = "unemployed",
    CurrentGrade = 0,
    CurrentLabel = "Unemployed",
    CurrentPayment = 0,
    JobLocations = {},
    JobVehicles = {},
    IsWorking = false,
    WorkBlips = {}
}

-- Initialize Job System
Framework.Client.Jobs.Initialize = function()
    Framework.Logging.Info("Initializing client job system...")
    
    -- Initialize job state
    Framework.Client.Jobs.State = {
        CurrentJob = "unemployed",
        CurrentGrade = 0,
        CurrentLabel = "Unemployed",
        CurrentPayment = 0,
        JobLocations = {},
        JobVehicles = {},
        IsWorking = false,
        WorkBlips = {}
    }
    
    Framework.Logging.Info("Client job system initialized")
end

-- Get Job Data
Framework.Client.Jobs.GetJob = function()
    return Framework.Client.Jobs.State.CurrentJob, Framework.Client.Jobs.State.CurrentGrade
end

-- Set Job Data
Framework.Client.Jobs.SetJob = function(job, grade, label)
    Framework.Client.Jobs.State.CurrentJob = job
    Framework.Client.Jobs.State.CurrentGrade = grade
    Framework.Client.Jobs.State.CurrentLabel = label or "Unemployed"
    
    -- Update job locations and vehicles
    Framework.Client.Jobs.UpdateJobData()
    
    Framework.Logging.Info("Job changed to: " .. job .. " (Grade: " .. grade .. ")")
end

-- Update Job Data
Framework.Client.Jobs.UpdateJobData = function()
    local job = Framework.Client.Jobs.State.CurrentJob
    
    -- Get job locations
    Framework.Callbacks.Trigger('AdvancedFiveMFramework:GetJobLocations', job, function(locations)
        Framework.Client.Jobs.State.JobLocations = locations
        Framework.Client.Jobs.CreateJobBlips()
    end)
    
    -- Get job vehicles
    Framework.Callbacks.Trigger('AdvancedFiveMFramework:GetJobVehicles', job, Framework.Client.Jobs.State.CurrentGrade, function(vehicles)
        Framework.Client.Jobs.State.JobVehicles = vehicles
    end)
end

-- Create Job Blips
Framework.Client.Jobs.CreateJobBlips = function()
    -- Remove existing blips
    Framework.Client.Jobs.RemoveJobBlips()
    
    -- Create new blips
    for _, location in pairs(Framework.Client.Jobs.State.JobLocations) do
        local blip = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(blip, 1)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(location.name)
        EndTextCommandSetBlipName(blip)
        
        table.insert(Framework.Client.Jobs.State.WorkBlips, blip)
    end
end

-- Remove Job Blips
Framework.Client.Jobs.RemoveJobBlips = function()
    for _, blip in pairs(Framework.Client.Jobs.State.WorkBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    Framework.Client.Jobs.State.WorkBlips = {}
end

-- Start Work
Framework.Client.Jobs.StartWork = function(workType)
    if not Framework.Client.Jobs.State.IsWorking then
        Framework.Client.Jobs.State.IsWorking = true
        
        Framework.Callbacks.Trigger('AdvancedFiveMFramework:StartWork', workType or "general", function(success)
            if success then
                Framework.Client.UI.ShowNotification("Work completed", "success")
            else
                Framework.Client.UI.ShowNotification("Work failed", "error")
            end
            Framework.Client.Jobs.State.IsWorking = false
        end)
    else
        Framework.Client.UI.ShowNotification("Already working", "error")
    end
end

-- Stop Work
Framework.Client.Jobs.StopWork = function()
    Framework.Client.Jobs.State.IsWorking = false
    Framework.Client.UI.ShowNotification("Work stopped", "info")
end

-- Get Job Info
Framework.Client.Jobs.GetInfo = function()
    local job = Framework.Client.Jobs.State.CurrentJob
    local grade = Framework.Client.Jobs.State.CurrentGrade
    local label = Framework.Client.Jobs.State.CurrentLabel
    local payment = Framework.Client.Jobs.State.CurrentPayment
    
    return {
        job = job,
        grade = grade,
        label = label,
        payment = payment,
        locations = Framework.Client.Jobs.State.JobLocations,
        vehicles = Framework.Client.Jobs.State.JobVehicles
    }
end

-- Show Job Info
Framework.Client.Jobs.ShowInfo = function()
    local info = Framework.Client.Jobs.GetInfo()
    
    local message = string.format(
        "Job: %s\n" ..
        "Grade: %d\n" ..
        "Label: %s\n" ..
        "Payment: $%d\n" ..
        "Locations: %d\n" ..
        "Vehicles: %d",
        info.job,
        info.grade,
        info.label,
        info.payment,
        #info.locations,
        #info.vehicles
    )
    
    Framework.Client.UI.ShowNotification(message, "info", 10000)
end

-- Open Job Menu
Framework.Client.Jobs.OpenMenu = function()
    local info = Framework.Client.Jobs.GetInfo()
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "openJobMenu",
        data = {
            job = info.job,
            grade = info.grade,
            label = info.label,
            payment = info.payment,
            locations = info.locations,
            vehicles = info.vehicles,
            isWorking = Framework.Client.Jobs.State.IsWorking
        }
    })
    
    Framework.Logging.Info("Job menu opened")
end

-- Close Job Menu
Framework.Client.Jobs.CloseMenu = function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "closeJobMenu"
    })
    
    Framework.Logging.Info("Job menu closed")
end

-- Event Handlers
AddEventHandler('AdvancedFiveMFramework:JobChanged', function(job, grade, label)
    Framework.Client.Jobs.SetJob(job, grade, label)
end)

-- Commands
RegisterCommand('job', function()
    Framework.Client.Jobs.ShowInfo()
end, false)

RegisterCommand('jobmenu', function()
    Framework.Client.Jobs.OpenMenu()
end, false)

RegisterCommand('work', function(source, args)
    local workType = args[1] or "general"
    Framework.Client.Jobs.StartWork(workType)
end, false)

RegisterCommand('stopwork', function()
    Framework.Client.Jobs.StopWork()
end, false)

-- NUI Callbacks
RegisterNUICallback('closeJobMenu', function(data, cb)
    Framework.Client.Jobs.CloseMenu()
    cb('ok')
end)

RegisterNUICallback('jobAction', function(data, cb)
    local action = data.action
    local params = data.params or {}
    
    if action == 'startWork' then
        Framework.Client.Jobs.StartWork(params.workType)
    elseif action == 'stopWork' then
        Framework.Client.Jobs.StopWork()
    elseif action == 'showInfo' then
        Framework.Client.Jobs.ShowInfo()
    elseif action == 'showLocations' then
        Framework.Client.Jobs.CreateJobBlips()
    elseif action == 'hideLocations' then
        Framework.Client.Jobs.RemoveJobBlips()
    end
    
    cb('ok')
end)

-- Initialize
Citizen.CreateThread(function()
    Framework.Client.Jobs.Initialize()
end)