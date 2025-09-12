fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name "rzw-starterpack"
description "ID: rzw-starterpack adalah resource simpel starterpack with ox_lib | EN: rzw-starterpack is a simple resource starterpack with ox_lib"
author "Rozir Wobari"
version "1.0.1"

shared_scripts {
	'@ox_lib/init.lua',
	'shared/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}
