Config = {}


Config.Blips = {

	MECHANIC = {
		Pos     = { x = -207.67, y = -1320.51, z = 30.88 },----202.7415, -1313.5946, 39.9633, 354.3580
		Sprite  = 446,
		Display = 4,
		Scale   = 0.9,
		Colour  = 49,
	},
}




Config.Boss = {
	
	Boss ={
		coords = vec3(-206.13, -1341.53, 34.89),
		groups = 'mechanic',
		minZ=32.09,
		maxZ=36.09,
	},
	
}



Config.Ano = {
	
	Ano ={
		coords = vec3(-200.69, -1314.54, 31.09),
		groups = 'mechanic',
		minZ=26.77,
		maxZ=30.77,
	},
}


Config.vet = {
	
	vet ={
		coords = vec3(-224.21, -1319.01, 30.89),
		groups = 'mechanic',
		minZ=28.49,
		maxZ=32.49,
	},
}

Config.Uniforms = {
	mechanic_wear = {
 		male = {
 			['tshirt_1'] = 15,  ['tshirt_2'] = 0,
 			['torso_1'] = 369,   ['torso_2'] = 8,
 			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 40,
 			['pants_1'] = 8,   ['pants_2'] = 3,
 			['shoes_1'] = 7,   ['shoes_2'] = 9,
			['helmet_1'] = 155,  ['helmet_2'] = 1,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0
        },

 		female = {
 			['tshirt_1'] = 15,  ['tshirt_2'] = 0,
 			['torso_1'] = 27,   ['torso_2'] = 5,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 0,
			['pants_1'] = 23,   ['pants_2'] = 6,
			['shoes_1'] = 6,   ['shoes_2'] = 0,
 			['helmet_1'] = -1,  ['helmet_2'] = 0,
 			['chain_1'] = 0,    ['chain_2'] = 0,
 			['ears_1'] = -1,     ['ears_2'] = 0	
        }			
    }
}
