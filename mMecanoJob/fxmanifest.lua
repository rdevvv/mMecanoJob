fx_version 'adamant'
game 'gta5'

client_scripts {
	'config/config.lua',
	'client/cl_mecano.lua'
}

server_scripts {
	'config/config.lua',
	'server/sv_mecano.lua'
}

shared_script {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua'
}