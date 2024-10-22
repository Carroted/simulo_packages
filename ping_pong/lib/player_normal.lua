local speed = 3;

function on_update()
    speed = self_component:get_property("speed").value;
    
    local vel = vec2(0, 0);
    if Input:key_pressed("D") then
        vel += vec2(speed, 0);
    end;
    if Input:key_pressed("A") then
        vel -= vec2(speed, 0);
    end;
    self:set_linear_velocity(vel);
end;