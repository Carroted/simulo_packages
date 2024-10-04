local hash = Scene:add_component({
    name = "Painter",
    id = "@carroted/bricks/painter",
    version = "0.1.0",
    code = require('./packages/@carroted/bricks/lib/painter.lua', 'string')
});

local function add_painter(pos, color, width, height)
    local line = Scene:add_box({
        position = pos + vec2(0, 0),
        size = vec2(0.02, (height * 0.2) + 0.05),
        color = color,
        is_static = true,
    });
    line:temp_set_collides(false);

    local top_box = Scene:add_polygon({
        position = pos + vec2(0, (height * 0.1) + 0.05),
        --size = vec2(width * 0.3, 0.1),
        points = {
            [1] = vec2(-(width * 0.15) - 0.6, 0.05),
            [2] = vec2((width * 0.15) + 0.6, 0.05),
            [3] = vec2((width * 0.15), -0.05),
            [4] = vec2(-(width * 0.15), -0.05),
        },
        color = 0x524a57,
        is_static = false,
    });
    local bottom_box = Scene:add_polygon({
        position = pos + vec2(0, -(height * 0.1) - 0.05),
        --size = vec2(width * 0.3, 0.1),
        points = {
            [1] = vec2(-(width * 0.15), 0.05),
            [2] = vec2((width * 0.15), 0.05),
            [3] = vec2((width * 0.15) + 0.6, -0.05),
            [4] = vec2(-(width * 0.15) - 0.6, -0.05),
        },
        color = 0x524a57,
        is_static = false,
    });
    top_box:set_friction(0);
    bottom_box:set_friction(0);
    bottom_box:bolt_to(top_box);

    local top_base = Scene:add_box({
        position = pos + vec2(0, (height * 0.1) + 0.15),
        size = vec2((width * 0.3) + 1.2 + 0.2, 0.1),
        color = 0x938a99,
        is_static = false,
    });
    local base = Scene:add_box({
        position = pos + vec2(0, -(height * 0.1) - 0.25),
        size = vec2((width * 0.3) + 1.2 + 0.2, 0.3),
        color = 0x938a99,
        is_static = false,
    });

    top_box:bolt_to(base);
    top_base:bolt_to(base);
    line:bolt_to(base);

    base:add_component({ hash = hash });
    base:send_event("@carroted/bricks/painter/init", {
        distance = (height * 0.2) + 0.05,
        color = color,
    });
end;

return add_painter;