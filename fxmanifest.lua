fx_version 'cerulean'
game 'gta5'

description 'qbx_recyclejob'
repository 'https://github.com/Qbox-project/qbx_recyclejob'
version '2.1.0'

shared_script {
    '@ox_lib/init.lua',
    '@qbx_core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
}

server_scripts {
    'server/*',
}

client_scripts {
    'client/*'
}

files {
    'config/client.lua',
    'config/server.lua',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'