fx_version 'cerulean'
game 'gta5'

author 'Alexandre'
description 'Random object spawning with interaction and item reward system'
version '1.0.0'
lua54 'yes'

client_scripts {
    'client.lua',  -- Client-side script
}

server_scripts {
    'server.lua',  -- Server-side script
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}
