require './packages/@carroted/pylon_recon/lib/gizmos.lua';

self:set_angle_locked(true);
self:set_body_type(BodyType.Dynamic);

local ground_body = Scene:add_circle({
    position = self:get_position(),
    radius = 1,
    color = Color:rgba(0,0,0,0),
    is_static = true,
});
ground_body:temp_set_collides(false);

local spring = Scene:add_drag_spring({
    point = self:get_position(),
    object_a = ground_body,
    object_b = self,
    strength = 2,
    damping = 0,
});

function on_update()
    clear_gizmos();
    spring:set_target(Input:pointer_pos());
    gizmo_line(spring:get_world_point_on_object(), Input:pointer_pos(), 0.02, 0xffffff, true);
end;