local speed = 3;
local host = Scene:get_host();

host:set_camera_position(vec2(0, 0));
host:set_camera_zoom(0.015);

function on_update()
    speed = self_component:get_property("speed").value;
    
    local vel = vec2(0, 0);
    if host:key_pressed("D") then
        vel += vec2(speed, 0);
    end;
    if host:key_pressed("A") then
        vel -= vec2(speed, 0);
    end;
    self:set_linear_velocity(vel);
end;
