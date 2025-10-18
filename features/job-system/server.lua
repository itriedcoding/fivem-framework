-- Advanced Job System - Server Side
-- Ultra Edition Feature

local Framework = AdvancedFiveMFramework

-- Job System
Framework.Jobs = {}

-- Job Configuration
Framework.Jobs.Config = {
    Jobs = {
        unemployed = {
            label = "Unemployed",
            grades = {
                {name = "Freelancer", payment = 0, level = 0}
            },
            blip = {sprite = 1, color = 0, scale = 0.8},
            locations = {},
            vehicles = {},
            uniforms = {},
            permissions = {}
        },
        police = {
            label = "Police",
            grades = {
                {name = "Recruit", payment = 500, level = 1},
                {name = "Officer", payment = 750, level = 2},
                {name = "Sergeant", payment = 1000, level = 3},
                {name = "Lieutenant", payment = 1250, level = 4},
                {name = "Captain", payment = 1500, level = 5}
            },
            blip = {sprite = 60, color = 3, scale = 0.8},
            locations = {
                {x = 425.1, y = -979.5, z = 30.7, name = "Police Station", type = "station"},
                {x = 1853.2, y = 3689.0, z = 34.3, name = "Sandy Shores PD", type = "station"},
                {x = -449.7, y = 6014.0, z = 31.7, name = "Paleto Bay PD", type = "station"}
            },
            vehicles = {
                {model = "police", label = "Police Car", grade = 1},
                {model = "police2", label = "Police Car 2", grade = 2},
                {model = "polmav", label = "Police Helicopter", grade = 4},
                {model = "policeb", label = "Police Bike", grade = 2}
            },
            uniforms = {
                {grade = 1, male = "police_uniform_male", female = "police_uniform_female"},
                {grade = 2, male = "police_uniform_male_2", female = "police_uniform_female_2"}
            },
            permissions = {"police.weapon", "police.vehicle", "police.radio"}
        },
        ambulance = {
            label = "Ambulance",
            grades = {
                {name = "Recruit", payment = 500, level = 1},
                {name = "Paramedic", payment = 750, level = 2},
                {name = "Doctor", payment = 1000, level = 3},
                {name = "Chief", payment = 1250, level = 4}
            },
            blip = {sprite = 61, color = 1, scale = 0.8},
            locations = {
                {x = 307.7, y = -1433.7, z = 29.9, name = "Central Medical", type = "hospital"},
                {x = 1839.6, y = 3672.9, z = 34.3, name = "Sandy Shores Medical", type = "hospital"},
                {x = -247.3, y = 6331.2, z = 32.4, name = "Paleto Bay Medical", type = "hospital"}
            },
            vehicles = {
                {model = "ambulance", label = "Ambulance", grade = 1},
                {model = "lguard", label = "Lifeguard", grade = 2}
            },
            uniforms = {
                {grade = 1, male = "ambulance_uniform_male", female = "ambulance_uniform_female"}
            },
            permissions = {"ambulance.weapon", "ambulance.vehicle", "ambulance.radio"}
        },
        mechanic = {
            label = "Mechanic",
            grades = {
                {name = "Recruit", payment = 400, level = 1},
                {name = "Mechanic", payment = 600, level = 2},
                {name = "Senior", payment = 800, level = 3},
                {name = "Boss", payment = 1000, level = 4}
            },
            blip = {sprite = 446, color = 5, scale = 0.8},
            locations = {
                {x = -347.3, y = -133.0, z = 39.0, name = "Los Santos Customs", type = "garage"},
                {x = 1175.0, y = 2640.0, z = 37.8, name = "Sandy Shores Customs", type = "garage"}
            },
            vehicles = {
                {model = "towtruck", label = "Tow Truck", grade = 1},
                {model = "flatbed", label = "Flatbed", grade = 2}
            },
            uniforms = {
                {grade = 1, male = "mechanic_uniform_male", female = "mechanic_uniform_female"}
            },
            permissions = {"mechanic.vehicle", "mechanic.tools"}
        },
        taxi = {
            label = "Taxi",
            grades = {
                {name = "Driver", payment = 300, level = 1},
                {name = "Senior", payment = 500, level = 2},
                {name = "Boss", payment = 700, level = 3}
            },
            blip = {sprite = 198, color = 5, scale = 0.8},
            locations = {
                {x = 909.0, y = -177.0, z = 74.2, name = "Downtown Cab Co.", type = "office"}
            },
            vehicles = {
                {model = "taxi", label = "Taxi", grade = 1},
                {model = "stretch", label = "Stretch", grade = 2}
            },
            uniforms = {
                {grade = 1, male = "taxi_uniform_male", female = "taxi_uniform_female"}
            },
            permissions = {"taxi.vehicle", "taxi.radio"}
        },
        delivery = {
            label = "Delivery",
            grades = {
                {name = "Driver", payment = 250, level = 1},
                {name = "Senior", payment = 400, level = 2},
                {name = "Boss", payment = 600, level = 3}
            },
            blip = {sprite = 478, color = 3, scale = 0.8},
            locations = {
                {x = 78.0, y = 111.0, z = 81.2, name = "Postal Service", type = "office"}
            },
            vehicles = {
                {model = "boxville", label = "Delivery Van", grade = 1},
                {model = "mule", label = "Delivery Truck", grade = 2}
            },
            uniforms = {
                {grade = 1, male = "delivery_uniform_male", female = "delivery_uniform_female"}
            },
            permissions = {"delivery.vehicle"}
        },
        trucker = {
            label = "Trucker",
            grades = {
                {name = "Driver", payment = 350, level = 1},
                {name = "Senior", payment = 550, level = 2},
                {name = "Boss", payment = 750, level = 3}
            },
            blip = {sprite = 477, color = 2, scale = 0.8},
            locations = {
                {x = 1208.0, y = -3114.0, z = 5.5, name = "Trucking Company", type = "office"}
            },
            vehicles = {
                {model = "hauler", label = "Hauler", grade = 1},
                {model = "phantom", label = "Phantom", grade = 2},
                {model = "packer", label = "Packer", grade = 3}
            },
            uniforms = {
                {grade = 1, male = "trucker_uniform_male", female = "trucker_uniform_female"}
            },
            permissions = {"trucker.vehicle"}
        },
        farmer = {
            label = "Farmer",
            grades = {
                {name = "Worker", payment = 300, level = 1},
                {name = "Senior", payment = 500, level = 2},
                {name = "Boss", payment = 700, level = 3}
            },
            blip = {sprite = 496, color = 2, scale = 0.8},
            locations = {
                {x = 2441.0, y = 4968.0, z = 51.7, name = "Farm", type = "workplace"}
            },
            vehicles = {
                {model = "tractor", label = "Tractor", grade = 1},
                {model = "tractor2", label = "Tractor 2", grade = 2}
            },
            uniforms = {
                {grade = 1, male = "farmer_uniform_male", female = "farmer_uniform_female"}
            },
            permissions = {"farmer.vehicle", "farmer.tools"}
        },
        miner = {
            label = "Miner",
            grades = {
                {name = "Worker", payment = 400, level = 1},
                {name = "Senior", payment = 600, level = 2},
                {name = "Boss", payment = 800, level = 3}
            },
            blip = {sprite = 318, color = 5, scale = 0.8},
            locations = {
                {x = -594.0, y = 2090.0, z = 131.4, name = "Mine", type = "workplace"}
            },
            vehicles = {
                {model = "bulldozer", label = "Bulldozer", grade = 1},
                {model = "dump", label = "Dump Truck", grade = 2}
            },
            uniforms = {
                {grade = 1, male = "miner_uniform_male", female = "miner_uniform_female"}
            },
            permissions = {"miner.vehicle", "miner.tools"}
        },
        fisherman = {
            label = "Fisherman",
            grades = {
                {name = "Worker", payment = 300, level = 1},
                {name = "Senior", payment = 500, level = 2},
                {name = "Boss", payment = 700, level = 3}
            },
            blip = {sprite = 68, color = 3, scale = 0.8},
            locations = {
                {x = -1037.0, y = -2737.0, z = 20.2, name = "Dock", type = "workplace"}
            },
            vehicles = {
                {model = "dinghy", label = "Dinghy", grade = 1},
                {model = "tug", label = "Tug Boat", grade = 2}
            },
            uniforms = {
                {grade = 1, male = "fisherman_uniform_male", female = "fisherman_uniform_female"}
            },
            permissions = {"fisherman.vehicle", "fisherman.tools"}
        },
        lumberjack = {
            label = "Lumberjack",
            grades = {
                {name = "Worker", payment = 350, level = 1},
                {name = "Senior", payment = 550, level = 2},
                {name = "Boss", payment = 750, level = 3}
            },
            blip = {sprite = 477, color = 2, scale = 0.8},
            locations = {
                {x = -1166.0, y = -1567.0, z = 4.7, name = "Lumber Mill", type = "workplace"}
            },
            vehicles = {
                {model = "mule", label = "Lumber Truck", grade = 1},
                {model = "phantom", label = "Lumber Hauler", grade = 2}
            },
            uniforms = {
                {grade = 1, male = "lumberjack_uniform_male", female = "lumberjack_uniform_female"}
            },
            permissions = {"lumberjack.vehicle", "lumberjack.tools"}
        },
        hunter = {
            label = "Hunter",
            grades = {
                {name = "Worker", payment = 400, level = 1},
                {name = "Senior", payment = 600, level = 2},
                {name = "Boss", payment = 800, level = 3}
            },
            blip = {sprite = 141, color = 1, scale = 0.8},
            locations = {
                {x = -679.0, y = 5834.0, z = 17.3, name = "Hunting Lodge", type = "workplace"}
            },
            vehicles = {
                {model = "bison", label = "Hunting Vehicle", grade = 1},
                {model = "bison2", label = "Hunting Vehicle 2", grade = 2}
            },
            uniforms = {
                {grade = 1, male = "hunter_uniform_male", female = "hunter_uniform_female"}
            },
            permissions = {"hunter.vehicle", "hunter.weapon"}
        },
        chef = {
            label = "Chef",
            grades = {
                {name = "Cook", payment = 400, level = 1},
                {name = "Chef", payment = 600, level = 2},
                {name = "Head Chef", payment = 800, level = 3}
            },
            blip = {sprite = 267, color = 1, scale = 0.8},
            locations = {
                {x = -1193.0, y = -891.0, z = 13.9, name = "Restaurant", type = "workplace"}
            },
            vehicles = {
                {model = "faggio", label = "Delivery Scooter", grade = 1}
            },
            uniforms = {
                {grade = 1, male = "chef_uniform_male", female = "chef_uniform_female"}
            },
            permissions = {"chef.vehicle", "chef.tools"}
        },
        bartender = {
            label = "Bartender",
            grades = {
                {name = "Worker", payment = 300, level = 1},
                {name = "Senior", payment = 500, level = 2},
                {name = "Boss", payment = 700, level = 3}
            },
            blip = {sprite = 93, color = 4, scale = 0.8},
            locations = {
                {x = 127.0, y = -1284.0, z = 29.3, name = "Bar", type = "workplace"}
            },
            vehicles = {},
            uniforms = {
                {grade = 1, male = "bartender_uniform_male", female = "bartender_uniform_female"}
            },
            permissions = {"bartender.tools"}
        },
        reporter = {
            label = "Reporter",
            grades = {
                {name = "Intern", payment = 400, level = 1},
                {name = "Reporter", payment = 600, level = 2},
                {name = "Editor", payment = 800, level = 3}
            },
            blip = {sprite = 135, color = 0, scale = 0.8},
            locations = {
                {x = -1042.0, y = -274.0, z = 21.4, name = "News Station", type = "office"}
            },
            vehicles = {
                {model = "rumpo", label = "News Van", grade = 1}
            },
            uniforms = {
                {grade = 1, male = "reporter_uniform_male", female = "reporter_uniform_female"}
            },
            permissions = {"reporter.vehicle", "reporter.camera"}
        },
        lawyer = {
            label = "Lawyer",
            grades = {
                {name = "Intern", payment = 500, level = 1},
                {name = "Lawyer", payment = 800, level = 2},
                {name = "Partner", payment = 1200, level = 3}
            },
            blip = {sprite = 408, color = 0, scale = 0.8},
            locations = {
                {x = -1912.0, y = -570.0, z = 19.1, name = "Law Office", type = "office"}
            },
            vehicles = {
                {model = "stretch", label = "Lawyer Car", grade = 2}
            },
            uniforms = {
                {grade = 1, male = "lawyer_uniform_male", female = "lawyer_uniform_female"}
            },
            permissions = {"lawyer.office", "lawyer.court"}
        }
    }
}

-- Job Management Functions
Framework.Jobs.GetJob = function(playerId)
    local playerData = Framework.Server.Players.GetData(playerId)
    if playerData then
        return playerData.job or "unemployed", playerData.job_grade or 0
    end
    return "unemployed", 0
end

Framework.Jobs.SetJob = function(playerId, job, grade)
    local jobData = Framework.Jobs.Config.Jobs[job]
    if jobData then
        grade = grade or 0
        local gradeData = jobData.grades[grade + 1]
        
        if gradeData then
            Framework.Server.Players.SetData(playerId, {
                job = job,
                job_grade = grade,
                job_label = jobData.label,
                job_payment = gradeData.payment
            })
            
            Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:JobChanged", job, grade, jobData.label)
            Framework.Logging.Info("Player " .. playerId .. " job changed to: " .. job .. " (Grade: " .. grade .. ")")
            return true
        end
    end
    return false
end

Framework.Jobs.GetJobData = function(job)
    return Framework.Jobs.Config.Jobs[job] or Framework.Jobs.Config.Jobs.unemployed
end

Framework.Jobs.GetJobGrade = function(job, grade)
    local jobData = Framework.Jobs.GetJobData(job)
    return jobData.grades[grade + 1] or jobData.grades[1]
end

Framework.Jobs.HasPermission = function(playerId, permission)
    local job, grade = Framework.Jobs.GetJob(playerId)
    local jobData = Framework.Jobs.GetJobData(job)
    local gradeData = Framework.Jobs.GetJobGrade(job, grade)
    
    if jobData.permissions then
        for _, perm in pairs(jobData.permissions) do
            if perm == permission then
                return true
            end
        end
    end
    
    return false
end

Framework.Jobs.GetJobLocations = function(job)
    local jobData = Framework.Jobs.GetJobData(job)
    return jobData.locations or {}
end

Framework.Jobs.GetJobVehicles = function(job, grade)
    local jobData = Framework.Jobs.GetJobData(job)
    local vehicles = {}
    
    for _, vehicle in pairs(jobData.vehicles or {}) do
        if vehicle.grade <= (grade or 0) then
            table.insert(vehicles, vehicle)
        end
    end
    
    return vehicles
end

Framework.Jobs.GetJobUniform = function(job, grade, sex)
    local jobData = Framework.Jobs.GetJobData(job)
    local gradeData = Framework.Jobs.GetJobGrade(job, grade)
    
    if jobData.uniforms then
        for _, uniform in pairs(jobData.uniforms) do
            if uniform.grade == grade then
                return uniform[sex or "male"]
            end
        end
    end
    
    return nil
end

-- Job Work System
Framework.Jobs.StartWork = function(playerId, workType)
    local job, grade = Framework.Jobs.GetJob(playerId)
    local jobData = Framework.Jobs.GetJobData(job)
    local gradeData = Framework.Jobs.GetJobGrade(job, grade)
    
    if gradeData.payment > 0 then
        -- Give payment
        Framework.Server.Economy.AddMoney(playerId, gradeData.payment, "money", "Job Payment")
        
        -- Log work
        Framework.Server.Database.Execute(
            "INSERT INTO job_work (player_id, job, grade, work_type, payment, timestamp) VALUES (?, ?, ?, ?, ?, ?)",
            {playerId, job, grade, workType, gradeData.payment, os.time()},
            function(result)
                if result then
                    Framework.Logging.Debug("Work logged for player: " .. playerId)
                end
            end
        )
        
        return true
    end
    
    return false
end

-- Job Progression
Framework.Jobs.PromotePlayer = function(playerId)
    local job, grade = Framework.Jobs.GetJob(playerId)
    local jobData = Framework.Jobs.GetJobData(job)
    
    if grade < #jobData.grades - 1 then
        Framework.Jobs.SetJob(playerId, job, grade + 1)
        return true
    end
    
    return false
end

Framework.Jobs.DemotePlayer = function(playerId)
    local job, grade = Framework.Jobs.GetJob(playerId)
    
    if grade > 0 then
        Framework.Jobs.SetJob(playerId, job, grade - 1)
        return true
    end
    
    return false
end

-- Job Statistics
Framework.Jobs.GetJobStats = function(job)
    local stats = {
        total_players = 0,
        total_work = 0,
        total_payments = 0,
        average_payment = 0
    }
    
    Framework.Server.Database.Fetch(
        "SELECT COUNT(*) as count FROM players WHERE job = ?",
        {job},
        function(result)
            if result and result[1] then
                stats.total_players = result[1].count
            end
        end
    )
    
    Framework.Server.Database.Fetch(
        "SELECT COUNT(*) as count, SUM(payment) as total FROM job_work WHERE job = ?",
        {job},
        function(result)
            if result and result[1] then
                stats.total_work = result[1].count
                stats.total_payments = result[1].total or 0
                stats.average_payment = stats.total_work > 0 and (stats.total_payments / stats.total_work) or 0
            end
        end
    )
    
    return stats
end

-- Commands
RegisterCommand('setjob', function(source, args)
    local playerId = tonumber(args[1])
    local job = args[2]
    local grade = tonumber(args[3]) or 0
    
    if playerId and job then
        if Framework.Jobs.SetJob(playerId, job, grade) then
            Framework.Events.TriggerClient(source, "AdvancedFiveMFramework:ShowNotification", "Job set successfully", "success")
        else
            Framework.Events.TriggerClient(source, "AdvancedFiveMFramework:ShowNotification", "Failed to set job", "error")
        end
    end
end, true)

RegisterCommand('promote', function(source, args)
    local playerId = tonumber(args[1])
    
    if playerId then
        if Framework.Jobs.PromotePlayer(playerId) then
            Framework.Events.TriggerClient(source, "AdvancedFiveMFramework:ShowNotification", "Player promoted", "success")
        else
            Framework.Events.TriggerClient(source, "AdvancedFiveMFramework:ShowNotification", "Cannot promote player", "error")
        end
    end
end, true)

RegisterCommand('demote', function(source, args)
    local playerId = tonumber(args[1])
    
    if playerId then
        if Framework.Jobs.DemotePlayer(playerId) then
            Framework.Events.TriggerClient(source, "AdvancedFiveMFramework:ShowNotification", "Player demoted", "success")
        else
            Framework.Events.TriggerClient(source, "AdvancedFiveMFramework:ShowNotification", "Cannot demote player", "error")
        end
    end
end, true)

RegisterCommand('jobinfo', function(source, args)
    local playerId = tonumber(args[1]) or source
    local job, grade = Framework.Jobs.GetJob(playerId)
    local jobData = Framework.Jobs.GetJobData(job)
    local gradeData = Framework.Jobs.GetJobGrade(job, grade)
    
    local info = string.format(
        "Job: %s\n" ..
        "Grade: %s\n" ..
        "Payment: $%d\n" ..
        "Level: %d",
        jobData.label,
        gradeData.name,
        gradeData.payment,
        gradeData.level
    )
    
    Framework.Events.TriggerClient(source, "AdvancedFiveMFramework:ShowNotification", info, "info")
end, false)

RegisterCommand('work', function(source, args)
    local playerId = source
    local workType = args[1] or "general"
    
    if Framework.Jobs.StartWork(playerId, workType) then
        Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:ShowNotification", "Work completed", "success")
    else
        Framework.Events.TriggerClient(playerId, "AdvancedFiveMFramework:ShowNotification", "Work failed", "error")
    end
end, false)

-- Callbacks
Framework.Callbacks.Register('AdvancedFiveMFramework:GetJob', function(source)
    return Framework.Jobs.GetJob(source)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:SetJob', function(source, job, grade)
    return Framework.Jobs.SetJob(source, job, grade)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:GetJobData', function(source, job)
    return Framework.Jobs.GetJobData(job)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:GetJobLocations', function(source, job)
    return Framework.Jobs.GetJobLocations(job)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:GetJobVehicles', function(source, job, grade)
    return Framework.Jobs.GetJobVehicles(job, grade)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:HasJobPermission', function(source, permission)
    return Framework.Jobs.HasPermission(source, permission)
end)

Framework.Callbacks.Register('AdvancedFiveMFramework:StartWork', function(source, workType)
    return Framework.Jobs.StartWork(source, workType)
end)

-- Initialize Job System
Citizen.CreateThread(function()
    -- Create database tables
    Framework.Server.Database.Execute([[
        CREATE TABLE IF NOT EXISTS job_work (
            id INT AUTO_INCREMENT PRIMARY KEY,
            player_id INT,
            job VARCHAR(50),
            grade INT,
            work_type VARCHAR(50),
            payment DECIMAL(10,2),
            timestamp INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]], {}, function(result)
        if result then
            Framework.Logging.Info("Job work table created/verified")
        end
    end)
    
    Framework.Logging.Info("Job System initialized")
end)