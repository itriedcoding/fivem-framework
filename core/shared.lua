-- Advanced FiveM Framework - Shared Configuration
-- Ultra Edition with 40+ Features

local Framework = {}

-- Framework Information
Framework.Name = "Advanced FiveM Framework"
Framework.Version = "2.0.0"
Framework.Author = "Advanced FiveM Framework Team"
Framework.Description = "Ultra Advanced FiveM Framework with 40+ Features"

-- Framework Configuration
Framework.Config = {
    -- Core Settings
    Debug = true,
    LogLevel = "INFO",
    MaxPlayers = 128,
    TickRate = 64,
    
    -- Database Settings
    Database = {
        Type = "mysql", -- mysql, postgresql, sqlite
        Host = "localhost",
        Port = 3306,
        Username = "fivem_user",
        Password = "secure_password",
        Database = "fivem_framework",
        PoolSize = 10,
        Timeout = 30000
    },
    
    -- Redis Settings
    Redis = {
        Host = "localhost",
        Port = 6379,
        Password = "",
        Database = 0,
        PoolSize = 5
    },
    
    -- API Settings
    API = {
        Port = 3000,
        Host = "localhost",
        RateLimit = {
            WindowMs = 900000, -- 15 minutes
            MaxRequests = 100
        },
        CORS = {
            Enabled = true,
            Origins = {"*"}
        }
    },
    
    -- Security Settings
    Security = {
        AntiCheat = {
            Enabled = true,
            StrictMode = false,
            LogSuspicious = true
        },
        RateLimiting = {
            Enabled = true,
            MaxRequests = 100,
            WindowMs = 60000
        },
        Encryption = {
            Enabled = true,
            Algorithm = "AES-256-GCM",
            KeyRotation = 86400 -- 24 hours
        }
    },
    
    -- Performance Settings
    Performance = {
        CacheEnabled = true,
        CacheTTL = 300, -- 5 minutes
        MemoryLimit = 1024, -- MB
        CPUThreshold = 80, -- Percentage
        GarbageCollection = {
            Enabled = true,
            Interval = 30000 -- 30 seconds
        }
    },
    
    -- Feature Settings
    Features = {
        PlayerManagement = { Enabled = true, Priority = 1 },
        EconomySystem = { Enabled = true, Priority = 2 },
        JobSystem = { Enabled = true, Priority = 3 },
        PropertyManagement = { Enabled = true, Priority = 4 },
        VehicleSystem = { Enabled = true, Priority = 5 },
        InventorySystem = { Enabled = true, Priority = 6 },
        BankingSystem = { Enabled = true, Priority = 7 },
        GovernmentSystem = { Enabled = true, Priority = 8 },
        LegalSystem = { Enabled = true, Priority = 9 },
        MedicalSystem = { Enabled = true, Priority = 10 },
        Roleplay = { Enabled = true, Priority = 11 },
        GangSystem = { Enabled = true, Priority = 12 },
        BusinessSystem = { Enabled = true, Priority = 13 },
        EventSystem = { Enabled = true, Priority = 14 },
        WeatherSystem = { Enabled = true, Priority = 15 },
        TimeSystem = { Enabled = true, Priority = 16 },
        RadioSystem = { Enabled = true, Priority = 17 },
        PhoneSystem = { Enabled = true, Priority = 18 },
        SocialMedia = { Enabled = true, Priority = 19 },
        StreamingSystem = { Enabled = true, Priority = 20 },
        Database = { Enabled = true, Priority = 21 },
        APISystem = { Enabled = true, Priority = 22 },
        WebDashboard = { Enabled = true, Priority = 23 },
        AntiCheat = { Enabled = true, Priority = 24 },
        Logging = { Enabled = true, Priority = 25 },
        Backup = { Enabled = true, Priority = 26 },
        Performance = { Enabled = true, Priority = 27 },
        Security = { Enabled = true, Priority = 28 },
        PluginSystem = { Enabled = true, Priority = 29 },
        UpdateSystem = { Enabled = true, Priority = 30 },
        DiscordIntegration = { Enabled = true, Priority = 31 },
        Webhook = { Enabled = true, Priority = 32 },
        ExternalAPIs = { Enabled = true, Priority = 33 },
        Analytics = { Enabled = true, Priority = 34 },
        Monitoring = { Enabled = true, Priority = 35 },
        BackupCloud = { Enabled = true, Priority = 36 },
        CDN = { Enabled = true, Priority = 37 },
        LoadBalancing = { Enabled = true, Priority = 38 },
        Clustering = { Enabled = true, Priority = 39 },
        Microservices = { Enabled = true, Priority = 40 }
    }
}

-- Utility Functions
Framework.Utils = {}

-- String Utilities
Framework.Utils.String = {
    -- Generate random string
    Random = function(length)
        local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        local result = ""
        for i = 1, length do
            local rand = math.random(#chars)
            result = result .. string.sub(chars, rand, rand)
        end
        return result
    end,
    
    -- Capitalize first letter
    Capitalize = function(str)
        return string.upper(string.sub(str, 1, 1)) .. string.lower(string.sub(str, 2))
    end,
    
    -- Split string by delimiter
    Split = function(str, delimiter)
        local result = {}
        local pattern = "(.-)" .. delimiter
        local last_end = 1
        local s, e, cap = str:find(pattern, 1)
        while s do
            if s ~= 1 or cap ~= "" then
                table.insert(result, cap)
            end
            last_end = e + 1
            s, e, cap = str:find(pattern, last_end)
        end
        if last_end <= #str then
            cap = str:sub(last_end)
            table.insert(result, cap)
        end
        return result
    end,
    
    -- Check if string is empty
    IsEmpty = function(str)
        return str == nil or str == "" or str:match("^%s*$")
    end
}

-- Table Utilities
Framework.Utils.Table = {
    -- Deep copy table
    DeepCopy = function(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[Framework.Utils.Table.DeepCopy(orig_key)] = Framework.Utils.Table.DeepCopy(orig_value)
            end
            setmetatable(copy, Framework.Utils.Table.DeepCopy(getmetatable(orig)))
        else
            copy = orig
        end
        return copy
    end,
    
    -- Merge tables
    Merge = function(t1, t2)
        for k, v in pairs(t2) do
            if type(v) == "table" and type(t1[k]) == "table" then
                Framework.Utils.Table.Merge(t1[k], v)
            else
                t1[k] = v
            end
        end
        return t1
    end,
    
    -- Check if table is empty
    IsEmpty = function(t)
        return next(t) == nil
    end,
    
    -- Get table length
    Length = function(t)
        local count = 0
        for _ in pairs(t) do count = count + 1 end
        return count
    end
}

-- Math Utilities
Framework.Utils.Math = {
    -- Round number
    Round = function(num, numDecimalPlaces)
        local mult = 10^(numDecimalPlaces or 0)
        return math.floor(num * mult + 0.5) / mult
    end,
    
    -- Clamp number between min and max
    Clamp = function(num, min, max)
        return math.max(min, math.min(max, num))
    end,
    
    -- Generate random number between min and max
    Random = function(min, max)
        return math.random() * (max - min) + min
    end,
    
    -- Check if number is in range
    InRange = function(num, min, max)
        return num >= min and num <= max
    end
}

-- Time Utilities
Framework.Utils.Time = {
    -- Get current timestamp
    Timestamp = function()
        return os.time()
    end,
    
    -- Format timestamp
    Format = function(timestamp, format)
        return os.date(format or "%Y-%m-%d %H:%M:%S", timestamp)
    end,
    
    -- Get time difference in seconds
    Difference = function(timestamp1, timestamp2)
        return math.abs(timestamp1 - timestamp2)
    end,
    
    -- Check if timestamp is today
    IsToday = function(timestamp)
        local today = os.date("*t")
        local date = os.date("*t", timestamp)
        return today.year == date.year and today.month == date.month and today.day == date.day
    end
}

-- Validation Utilities
Framework.Utils.Validation = {
    -- Validate email
    IsEmail = function(email)
        return string.match(email, "^[%w%._%+-]+@[%w%._%+-]+%.%w+$") ~= nil
    end,
    
    -- Validate phone number
    IsPhone = function(phone)
        return string.match(phone, "^%d{10,15}$") ~= nil
    end,
    
    -- Validate IP address
    IsIP = function(ip)
        return string.match(ip, "^%d+%.%d+%.%d+%.%d+$") ~= nil
    end,
    
    -- Validate UUID
    IsUUID = function(uuid)
        return string.match(uuid, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
    end
}

-- Event System
Framework.Events = {}

-- Register event
Framework.Events.Register = function(eventName, callback, priority)
    priority = priority or 0
    AddEventHandler(eventName, function(...)
        if callback then
            callback(...)
        end
    end)
end

-- Trigger event
Framework.Events.Trigger = function(eventName, ...)
    TriggerEvent(eventName, ...)
end

-- Trigger server event
Framework.Events.TriggerServer = function(eventName, ...)
    TriggerServerEvent(eventName, ...)
end

-- Trigger client event
Framework.Events.TriggerClient = function(playerId, eventName, ...)
    TriggerClientEvent(eventName, playerId, ...)
end

-- Callback System
Framework.Callbacks = {}

-- Register callback
Framework.Callbacks.Register = function(name, callback)
    RegisterCallback(name, function(source, cb, ...)
        local result = callback(source, ...)
        cb(result)
    end)
end

-- Trigger callback
Framework.Callbacks.Trigger = function(name, ...)
    return exports['advanced-fivem-framework']:TriggerCallback(name, ...)
end

-- Logging System
Framework.Logging = {}

-- Log levels
Framework.Logging.Levels = {
    DEBUG = 0,
    INFO = 1,
    WARN = 2,
    ERROR = 3,
    FATAL = 4
}

-- Current log level
Framework.Logging.CurrentLevel = Framework.Logging.Levels.INFO

-- Log function
Framework.Logging.Log = function(level, message, data)
    if level >= Framework.Logging.CurrentLevel then
        local timestamp = Framework.Utils.Time.Format(Framework.Utils.Time.Timestamp())
        local levelName = ""
        
        for name, value in pairs(Framework.Logging.Levels) do
            if value == level then
                levelName = name
                break
            end
        end
        
        local logMessage = string.format("[%s] [%s] %s", timestamp, levelName, message)
        
        if data then
            logMessage = logMessage .. " | Data: " .. json.encode(data)
        end
        
        print(logMessage)
    end
end

-- Debug log
Framework.Logging.Debug = function(message, data)
    Framework.Logging.Log(Framework.Logging.Levels.DEBUG, message, data)
end

-- Info log
Framework.Logging.Info = function(message, data)
    Framework.Logging.Log(Framework.Logging.Levels.INFO, message, data)
end

-- Warning log
Framework.Logging.Warn = function(message, data)
    Framework.Logging.Log(Framework.Logging.Levels.WARN, message, data)
end

-- Error log
Framework.Logging.Error = function(message, data)
    Framework.Logging.Log(Framework.Logging.Levels.ERROR, message, data)
end

-- Fatal log
Framework.Logging.Fatal = function(message, data)
    Framework.Logging.Log(Framework.Logging.Levels.FATAL, message, data)
end

-- Export Framework
_G.AdvancedFiveMFramework = Framework

-- Initialize Framework
if IsServer then
    Framework.Logging.Info("Advanced FiveM Framework - Server Side Initialized")
else
    Framework.Logging.Info("Advanced FiveM Framework - Client Side Initialized")
end

return Framework