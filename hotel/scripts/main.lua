Scene:reset():destroy();

local ground_pos = vec2(0, -60)
local ground_size = vec2(1000, 100)
local basement_pos = vec2(7.1, -10)
local basement_size = vec2(21, 3.7)

local ground_part_width = ground_size.x - basement_size.x
local ground_part_height = ground_size.y - basement_size.y

-- adjust the positions based on basement_pos.x
local ground_1 = Scene:add_box({
    position = vec2(-ground_part_width / 4 + basement_pos.x - (basement_size.x / 2), ground_pos.y),
    size = vec2(ground_part_width / 2, ground_size.y),
    color = 0xb9a1c4,
    is_static = true,
})

local ground_2 = Scene:add_box({
    position = vec2(ground_part_width / 4 + basement_pos.x + (basement_size.x / 2), ground_pos.y),
    size = vec2(ground_part_width / 2, ground_size.y),
    color = 0xb9a1c4,
    is_static = true,
})

local ground_3 = Scene:add_box({
    position = vec2(basement_pos.x, ground_pos.y - (basement_size.y / 2)),
    size = vec2(ground_size.x, ground_size.y - basement_size.y),
    color = 0xb9a1c4,
    is_static = true,
})

ground_1:bolt_to(ground_3)
ground_2:bolt_to(ground_3)


Scene.background_color = 0x150a16;

Scene.ambient_light_brightness = 0;

local floor_count = 13;
local elevator_shaft_height = (3.5 * floor_count) + 0.2;

local elevator_shaft = Scene:add_box({
    position = vec2(-(3.2/2/2), -10 + (elevator_shaft_height / 2) - 3.5 - 0.2),
    size = vec2(3.2 + (3.2/2), elevator_shaft_height),
    is_static = true,
    color = 0x2d2a2d,
});
elevator_shaft:temp_set_collides(false);

local shaft_wall_color = Color:hex(0xbfb9c5);
shaft_wall_color.a = 20;

local elevator_shaft_wall = Scene:add_box({
    position = vec2((-3.2/2) - 0.1, -10 + (elevator_shaft_height / 2) - 3.5 - 0.2),
    size = vec2(0.2, elevator_shaft_height),
    is_static = true,
    color = shaft_wall_color,
});
elevator_shaft_wall:temp_set_collides(false);

local elevator_shaft_wall_2 = Scene:add_box({
    position = vec2((-3.2/2) - 0.1 - (3.2/2), -10 + (elevator_shaft_height / 2) - 3.5 - 0.2),
    size = vec2(0.2, elevator_shaft_height),
    is_static = true,
    color = 0xbfb9c5,
});
for i=1,floor_count do
    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = nil,
        },
        parent = elevator_shaft_wall_2,
        local_position = vec2(0.2, (-elevator_shaft_height / 2) + (i * 3.5) - 1.75 - 0.3),
        local_angle = -math.pi / 2,
        image = "./packages/core/assets/textures/point_light.png",
        size = 1 / 256 / 10,
        color = 0xffba81,
        light = {
            color = 0xff9036,
            intensity = 0.2,
            radius = 1.75,
        }
    });
    local step = Scene:add_box({
        position = elevator_shaft_wall_2:get_world_point(vec2(0.15 + 0.1, (-elevator_shaft_height / 2) + (i * 3.5) - 0.3)),
        size = vec2(0.3, 0.1),
        is_static = true,
        color = 0xbfb9c5,
    });
    step:bolt_to(elevator_shaft_wall_2);

    local step = Scene:add_box({
        position = elevator_shaft_wall_2:get_world_point(vec2(0.1 + (3.2/2) - 0.15, (-elevator_shaft_height / 2) + (i * 3.5) - 0.3 - 1.75)),
        size = vec2(0.3, 0.1),
        is_static = true,
        color = 0xbfb9c5,
    });
    step:bolt_to(elevator_shaft_wall_2);
end;

local elevator_color = Color:hex(0xa5a3a7);

local elevator = Scene:add_box({
    position = vec2(0, 1.75),
    size = vec2(3.2, 3.7),
    is_static = false,
    color = 0x644841,
});
elevator:temp_set_collides(false);

local elevator_bottom = Scene:add_box({
    position = vec2(0, 0.1 + 0.2),
    size = vec2(3.2, 0.4),
    is_static = false,
    color = 0x63585e,
});
elevator_bottom:temp_set_collides(false);
elevator_bottom:bolt_to(elevator);

local panel = Scene:add_capsule({
    position = vec2(-1, 1),
    local_point_a = vec2(0, 0.14),
    local_point_b = vec2(0, -0.14),
    is_static = false,
    color = 0xa5a3a7,
    radius = 0.18,
});

local panel_inner = Scene:add_capsule({
    position = vec2(-1, 1),
    local_point_a = vec2(0, 0.14),
    local_point_b = vec2(0, -0.14),
    is_static = false,
    color = 0x838086,
    radius = (0.165 + 0.125) / 2,
});

local button_1 = Scene:add_attachment({
    name = "Image",
    component = {
        name = "Image",
        code = nil,
    },
    parent = panel,
    local_position = vec2(0, 0.28/2),
    local_angle = 0,
    image = "./packages/@carroted/hotel/assets/elevator.png",
    size = 1 / 256 / 4,
    color = Color:hex(0xffa734),
    light = {
        color = 0xf19b31,
        intensity = 0.7,
        radius = 0.3,
    }
});
local button_2 = Scene:add_attachment({
    name = "Image",
    component = {
        name = "Image",
        code = nil,
    },
    parent = panel,
    local_position = vec2(0, -0.28/2),
    local_angle = 0,
    image = "./packages/@carroted/hotel/assets/elevator.png",
    size = 1 / 256 / 4,
    color = Color:hex(0xffa734),
    flip_y = true,
    light = {
        color = 0xf19b31,
        intensity = 0.7,
        radius = 0.3,
    }
});

panel_inner:temp_set_collides(false);
panel_inner:bolt_to(panel);
panel:temp_set_collides(false);
panel:bolt_to(elevator);

local box1 = Scene:add_box({
    position = vec2(0, 0),
    size = vec2(3.2, 0.2),
    is_static = false,
    color = 0x827e86,
});
local box2 = Scene:add_box({
    position = vec2(1.5, (1.75 * 2) - 0.2),
    size = vec2(0.2, 0.2),
    is_static = false,
    color = elevator_color,
});
local box3 = Scene:add_box({
    position = vec2(-1.5, 1.75),
    size = vec2(0.2, 3.3),
    is_static = false,
    color = 0x827e86,
});
local box4 = Scene:add_box({
    position = vec2(0, 1.75 * 2),
    size = vec2(3.2, 0.2),
    is_static = false,
    color = 0x827e86,
});
local light1 = Scene:add_attachment({
    name = "Image",
    component = {
        name = "Image",
        code = nil,
    },
    parent = box4,
    local_position = vec2(-1, -0.24),
    local_angle = math.pi,
    image = "./packages/core/assets/textures/point_light.png",
    size = 1 / 256 / 7,
    color = 0xffffff,
    light = {
        color = 0xffffff,
        intensity = 0.3,
        radius = 4,
    }
});
local light2 = Scene:add_attachment({
    name = "Image",
    component = {
        name = "Image",
        code = nil,
    },
    parent = box4,
    local_position = vec2(1, -0.24),
    local_angle = math.pi,
    image = "./packages/core/assets/textures/point_light.png",
    size = 1 / 256 / 7,
    color = 0xffffff,
    light = {
        color = 0xffffff,
        intensity = 0.3,
        radius = 4,
    }
});
box1:bolt_to(elevator);
box2:bolt_to(elevator);
box3:bolt_to(elevator);
box4:bolt_to(elevator);

elevator:set_body_type(BodyType.Kinematic);

local hash = Scene:add_component({
    name = "Elevator",
    id = "@carroted/hotel/elevator",
    version = "0.1.0",
    code = require('./packages/@carroted/hotel/lib/elevator.lua', 'string'),
});

elevator:set_position(vec2(0, -10 + 1.75 + 0.1 - 0.2));

local floors = {};

for i=0,(floor_count - 1) do
    local wall = Scene:add_box({
        position = vec2((3.2 / 2) + (3.2 * 5 / 2), -10 + 1.75 + 0.1 + (3.5*i) - 3.5 - 0.2),
        size = vec2(3.2 * 5, 3.3),
        is_static = true,
        color = 0x7b6a5a,
    });
    wall:temp_set_collides(false);

    local floor = Scene:add_box({
        position = vec2((3.2 / 2) + (3.2 * 5 / 2), -10 + 0.1 + (3.5*i) - 3.5 - 0.2),
        size = vec2(3.2 * 5, 0.2),
        is_static = true,
        color = 0xbfb9c5,
    });
    wall:bolt_to(floor);

    local ceiling = nil;
    if i == (floor_count - 1) then
        ceiling = Scene:add_box({
            position = vec2((3.2 / 2) + (3.2 * 5 / 2), -10 + 0.1 + (3.5*(i + 1)) - 3.5 - 0.2),
            size = vec2(3.2 * 5, 0.2),
            is_static = true,
            color = 0xbfb9c5,
        });
        ceiling:bolt_to(floor);
    end;

    local panel = Scene:add_circle({
        position = floor:get_world_point(vec2(-1 - 6.4, 1)),
        is_static = false,
        color = 0xa5a3a7,
        radius = 0.18,
    });

    local panel_inner = Scene:add_circle({
        position = panel:get_position(),
        is_static = false,
        color = 0x838086,
        radius = (0.165 + 0.125) / 2,
    });

    panel_inner:temp_set_collides(false);
    panel_inner:bolt_to(panel);
    panel:temp_set_collides(false);
    panel:bolt_to(floor);

    local button_1 = Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = require("./packages/@carroted/hotel/lib/call.lua", "string"),
        },
        parent = panel,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/@carroted/hotel/assets/call.png",
        size = 1 / 256 / 4,
        color = Color:hex(0xffa734),
        light = {
            color = 0xf19b31,
            intensity = 0.7,
            radius = 0.3,
        },
        saved_data = {
            elevator = elevator,
            floor = i,
        }
    });

    if (i == 0) then
        local box2 = Scene:add_box({
            position = vec2(1.5 + 0.2, -10 + 0.1 + (3.5*i) + 3.3 - 3.5 - 0.2),
            size = vec2(0.2, 0.2),
            is_static = true,
            color = elevator_color,
        });
        table.insert(floors, {
            door = box2,
            height = 0.2,
        });
    else
        local box2 = Scene:add_box({
            position = vec2(1.5 + 0.2, -10 + 0.1 + (3.5*i) + 1.75 - 3.5 - 0.2),
            size = vec2(0.2, 3.3),
            is_static = true,
            color = elevator_color,
        });
        table.insert(floors, {
            door = box2,
            height = 3.3,
        });

        for i=0,3 do
            local atch = {
                name = "Image",
                component = {
                    name = "Image",
                    code = nil,
                },
                parent = floor,
                local_position = vec2(1 - 6.4 + (i*4), -0.24),
                local_angle = math.pi,
                image = "./packages/core/assets/textures/point_light.png",
                size = 1 / 256 / 7,
                color = 0xffffff,
                light = {
                    color = 0xffffff,
                    intensity = 0.8,
                    radius = 8,
                }
            };
            local light = Scene:add_attachment(atch);
            if ceiling ~= nil then
                atch.parent = ceiling;
                Scene:add_attachment(atch);
            end;
        end;
    end;
end;

elevator:add_component({
    hash = hash,
    saved_data = {
        door = box2,
        button_1 = button_1,
        button_2 = button_2,
        state = "idle",
        change = 0,
        height = 0.2,
        target_is_up = false,
        floors = floors,
    },
});