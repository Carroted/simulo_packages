function on_collision_start(data)
    data.other:send_event("@carroted/pylon_recon/weapon/pickup", {
        weapon = {
            id = "gun",
            offset = vec2(0.3, 0),
            -- ...
        },
        object = self,
    });
end;

function on_event(id, data)
    if id == "@carroted/pylon_recon/weapon/fire" then
        Scene:add_circle({
            position = self:get_world_point(vec2(1, 0)),
            linear_velocity = self:get_right_direction() * 20,
            radius = 2/12,
        });
    end;
end;