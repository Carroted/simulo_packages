local ball = Scene:add_circle({
    position = vec2(0, 0),
    color = Color:hex(0x9f6ae8),
    is_static = false,
    radius = 0.25,
});

local hash = Scene:add_component({
    name = "Virus",
    id = "@carroted/viruses/virus",
    version = "0.1.0",
    code = require('./packages/@carroted/viruses/lib/virus.lua', 'string')
});

ball:add_component({ hash = hash });

ball:send_event("@carroted/viruses/set_data", {
    takeover = 10,
    color = ball:get_color(),
    shake = false,
    color_change = true,
    mutation_amount = 0,
    shake_speed = 1,
    takeover_to = 1,
    takeover_equal = false,
});

local ball = Scene:add_circle({
    position = vec2(0, 0),
    color = Color:hex(0xe8704c),
    is_static = false,
    radius = 0.25,
});

ball:add_component({ hash = hash });

ball:send_event("@carroted/viruses/set_data", {
    takeover = 10,
    color = ball:get_color(),
    shake = true,
    color_change = false,
    mutation_amount = 0,
    shake_speed = 1,
    takeover_to = 1,
    takeover_equal = false,
});