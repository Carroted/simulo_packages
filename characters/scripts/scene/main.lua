Scene:reset();

function spawn_mike(position)
    local hash = Scene:add_component({
        name = "Mike Arm",
        id = "@carroted/characters/mike_arm",
        version = "0.1.0",
        code = require('./packages/@carroted/characters/lib/mike_arm.lua', 'string')
    });

    Scene:add_simulon({
        color = Color:hex(0xd4af7b),
        size = 1,
        density = 1,
        position = position,
    });

    local objs = Scene:get_all_objects();

    local head = nil;
    local body = nil;
    for i=1,#objs do
        local obj = objs[i];
        if obj:get_name() == "Simulon Head" then
            head = obj;
        end;
        if obj:get_name() == "Simulon Body Part 1" then
            body = obj;
        end;
    end;

    local eye1 = Scene:add_circle({
        color = Color:hex(0x3b2b1f),
        radius = 0.05,
        position = position + vec2(-0.054, 0.67),
        is_static = false, 
    });
    eye1:set_density(0.1);

    local eye2 = Scene:add_circle({
        color = Color:hex(0x3b2b1f),
        radius = 0.05,
        position = position + vec2(0.128, 0.67),
        is_static = false,
    });
    eye2:set_density(0.1);

    eye1:bolt_to(head);
    eye2:bolt_to(head);

    local capsule1 = Scene:add_capsule({
        color = Color:hex(0x6f6773),
        radius = 0.061,
        position = position,
        local_point_a = vec2(0.172, 0.284),
        local_point_b = vec2(0.59225, 0.284),
        is_static = false,
    });
    local hinge1 = Scene:add_hinge_at_world_point({
        point = position + vec2(0.172, 0.284),
        object_a = body,
        object_b = capsule1,
        motor_enabled = true,
        motor_speed = 0, -- radians per second
        max_motor_torque = 1.25, -- maximum torque for the motor, in newton-meters
    });
    local capsule2 = Scene:add_capsule({
        color = Color:hex(0x584f5c),
        radius = 0.061,
        position = position,
        local_point_a = vec2(0.59225, 0.284),
        local_point_b = vec2(1.0125, 0.284),
        is_static = false,
    });
    local hinge2 = Scene:add_hinge_at_world_point({
        point = position + vec2(0.59225, 0.284),
        object_a = capsule1,
        object_b = capsule2,
        motor_enabled = true,
        motor_speed = 0, -- radians per second
        max_motor_torque = 1.25, -- maximum torque for the motor, in newton-meters
    });
    local polygon1 = Scene:add_polygon({
        color = Color:hex(0x423847),
        radius = 0,
        position = position + vec2(1.0985 - 0.04, 0.284),
        points = {
            vec2(-0.1, 0.08655154019),
            vec2(0.13, 0.08655154019),
            vec2(0.13 + 0.0966, 0.03),
            vec2(0.13 + 0.0966, -0.03),
            vec2(0.13, -0.08655154019),
            vec2(-0.1, -0.08655154019),
        },
        is_static = false,
    });
    local hinge3 = Scene:add_hinge_at_world_point({
        point = position + vec2(1.0125, 0.284),
        object_a = capsule2,
        object_b = polygon1,
        motor_enabled = true,
        motor_speed = 0, -- radians per second
        max_motor_torque = 1.25, -- maximum torque for the motor, in newton-meters
    });
    local end_box = Scene:add_box({
        size = vec2(0.3266, 0.17310308038),
        position = position + vec2(1.3518, 0.284),
        color = Color:hex(0x423847),
        is_static = false,
    });
    end_box:add_component(hash);

    local hinge4 = Scene:add_hinge_at_world_point({
        point = position + vec2(1.27015, 0.284),
        object_a = polygon1,
        object_b = end_box,
        motor_enabled = true,
        motor_speed = 0, -- radians per second
        max_motor_torque = 1.25, -- maximum torque for the motor, in newton-meters
    });
end;

spawn_mike(vec2(0, -9.7));

function generate_polygon_points(n, size)
    local points = {}
    for i = 0, n - 1 do
        local angle = (2 * math.pi / n) * i
        table.insert(points, vec2(size * math.cos(angle), size * math.sin(angle)))
    end
    return points
end

function add_hexagon(table)
    local hexagon_points = generate_polygon_points(6, table.size);

    local radius = table.radius;
    if table.radius == nil then
        radius = 0;
    end;

    return Scene:add_polygon({
        position = table.position,
        points = hexagon_points,
        color = table.color,
        is_static = table.is_static,
        radius = radius,
    });
end;

function add_empire_icon(position, size, color)
    local gap = 0.2 * size;
    local hexagons = {};
    local hex = add_hexagon({
        position = position,
        size = size,
        color = color,
    });
    table.insert(hexagons, hex);
    local hex = add_hexagon({
        position = position - vec2(0, (size * 1.8) + gap),
        size = size,
        color = color,
    });
    table.insert(hexagons, hex);
    local hex = add_hexagon({
        position = position + vec2(0, (size * 1.8) + gap),
        size = size,
        color = color,
    });
    table.insert(hexagons, hex);
    local hex = add_hexagon({
        position = position + vec2((size + gap) * 1.47, ((size * 1.8) + gap) / 2),
        size = size,
        color = color,
    });
    table.insert(hexagons, hex);
    local hex = add_hexagon({
        position = position - vec2((size + gap) * 1.47, ((size * 1.8) + gap) / 2),
        size = size,
        color = color,
    });
    table.insert(hexagons, hex);
    local hex = add_hexagon({
        position = position - vec2((size + gap) * 1.47, -((size * 1.8) + gap) / 2),
        size = size,
        color = color,
    });
    table.insert(hexagons, hex);
    local hex = add_hexagon({
        position = position + vec2((size + gap) * 1.47, -((size * 1.8) + gap) / 2),
        size = size,
        color = color,
    });
    table.insert(hexagons, hex);
    return hexagons;
end;

function spawn_moderizer(position)
    Scene:add_simulon({
        color = Color:hex(0xe55f50),
        size = 1,
        density = 1,
        position = position,
    });

    local objs = Scene:get_all_objects();

    local head = nil;
    local body = nil;
    for i=1,#objs do
        local obj = objs[i];
        if (obj:get_color().r == 229 and obj:get_color().g == 95 and obj:get_color().b == 80) and (obj:get_name() == "Simulon Head") then
            head = obj;
        end;
        if (obj:get_color().r == 229 and obj:get_color().g == 95 and obj:get_color().b == 80) and (obj:get_name() == "Simulon Body Part 1") then
            body = obj;
        end;
    end;

    local eye1 = Scene:add_circle({
        color = Color:hex(0x5e2a28),
        radius = 0.053,
        position = position + vec2(-0.102, 0.6707),
        is_static = false, 
    });
    eye1:set_density(0.1);

    local eye2 = Scene:add_circle({
        color = Color:hex(0x5e2a28),
        radius = 0.053,
        position = position + vec2(0.102, 0.6707),
        is_static = false,
    });
    eye2:set_density(0.1);

    eye1:bolt_to(head);
    eye2:bolt_to(head);

    local hexagons = add_empire_icon(position + vec2(-0.115, 0.175), 0.032, Color:hex(0x96352b));
    for i=1,#hexagons do
        hexagons[i]:bolt_to(body);
    end;
end;

spawn_moderizer(vec2(4, -9.7));

function spawn_emperor(position)
    Scene:add_simulon({
        color = Color:hex(0xe07641),
        size = 1.536,
        density = 1,
        position = position,
    });

    local objs = Scene:get_all_objects();

    local head = nil;
    local body = nil;
    for i=1,#objs do
        local obj = objs[i];
        if (obj:get_color().r == 224 and obj:get_color().g == 118 and obj:get_color().b == 65) and (obj:get_name() == "Simulon Head") then
            head = obj;
        end;
        if (obj:get_color().r == 224 and obj:get_color().g == 118 and obj:get_color().b == 65) and (obj:get_name() == "Simulon Body Part 1") then
            body = obj;
        end;
    end;

    local hexagons = add_empire_icon(head:get_position(), 0.088, Color:hex(0xb85b37));
    for i=1,#hexagons do
        hexagons[i]:set_density(0.1);
        hexagons[i]:bolt_to(head);
    end;
    print("did it for " .. tostring(#hexagons) .. " hexagons");

    local armor_color = Color:hex(0x565059);

    local right_part1 = Scene:add_capsule({
        position = position,
        local_point_a = vec2(0.48, 1.085),
        local_point_b = vec2(0.48, 1.7),
        color = armor_color,
        is_static = false,
        radius = 0.075,
    });
    right_part1:bolt_to(body);
    local part2 = Scene:add_capsule({
        position = position,
        local_point_a = vec2(0.48, 1.7),
        local_point_b = vec2(0.38, 1.92),
        color = armor_color,
        is_static = false,
        radius = 0.075,
    });
    part2:bolt_to(body);
    local part3 = Scene:add_capsule({
        position = position,
        local_point_a = vec2(0.38, 1.92),
        local_point_b = vec2(0.36, 1.94),
        color = armor_color,
        is_static = false,
        radius = 0.075,
    });

    part3:bolt_to(body);

    Scene:add_hinge_at_world_point({
        object_a = part3,
        object_b = Scene:add_circle({
            position = position + vec2(0.36, 1.94),
            color = Color:rgba(0,0,0,0),
            is_static = false,
            radius = 0.075,
        }),
        point = position + vec2(0.36, 1.94),
        motor_enabled = true,
        motor_speed = 0, -- radians per second
        max_motor_torque = 1.25,
    });

    local left_part1 = Scene:add_capsule({
        position = position,
        local_point_a = vec2(-0.48, 1.085),
        local_point_b = vec2(-0.48, 1.7),
        color = armor_color,
        is_static = false,
        radius = 0.075,
    });
    left_part1:bolt_to(body);
    local part2 = Scene:add_capsule({
        position = position,
        local_point_a = vec2(-0.48, 1.7),
        local_point_b = vec2(-0.38, 1.92),
        color = armor_color,
        is_static = false,
        radius = 0.075,
    });
    part2:bolt_to(body);
    local part3 = Scene:add_capsule({
        position = position,
        local_point_a = vec2(-0.38, 1.92),
        local_point_b = vec2(-0.36, 1.94),
        color = armor_color,
        is_static = false,
        radius = 0.075,
    });

    part3:bolt_to(body);

    Scene:add_hinge_at_world_point({
        object_a = part3,
        object_b = Scene:add_circle({
            position = position + vec2(-0.36, 1.94),
            color = Color:rgba(0,0,0,0),
            is_static = false,
            radius = 0.075,
        }),
        point = position + vec2(-0.36, 1.94),
        motor_enabled = true,
        motor_speed = 0, -- radians per second
        max_motor_torque = 1.25,
    });

    local right_laser_box = Scene:add_box({
        position = position + vec2(0.13 + 0.48, 0.19 + 1.3925),
        size = vec2(0.47, 252 * (0.47 / 512)),
        color = Color:rgba(0,0,0,0),
        is_static = false,
    });

    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = nil,
        },
        parent = right_laser_box,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/@carroted/characters/assets/emperor_laser.png",
        size = 0.47 / 512,
        color = Color:hex(0xffffff),
    });

    right_laser_box:bolt_to(right_part1);

    local hash = Scene:add_component({
        name = "Emperor Laser",
        id = "@carroted/characters/emperor_laser",
        version = "0.1.0",
        code = require('./packages/@carroted/characters/lib/emperor_laser.lua', 'string')
    });

    right_laser_box:add_component(hash);

    local left_laser_box = Scene:add_box({
        position = position + vec2(-0.13 - 0.48, 0.19 + 1.3925),
        size = vec2(0.47, 252 * (0.47 / 512)),
        color = Color:rgba(0,0,0,0),
        is_static = false,
    });

    left_laser_box:set_angle(math.rad(180));
    left_laser_box:bolt_to(left_part1);

    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = nil,
        },
        parent = left_laser_box,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/@carroted/characters/assets/emperor_laser.png",
        size = 0.47 / 512,
        color = Color:hex(0xffffff),
    });

    --left_laser_box:bolt_to(left_part1);

    local hash = Scene:add_component({
        name = "Emperor Laser",
        id = "@carroted/characters/emperor_laser",
        version = "0.1.0",
        code = require('./packages/@carroted/characters/lib/emperor_laser.lua', 'string')
    });

    left_laser_box:add_component(hash);
end;

spawn_emperor(vec2(6, -10.9));

function climbable_generator(position, height)
    local block_height = 0.5;
    local y = position.y;
    local colors = {
        Color:hex(0xa0a0a0),
        Color:hex(0xc0c0c0),
    };
    local light_number = 0;
    local light_colors = {
        Color:hex(0xff8080),
        Color:hex(0x80ff80),
        Color:hex(0x8080ff),
    }

    for i=1,height do
        Scene:add_box({
            position = vec2(position.x, y),
            size = vec2(0.1, block_height),
            is_static = true,
            color = colors[(i % 2) + 1]
        });
        if i % 25 == 0 then 
            Scene:add_box({
                position = vec2(position.x - 10, y),
                size = vec2(0.1, block_height),
                is_static = true,
                color = light_colors[(light_number % 3) + 1],
                name = "Light"
            });
            light_number += 1;
        end;
        y += block_height;
    end;
end;

climbable_generator(vec2(80, -9), 100);

--[[
local weapon_item = Scene:add_box({
    position = vec2(44, 0.5) / 2,
    size = vec2(0.7, 0.1),
    color = 0xffffff,
    is_static = false,
    name = "Weapon 1"
});]]
--[[
local detacher = Scene:add_polygon({
    points = {
        [1] = vec2(-2, 0),
        [2] = vec2(2, 0.5),
        [3] = vec2(2, -0.5),
    },
    color = 0x000000,
    is_static = false,
    position = vec2(10, 0),
});
local hash = Scene:add_component({
    name = "detacher",
    id = "@carroted/characters/detacher",
    version = "0.1.0",
    code = require('./packages/@carroted/characters/lib/detacher.lua', 'string')
});

detacher:add_component(hash);

local attacher = Scene:add_polygon({
    points = {
        [1] = vec2(-2, 0),
        [2] = vec2(2, 0.5),
        [3] = vec2(2, -0.5),
    },
    color = 0xffffff,
    is_static = false,
    position = vec2(20, 0),
});
local hash = Scene:add_component({
    name = "attacher",
    id = "@carroted/characters/attacher",
    version = "0.1.0",
    code = require('./packages/@carroted/characters/lib/attacher.lua', 'string')
});

attacher:add_component(hash);]]

-- hiiii

--[[
local image = temp_load_image('./packages/@carroted/characters/weapon.png');

local pixel_size = 1 / 12;
local half_width = (image.width / 2) * pixel_size;
local half_height = (image.height / 2) * pixel_size;

local base = Scene:add_circle({
    position = vec2(0, 0),
    radius = pixel_size,
    is_static = false,
    color = Color:rgba(0, 0, 0, 0),
});

for x=0,(image.width - 1) do
    for y=0,(image.height - 1) do
        local pixel = image:get_pixel(vec2(x, y));

        if pixel.a > 0 then
            local box = Scene:add_box({
                position = vec2((x * pixel_size) - half_width + (pixel_size * 0.5), -(y * pixel_size) + half_height - (pixel_size * 0.5)),
                size = vec2(pixel_size, pixel_size),
                is_static = false,
                color = Color:rgba(pixel.r, pixel.g, pixel.b, pixel.a),
                name = "Pixel"
            });

            box:bolt_to(base);
        end;
    end;
end;]]
--[[
local cannibal = Scene:add_simulon({
    color = 0x8e8371,
    size = 1,
    density = 1,
    position = vec2(-10, 0),
});

local objs = Scene:get_all_objects();

local head = nil;
for i=1,#objs do
    local obj = objs[i];
    if (obj:get_name() == "Simulon Head") and (obj:get_color().r == 142) and (obj:get_color().g == 131) and (obj:get_color().b == 113) then
        head = obj;
    end;
end;
local hash = Scene:add_component({
    name = "cannibal",
    id = "@carroted/characters/cannibal",
    version = "0.1.0",
    code = require('./packages/@carroted/characters/lib/cannibal.lua', 'string')
});

head:add_component(hash);]]

local hammer_1 = Scene:add_box({
    position = vec2(30, 0),
    size = vec2(3, 0.15),
    is_static = false,
    color = 0x98684f,
    name = "hammer_1"
});

local hammer_2 = Scene:add_box({
    position = vec2(31.5, 0),
    size = vec2(0.5, 1),
    is_static = false,
    color = 0xb6abbd,
    name = "hammer_2"
});

hammer_2:bolt_to(hammer_1);

local hash = Scene:add_component({
    name = "hammer",
    id = "@carroted/characters/hammer",
    version = "0.1.0",
    code = require('./packages/@carroted/characters/lib/hammer.lua', 'string')
});

hammer_2:add_component(hash);

--[[
local nuke = Scene:add_box({
    color = 0x565d44,
    position = vec2(40, 0),
    size = vec2(2, 0.9),
    is_static = false,
});

local hash = Scene:add_component({
    name = "nuke",
    id = "@carroted/characters/nuke",
    version = "0.1.0",
    code = require('./packages/@carroted/characters/lib/nuke.lua', 'string')
});

nuke:add_component(hash);]]

local spawn_pylon = require('./packages/@carroted/pylon/lib/spawn.lua');

spawn_pylon(vec2(-2, 0));

local mike_axe_width = 641;
local mike_axe_height = 1251;
local mike_axe_size = 0.75;

local mike_axe = Scene:add_box({
    position = vec2(-5, 0),
    size = vec2(0.14, mike_axe_height * (mike_axe_size / mike_axe_width)),
    color = Color:rgba(0,0,0,0),
    is_static = false,
});

Scene:add_attachment({
    name = "Image",
    component = {
        name = "Image",
        code = nil,
    },
    parent = mike_axe,
    local_position = vec2(0.07, 0),
    local_angle = 0,
    image = "./packages/@carroted/characters/assets/mike_axe.png",
    size = mike_axe_size / mike_axe_width,
    color = Color:hex(0xffffff),
});

local bottle_width = 679;
local bottle_height = 1500;
local bottle_size = 0.2;

local bottle = Scene:add_box({
    position = vec2(-5, 0),
    size = vec2(bottle_size, bottle_height * (bottle_size / bottle_width)),
    color = Color:rgba(0,0,0,0),
    is_static = false,
});

Scene:add_attachment({
    name = "Image",
    component = {
        name = "Image",
        code = nil,
    },
    parent = bottle,
    local_position = vec2(0, 0),
    local_angle = 0,
    image = "./packages/@carroted/characters/assets/water_bottle.png",
    size = bottle_size / bottle_width,
    color = Color:hex(0xffffff),
});