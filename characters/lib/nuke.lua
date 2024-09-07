function explosion(point)
    local hash = Scene:add_component({
        code = require('./packages/@carroted/characters/lib/nuke_explosion.lua')
    });
    local c = Scene:add_circle({
        position = point,
        radius = 500,
        color = 0xffffff,
        name = "Light",
        is_static = true;
    });
    c:temp_set_collides(false);
    c:add_component(hash);
end;

function on_collision_start(data)
    if data.other:get_name() == "hammer_2" then
        explosion(self:get_position());
        self:destroy();
    end;
end;