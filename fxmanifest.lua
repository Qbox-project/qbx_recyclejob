fx_version 'cerulean'
game 'gta5'

description 'QB-RecycleJob'
version '2.1.0'

shared_scripts {
  '@qb-core/shared/locale.lua',
  'locales/en.lua',
  'locales/*.lua',
  'config.lua'
}

client_script {
  'client/main.lua',
  '@PolyZone/client.lua',
  '@PolyZone/BoxZone.lua',
  '@PolyZone/CircleZone.lua'
}

server_script 'server/main.lua'

files {
  'config/client.lua',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
