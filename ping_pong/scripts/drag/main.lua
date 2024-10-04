local setup = require('./packages/@carroted/ping_pong/lib/setup.lua');

local paddle_1 = setup(0x3f6d46);

local hash = Scene:add_component({
    name = "Player Paddle",
    id = "@carroted/ping_pong/player",
    version = "0.1.0",
    code = require('./packages/@carroted/ping_pong/lib/player_drag.lua', 'string')
});

paddle_1:add_component({ hash = hash });

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
    local_position = vec2(7 / 2, -8 / 2),
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
Scene:add_attachment({
    name = "Point Light",
    component = {
        name = "Point Light",
        code = nil,
    },
    parent = light_parent,
    local_position = vec2(-7 / 2, 8 / 2),
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

Scene.background_color = 0x1f2621;

paddle_1:temp_set_group_index(9872);

local box = Scene:add_box({
    position = vec2(0, 0.45),
    size = vec2(5.5, 1),
    color = Color:rgba(255,0,0,0),
    is_static = true,
});
box:temp_set_collides(false);
box:set_restitution(0);
box:set_friction(0);
box:temp_set_group_index(9872);

local box = Scene:add_box({
    position = vec2(0, -0.5 - 3.25 - 0.1),
    size = vec2(5.7, 1),
    color = Color:rgba(255,0,0,0),
    is_static = true,
});
box:temp_set_collides(false);
box:set_restitution(0);
box:set_friction(0);
box:temp_set_group_index(9872);