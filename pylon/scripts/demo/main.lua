local ground = Scene:reset();
ground:set_color(0x2b282d);
ground:set_friction(1);
ground:set_restitution(0);

Scene.background_color = 0x09080a;

Scene.ambient_light_brightness = 0;

--[[
Scene:add_box({
    position = vec2(1, -10 + 0.5),
    size = vec2(0.1, 1),
    color = 0xffa0a0,
    is_static = true
});

Scene:add_box({
    position = vec2(0, -10 + 0.5),
    size = vec2(1, 1),
    color = Color:rgba(255,255,255,2),
    is_static = true
}):temp_set_collides(false);

Scene:add_box({
    position = vec2(0, -10 + 0.5),
    size = vec2(0.01, 1),
    color = Color:rgba(255,255,255,5),
    is_static = true
}):temp_set_collides(false);

Scene:add_box({
    position = vec2(0, -10 + 0.5),
    size = vec2(1, 0.01),
    color = Color:rgba(255,255,255,5),
    is_static = true
}):temp_set_collides(false);

]]


local wall = Scene:add_box({
    position = vec2(10 + 8, -10 + 2),
    size = vec2(16, 4),
    color = Color:hex(0x1f1e20),
    is_static = true,
});

wall:temp_set_collides(false);

local floor = Scene:add_box({
    position = vec2(10 + 8, -10 - 0.05),
    size = vec2(16 + 0.5, 0.1),
    color = Color:hex(0x403f42),
    is_static = true,
});

local door = Scene:add_box({
    position = vec2(10, -10 + (2 / 2)),
    size = vec2(0.3, 2),
    color = Color:hex(0x6d6b70),
    is_static = true,
});

local hash = Scene:add_component({
    name = "Door",
    id = "@carroted/pylon/door",
    version = "0.1.0",
    code = require('./packages/@carroted/pylon/lib/door.lua', 'string')
});

door:add_component(hash);

local door2 = Scene:add_box({
    position = vec2(10 + 4, -10 + (2 / 2)),
    size = vec2(0.3, 2),
    color = Color:hex(0x6d6b70),
    is_static = true,
});

door2:add_component(hash);

Scene:add_box({
    position = vec2(10 + 4, -10 + 2 + 1),
    size = vec2(0.5, 2),
    color = Color:hex(0x545256),
    is_static = true,
});

local door3 = Scene:add_box({
    position = vec2(10 + 16, -10 + (2 / 2)),
    size = vec2(0.3, 2),
    color = Color:hex(0x6d6b70),
    is_static = true,
});

local box = Scene:add_box({
    position = vec2(10, -10 + 2 + 1),
    size = vec2(0.5, 2),
    color = Color:hex(0x545256),
    is_static = true,
});

local box2 = Scene:add_box({
    position = vec2(10 + 8, -10 + 2 + 2 + 0.25),
    size = vec2(16 + 0.5, 0.5),
    color = Color:hex(0x545256),
    is_static = true,
});

local box3 = Scene:add_box({
    position = vec2(10 + 16, -10 + 2 + 1),
    size = vec2(0.5, 2),
    color = Color:hex(0x545256),
    is_static = true,
});

function spawn_light_box(pos)
    local light_box = Scene:add_box({
        position = pos,
        size = vec2(0.25, 0.5),
        is_static = true,
        color = 0xffffff,
    });
    Scene:add_box({
        position = pos + vec2(0, 0.25 + 0.05),
        size = vec2(0.25, 0.1),
        is_static = true,
        color = 0x3d3b3e,
    });
    Scene:add_box({
        position = pos + vec2(0, -0.25 - 0.05),
        size = vec2(0.25, 0.1),
        is_static = true,
        color = 0x3d3b3e,
    });

    Scene:add_attachment({
        name = "Point Light",
        component = {
            name = "Point Light",
            code = nil,
        },
        parent = light_box,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/core/assets/textures/point_light.png",
        size = 0.001,
        color = Color:rgba(0,0,0,0),
        light = {
            color = 0xff7029,
            intensity = 3,
            radius = 5,
        }
    });

    Scene:add_attachment({
        name = "Point Light",
        component = {
            name = "Point Light",
            code = nil,
        },
        parent = light_box,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/core/assets/textures/point_light.png",
        size = 0.001,
        color = Color:rgba(0,0,0,0),
        light = {
            color = 0xff7029,
            intensity = 5,
            radius = 2,
        }
    });
end;

spawn_light_box(vec2(10 - 0.25 - 0.125, -10 + 2 + 1.5));

spawn_light_box(vec2(10 + 16 + 0.25 + 0.125, -10 + 2 + 1.5));

function spawn_indoors_light(pos, color)
    if color == nil then
        color = 0xffffff;
    end;

    local bg_circle = Scene:add_circle({
        position = pos,
        radius = 0.16,
        is_static = true,
        color = 0x3d3b3e,
    });
    bg_circle:temp_set_collides(false);

    local light_circle = Scene:add_circle({
        position = pos,
        radius = 0.1,
        is_static = true,
        color = 0xffffff,
    });
    light_circle:temp_set_collides(false);

    Scene:add_attachment({
        name = "Point Light",
        component = {
            name = "Point Light",
            code = nil,
        },
        parent = light_circle,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/core/assets/textures/point_light.png",
        size = 0.001,
        color = Color:rgba(0,0,0,0),
        light = {
            color = color,
            intensity = 3,
            radius = 5,
        }
    });

    Scene:add_attachment({
        name = "Point Light",
        component = {
            name = "Point Light",
            code = nil,
        },
        parent = light_circle,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/core/assets/textures/point_light.png",
        size = 0.001,
        color = Color:rgba(0,0,0,0),
        light = {
            color = color,
            intensity = 3,
            radius = 1,
        }
    });

    Scene:add_attachment({
        name = "Point Light",
        component = {
            name = "Point Light",
            code = nil,
        },
        parent = light_circle,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/core/assets/textures/point_light.png",
        size = 0.001,
        color = Color:rgba(0,0,0,0),
        light = {
            color = color,
            intensity = 3,
            radius = 0.5
        }
    });
end;

spawn_indoors_light(vec2(10+2, -10+2+1.5), 0xff7029);

spawn_indoors_light(vec2(10+8, -10+2+1.5));
spawn_indoors_light(vec2(10+12, -10+2+1.5));

local spawn_pylon = require('./packages/@carroted/pylon/lib/spawn.lua');

spawn_pylon(vec2(20, 0), false, true);

local spawn_enemy = require('./packages/@carroted/pylon/lib/spawn_enemy.lua');

spawn_enemy(vec2(2, 0));
spawn_enemy(vec2(0, 0));
spawn_enemy(vec2(-2, 0));
spawn_enemy(vec2(-3.1, 0));