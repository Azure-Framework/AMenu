Config = Config or {}

Config.AzResource = 'Az-Framework'

Config.Debug = true

Config.AdminAces = {
    'vMenu.Framework.Admin',
    'vMenu.QBCore.Admin',
    'vMenu.QBCore.Menu',
    'vMenu.Staff',
    'admin'
}

Config.RequireAdminForManagement = true

Config.RestrictVehicleSpawner = false
Config.AllowedVehicleJobs = {
    police = true,
    sheriff = true,
    state = true,
    ambulance = true,
    ems = true,
    fire = true,
}

Config.SpawnCosts = {
    Default = 0,
    Classes = {

    }
}

Config.Keys = {
    ServerEvent = '',
    ClientEvent = '',
}

Config.Notifications = {
    UseOxLibFallback = true,
    Title = 'vMenu Bridge'
}
