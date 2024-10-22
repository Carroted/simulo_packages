Scene:reset():destroy();

local dispenser_width = 926;
local dispenser_height = 704;
local size = 0.8;

local player = Scene:add_box({
    position = vec2(0,0),
    size = vec2(size, (dispenser_height / dispenser_width) * size),
    color = Color:rgba(0,0,0,0),
    is_static = false,
});
player:set_restitution(0);

local hash = Scene:add_component({
    name = "Player",
    id = "@carroted/entaped_test_2d/player",
    version = "0.1.0",
    code = require('./packages/@carroted/entaped_test_2d/lib/player.lua', 'string')
});

player:add_component({ hash = hash });

local ceiling = Scene:add_box({
    position = vec2(8, 0),
    size = vec2(8, 0.5),
    color = 0xffffff,
    is_static = true
});
ceiling:set_restitution(0);
ceiling:set_angle(-0.2);

local box = Scene:add_box({
    position = vec2(6, -2),
    size = vec2(2, 1),
    color = 0xffffff,
    is_static = true
});

local box = Scene:add_box({
    position = vec2(15+3 + 40, -3),
    size = vec2(80, 1),
    color = 0xffffff,
    is_static = true
});

local box = Scene:add_box({
    position = vec2(15+7, -8),
    size = vec2(2, 1),
    color = 0xffffff,
    is_static = true
});

local box = Scene:add_box({
    position = vec2(15+7+30, -8),
    size = vec2(2, 1),
    color = 0xffffff,
    is_static = true
});
--[[
local box = Scene:add_box({
    position = vec2(15+3, -6),
    size = vec2(8, 0.5),
    color = 0xffffff,
    is_static = true
}):set_restitution(0);]]