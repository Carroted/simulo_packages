local function spawn_gun(pos)
    local gun = Scene:add_box({
        position = pos,
        size = vec2(18/12, 4/12),
        color = Color:rgba(0,0,0,0),
        is_static = false,
    });

    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = nil,
        },
        parent = gun,
        local_position = vec2(0, 1/12),
        local_angle = 0,
        image = "./packages/@carroted/pylon_recon/assets/textures/weapons/gun.png",
        size = 1 / 12,
        color = Color:hex(0xffffff),
    });

    local hash = Scene:add_component({
        name = "Weapon",
        id = "@carroted/pylon_recon/weapon",
        version = "0.1.0",
        code = require('./packages/@carroted/pylon_recon/lib/weapon.lua', 'string')
    });

    gun:add_component({ hash = hash });
end;

return spawn_gun;