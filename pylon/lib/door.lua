local closed_y = -10 + (2 / 2);
local open_y = closed_y + 1.9;

local speed = 0.1;
local radius = 1;

local open = false;

function on_step()
    local objs = Scene:get_objects_in_circle({
        position = vec2(self:get_position().x, closed_y),
        radius = radius,
    });

    open = false;

    for i=1,#objs do
        if objs[i]:get_name() == "Pylon" then
            open = true;
            break;
        end;
    end;

    if open then
        local pos = self:get_position();
        pos.y = math.min(pos.y + speed, open_y);
        self:set_position(pos);
    else
        local pos = self:get_position();
        pos.y = math.max(pos.y - speed, closed_y);
        self:set_position(pos);
    end;
end;