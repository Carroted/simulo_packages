local function spawn_pylon(spawn_offset, light, permanent_controller)
    local pylon_main = Scene:add_polygon({
        points = {
            [1] = vec2(-1.4 * 0.0625, 1),
            [2] = vec2(1.4 * 0.0625, 1),
            [3] = vec2(-0.5 + (2.1 * 0.0625), 2.6 * 0.0625),
            [4] = vec2(0.5 - (2.1 * 0.0625), 2.6 * 0.0625),
        },
        color = Color:hex(0x874e32),
        is_static = false,
        position = vec2(0, -10) + spawn_offset,
        name = "Pylon"
    });

    local pylon_base = Scene:add_box({
        position = vec2(0, -10 + (0.0625 * 2.6 * 0.5)) + spawn_offset,
        size = vec2(1 - 0.0625, 2.6 * 0.0625),
        color = Color:hex(0x4e2c2f),
        is_static = false,
        name = "Pylon Base",
    });

    pylon_base:set_friction(1);
    pylon_base:set_restitution(0);

    pylon_base:bolt_to(pylon_main);

    local visor = Scene:add_polygon({
        points = {
            [1] = vec2(-3.2 * 0.0625, 2.1 * 0.0625),
            [2] = vec2(3.2 * 0.0625, 2.1 * 0.0625),
            [3] = vec2(4.6 * 0.0625, -2.1 * 0.0625),
            [4] = vec2(-4.6 * 0.0625, -2.1 * 0.0625),
        },
        color = Color:hex(0x0f0c11),
        is_static = false,
        position = vec2(0, -10 + (10 * 0.0625)) + spawn_offset,
    });

    local visor_border_height = 0.305 * 0.0625;
    local visor_bottom = Scene:add_polygon({
        points = {
            [1] = vec2(-4.6 * 0.0625, -2.1 * 0.0625),
            [2] = vec2(4.6 * 0.0625, -2.1 * 0.0625),
            [3] = vec2(((-0.13125 - visor_border_height) - 0.73125) / 3, -0.13125 - visor_border_height),
            [4] = vec2(-(((-0.13125 - visor_border_height) - 0.73125) / 3), -0.13125 - visor_border_height),
        },
        color = Color:hex(0x6a636e),
        is_static = false,
        position = vec2(0, -10 + (10 * 0.0625)) + spawn_offset,
    });
    local visor_top = Scene:add_polygon({
        points = {
            [1] = vec2(-3.2 * 0.0625, 2.1 * 0.0625),
            [2] = vec2(3.2 * 0.0625, 2.1 * 0.0625),
            [3] = vec2(((0.13125 + visor_border_height) - 0.73125) / 3, 0.13125 + visor_border_height),
            [4] = vec2(-(((0.13125 + visor_border_height) - 0.73125) / 3), 0.13125 + visor_border_height),
        },
        color = Color:hex(0x6a636e),
        is_static = false,
        position = vec2(0, -10 + (10 * 0.0625)) + spawn_offset,
    });

    local eye_color = Color:hex(0xff9a52);
    eye_color.a = 70;

    local left_eye = Scene:add_circle({
        position = vec2(-1.8 * 0.0625, -10 + (10 * 0.0625)) + spawn_offset,
        radius = 1.6 * 0.0625 * 0.5,
        color = eye_color,
        is_static = false,
        name = "Pylon Left Eye",
    });

    Scene:add_attachment({
        name = "Point Light",
        component = {
            name = "Point Light",
            code = nil,
        },
        parent = left_eye,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/core/assets/textures/point_light.png",
        size = 0.001,
        color = Color:rgba(0,0,0,0),
        light = {
            color = Color:hex(0xff9a52),
            intensity = 10,
            radius = 0.15,
        }
    });

    Scene:add_attachment({
        name = "Point Light",
        component = {
            name = "Point Light",
            code = nil,
        },
        parent = left_eye,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/core/assets/textures/point_light.png",
        size = 0.001,
        color = Color:rgba(0,0,0,0),
        light = {
            color = Color:hex(0xff9a52),
            intensity = 0.01,
            radius = 1.5,
        }
    });

    left_eye:bolt_to(visor);

    local right_eye = Scene:add_circle({
        position = vec2(1.8 * 0.0625, -10 + (10 * 0.0625)) + spawn_offset,
        radius = 1.6 * 0.0625 * 0.5,
        color = eye_color,
        is_static = false,
        name = "Pylon Right Eye",
    });

    Scene:add_attachment({
        name = "Point Light",
        component = {
            name = "Point Light",
            code = nil,
        },
        parent = right_eye,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/core/assets/textures/point_light.png",
        size = 0.001,
        color = Color:rgba(0,0,0,0),
        light = {
            color = Color:hex(0xff9a52),
            intensity = 10,
            radius = 0.15,
        }
    });

    Scene:add_attachment({
        name = "Point Light",
        component = {
            name = "Point Light",
            code = nil,
        },
        parent = right_eye,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/core/assets/textures/point_light.png",
        size = 0.001,
        color = Color:rgba(0,0,0,0),
        light = {
            color = Color:hex(0xff9a52),
            intensity = 0.01,
            radius = 1.5,
        }
    });


    right_eye:bolt_to(visor);

    visor_top:bolt_to(visor);
    visor_bottom:bolt_to(visor);
    visor:bolt_to(pylon_main);

    local weapon_1 = Scene:add_polygon({
        points = {
            [1] = vec2(-4.9 * 0.0625, 1.3 * 0.0625),
            [2] = vec2(7.5 * 0.0625, 1.3 * 0.0625),
            [3] = vec2(5 * 0.0625, -1.3 * 0.0625),
            [4] = vec2(-4.9 * 0.0625, -1.3 * 0.0625),
        },
        color = Color:hex(0x403c42),
        is_static = false,
        position = vec2(0, -10 + (5.8 * 0.0625)) + spawn_offset,
        name = "pylon_weapon_1"
    });

    local weapon_2 = Scene:add_polygon({
        points = {
            [1] = vec2(7.5 * 0.0625, 1.3 * 0.0625),
            [2] = vec2(12.1 * 0.0625, 1.3 * 0.0625),
            [3] = vec2(12.1 * 0.0625, -1.3 * 0.0625),
            [4] = vec2(5 * 0.0625, -1.3 * 0.0625),
        },
        color = Color:hex(0x1b191c),
        is_static = false,
        position = vec2(0, -10 + (5.8 * 0.0625)) + spawn_offset,
        name = "pylon_weapon_2"
    });

    local weapon_3 = Scene:add_circle({
        position = vec2(0, -10 + (5.8 * 0.0625)) + spawn_offset,
        radius = 1.6 * 0.0625 * 0.5,
        color = Color:hex(0x1b191c),
        is_static = false,
        name = "pylon_weapon_3"
    });

    weapon_2:bolt_to(weapon_1);
    weapon_3:bolt_to(weapon_1);

    Scene:add_hinge_at_world_point({
        point = vec2(0, -10 + (5.8 * 0.0625)) + spawn_offset,
        object_a = weapon_1,
        object_b = pylon_main,
        motor_enabled = true,
        motor_speed = 0, -- radians per second
        max_motor_torque = 1.25, -- maximum torque for the motor, in newton-meters
    });

    local hash = Scene:add_component({
        name = "Weapon",
        id = "@carroted/pylon/weapon",
        version = "0.1.0",
        code = require('./packages/@carroted/pylon/lib/weapon.lua', 'string')
    });

    weapon_2:add_component(hash);

    weapon_1:set_angle(-0.38945937156677246);

    local hash = Scene:add_component({
        name = "Pylon",
        id = "@carroted/pylon/controller",
        version = "0.1.0",
        code = require('./packages/@carroted/pylon/lib/controller.lua', 'string')
    });

    pylon_main:add_component(hash);
    pylon_main:send_event("@carroted/pylon/objects", {
        left_eye = left_eye.guid,
        right_eye = right_eye.guid,
        weapon = weapon_2.guid,
    });
    if permanent_controller then
        pylon_main:send_event("@carroted/pylon/permanent_controller");
        weapon_2:send_event("@carroted/pylon/permanent_controller");
    end;

    if light then 
        Scene:add_attachment({
            name = "Point Light",
            component = {
                name = "Point Light",
                code = nil,
            },
            parent = pylon_main,
            local_position = vec2(0, 0),
            local_angle = 0,
            image = "./packages/core/assets/textures/point_light.png",
            size = 0.001,
            color = Color:rgba(0,0,0,0),
            light = {
                color = 0xffffff,
                intensity = 0.1,
                radius = 5,
            }
        });
    end;
end;

return spawn_pylon;