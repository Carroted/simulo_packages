local function spawn_pylon(pos)
    local pylon = Scene:add_polygon({
        position = pos,
        points = {
            vec2((-11 / 12) * 0.5, (-8 / 12) * 0.5),
            vec2((-11 / 12) * 0.5, -0.5),
            vec2((11 / 12) * 0.5, -0.5),
            vec2((11 / 12) * 0.5, (-8 / 12) * 0.5),
            vec2((1 / 12) * 0.5, 0.5),
            vec2((-1 / 12) * 0.5, 0.5),
        },
        -- color = Color:hex(0xffcb81),
        color = Color:rgba(0,0,0,0),
        is_static = false,
    });
    pylon:set_name("player_100");

    local sprite = Scene:add_attachment({
        name = "Image",
        parent = pylon,
        local_position = vec2(0, 0),
        local_angle = 0,
        images = {{
            texture = require("./packages/@carroted/pylon_recon/assets/textures/entities/cone.png"),
            scale = vec2(1/12, 1/12),
        }},
    });

    local hash = Scene:add_component_def({
        name = "Pylon",
        id = "@carroted/pylon_recon/pylon",
        version = "0.1.0",
        code = require('./packages/@carroted/pylon_recon/lib/pylon.lua', 'string'),
        properties = {
            {
                id = "health",
                name = "Health",
                input_type = "slider",
                default_value = 100,
                min_value = 0,
                max_value = 100,
            },
            {
                id = "jump",
                name = "Jump",
                input_type = "button",
                event = "jump"
            },
            {
                id = "z_angle",
                name = "Angle (just for demo)",
                input_type = "slider",
                default_value = 0,
                min_value = -math.pi,
                max_value = math.pi,
            }
        }
    });

    pylon:add_component({
        hash = hash,
        saved_data = {
            sprite = sprite,
        },
    });
end;

return spawn_pylon;