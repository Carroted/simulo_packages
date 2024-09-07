Scene:reset():destroy();
Scene:set_gravity(vec2(0, 0));

local player = Scene:add_circle({
    name = "player",
    position = vec2(8, 29),
    radius = 0.5,
    is_static = false,
    color = 0xaaaaaa,
});
player:set_angle(math.rad(45));

local hash = Scene:add_component({
    name = "player Component",
    id = "@carroted/raycast3d/player",
    version = "0.2.0",
    code = require('./packages/@carroted/raycast3d/lib/player.lua', 'string')
});

player:add_component(hash);

Scene:add_box({
    position = vec2(0, 0),
    size = vec2(0.5 * 150, 50),
    is_static = true,
    color = 0x111111,
}):temp_set_collides(false);

Scene:add_circle({
    position = vec2(4, 36),
    radius = 1,
    is_static = true,
    color = 0x829dff
});

Scene:add_box({
    position = vec2(-1, 40),
    size = vec2(5, 2),
    is_static = true,
    color = 0x83bd63,
}):set_angle(1);

Scene:add_box({
    position = vec2(0.6, 34),
    size = vec2(0.6, 0.6),
    is_static = true,
    color = 0xbd7a5b,
}):set_angle(-1);

Scene:add_box({
    position = vec2(-10, 37),
    size = vec2(0.1, 20),
    is_static = true,
    color = 0xc9c9c9
});

Scene:add_box({
    position = vec2(10, 37),
    size = vec2(0.1, 20),
    is_static = true,
    color = 0xc9c9c9
});

Scene:add_box({
    position = vec2(0, 47),
    size = vec2(20, 0.1),
    is_static = true,
    color = 0xc9c9c9
});

Scene:add_box({
    position = vec2(0, 27),
    size = vec2(20, 0.1),
    is_static = true,
    color = 0xc9c9c9
});