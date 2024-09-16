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
                code = nil,
            },
            parent = floor,
            local_position = vec2(-((floor_width - 1) * (24 / 12) * 0.5) + ((i - 1) * (24 / 12)), (26 / 12 / 2) + ((j-1) * (24/12)) - (8/12)),
            local_angle = 0,
            image = "./packages/@carroted/pylon_recon/assets/textures/wall.png",
            size = 1 / 12,
            color = Color:hex(0xcfcfcf),
        });
    end;

    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = nil,
        },
        parent = floor,
        local_position = vec2(-((floor_width - 1) * (24 / 12) * 0.5) + ((i - 1) * (24 / 12)), (26 / 12 / 2) - (7 / 12 / 2)),
        local_angle = 0,
        image = "./packages/@carroted/pylon_recon/assets/textures/floor_top.png",
        size = 1 / 12,
        color = Color:hex(0xffffff),
    });
    for j=1,floor_height do
        Scene:add_attachment({
            name = "Image",
            component = {
                name = "Image",
                code = nil,
            },
            parent = floor,
            local_position = vec2(-((floor_width - 1) * (24 / 12) * 0.5) + ((i - 1) * (24 / 12)), -(26 / 12 / 2) - ((j-1) * (18/12)) + (18/12/2) + (1/12)),
            local_angle = 0,
            image = "./packages/@carroted/pylon_recon/assets/textures/floor_bottom.png",
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
                    code = nil,
                },
                parent = floor,
                local_position = vec2(-((floor_width - 1) * (24 / 12) * 0.5) + ((i - 1) * (24 / 12)), j * 5),
                local_angle = 0,
                image = "./packages/core/assets/textures/point_light.png",
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

local spawn_small_crate = require('./packages/@carroted/pylon_recon/lib/spawn_small_crate.lua');
local spawn_large_crate = require('./packages/@carroted/pylon_recon/lib/spawn_large_crate.lua');

spawn_small_crate(vec2(-7, -10 + (13/12) + (11/12/2)));
spawn_large_crate(vec2(-8.15, -10 + (13/12) + (16/12/2)));
spawn_small_crate(vec2(-7.8, -10 + (13/12) + (16/12) + (11/12/2)));

local spawn_nojump = require('./packages/@carroted/pylon_recon/lib/spawn_nojump.lua');
spawn_nojump(vec2(5, -10 + (13/12) + (((13/12) + (13/12) + (3)) / 2)), 5, false);
spawn_nojump(vec2(5, -10 + (13/12) + (((13/12) + (13/12) + (3)) * 2)), 5, false);

local spawn_pylon = require('./packages/@carroted/pylon_recon/lib/spawn_pylon.lua');
spawn_pylon(vec2(-2.5, -10 + 0.5 + (13/12)));

local spawn_flingstick = require('./packages/@carroted/pylon_recon/lib/spawn_flingstick.lua');
spawn_flingstick(vec2(2, -10 + (13/12) + (5/12/2)));

--[[
local spawn_gun = require('./packages/@carroted/pylon_recon/lib/spawn_gun.lua');
spawn_gun(vec2(4, -10 + (13/12) + (5/12/2)));
]]