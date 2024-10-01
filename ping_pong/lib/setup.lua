local function setup(color)
    Scene:reset();
    Scene.background_color = 0x201724;
    Scene.ambient_light_brightness = 0;

    Scene:set_gravity(vec2(0, 0));

    Camera:reset();
    Camera:set_position(vec2(0, 0));

    local wall = Scene:add_box({
        position = vec2(-5.6 / 2, 0),
        size = vec2(0.1, 6.7),
        color = Color:rgba(215,215,215,255),
        is_static = true
    });
    wall:set_friction(0);
    wall:set_restitution(0);
    local wall = Scene:add_box({
        position = vec2(5.6 / 2, 0),
        size = vec2(0.1, 6.7),
        color = Color:rgba(215,215,215,255),
        is_static = true
    });
    wall:set_friction(0);
    wall:set_restitution(0);

    Scene:add_box({
        position = vec2(0, -6.6 / 2),
        size = vec2(5.5, 0.1),
        color = Color:mix(color, Color:hex(0xe0e0e0), 50/255),
        is_static = true
    }):temp_set_collides(false);

    Scene:add_box({
        position = vec2(0, 6.6 / 2),
        size = vec2(5.5, 0.1),
        color = Color:mix(color, Color:hex(0xe0e0e0), 50/255),
        is_static = true
    }):temp_set_collides(false);

    local table = Scene:add_box({
        position = vec2(0, 0),
        size = vec2(5.5, 6.5),
        color = Color:hex(color),
        is_static = true,
    });

    table:temp_set_collides(false);

    Scene:add_box({
        position = vec2(0, 0),
        size = vec2(0.03, 6.5),
        color = Color:rgba(224,224,224,50),
        is_static = true,
    }):temp_set_collides(false);

    Scene:add_box({
        position = vec2(0, 0),
        size = vec2(5.5, 0.1),
        color = Color:rgba(215,215,215,255),
        is_static = true,
    }):temp_set_collides(false);

    Scene:add_box({
        position = vec2(0, 1.7),
        size = vec2(5.5, 0.6),
        color =  Color:mix(color, Color:hex(0xe0e0e0), 50/255),
        is_static = true,
    }):temp_set_collides(false);
    Scene:add_box({
        position = vec2(0, -1.7),
        size = vec2(5.5, 0.6),
        color =  Color:mix(color, Color:hex(0xe0e0e0), 50/255),
        is_static = true,
    }):temp_set_collides(false);

    local paddle_1 = Scene:add_box({
        position = vec2(0, -3),
        size = vec2(1, 0.1),
        color = Color:hex(0xe04f4f),
        is_static = false,
    });

    paddle_1:set_body_type(BodyType.Kinematic);

    local paddle_2 = Scene:add_box({
        position = vec2(0, 3),
        size = vec2(1, 0.1),
        color = Color:hex(0x1a1a1a),
        is_static = false,
    });

    paddle_2:set_body_type(BodyType.Kinematic);

    local hash = Scene:add_component({
        name = "Computer Paddle",
        id = "@carroted/ping_pong/computer",
        version = "0.1.0",
        code = require('./packages/@carroted/ping_pong/lib/computer.lua', 'string')
    });

    paddle_2:add_component(hash);

    local ball = Scene:add_circle({
        position = vec2(0, 0),
        radius = 0.1,
        color = Color:hex(0xffb36b),
        is_static = false,
    });

    ball:set_linear_velocity(vec2(0, 3));

    ball:set_is_bullet(true);

    ball:set_restitution(1.1);
    paddle_1:set_restitution(0);
    paddle_2:set_restitution(0);

    ball:set_friction(1);
    paddle_1:set_friction(1);
    paddle_2:set_friction(1);

    paddle_2:send_event("@carroted/ping_pong/ball", {
        guid = ball.guid,
    });

    return paddle_1;
end;

return setup;