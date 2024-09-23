Scene:reset();

function add_baseplate(pos, color, width)
    local box1 = Scene:add_box({
        position = pos,
        size = vec2(0.3 * width, 0.1),
        is_static = true,
        color = color
    });
    box1:set_friction(0);

    for i=1,width do
        local x = (i - (width / 2)) * 0.3;

        local box2 = Scene:add_box({
            position = pos + vec2(x - 0.15, 0.05),
            size = vec2(0.1, 0.2),
            is_static = true,
            color = color
        });
        box2:set_friction(0);

        box2:bolt_to(box1);
    end;
end;

function add_brick(pos, color, width, height)
    if true then
        local prev = nil;

        for i=1,width do
            local x = (i - (width / 2)) * 0.3;

            local box1 = Scene:add_box({
                position = pos + vec2(x - 0.15, 0.05),
                size = vec2(0.1, (height * 0.1) + 0.1),
                is_static = false,
                color = color
            });

            local polygon1 = Scene:add_polygon({
                position = pos + vec2(x + -0.1 - 0.15, -0.05),
                points = {
                    [1] = vec2(-0.05, (height * 0.05) + 0.05),
                    [2] = vec2(0.05, (height * 0.05) + 0.05),
                    [3] = vec2(0.05, -(height * 0.05)),
                    [4] = vec2(0, -(height * 0.05) - 0.05),
                    [5] = vec2(-0.05, -(height * 0.05) - 0.05),
                },
                color = color,
                is_static = false,
            });

            local polygon2 = Scene:add_polygon({
                position = pos + vec2(x + 0.1 - 0.15, -0.05),
                points = {
                    [1] = vec2(0.05, (height * 0.05) + 0.05),
                    [2] = vec2(-0.05, (height * 0.05) + 0.05),
                    [3] = vec2(-0.05, -(height * 0.05)),
                    [4] = vec2(0, -(height * 0.05) - 0.05),
                    [5] = vec2(0.05, -(height * 0.05) - 0.05),
                },
                color = color,
                is_static = false,
            });

            polygon1:bolt_to(box1);
            polygon2:bolt_to(box1);

            if prev ~= nil then
                box1:bolt_to(prev);
            end;

            prev = box1;
        end;
    else
        local box1 = Scene:add_box({
            position = pos,
            size = vec2(width * 0.3, height * 0.1),
            is_static = false,
            color = color
        });

        for i=1,width do
            local x = (i - (width / 2)) * 0.3;

            local box2 = Scene:add_box({
                position = pos + vec2(x - 0.15, height * 0.05),
                size = vec2(0.1, 0.2),
                is_static = false,
                color = color
            });

            local polygon1 = Scene:add_polygon({
                position = pos + vec2(x + -0.1 - 0.15, -height * 0.05),
                points = {
                    [1] = vec2(-0.05, 0.1),
                    [2] = vec2(0.05, 0.1),
                    [3] = vec2(0.05, -0.05),
                    [4] = vec2(0, -0.1),
                    [5] = vec2(-0.05, -0.1),
                },
                color = color,
                is_static = false,
            });

            local polygon2 = Scene:add_polygon({
                position = pos + vec2(x + 0.1 - 0.15, -height * 0.05),
                points = {
                    [1] = vec2(0.05, 0.1),
                    [2] = vec2(-0.05, 0.1),
                    [3] = vec2(-0.05, -0.05),
                    [4] = vec2(0, -0.1),
                    [5] = vec2(0.05, -0.1),
                },
                color = color,
                is_static = false,
            });

            polygon1:bolt_to(box1);
            polygon2:bolt_to(box1);
            box2:bolt_to(box1);
        end;
    end;
end;

add_brick(vec2(0,-8), 0xb2a5bc, 10, 1);
for i=1,10 do
    add_brick(vec2(0,-7+i), 0xf6be6f, 2, 1);
end;
add_baseplate(vec2(0,-9), 0x8197f6, 100);

for i=1,10 do
    add_brick(vec2(1,-7+i), 0xf66262, 4, 2);
end;

local add_painter = require('./packages/@carroted/bricks/lib/add_painter.lua');
add_painter(vec2(5, -5), 0x73ae3d, 10, 2);

add_painter(vec2(5, -3), 0xf66262, 10, 2);