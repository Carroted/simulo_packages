local host = Scene:get_host();

host:set_camera_position(vec2(0, 0));
host:set_camera_zoom(0.015);

self:set_body_type(BodyType.Dynamic);

local spring = nil;

function on_start(saved_data)
    if saved_data and saved_data.spring then
        spring = saved_data.spring;
    else
        spring = Scene:add_spring({
            local_anchor_a = host:pointer_pos(),
            object_b = self,
            stiffness = 2,
            damping = 0,
        });
    end;
end;

function on_save()
    return {
        spring = spring,
    };
end;

function on_update()
    speed = self_component:get_property("speed").value;
    
    spring:set_local_anchor_a(host:pointer_pos());
    Gizmos:line({
        point_a = spring:get_world_anchor_b(),
        point_b = host:pointer_pos(),
        --width = 0.02,
        color = 0xffffff,
    });
end;

function on_step()
    self:set_angle(0);
    self:set_angular_velocity(0);
end;
