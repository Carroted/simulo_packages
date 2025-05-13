local function setup(color)
    Scene:reset();
    Scene:set_background_color(0x201724);
    Scene:set_ambient_light_intensity(0);

    Scene:set_gravity(vec2(0, 0));

    local wall = Scene:add_box({
        position = vec2(-5.6 / 2, 0),
        size = vec2(0.1, 6.7),
        color = Color:rgba(215,215,215,255),
        body_type = BodyType.Static,
        friction = 0,
        restitution = 0,
    });
    local wall = Scene:add_box({
        position = vec2(5.6 / 2, 0),
        size = vec2(0.1, 6.7),
        color = Color:rgba(215,215,215,255),
        body_type = BodyType.Static,
        friction = 0,
        restitution = 0,
    });

    Scene:add_box({
        position = vec2(0, -6.6 / 2),
        size = vec2(5.5, 0.1),
        color = Color:mix(color, Color:hex(0xe0e0e0), 50/255),
        body_type = BodyType.Static,
        collision_layers = {},
    });

    Scene:add_box({
        position = vec2(0, 6.6 / 2),
        size = vec2(5.5, 0.1),
        color = Color:mix(color, Color:hex(0xe0e0e0), 50/255),
        body_type = BodyType.Static,
        collision_layers = {},
    });

    local table = Scene:add_box({
        position = vec2(0, 0),
        size = vec2(5.5, 6.5),
        color = Color:hex(color),
        body_type = BodyType.Static,
        collision_layers = {},
    });

    Scene:add_box({
        position = vec2(0, 0),
        size = vec2(0.03, 6.5),
        color = Color:rgba(224,224,224,50),
        body_type = BodyType.Static,
        collision_layers = {},
    });

    Scene:add_box({
        position = vec2(0, 0),
        size = vec2(5.5, 0.1),
        color = Color:rgba(215,215,215,255),
        body_type = BodyType.Static,
        collision_layers = {},
    });

    Scene:add_box({
        position = vec2(0, 1.7),
        size = vec2(5.5, 0.6),
        color =  Color:mix(color, Color:hex(0xe0e0e0), 50/255),
        body_type = BodyType.Static,
        collision_layers = {},
    });
    Scene:add_box({
        position = vec2(0, -1.7),
        size = vec2(5.5, 0.6),
        color =  Color:mix(color, Color:hex(0xe0e0e0), 50/255),
        body_type = BodyType.Static,
        collision_layers = {},
    });

    local paddle_1 = Scene:add_box({
        position = vec2(0, -3),
        size = vec2(1, 0.1),
        color = Color:hex(0xe04f4f),
        body_type = BodyType.Kinematic,
        restitution = 0,
        friction = 1,
    });

    local paddle_2 = Scene:add_box({
        position = vec2(0, 3),
        size = vec2(1, 0.1),
        color = Color:hex(0x1a1a1a),
        body_type = BodyType.Kinematic,
        restitution = 0,
        friction = 1,
    });

    local hash = Scene:add_component_def({
        name = "Computer Paddle",
        id = "@carroted/ping_pong/computer",
        version = "0.1.0",
        code = require('./packages/@carroted/ping_pong/lib/computer.lua', 'string'),
        properties = {
            {
                id = "speed",
                name = "Speed",
                input_type = "slider",
                default_value = 3,
                min_value = 0,
                max_value = 10,
            }
        }
    });

    local ball = Scene:add_circle({
        position = vec2(0, 0),
        radius = 0.1,
        color = Color:hex(0xffb36b),
        linear_velocity = vec2(0, 3),
        is_bullet = true,
        restitution = 1.1,
        friction = 1,
    });

    paddle_2:add_component({ hash = hash, saved_data = { ball = ball } });

    paddle_2:send_event("wakey wakey");

    return paddle_1;
end;

return setup;
