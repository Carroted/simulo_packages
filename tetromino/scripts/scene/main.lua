Scene:reset();
Camera:set_position(vec2(0, -1.75));
Camera:set_orthographic_scale(0.022);

local hash = Scene:add_component({
    name = "Tetromino Manager",
    id = "@carroted/tetromino/manager",
    version = "0.2.0",
    code = require('./packages/@carroted/tetromino/lib/manager.lua', 'string')
});

local manager = Scene:add_box({
    name = "Tetromino Manager",
    size = vec2(0.2, 0.2),
    position = vec2(0, -100),
    is_static = true,
    color = 0xa0a0a0,
});

manager:add_component(hash);