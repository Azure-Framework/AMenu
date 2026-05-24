Config = Config or {}

Config.Debug = false



Config.Framework = {
    Mode = 'auto',
    Priority = { 'az', 'esx', 'nd', 'qb' },
    Resources = {
        az = 'Az-Framework',
        esx = 'es_extended',
        nd = 'ND_Core',
        qb = 'qb-core'
    },

    AdminAces = {
        'AMenu.Framework.Admin',
        'AMenu.Framework.Menu',
        'AMenu.ESX.Admin',
        'AMenu.NDCore.Admin',
        'AMenu.QBCore.Admin',
        'AMenu.QBCore.Menu',
        'AMenu.Staff',
        'admin'
    },

    ESXAdminGroups = {
        admin = true,
        superadmin = true,
        owner = true,
        mod = true,
        moderator = true
    },

    NDAdminGroups = {
        admin = 1,
        staff = 1,
        moderator = 1,
        mod = 1
    },

    QBCoreAdminPermissions = { 'god', 'admin' },

    RestrictVehicleSpawner = false,
    AllowedVehicleJobs = {
        police = true,
        sheriff = true,
        bcso = true,
        lspd = true,
        sahp = true,
        sasp = true,
        state = true,
        ambulance = true,
        ems = true,
        fire = true,
        safd = true
    },

    SpawnCosts = {
        Default = 0,
        Classes = {}
    }
}


Config.Keys = {
    ServerEvent = '',
    ClientEvent = '',
}

Config.Notifications = {
    UseOxLibFallback = true,
    Title = 'AMenu Bridge'
}


Config.AzResource = Config.Framework.Resources.az
Config.AdminAces = Config.Framework.AdminAces
Config.RequireAdminForManagement = true
Config.RestrictVehicleSpawner = Config.Framework.RestrictVehicleSpawner
Config.AllowedVehicleJobs = Config.Framework.AllowedVehicleJobs
Config.SpawnCosts = Config.Framework.SpawnCosts
