local setup = require('./packages/@carroted/ping_pong/lib/setup.lua');

local paddle_1 = setup(0x3c407f);

local hash = Scene:add_component({
    name = "Player Paddle",
    id = "@carroted/ping_pong/player",
    version = "0.1.0",
    code = require('./packages/@carroted/ping_pong/lib/player_normal.lua', 'string')
});

paddle_1:add_component(hash);

local light_parent = Scene:add_circle({
    position = vec2(0,0),
    radius = 1,
    color = Color:rgba(0,0,0,0),
    is_static = true,
});
light_parent:temp_set_collides(false);

Scene:add_attachment({
    name = "Point Light",
    component = {
        name = "Point Light",
        code = nil,
    },
    parent = light_parent,
    local_position = vec2(-7 / 2, -8 / 2),
    local_angle = 0,
    image = "./packages/core/assets/textures/point_light.png",
    size = 0.0005,
    color = Color:rgba(0,0,0,0),
    light = {
        color = 0xffffff,
        intensity = 2,
        radius = 8,
    }
});

Scene:add_attachment({
    name = "Point Light",
    component = {
        name = "Point Light",
        code = nil,
    },
    parent = light_parent,
    local_position = vec2(7 / 2, 8 / 2),
    local_angle = 0,
    image = "./packages/core/assets/textures/point_light.png",
    size = 0.0005,
    color = Color:rgba(0,0,0,0),
    light = {
        color = 0xffffff,
        intensity = 2,
        radius = 8,
    }
});