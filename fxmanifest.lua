fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'esx_givevehicle'
author 'Karos#7804' 
version '1.10.5'

shared_scripts {

    '@es_extended/imports.lua',
	'@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}

client_scripts {
	'client/*.lua',
}

dependency {
	'es_extended',
	'esx_vehicleshop'
}