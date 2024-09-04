Scene:reset():set_restitution(0);
Scene.bloom = true;

Scene.ambient_light_brightness = 0;

local floor_width = 30;
local floor_height = 5;
local wall_height = 10;

local floor = Scene:add_box({
    position = vec2(0, -10),
    size = vec2((24 / 12) * floor_width, 26 / 12),
    color = 0xff0000,
    is_static = true,
});

floor:set_restitution(0);

for i=1,floor_width do
    for j=1,wall_height do
        Scene:add_attachment({
            name = "Image",
            component = {
                name = "Image",
                code = temp_load_string('./scripts/core/hinge.lua'),
            },
            parent = floor,
            local_position = vec2(-((floor_width - 1) * (24 / 12) * 0.5) + ((i - 1) * (24 / 12)), (26 / 12 / 2) + ((j-1) * (24/12)) - (8/12)),
            local_angle = 0,
            image = "~/scripts/@carroted/pylon_recon/assets/textures/wall.png",
            size = 1 / 12,
            color = Color:hex(0xcfcfcf),
        });
    end;

    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = temp_load_string('./scripts/core/hinge.lua'),
        },
        parent = floor,
        local_position = vec2(-((floor_width - 1) * (24 / 12) * 0.5) + ((i - 1) * (24 / 12)), (26 / 12 / 2) - (7 / 12 / 2)),
        local_angle = 0,
        image = "~/scripts/@carroted/pylon_recon/assets/textures/floor_top.png",
        size = 1 / 12,
        color = Color:hex(0xffffff),
    });
    for j=1,floor_height do
        Scene:add_attachment({
            name = "Image",
            component = {
                name = "Image",
                code = temp_load_string('./scripts/core/hinge.lua'),
            },
            parent = floor,
            local_position = vec2(-((floor_width - 1) * (24 / 12) * 0.5) + ((i - 1) * (24 / 12)), -(26 / 12 / 2) - ((j-1) * (18/12)) + (18/12/2) + (1/12)),
            local_angle = 0,
            image = "~/scripts/@carroted/pylon_recon/assets/textures/floor_bottom.png",
            size = 1 / 12,
            color = Color:hex(0xffffff),
        });
    end;

    if i % 5 == 0 then
        for j=1,wall_height do
            Scene:add_attachment({
                name = "Point Light",
                component = {
                    name = "Point Light",
                    code = temp_load_string('./scripts/core/hinge.lua'),
                },
                parent = floor,
                local_position = vec2(-((floor_width - 1) * (24 / 12) * 0.5) + ((i - 1) * (24 / 12)), j * 5),
                local_angle = 0,
                image = "embedded://textures/point_light.png",
                size = 0.001,
                color = Color:hex(0xffffff),
                light = {
                    color = 0xffffff,
                    intensity = 1.2,
                    radius = 10,
                }
            });
        end;
    end;
end;

local pylon = Scene:add_polygon({
    position = vec2(-2.5, -10 + 0.5 + (13/12)),
    points = {
        vec2((-11 / 12) * 0.5, (-8 / 12) * 0.5),
        vec2((-11 / 12) * 0.5, -0.5),
        vec2((11 / 12) * 0.5, -0.5),
        vec2((11 / 12) * 0.5, (-8 / 12) * 0.5),
        vec2((1 / 12) * 0.5, 0.5),
        vec2((-1 / 12) * 0.5, 0.5),
    },
    -- color = Color:hex(0xffcb81),
    color = Color:rgba(0,0,0,0),
    is_static = false,
});
pylon:set_name("player_100");

local hash = Scene:add_component({
    name = "Pylon",
    id = "@carroted/pylon_recon/pylon",
    version = "0.1.0",
    code = temp_load_string('./scripts/@carroted/pylon_recon/pylon.lua')
});

pylon:add_component(hash);

local flingstick = Scene:add_box({
    position = vec2(2, -10 + (13/12) + (5/12/2)),
    size = vec2(34/12, 5/12),
    color = Color:rgba(0,0,0,0),
    is_static = false,
});

Scene:add_attachment({
    name = "Image",
    component = {
        name = "Image",
        code = temp_load_string('./scripts/core/hinge.lua'),
    },
    parent = flingstick,
    local_position = vec2(0, 0),
    local_angle = 0,
    image = "~/scripts/@carroted/pylon_recon/assets/textures/weapons/flingstick.png",
    size = 1 / 12,
    color = Color:hex(0xffffff),
});

local hash = Scene:add_component({
    name = "Weapon",
    id = "@carroted/pylon_recon/weapon",
    version = "0.1.0",
    code = temp_load_string('./scripts/@carroted/pylon_recon/weapon.lua')
});

flingstick:add_component(hash);

function spawn_small_crate(pos)
    local crate = Scene:add_box({
        position = pos,
        size = vec2(11/12, 11/12),
        color = Color:rgba(0,0,0,0),
        is_static = false,
    });
    crate:set_friction(0.75);
    crate:set_restitution(0);

    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = temp_load_string('./scripts/core/hinge.lua'),
        },
        parent = crate,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "~/scripts/@carroted/pylon_recon/assets/textures/crate_small.png",
        size = 1 / 12,
        color = Color:hex(0xffffff),
    });
end;

function spawn_large_crate(pos)
    local crate = Scene:add_box({
        position = pos,
        size = vec2(16/12, 16/12),
        color = Color:rgba(0,0,0,0),
        is_static = false,
    });
    crate:set_friction(0.75);
    crate:set_restitution(0);

    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = temp_load_string('./scripts/core/hinge.lua'),
        },
        parent = crate,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "~/scripts/@carroted/pylon_recon/assets/textures/crate_large.png",
        size = 1 / 12,
        color = Color:hex(0xffffff),
    });
end;

spawn_small_crate(vec2(-7, -10 + (13/12) + (11/12/2)));
spawn_large_crate(vec2(-8.15, -10 + (13/12) + (16/12/2)));
spawn_small_crate(vec2(-7.8, -10 + (13/12) + (16/12) + (11/12/2)));