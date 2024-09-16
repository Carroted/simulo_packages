local function spawn_enemy(spawn_offset)
    local enemy_main = Scene:add_polygon({
        points = {
            [1] = vec2(-1.4 * 0.0625, 1),
            [2] = vec2(1.4 * 0.0625, 1),
            [3] = vec2(-0.5 + (2.1 * 0.0625), 2.6 * 0.0625),
            [4] = vec2(0.5 - (2.1 * 0.0625), 2.6 * 0.0625),
        },
        color = Color:hex(0xc7c7c7),
        is_static = false,
        position = vec2(0, -10) + spawn_offset,
    });

    local enemy_base = Scene:add_box({
        position = vec2(0, -10 + (0.0625 * 2.6 * 0.5)) + spawn_offset,
        size = vec2(1 - 0.0625, 2.6 * 0.0625),
        color = Color:hex(0x535054),
        is_static = false,
    });

    enemy_base:bolt_to(enemy_main);

    local visor = Scene:add_polygon({
        points = {
            [1] = vec2(-2.9 * 0.0625, 2.1 * 0.0625),
            [2] = vec2(2.9 * 0.0625, 2.1 * 0.0625),
            [3] = vec2(4.3 * 0.0625, -2.1 * 0.0625),
            [4] = vec2(-4.3 * 0.0625, -2.1 * 0.0625),
        },
        color = Color:hex(0xc56c43),
        is_static = false,
        position = vec2(0, -10 + (10 * 0.0625)) + spawn_offset,
    });

    visor:bolt_to(enemy_main);

    local weapon_1 = Scene:add_polygon({
        points = {
            [1] = vec2(-5.5 * 0.0625, 1.2 * 0.0625),
            [2] = vec2(8.5 * 0.0625, 1.2 * 0.0625),
            [3] = vec2(8.5 * 0.0625, -1.2 * 0.0625),
            [4] = vec2(-5.5 * 0.0625, -1.2 * 0.0625),
        },
        color = Color:hex(0x2f2e30),
        is_static = false,
        position = vec2(0, -10 + (5.8 * 0.0625)) + spawn_offset,
        name = "enemy_weapon_1"
    });

    local weapon_2 = Scene:add_polygon({
        points = {
            [1] = vec2(8.5 * 0.0625, 1.2 * 0.0625),
            [2] = vec2(12.1 * 0.0625, 1.2 * 0.0625),
            [3] = vec2(12.1 * 0.0625, -1.2 * 0.0625),
            [4] = vec2(8.5 * 0.0625, -1.2 * 0.0625),
        },
        color = Color:hex(0x1d1c1d),
        is_static = false,
        position = vec2(0, -10 + (5.8 * 0.0625)) + spawn_offset,
        name = "enemy_weapon_2"
    });

    local weapon_3 = Scene:add_circle({
        position = vec2(0, -10 + (5.8 * 0.0625)) + spawn_offset,
        radius = 1.6 * 0.0625 * 0.4,
        color = Color:hex(0x1d1c1d),
        is_static = false,
        name = "enemy_weapon_3"
    });

    weapon_1:temp_set_collides(false);
    weapon_2:temp_set_collides(false);
    weapon_3:temp_set_collides(false);

    weapon_2:bolt_to(weapon_1);
    weapon_3:bolt_to(weapon_1);

    Scene:add_hinge_at_world_point({
        point = vec2(0, -10 + (5.8 * 0.0625)) + spawn_offset,
        object_a = weapon_1,
        object_b = enemy_main,
        motor_enabled = true,
        motor_speed = 0, -- radians per second
        max_motor_torque = 1.25, -- maximum torque for the motor, in newton-meters
    });

    weapon_1:set_angle(-0.38945937156677246);

    local hash = Scene:add_component({
        name = "Enemy",
        id = "@carroted/pylon/enemy",
        version = "0.1.0",
        code = require('./packages/@carroted/pylon/lib/enemy.lua', 'string')
    });

    enemy_main:add_component(hash);
    enemy_main:send_event("@carroted/pylon/objects", {
        weapon = weapon_2.guid,
    });

    --[[Scene:add_attachment({
        name = "Point Light",
        component = {
            name = "Point Light",
            code = nil,
        },
        parent = enemy_main,
        local_position = vec2(0.5, 0),
        local_angle = 0,
        image = "./packages/core/assets/textures/point_light.png",
        size = 0.001,
        color = Color:rgba(0,0,0,0),
        light = {
            color = 0xffffff,
            intensity = 1,
            radius = 10,
        }
    });]]
end;

return spawn_enemy;