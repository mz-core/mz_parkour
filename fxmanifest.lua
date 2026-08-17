fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Mazus / MZ Core'
description 'Parkour nativo inspirado no GTA IV para mz_core'
version '0.2.0-taskclimb'

dependencies {
    'mz_core',
    'mz_animations'
}

shared_scripts {
    'shared/config.lua',
    'shared/states.lua'
}

client_scripts {
    'client/utils.lua',
    'client/shapetest.lua',
    'client/detector.lua',
    'client/animations.lua',
    'client/controller.lua',
    'client/debug.lua'
}

server_script 'server/main.lua'
