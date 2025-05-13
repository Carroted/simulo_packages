local function spawn_flingstick(pos)
    local flingstick = Scene:add_box({
        position = pos,
        size = vec2(34/12, 5/12),
        color = Color:rgba(0,0,0,0),
    });

    Scene:add_attachment({
        name = "Image",
        parent = flingstick,
        local_position = vec2(0, 0),
        local_angle = 0,
        images = {{
            texture = require("./packages/@carroted/pylon_recon/assets/textures/weapons/flingstick.png"),
            scale = vec2(1/12, 1/12),
        }},
    });

    local hash = Scene:add_component_def({
        name = "Weapon",
        id = "@carroted/pylon_recon/weapon",
        version = "0.1.0",
        code = require('./packages/@carroted/pylon_recon/lib/weapons/flingstick.lua', 'string')
    });

    flingstick:add_component({ hash = hash });

    return flingstick;
end;

return spawn_flingstick;