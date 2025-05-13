local setup = require('@carroted/ping_pong/lib/setup.lua');

local paddle_1 = setup(0x3c407f);

local hash = Scene:add_component_def({
    name = "Player Paddle",
    id = "@carroted/ping_pong/player",
    version = "0.1.0",
    code = require('@carroted/ping_pong/lib/player_normal.lua', 'string'),
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

paddle_1:add_component({ hash = hash });

local light_parent = Scene:add_circle({
    position = vec2(0,0),
    radius = 1,
    color = Color:rgba(0,0,0,0),
    body_type = BodyType.Static,
    collision_layers = {},
});

Scene:add_attachment({
    name = "Point Light",
    component = {
        name = "Point Light",
        version = "0.1.0",
        id = "wanda",
        code = "",
    },
    parent = light_parent,
    local_position = vec2(-7 / 2, -8 / 2),
    local_angle = 0,
    lights = {{
        color = 0xffffff,
        intensity = 2,
        radius = 8,
    }},
    collider = { shape_type = "circle", radius = 0.1, }
});

Scene:add_attachment({
    name = "Point Light",
    component = {
        name = "Point Light",
        version = "0.1.0",
        id = "wanda",
        code = "",
    },
    parent = light_parent,
    local_position = vec2(7 / 2, 8 / 2),
    local_angle = 0,
    lights = {{
        color = 0xffffff,
        intensity = 2,
        radius = 8,
    }},
    collider = { shape_type = "circle", radius = 0.1, }
});
