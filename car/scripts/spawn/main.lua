print('hoy');

Scene:reset():destroy();
Scene:set_gravity(vec2(0,0));

local code = [[-- Define the car's properties
local car_body = self;
local wheels = {}
local wheel_joints = {}
local wheel_count = 4
local wheel_radius = 0.5
local wheel_friction = 0.5
local wheel_max_drive_force = 100
local wheel_max_lateral_impulse = 10
local wheel_max_forward_speed = 100
local wheel_max_backward_speed = -20
local wheel_turn_speed = 100
local wheel_turn_torque = 10
local wheel_lock_angle = 35

-- Create the wheels and joints
function on_start()
    print('hi');
    -- Create the wheels
    for i = 1, wheel_count do
        local wheel = Scene:add_circle({
            position = vec2(0, 0),
            radius = wheel_radius,
            color = 0x111111,
            is_static = false,
        })
        table.insert(wheels, wheel)
    end

    -- Create the wheel joints
    local wheel_joint_def = {
        point = self:get_world_point(vec2(-3, 0.75)),
        object_a = car_body,
        object_b = nil,
        local_anchor_a = vec2(0, 0),
        local_anchor_b = vec2(0, 0),
        enable_limit = true,
        lower_angle = 0,
        upper_angle = 0,
    }

    -- Back left wheel
    wheel_joint_def.object_b = wheels[1]
    wheel_joint_def.local_anchor_a = vec2(-3, 0.75)
    wheel_joints[1] = Scene:add_hinge_at_world_point(wheel_joint_def)

    -- Back right wheel
    wheel_joint_def.object_b = wheels[2]
    wheel_joint_def.local_anchor_a = vec2(3, 0.75)
    wheel_joint_def.point = self:get_world_point(vec2(3, 0.75));
    wheel_joints[2] = Scene:add_hinge_at_world_point(wheel_joint_def)

    -- Front left wheel
    wheel_joint_def.object_b = wheels[3]
    wheel_joint_def.local_anchor_a = vec2(-3, 8.5)
    wheel_joint_def.point = self:get_world_point(vec2(-3, 8.5));
    wheel_joints[3] = Scene:add_hinge_at_world_point(wheel_joint_def)

    -- Front right wheel
    wheel_joint_def.object_b = wheels[4]
    wheel_joint_def.local_anchor_a = vec2(3, 8.5)
    wheel_joint_def.point = self:get_world_point(vec2(3, 8.5));
    wheel_joints[4] = Scene:add_hinge_at_world_point(wheel_joint_def)

    print('made wheels')
end

function dot(vec1, vec22)
    return vec1.x * vec22.x + vec1.y * vec22.y
end

-- Update the car's physics
function on_step()
    -- Update the wheels' friction
    for i = 1, wheel_count do
        local wheel = wheels[i]
        local velocity = wheel:get_linear_velocity()
        local friction = vec2(0, 0)
        friction.x = -velocity.x * wheel_friction
        friction.y = -velocity.y * wheel_friction
        wheel:apply_force_to_center(friction)
    end

    -- Update the car's drive
    local drive_force = 0
    if Input:key_pressed("W") then
        drive_force = wheel_max_drive_force
    elseif Input:key_pressed("S") then
        drive_force = -wheel_max_drive_force
    end
    for i = 1, wheel_count do
        local wheel = wheels[i]
        local velocity = wheel:get_linear_velocity()
        local direction = wheel:get_up_direction();
        local speed = dot(velocity, direction)
        if drive_force > 0 and speed < wheel_max_forward_speed then
            wheel:apply_force_to_center(direction * drive_force)
        elseif drive_force < 0 and speed > wheel_max_backward_speed then
            wheel:apply_force_to_center(direction * drive_force)
        end
    end

    -- Update the car's turn
    local turn_torque = 0
    if Input:key_pressed("A") then
        turn_torque = -wheel_turn_torque
    elseif Input:key_pressed("D") then
        turn_torque = wheel_turn_torque
    end
    for i = 1, wheel_count do
        local wheel = wheels[i]
        wheel:apply_torque(turn_torque)
    end

    -- Update the wheel joints' limits
    local lock_angle = wheel_lock_angle * math.pi / 180
    for i = 3, 4 do
        local joint = wheel_joints[i]
        local angle = joint:get_angle()
        if Input:key_pressed("A") then
            joint:set_limits(-lock_angle, -lock_angle)
        elseif Input:key_pressed("D") then
            joint:set_limits(lock_angle, lock_angle)
        else
            joint:set_limits(0, 0)
        end
    end
end]];

local car_body = Scene:add_polygon({
        position = vec2(0,0),
        points = {
            vec2(-1.5, 0),
            vec2(1.5, 0),
            vec2(3, 2.5),
            vec2(2.8, 5.5),
            vec2(1, 10),
            vec2(-1, 10),
            vec2(-2.8, 5.5),
            vec2(-3, 2.5),
            vec2(-1.5, 0),
        },
        color = 0x111111,
        is_static = false,
    });

local hash = Scene:add_component({
    name = "Car",
    version = "0.1.0",
    id = "@carroted/car/car",

    -- Lua/Luau code
    code = code,
});

car_body:add_component({hash = hash});