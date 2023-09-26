fx_version 'cerulean'

game 'gta5'

author 'Discord: femabeh'

title 'fex_credits'

description 'Fully Customizable ESX Credit Script'

version '1.0.0'

shared_scripts {
	'@es_extended/locale.lua',
	'@es_extended/imports.lua',
	'locales/*.lua',
	'config.lua',
}

client_scripts {
    'client.lua',
}
server_script {
    'server.lua',
	'@mysql-async/lib/MySQL.lua',
}

dependencies {
	'es_extended',
	'esx_menu_default',
}
