fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'vMenu-Bridge'
author 'MadeByAzure'
description 'AZ-ONLY vMenu bridge. No QBCore, no ND_Core, no framework guessing. Calls Az-Framework exports directly.'
version '19.0.0-az-action-final'

shared_script 'config.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}
client_script 'client/main.lua'
