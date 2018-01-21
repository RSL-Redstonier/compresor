function get_compresor_inactivo_formspec()
	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image[1,2.5;1,1;compresor_bslot.png]"..
		"image[3.5,2.5;1,1;compresor_plates.png]"..
		"image[3.5,0.5;1,1;compresor_plates.png^[transformR180]"..
		"image[2.5,1.5;1,1;compresor_plates.png^[transformR270]"..
		"image[4.5,1.5;1,1;compresor_plates.png^[transformR90]"..
		"list[context;a_comprimir;3.5,1.5;1,1;]"..
		"list[context;batery_slot;1,2.5;1,1;]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[current_player;main]"..
		"listring[context;a_comprimir]"..
		"listring[context;batery_slot]"..
		"listring[current_player;main]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

function get_compresor_activo_formspec()
	return "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image[2.5,1.5;3,1;compresor_working.png]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[current_player;main]"..
		"listring[current_player;main]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

minetest.register_craftitem("compresor:pressure_plates", {
	description = "Pressure plate, part of the compressor",
	inventory_image = "compresor_plates.png"
})

minetest.register_craftitem("compresor:AAA_Batery", {
	description = "AAA Batery",
	inventory_image = "compresor_aaa_batery.png",
	groups = {batery = 1},
})

minetest.register_node("compresor:inactivo", {
	description = "Electric compressor",
	tiles = {
		"compresor_side.png", "compresor_side.png",
		"compresor_side.png", "compresor_side.png",
		"compresor_side.png", "compresor_inactive.png"
	},
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	groups = {cracky=2},
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("a_comprimir") and inv:is_empty("batery_slot")
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_compresor_inactivo_formspec())
		local inv = meta:get_inventory()
		inv:set_size("a_comprimir", 1)
		inv:set_size("batery_slot", 1)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local cmplist = inv:get_list("a_comprimir")
		local btrlist = inv:get_list("batery_slot")
		if listname == "a_comprimir" then
			if cmplist[1]:get_name() == "default:coalblock" then
				return 0
			else
				if stack:get_name() == "default:coalblock" then
					return 1
				else
					return 0
				end

			end
		end
		if listname == "batery_slot" then
			if btrlist[1]:get_name() == "compresor:AAA_Batery" then
				return 0
			else
				if stack:get_name() == "compresor:AAA_Batery" then
					return 1
				else
					return 0
				end

			end
		end
	end,
	drop = "compresor:inactivo",
	on_punch = function(pos, node, player, pointed_thing)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local cmplist = inv:get_list("a_comprimir")
		local btrlist = inv:get_list("batery_slot")
		if cmplist[1]:get_name() == "default:coalblock" and btrlist[1]:get_name() == "compresor:AAA_Batery" then
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", get_compresor_activo_formspec())
			local inv = meta:get_inventory()
			inv:set_size("a_comprimir", 1)
			inv:set_size("batery_slot", 1)
			minetest.get_node_timer(pos):start(300)
			swap_node(pos, "compresor:activo")
		end
	end,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("compresor:activo", {
	description = "Electric compressor",
	tiles = {
		"compresor_side.png", "compresor_side.png",
		"compresor_side.png", "compresor_side.png",
		"compresor_side.png", "compresor_active.png"
	},
	paramtype2 = "facedir",
	light_source = 4,
	legacy_facedir_simple = true,
	groups = {cracky=2, not_in_creative_inventory=1},
	diggable = false,
	on_timer = function(pos, elapsed)
--	instercambiar el carbon por el diamante
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local cmplist = inv:get_list("a_comprimir")
		local btrlist = inv:get_list("batery_slot")
		cmplist[1]:clear()
		btrlist[1]:clear()
		inv:set_stack("batery_slot", 1, btrlist[1])
		inv:set_stack("a_comprimir", 1, cmplist[1])
		cmplist[1]:add_item("a_comprimir", "default:diamond")
		inv:set_stack("a_comprimir", 1, cmplist[1])
--	volver al formspec inactivo
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_compresor_inactivo_formspec())
		local inv = meta:get_inventory()
		inv:set_size("a_comprimir", 1)
		inv:set_size("batery_slot", 1)
--	volver al nodo inactivo
		swap_node(pos, "compresor:inactivo")
	end,
	sounds = default.node_sound_stone_defaults(),
})

--	recipes

minetest.register_craft({
	output = "compresor:inactivo",
	recipe = {
		{"group:stone","compresor:pressure_plates","group:stone"},
		{"compresor:pressure_plates","default:steel_ingot","compresor:pressure_plates"},
		{"group:stone","compresor:pressure_plates","group:stone"}
	},
})

minetest.register_craft({
	output = "compresor:pressure_plates",
	recipe = {
		{"default:obsidian","default:obsidian","default:obsidian"},
		{"","default:steel_ingot",""},
		{"","default:steel_ingot",""}
	},
})
minetest.register_craft({
	output = "compresor:AAA_Batery",
	recipe = {
		{"default:bronze_ingot"},
		{"default:gold_ingot"}
	},
})
