local the_shire = {}

-- ============
-- HOBBIT DOORS
-- ============
the_shire_doors = {
    ["hobbit_door_wood"] = {
        description = "Hobbit Door Wood",
        texture = "hobbit_door_wood.png",
        knob_texture = "hobbit_brass.png",
        groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 },
        sounds = default.node_sound_wood_defaults(),
        sound_open = "hobbit_door_open",
        sound_close = "hobbit_door_close",
        gain_open = 0.5,
        gain_close = 0.5,
        key_item = "the_shire:hobbit_door_key",
    },
    ["hobbit_door_acacia_wood"] = {
        description = "Hobbit Door Acacia Wood",
        texture = "hobbit_door_acacia_wood.png",
        knob_texture = "hobbit_brass.png",
        groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 },
        sounds = default.node_sound_wood_defaults(),
        sound_open = "hobbit_door_open",
        sound_close = "hobbit_door_close",
        gain_open = 0.5,
        gain_close = 0.5,
        key_item = "the_shire:hobbit_door_key",
    },
    ["hobbit_door_aspen_wood"] = {
        description = "Hobbit Door Aspen Wood",
        texture = "hobbit_door_aspen_wood.png",
        knob_texture = "hobbit_brass.png",
        groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 },
        sounds = default.node_sound_wood_defaults(),
        sound_open = "hobbit_door_open",
        sound_close = "hobbit_door_close",
        gain_open = 0.5,
        gain_close = 0.5,
        key_item = "the_shire:hobbit_door_key",
    },
    ["hobbit_door_junglewood"] = {
        description = "Hobbit Door Junglewood",
        texture = "hobbit_door_junglewood.png",
        knob_texture = "hobbit_brass.png",
        groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 },
        sounds = default.node_sound_wood_defaults(),
        sound_open = "hobbit_door_open",
        sound_close = "hobbit_door_close",
        gain_open = 0.5,
        gain_close = 0.5,
        key_item = "the_shire:hobbit_door_key",
    },
    ["hobbit_door_pine_wood"] = {
        description = "Hobbit Door Pine Wood",
        texture = "hobbit_door_pine_wood.png",
        knob_texture = "hobbit_brass.png",
        groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 },
        sounds = default.node_sound_wood_defaults(),
        sound_open = "hobbit_door_open",
        sound_close = "hobbit_door_close",
        gain_open = 0.5,
        gain_close = 0.5,
        key_item = "the_shire:hobbit_door_key",
    },
    ["hobbit_door_blue_wood"] = {
        description = "Hobbit Door Blue Wood",
        texture = "hobbit_door_blue_wood.png",
        knob_texture = "hobbit_brass.png",
        groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 },
        sounds = default.node_sound_wood_defaults(),
        sound_open = "hobbit_door_open",
        sound_close = "hobbit_door_close",
        gain_open = 0.5,
        gain_close = 0.5,
        key_item = "the_shire:hobbit_door_key",
    },
    ["hobbit_door_green_wood"] = {
        description = "Hobbit Door Green Wood",
        texture = "hobbit_door_green_wood.png",
        knob_texture = "hobbit_brass.png",
        groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 },
        sounds = default.node_sound_wood_defaults(),
        sound_open = "hobbit_door_open",
        sound_close = "hobbit_door_close",
        gain_open = 0.5,
        gain_close = 0.5,
        key_item = "the_shire:hobbit_door_key",
    },
}

minetest.register_node("the_shire:hidden_protector", {
    description = "Invisible Door Barrier",
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = false,
    groups = {not_in_creative_inventory = 1, falling_node = 1},
})

local function has_door_access(pos, player)
    if not player then return false end
    local name = player:get_player_name()

    if minetest.check_player_privs(name, {protection_bypass=true}) then
        return true
    end

    if not minetest.is_protected(pos, name) then
        return true
    end

    local meta = minetest.get_meta(pos)
    local owner = meta:get_string("owner")
    if owner == "" or owner == name then
        return true
    end

    local key_name = meta:get_string("key_lock")
    if key_name ~= "" and player:get_inventory():contains_item("main", key_name) then
        return true
    end

    return false
end

local function swap_door_state(pos, mat_key, next_state, delay, final_state)
    minetest.after(delay, function()
        local current = minetest.get_node(pos)
        if string.find(current.name, "the_shire:" .. mat_key .. "_") then
            minetest.swap_node(pos, {name = "the_shire:" .. mat_key .. "_" .. next_state, param2 = current.param2})

            if string.find(next_state, "open") then
                local barrier_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
                if minetest.get_node(barrier_pos).name == "air" then
                    minetest.set_node(barrier_pos, {name = "the_shire:hidden_protector"})
                end
            elseif string.find(next_state, "closed") then
                local barrier_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
                if minetest.get_node(barrier_pos).name == "the_shire:hidden_protector" then
                    minetest.remove_node(barrier_pos)
                end
            end

            if final_state then
                swap_door_state(pos, mat_key, final_state, delay)
            end
        end
    end)
end

local function register_hobbit_door_state(mat_key, mat_def, state_key, mesh_file, selection_settings, collision_settings, creative_status)
    local current_groups = {}
    if mat_def.groups then
        for k, v in pairs(mat_def.groups) do
            current_groups[k] = v
        end
    end
    current_groups.door = 1
    if not creative_status then
        current_groups.not_in_creative_inventory = 1
    end

    minetest.register_node("the_shire:" .. mat_key .. "_" .. state_key, {
        description = mat_def.description,
        drawtype = "mesh",
        mesh = mesh_file,
        tiles = {
            mat_def.texture,
            mat_def.knob_texture
        },
        paramtype = "light",
        paramtype2 = "facedir",
        groups = current_groups,
        sounds = mat_def.sounds,
        drop = "the_shire:" .. mat_key .. "_closed",
        selection_box = selection_settings,
        collision_box = collision_settings,

        after_place_node = function(pos, placer, itemstack, pointed_thing)
            if state_key == "closed" then
                local name = placer and placer:get_player_name() or ""
                local meta = minetest.get_meta(pos)
                meta:set_string("owner", name)

                local lock_id = mat_def.key_item or ""
                meta:set_string("key_lock", lock_id)
            end
        end,

        after_dig_node = function(pos, oldnode, oldmetadata, digger)
            local barrier_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
            if minetest.get_node(barrier_pos).name == "the_shire:hidden_protector" then
                minetest.remove_node(barrier_pos)
            end
        end,

        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            local name = clicker:get_player_name()
            local meta = minetest.get_meta(pos)
            local current_key = meta:get_string("key_lock")

            if itemstack:get_name() == "the_shire:hobbit_door_key" then
                if current_key == "" then
                    meta:set_string("key_lock", "the_shire:hobbit_door_key")
                    minetest.chat_send_player(name, "This Hobbit Door is now locked tight!")
                else
                    meta:set_string("key_lock", "")
                    minetest.chat_send_player(name, "The Hobbit Door has been unlocked.")
                end
                return
            end

            if not has_door_access(pos, clicker) then
                minetest.chat_send_player(name, "This Hobbit Door is locked tight!")
                return
            end

            if state_key == "closed" then
                if mat_def.sound_open then
                    minetest.sound_play(mat_def.sound_open, {pos = pos, gain = mat_def.gain_open or 0.5})
                end
                swap_door_state(pos, mat_key, "half", 0.15, "open")
            elseif state_key == "open" then
                if mat_def.sound_close then
                    minetest.sound_play(mat_def.sound_close, {pos = pos, gain = mat_def.gain_close or 0.5})
                end
                swap_door_state(pos, mat_key, "half", 0.15, "closed")
            end
        end,
    })
end

for mat_key, mat_def in pairs(the_shire_doors) do
    register_hobbit_door_state(mat_key, mat_def, "closed", "hobbit_door.obj",
        { type = "fixed", fixed = {-1.4375, -0.4375, 0.5625, 0.4375, 1.4375, 0.6875} },
        { type = "fixed", fixed = {-1.4375, -0.4375, 0.5625, 0.4375, 1.4375, 0.6875} }, true)

    register_hobbit_door_state(mat_key, mat_def, "half", "hobbit_door_half_open.obj",
        { type = "fixed", fixed = {-1.4375, -0.4375, 0.5625, 0.4375, 1.4375, 0.6875} },
        { type = "fixed", fixed = {-1.4375, -0.4375, 0.5625, 0.4375, 1.4375, 0.6875} }, false)

    register_hobbit_door_state(mat_key, mat_def, "open", "hobbit_door_open.obj",
        { type = "fixed", fixed = {0.3125, -0.4375, -1.3125, 0.4375, 1.4375, 0.5625} },
        { type = "fixed", fixed = {0.3125, -0.4375, -1.3125, 0.4375, 1.4375, 0.5625} }, false)
end

-- =================================
-- HOBBIT DOOR KEY & CRAFTING RECIPE
-- =================================
minetest.register_craftitem("the_shire:hobbit_door_key", {
    description = "Hobbit Door Key\nUsed to lock and unlock Hobbit Doors.",
    inventory_image = "hobbit_door_key.png",
    stack_max = 1,
})

minetest.register_craft({
    output = "the_shire:hobbit_door_key",
    recipe = {
        {"default:bronze_ingot", ""},
        {"", "default:bronze_ingot"},
    }
})


-- ==============
-- HOBBIT WINDOWS
-- ==============

local hobbit_windows = {
	["desert_sandstone_wood"] = {
        desc = "Desert Sandstone & Wood Hobbit Window",
        glass = "default_wood.png",
        frame = "default_desert_sandstone.png"
    },
    ["desert_sandstone_acacia"] = {
        desc = "Desert Sandstone & Acacia Hobbit Window",
        glass = "default_acacia_wood.png",
        frame = "default_desert_sandstone.png"
    },
    ["desert_sandstone_junglewood"] = {
        desc = "Desert Sandstone & Junglewood Hobbit Window",
        glass = "default_junglewood.png",
        frame = "default_desert_sandstone.png"
    },
    ["desert_sandstone_pine"] = {
        desc = "Desert Sandstone & Pine Hobbit Window",
        glass = "default_pine_wood.png",
        frame = "default_desert_sandstone.png"
    },
    ["desert_sandstone_aspen"] = {
        desc = "Desert Sandstone & Aspen Hobbit Window",
        glass = "default_aspen_wood.png",
        frame = "default_desert_sandstone.png"
    },
	["sandstone_wood"] = {
        desc = "Sandstone & Wood Hobbit Window",
        glass = "default_wood.png",
        frame = "default_sandstone.png"
    },
    ["sandstone_acacia"] = {
        desc = "Sandstone & Acacia Hobbit Window",
        glass = "default_acacia_wood.png",
        frame = "default_sandstone.png"
    },
    ["sandstone_junglewood"] = {
        desc = "Sandstone & Junglewood Hobbit Window",
        glass = "default_junglewood.png",
        frame = "default_sandstone.png"
    },
    ["sandstone_pine"] = {
        desc = "Sandstone & Pine Hobbit Window",
        glass = "default_pine_wood.png",
        frame = "default_sandstone.png"
    },
    ["sandstone_aspen"] = {
        desc = "Sandstone & Aspen Hobbit Window",
        glass = "default_aspen_wood.png",
        frame = "default_sandstone.png"
    },
    ["silver_sandstone_wood"] = {
        desc = "Silver Sandstone & Wood Hobbit Window",
        glass = "default_wood.png",
        frame = "default_silver_sandstone.png"
    },
    ["silver_sandstone_acacia"] = {
        desc = "Silver Sandstone & Acacia Hobbit Window",
        glass = "default_acacia_wood.png",
        frame = "default_silver_sandstone.png"
    },
    ["silver_sandstone_junglewood"] = {
        desc = "Silver Sandstone & Junglewood Hobbit Window",
        glass = "default_junglewood.png",
        frame = "default_silver_sandstone.png"
    },
    ["silver_sandstone_pine"] = {
        desc = "Silver Sandstone & Pine Hobbit Window",
        glass = "default_pine_wood.png",
        frame = "default_silver_sandstone.png"
    },
    ["silver_sandstone_aspen"] = {
        desc = "Silver Sandstone & Aspen Hobbit Window",
        glass = "default_aspen_wood.png",
        frame = "default_silver_sandstone.png"
    }
}

local function make_window(wood_type, details)
    minetest.register_node("the_shire:hobbit_window_" .. wood_type, {
        description = details.desc,
        drawtype = "mesh",
        mesh = "hobbit_window.obj",
		tiles = {
            details.glass,
            details.frame
        },
		paramtype = "light",
        paramtype2 = "facedir",
        sunlight_propagates = true,
        selection_box = { type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, -0.125} },
        collision_box = { type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, -0.125} },
        groups = { choppy = 2, oddly_breakable_by_hand = 3, glass = 1 },
        sounds = default.node_sound_glass_defaults(),
    })

    minetest.register_craft({
        output = "the_shire:hobbit_window_" .. wood_type,
        recipe = {
            {"default:wood", "default:glass"},
        }
    })
end

for wood_type, details in pairs(hobbit_windows) do
    make_window(wood_type, details)
end


if minetest.get_modpath("some_elf_mod") then
    make_window("mallorn", {
        desc = "Mallorn Hobbit Window",
        glass = "the_shire_window_glass.png",
        frame = "some_elf_mod_mallorn_wood.png"
    })
end


-- ===========
-- SHIRE GRASS
-- ===========
minetest.register_node("the_shire:shire_grass", {
    description = "Shire Grass Block\nA block entirely covered in lush grass.",
	drawtype = "normal",
	tiles = {"default_grass.png"},
	paramtype = "light",
    groups = { crumbly = 3, soil = 1, grass = 1 },
    sounds = default.node_sound_dirt_defaults({
        footstep = { name = "default_grass_footstep", gain = 0.25 },
    }),
})

-- Crafting Recipe
minetest.register_craft({
    output = "the_shire:shire_grass 2",
    recipe = {
        {"default:dirt", "default:dirt"},
        {"default:grass_1", "default:grass_1"},
    }
})

-- ==================
-- SHIRE GRASS STAIRS
-- ==================

-- STAIR
minetest.register_node("the_shire:stair_shire_grass", {
    description = "Shire Grass Stair",
    drawtype = "nodebox",
    tiles = {"default_grass.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { crumbly = 3, soil = 1, grass = 1, stair = 1 },
    sounds = default.node_sound_dirt_defaults({
        footstep = { name = "default_grass_footstep", gain = 0.25 },
    }),
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
            {-0.5, 0.0, 0.0, 0.5, 0.5, 0.5},
        },
    },
    on_place = minetest.rotate_node,
})

-- INNER CORNER STAIR
minetest.register_node("the_shire:stair_shire_grass_inner", {
    description = "Shire Grass Stair (Inner Corner)",
    drawtype = "nodebox",
    tiles = {"default_grass.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { crumbly = 3, soil = 1, grass = 1, stair = 1 },
    sounds = default.node_sound_dirt_defaults({
        footstep = { name = "default_grass_footstep", gain = 0.25 },
    }),
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
            {-0.5, 0.0, 0.0, 0.5, 0.5, 0.5},
            {-0.5, 0.0, -0.5, 0.0, 0.5, 0.0},
        },
    },
    on_place = minetest.rotate_node,
})

-- OUTER CORNER STAIR
minetest.register_node("the_shire:stair_shire_grass_outer", {
    description = "Shire Grass Stair (Outer Corner)",
    drawtype = "nodebox",
    tiles = {"default_grass.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { crumbly = 3, soil = 1, grass = 1, stair = 1 },
    sounds = default.node_sound_dirt_defaults({
        footstep = { name = "default_grass_footstep", gain = 0.25 },
    }),
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
            {0.0, 0.0, 0.0, 0.5, 0.5, 0.5},
        },
    },
    on_place = minetest.rotate_node,
})

-- SHIRE GRASS SLAB
minetest.register_node("the_shire:slab_shire_grass", {
    description = "Shire Grass Slab",
    drawtype = "nodebox",
    tiles = {"default_grass.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { crumbly = 3, soil = 1, grass = 1, slab = 1 },
    sounds = default.node_sound_dirt_defaults({
        footstep = { name = "default_grass_footstep", gain = 0.25 },
    }),
    node_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
    },
    on_place = minetest.rotate_node,
})

-- CRAFTING RECIPE
minetest.register_craft({
    output = "the_shire:stair_shire_grass 4",
    recipe = {
        {"the_shire:shire_grass", "", ""},
        {"the_shire:shire_grass", "the_shire:shire_grass", ""},
        {"the_shire:shire_grass", "the_shire:shire_grass", "the_shire:shire_grass"},
    }
})

minetest.register_craft({
    output = "the_shire:slab_shire_grass 6",
    recipe = {
        {"the_shire:shire_grass", "the_shire:shire_grass", "the_shire:shire_grass"},
    }
})

-- ===========================
-- CUSTOM MESH SHIRE GRASS 1-5
-- ===========================

-- SHIRE GRASS 1
minetest.register_node("the_shire:shire_grass_1", {
    description = "Shire Grass",
    drawtype = "mesh",
    mesh = "shirelike.obj",
    waving = 1,
    tiles = {"default_grass_1.png"},
    inventory_image = "default_grass_3.png",
    wield_image = "default_grass_3.png",
	use_texture_alpha = "clip",
	paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    walkable = false,
    buildable_to = true,
    groups = {snappy = 3, flora = 1, attached_node = 1, grass = 1, normal_grass = 1, flammable = 1},
    sounds = default.node_sound_leaves_defaults(),
	selection_box = {
        type = "fixed",
        fixed = {-0.375, -1.0, -0.375, 0.375, -0.8125, 0.375},
    },

    on_place = function(itemstack, placer, pointed_thing)
        local stack = ItemStack("the_shire:shire_grass_" .. math.random(1, 5))
        local ret = minetest.item_place(stack, placer, pointed_thing)
        return ItemStack("the_shire:shire_grass_1 " .. itemstack:get_count() - (1 - ret:get_count()))
    end,
})

for i = 2, 5 do
    minetest.register_node("the_shire:shire_grass_" .. i, {
        description = "Shire Grass",
        drawtype = "mesh",
        mesh = "shirelike.obj",
        waving = 1,
        tiles = {"default_grass_" .. i .. ".png"},
        inventory_image = "default_grass_" .. i .. ".png",
        wield_image = "default_grass_" .. i .. ".png",
		use_texture_alpha = "clip",
		paramtype = "light",
        paramtype2 = "facedir",
        sunlight_propagates = true,
        walkable = false,
        buildable_to = true,
        drop = "the_shire:shire_grass_1",
        groups = {snappy = 3, flora = 1, attached_node = 1, not_in_creative_inventory = 1, grass = 1, normal_grass = 1, flammable = 1},
        sounds = default.node_sound_leaves_defaults(),
		selection_box = {
            type = "fixed",
            fixed = {-0.375, -1.0, -0.375, 0.375, -0.8125, 0.375},
        },
    })
end


-- =====================
-- SHIRE FLOWERING VINES
-- =====================

minetest.register_node("the_shire:vines_bloom", {
    description = "Flowering Shire Vines\nCan be placed on walls, ceilings, or floors.",
	drawtype = "signlike",
	tiles = {"shire_vines_bloom.png"},
	inventory_image = "shire_vines_bloom.png",
    wield_image = "shire_vines_bloom.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
    walkable = false,
    climbable = true,
    buildable_to = true,
	groups = { snappy = 3, flammable = 1, flora = 1 },
    sounds = default.node_sound_leaves_defaults(),
	selection_box = {
        type = "wallmounted",
        wall_top    = {-0.375,  0.4375, -0.375, 0.375,  0.5,    0.375},
        wall_bottom = {-0.375, -0.5,    -0.375, 0.375, -0.4375, 0.375},
        wall_side   = {-0.5,   -0.375,  -0.375, -0.4375, 0.375,  0.375},
    },

    on_place = function(itemstack, placer, pointed_thing)
        return minetest.item_place(itemstack, placer, pointed_thing)
    end,
})

minetest.register_node("the_shire:vines", {
    description = "Shire Vines\nCan be placed on walls, ceilings, or floors.",
	drawtype = "signlike",
	tiles = {"shire_vines.png"},
	inventory_image = "shire_vines.png",
    wield_image = "shire_vines.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
    walkable = false,
    climbable = true,
    buildable_to = true,
	groups = { snappy = 3, flammable = 1, flora = 1 },
    sounds = default.node_sound_leaves_defaults(),
	selection_box = {
        type = "wallmounted",
        wall_top    = {-0.375,  0.4375, -0.375, 0.375,  0.5,    0.375},
        wall_bottom = {-0.375, -0.5,    -0.375, 0.375, -0.4375, 0.375},
        wall_side   = {-0.5,   -0.375,  -0.375, -0.4375, 0.375,  0.375},
    },

    on_place = function(itemstack, placer, pointed_thing)
        return minetest.item_place(itemstack, placer, pointed_thing)
    end,
})

-- Crafting Recipe
minetest.register_craft({
    output = "the_shire:shire_flowering_vine 3",
    recipe = {
        {"default:grass_1", "group:flower"},
        {"default:grass_1", ""},
    }
})


-- ================
-- SHIRE PATHSTONES
-- ================

minetest.register_node("the_shire:shire_pathstones", {
    description = "Shire Pathstones\nNatural stones embedded into the lush turf.",
    drawtype = "normal",
    tiles = {
        "default_grass.png^shire_pathstones.png",
        "default_grass.png",
        "default_grass.png",
        "default_grass.png",
        "default_grass.png",
        "default_grass.png"
    },
    paramtype = "light",
    paramtype2 = "facedir",
    groups = { cracky = 3, stone = 1, soil = 1, grass = 1 },
    sounds = default.node_sound_stone_defaults({
        footstep = { name = "default_grass_footstep", gain = 0.25 },
    }),
})

-- Crafting Recipe
minetest.register_craft({
    output = "the_shire:shire_pathstones 4",
    recipe = {
        {"default:stone", "default:dirt"},
        {"default:stone", "default:grass_1"},
    }
})
