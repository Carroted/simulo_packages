Scene:reset();

local box = Scene:add_box({
    position = vec2(0, 0),
    size = vec2(3, 0.2),
    is_static = false,
    color = 0xffffff,
});
local box2 = Scene:add_box({
    position = vec2(1.5, 1.75),
    size = vec2(0.2, 3.7),
    is_static = false,
    color = 0xffffff,
});
local box3 = Scene:add_box({
    position = vec2(-1.5, 1.75),
    size = vec2(0.2, 3.7),
    is_static = false,
    color = 0xffffff,
});
box2:bolt_to(box);
box3:bolt_to(box);

box:set_body_type(BodyType.Kinematic);
box:set_linear_velocity(vec2(0,2));