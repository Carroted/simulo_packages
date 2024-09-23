require './packages/@carroted/pylon_recon/lib/gizmos.lua';

local color = 0xff0000;
local distance = 0.4;

function on_event(id, data)
    if id == "@carroted/bricks/painter/init" then
        color = data.color;
        distance = data.distance;
    end;
end;

function on_step()
    clear_gizmos();

    local direction = self:get_up_direction();
    local ray = {
        origin = self:get_world_point(vec2(0, 0.20)),
        direction = direction,
        distance = distance,
        closest_only = false,
    };

    local hits = Scene:raycast(ray);

    for i=1,#hits do
        if hits[i].object:get_body_type() == BodyType.Dynamic then
            hits[i].object:set_color(color);
        end;
    end;
end;