Scene:reset();
Scene:set_gravity(vec2(0, 0));

Camera:reset();
Camera:set_position(vec2(0, 0));

local width = 12;
local height = 19;
local collide_height = 5;

-- Pixels Per Unit
local ppu = 16;

function spawn_floor(grid_pos)
    local tile = Scene:add_box({
        position = grid_pos,
        size = vec2(1, 1),
        color = Color:rgba(0,0,0,0),
        is_static = true,
    });
    tile:temp_set_collides(false);
    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = nil,
        },
        parent = tile,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/@carroted/rpg/assets/floor.png",
        size = 1 / ppu,
        color = Color:hex(0xffffff),
    });
end;

function spawn_wall(grid_pos)
    local tile = Scene:add_box({
        position = grid_pos,
        size = vec2(1, 1),
        color = Color:rgba(0,0,0,0),
        is_static = true,
    });
    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = nil,
        },
        parent = tile,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/@carroted/rpg/assets/wall.png",
        size = 1 / ppu,
        color = Color:hex(0xffffff),
    });
end;

for x=1,10 do
    spawn_wall(vec2(x, 11));
    for y=1,10 do
        spawn_floor(vec2(x, y));
    end;
end;

local player = Scene:add_box({
    position = vec2(0, 0),
    size = vec2(width / ppu, collide_height / ppu),
    color = Color:rgba(0,0,0,0),
    is_static = false,
});
player:set_angle_locked(true);

local hash = Scene:add_component({
    name = "RPG Player",
    id = "@carroted/rpg/player",
    version = "0.1.0",
    code = require('./packages/@carroted/rpg/lib/player.lua', 'string')
});

player:add_component(hash);