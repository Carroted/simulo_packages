local setup = require('@carroted/ping_pong/lib/setup.lua');

local paddle_1 = setup(0x3f6d46);

local hash = Scene:add_component_def({
    name = "Player Paddle",
    id = "@carroted/ping_pong/player",
    version = "0.1.0",
    code = require('@carroted/ping_pong/lib/player_drag.lua', 'string'),
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
    local_position = vec2(7 / 2, -8 / 2),
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
Scene:add_attachment({
    name = "Point Light",
    component = {
        name = "Point Light",
        version = "0.1.0",
        id = "wanda",
        code = "",
    },
    parent = light_parent,
    local_position = vec2(-7 / 2, 8 / 2),
    local_angle = 0,
    lights = {{
        color = 0xffffff,
        intensity = 2,
        radius = 8,
    }},
    collider = { shape_type = "circle", radius = 0.1, }
});

Scene:set_background_color(0x1f2621);

paddle_1:set_collision_layers({1, 2});

local box = Scene:add_box({
    position = vec2(0, 0.45),
    size = vec2(5.5, 1),
    color = Color:rgba(255,0,0,0),
    body_type = BodyType.Static,
    collision_layers = {2},
    restitution = 0,
    friction = 0,
});

local box = Scene:add_box({
    position = vec2(0, -0.5 - 3.25 - 0.1),
    size = vec2(5.7, 1),
    color = Color:rgba(255,0,0,0),
    body_type = BodyType.Static,
    collision_layers = {2},
    restitution = 0,
    friction = 0,
});
