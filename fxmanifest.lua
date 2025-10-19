fx_version 'cerulean'
game 'gta5'

author 'FiveM Framework'
description 'The world best FiveM framework pakced with 40+ features.'
version '2.0.0'

-- Core Dependencies
dependencies {
    'yarn',
    'webpack'
}

-- Server Scripts
server_scripts {
    'core/server.lua',
    'core/shared.lua',
    'python-backend/api/server.py',
    'python-backend/database/manager.py',
    'python-backend/analytics/collector.py',
    'python-backend/monitoring/health.py',
    'python-backend/services/*.py'
}

-- Client Scripts
client_scripts {
    'core/client.lua',
    'core/shared.lua'
}

-- Shared Scripts
shared_scripts {
    'core/shared.lua',
    'config/*.json'
}

-- Feature Modules
server_scripts {
    'features/player-management/server.lua',
    'features/economy-system/server.lua',
    'features/job-system/server.lua',
    'features/property-management/server.lua',
    'features/vehicle-system/server.lua',
    'features/inventory-system/server.lua',
    'features/banking-system/server.lua',
    'features/government-system/server.lua',
    'features/legal-system/server.lua',
    'features/medical-system/server.lua',
    'features/roleplay/server.lua',
    'features/gang-system/server.lua',
    'features/business-system/server.lua',
    'features/event-system/server.lua',
    'features/weather-system/server.lua',
    'features/time-system/server.lua',
    'features/radio-system/server.lua',
    'features/phone-system/server.lua',
    'features/social-media/server.lua',
    'features/streaming-system/server.lua',
    'features/database/server.lua',
    'features/api-system/server.lua',
    'features/web-dashboard/server.lua',
    'features/anti-cheat/server.lua',
    'features/logging/server.lua',
    'features/backup/server.lua',
    'features/performance/server.lua',
    'features/security/server.lua',
    'features/plugin-system/server.lua',
    'features/update-system/server.lua',
    'features/discord-integration/server.lua',
    'features/webhook/server.lua',
    'features/external-apis/server.lua',
    'features/analytics/server.lua',
    'features/monitoring/server.lua',
    'features/backup-cloud/server.lua',
    'features/cdn/server.lua',
    'features/load-balancing/server.lua',
    'features/clustering/server.lua',
    'features/microservices/server.lua'
}

client_scripts {
    'features/player-management/client.lua',
    'features/economy-system/client.lua',
    'features/job-system/client.lua',
    'features/property-management/client.lua',
    'features/vehicle-system/client.lua',
    'features/inventory-system/client.lua',
    'features/banking-system/client.lua',
    'features/government-system/client.lua',
    'features/legal-system/client.lua',
    'features/medical-system/client.lua',
    'features/roleplay/client.lua',
    'features/gang-system/client.lua',
    'features/business-system/client.lua',
    'features/event-system/client.lua',
    'features/weather-system/client.lua',
    'features/time-system/client.lua',
    'features/radio-system/client.lua',
    'features/phone-system/client.lua',
    'features/social-media/client.lua',
    'features/streaming-system/client.lua',
    'features/database/client.lua',
    'features/api-system/client.lua',
    'features/web-dashboard/client.lua',
    'features/anti-cheat/client.lua',
    'features/logging/client.lua',
    'features/backup/client.lua',
    'features/performance/client.lua',
    'features/security/client.lua',
    'features/plugin-system/client.lua',
    'features/update-system/client.lua',
    'features/discord-integration/client.lua',
    'features/webhook/client.lua',
    'features/external-apis/client.lua',
    'features/analytics/client.lua',
    'features/monitoring/client.lua',
    'features/backup-cloud/client.lua',
    'features/cdn/client.lua',
    'features/load-balancing/client.lua',
    'features/clustering/client.lua',
    'features/microservices/client.lua'
}

-- UI Files
ui_page 'web-dashboard/frontend/index.html'

files {
    'web-dashboard/frontend/index.html',
    'web-dashboard/frontend/css/*.css',
    'web-dashboard/frontend/js/*.js',
    'web-dashboard/frontend/assets/*',
    'config/*.json'
}

-- NUI Callbacks
lua54 'yes'

-- Export Functions
exports {
    'GetPlayerData',
    'GetEconomyData',
    'GetServerStats',
    'TriggerEvent',
    'RegisterCallback'
}

-- Server Exports
server_exports {
    'GetPlayerData',
    'GetEconomyData',
    'GetServerStats',
    'TriggerEvent',
    'RegisterCallback'
}

-- Client Exports
client_exports {
    'GetPlayerData',
    'GetEconomyData',
    'GetServerStats',
    'TriggerEvent',
    'RegisterCallback'
}
