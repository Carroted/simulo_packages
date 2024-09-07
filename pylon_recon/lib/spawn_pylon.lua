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

    local hash = Scene:add_component({
        name = "Pylon",
        id = "@carroted/pylon_recon/pylon",
        version = "0.1.0",
        code = require('./packages/@carroted/pylon_recon/lib/pylon.lua', 'string')
    });

    pylon:add_component(hash);
end;

return spawn_pylon;