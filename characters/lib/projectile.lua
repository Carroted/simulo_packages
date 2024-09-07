local counter = 300;

function explosion()
    local hash = Scene:add_component({
        code = require('./packages/@carroted/characters/lib/explosion.lua', 'string')
    });
    local c = Scene:add_circle({
        position = self:get_position(),
        radius = 0.2,
        color = 0xffffff,
        name = "Light",
        is_static = true;
    });
    c:temp_set_collides(false);
    c:add_component(hash);
end;

function on_collision_start(data)
    explosion();
    self:destroy();
    return;
end;

local start_vel = nil;

function on_step()
    if start_vel == nil then
        start_vel = self:get_linear_velocity();
    end;

    self:set_linear_velocity(start_vel);

    counter -= 1;
    if counter <= 0 then
        self:destroy();
    end;
end;