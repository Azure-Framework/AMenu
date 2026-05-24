fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'AMenu-Bridge'
author 'MadeByAzure'
description 'Framework bridge for AMenu with Az-Framework, ESX Legacy, NDCore, QBCore, and standalone fallback support.'
version '20.0.0-amenu-frameworks'

shared_script 'config.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}
client_script 'client/main.lua'
