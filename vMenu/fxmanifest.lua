fx_version 'cerulean'
game 'gta5'

ui_page 'html/index.html'

files {
  'html/*.*',
  'html/banners/*.png',
  'config/permissions.cfg',
  'README.md',
  'addons.json'
}

shared_scripts {
  'config.lua'
}

client_scripts {
  'client.lua'
}

server_scripts {
  'server.lua'
}
