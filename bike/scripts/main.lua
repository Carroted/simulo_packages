
Scene:reset()
-- =============================================================================
-- == Motorbike Spawner Script for Simulo (Precise Guides v7)
-- =============================================================================

-- Helper function to merge two tables. Keys in table 'b' overwrite keys in table 'a'.
local function merge_tables(a, b)
    local new_table = {}
    for k, v in pairs(a) do new_table[k] = v end
    for k, v in pairs(b) do new_table[k] = v end
    return new_table
end

-- Require core functions
local core_bolt = require('core/lib/bolt.lua')
local simulon = require('core/lib/simulon.lua')

-- Define constants
local BIKE_COLOR = Color:hex(0xff5741) -- Red
local WHEEL_COLOR = Color:hex(0x221e23)
local SEAT_COLOR = Color:hex(0x2d272f)
local GUIDE_COLOR = Color:rgba(1,1,1,0.03) -- Invisible guides

local CHASSIS_POS = vec2(0, 2)
local CHASSIS_SIZE = vec2(1.2, 0.25)
local CHASSIS_DENSITY = 1.5

local SEAT_OFFSET = vec2(-0.3, CHASSIS_SIZE.y / 2)
local SEAT_SIZE = vec2(0.5, 0.06)

local WHEEL_RADIUS = 0.2
local WHEEL_DENSITY = 0.8
local WHEEL_FRICTION = 0.8 -- Wheel needs friction
local WHEEL_RESTITUTION = 0.1
local WHEEL_LINEAR_DAMPING = 0.2
local WHEEL_ANGULAR_DAMPING = 0.5

-- Spring attachment points relative to Chassis center
local FRONT_SPRING_ATTACH_CHASSIS = vec2(CHASSIS_SIZE.x * 0.45, -CHASSIS_SIZE.y * 0.2)
local REAR_SPRING_ATTACH_CHASSIS = vec2(-CHASSIS_SIZE.x * 0.45, -CHASSIS_SIZE.y * 0.2)

-- Initial Y offset for wheel position relative to chassis spring anchor
local INITIAL_WHEEL_OFFSET_Y = -0.5

local SPRING_STIFFNESS = 50.0
local SPRING_DAMPING = 0.3
local SPRING_REST_LENGTH = 0.5

local DRIVE_TORQUE = 0.0
local BRAKE_TORQUE_FACTOR = 2.0

-- Guide properties
local GUIDE_HEIGHT = WHEEL_RADIUS * 20
local GUIDE_WIDTH = 0.1
-- *** CORRECTED: Offset from centerline to the CENTER of the guide box ***
local GUIDE_CENTER_OFFSET_X = WHEEL_RADIUS + (GUIDE_WIDTH / 2)
local GUIDE_DENSITY = 0
local GUIDE_FRICTION = 0.0 -- *** CHANGED ***
local GUIDE_RESTITUTION = 0.0 -- *** CHANGED ***

-- Collision Layers
local LAYER_GROUND = { 1 }
local LAYER_GUIDES = { 2 }
local LAYER_WHEELS = { 1, 2 }


-- =============================================================================
-- == Bike Controller Component Definition (Unchanged from v5/v6)
-- =============================================================================
local bike_controller_hash = Scene:add_component_def({
    name = "Motorbike Torque Controller",
    id = "@my_scripts/bike_torque_controller",
    version = "1.0.0",
    script = {
        lang = "lua",
        code = [[
            local player = nil
            local front_wheel = nil
            local rear_wheel = nil

            local DRIVE_TORQUE = 0.3
            local BRAKE_TORQUE_FACTOR = 0.1

            function on_start(saved_data)
                player = Scene:get_host()
                if not player then print("BikeController: Could not find player!"); return end
                if saved_data and saved_data.front_wheel_id and saved_data.rear_wheel_id then
                    front_wheel = Scene:get_object(saved_data.front_wheel_id)
                    rear_wheel = Scene:get_object(saved_data.rear_wheel_id)
                end
                if not front_wheel or front_wheel:is_destroyed() then print("BikeController: Front wheel missing!"); front_wheel = nil end
                if not rear_wheel or rear_wheel:is_destroyed() then print("BikeController: Rear wheel missing!"); rear_wheel = nil end
            end

            function apply_control_torque(wheel, desired_torque, is_braking_hard)
                 if not wheel or wheel:is_destroyed() then return end
                 local current_ang_vel = wheel:get_angular_velocity()
                 local final_torque = 0
                 if desired_torque ~= 0 then
                     final_torque = desired_torque
                 else
                     local brake_force = BRAKE_TORQUE_FACTOR
                     if is_braking_hard then brake_force = brake_force * 2.0 end
                     final_torque = -current_ang_vel * brake_force
                 end
                 wheel:apply_torque(final_torque)
             end

            function on_step(time_step)
                if not player or not front_wheel or not rear_wheel then return end
                if front_wheel:is_destroyed() or rear_wheel:is_destroyed() then return end

                local target_drive_torque = 0
                local hard_brake = player:key_pressed("S")
                if not hard_brake then
                    if player:key_pressed("D") then target_drive_torque = -DRIVE_TORQUE
                    elseif player:key_pressed("A") then target_drive_torque = DRIVE_TORQUE
                    end
                end
                 apply_control_torque(front_wheel, target_drive_torque, hard_brake)
                 apply_control_torque(rear_wheel, target_drive_torque, hard_brake)
            end

             function on_save()
                 local data = {}
                 if front_wheel and not front_wheel:is_destroyed() then data.front_wheel_id = front_wheel.id end
                 if rear_wheel and not rear_wheel:is_destroyed() then data.rear_wheel_id = rear_wheel.id end
                 return data
             end
        ]]
    }
})
if not bike_controller_hash then print("ERROR: Failed to define bike torque controller component!"); return end

-- =============================================================================
-- == Create Bike Parts
-- =============================================================================

-- Chassis (Unchanged)
local chassis = Scene:add_box({
    position = CHASSIS_POS, size = CHASSIS_SIZE, color = BIKE_COLOR,
    density = CHASSIS_DENSITY, name = "Motorbike Chassis",
    collision_layers = LAYER_GROUND,
})
if not chassis then print("ERROR: Failed to create chassis!"); return end

-- Seat (Unchanged)
local seat_pos = chassis:get_world_point(SEAT_OFFSET)
local seat = Scene:add_box({
    position = seat_pos, size = SEAT_SIZE, color = SEAT_COLOR,
    density = CHASSIS_DENSITY * 0.5, name = "Motorbike Seat",
    collision_layers = LAYER_GROUND,
})
if not seat then print("ERROR: Failed to create seat!"); return end
Scene:add_bolt({ object_a = chassis, object_b = seat, local_anchor_a = SEAT_OFFSET, local_anchor_b = vec2(0, -SEAT_SIZE.y / 2) })

-- Wheels
local wheel_common_props = {
    radius = WHEEL_RADIUS, color = WHEEL_COLOR, density = WHEEL_DENSITY,
    friction = WHEEL_FRICTION, restitution = WHEEL_RESTITUTION, -- WHEEL friction applied here
    linear_damping = WHEEL_LINEAR_DAMPING, angular_damping = WHEEL_ANGULAR_DAMPING,
    collision_layers = LAYER_WHEELS,
    ccd_enabled = true,
}
-- Calculate initial wheel positions
local front_spring_anchor_world = chassis:get_world_point(FRONT_SPRING_ATTACH_CHASSIS)
local front_wheel_pos = front_spring_anchor_world + vec2(0, INITIAL_WHEEL_OFFSET_Y)
local front_wheel = Scene:add_circle(merge_tables(wheel_common_props, { position = front_wheel_pos, name = "Front Wheel" }))
if not front_wheel then print("ERROR: Failed to create front wheel!"); return end

local rear_spring_anchor_world = chassis:get_world_point(REAR_SPRING_ATTACH_CHASSIS)
local rear_wheel_pos = rear_spring_anchor_world + vec2(0, INITIAL_WHEEL_OFFSET_Y)
local rear_wheel = Scene:add_circle(merge_tables(wheel_common_props, { position = rear_wheel_pos, name = "Rear Wheel" }))
if not rear_wheel then print("ERROR: Failed to create rear wheel!"); return end

-- Dynamic Wheel Guides (Bolted to Chassis)
local guide_common_props = {
    size = vec2(GUIDE_WIDTH, GUIDE_HEIGHT),
    body_type = BodyType.Dynamic,
    color = GUIDE_COLOR,
    density = GUIDE_DENSITY,
    collision_layers = LAYER_GUIDES,
    friction = GUIDE_FRICTION, -- *** CHANGED ***
    restitution = GUIDE_RESTITUTION, -- *** CHANGED ***
    gravity_scale = 0,
}

-- Calculate guide positions RELATIVE TO CHASSIS spring anchors
local front_guide_base_local = FRONT_SPRING_ATTACH_CHASSIS + vec2(0, INITIAL_WHEEL_OFFSET_Y)
local rear_guide_base_local = REAR_SPRING_ATTACH_CHASSIS + vec2(0, INITIAL_WHEEL_OFFSET_Y)

-- Create and Bolt Front Guides using corrected offset
local fg_l_pos = chassis:get_world_point(front_guide_base_local + vec2(-GUIDE_CENTER_OFFSET_X, 0))
local fg_l = Scene:add_box(merge_tables(guide_common_props, { position = fg_l_pos, name = "FG L" }))
Scene:add_bolt({ object_a = chassis, object_b = fg_l, local_anchor_a = front_guide_base_local + vec2(-GUIDE_CENTER_OFFSET_X, 0), local_anchor_b = vec2(0,0) })

local fg_r_pos = chassis:get_world_point(front_guide_base_local + vec2( GUIDE_CENTER_OFFSET_X, 0))
local fg_r = Scene:add_box(merge_tables(guide_common_props, { position = fg_r_pos, name = "FG R" }))
Scene:add_bolt({ object_a = chassis, object_b = fg_r, local_anchor_a = front_guide_base_local + vec2( GUIDE_CENTER_OFFSET_X, 0), local_anchor_b = vec2(0,0) })

-- Create and Bolt Rear Guides using corrected offset
local rg_l_pos = chassis:get_world_point(rear_guide_base_local + vec2(-GUIDE_CENTER_OFFSET_X, 0))
local rg_l = Scene:add_box(merge_tables(guide_common_props, { position = rg_l_pos, name = "RG L" }))
Scene:add_bolt({ object_a = chassis, object_b = rg_l, local_anchor_a = rear_guide_base_local + vec2(-GUIDE_CENTER_OFFSET_X, 0), local_anchor_b = vec2(0,0) })

local rg_r_pos = chassis:get_world_point(rear_guide_base_local + vec2( GUIDE_CENTER_OFFSET_X, 0))
local rg_r = Scene:add_box(merge_tables(guide_common_props, { position = rg_r_pos, name = "RG R" }))
Scene:add_bolt({ object_a = chassis, object_b = rg_r, local_anchor_a = rear_guide_base_local + vec2( GUIDE_CENTER_OFFSET_X, 0), local_anchor_b = vec2(0,0) })

-- =============================================================================
-- == Connect Parts with Joints (Spring Only - Unchanged)
-- =============================================================================
local spring_common = { stiffness = SPRING_STIFFNESS, damping = SPRING_DAMPING, rest_length = SPRING_REST_LENGTH, collide_connected = true }
Scene:add_spring(merge_tables(spring_common, { object_a = chassis, object_b = front_wheel, local_anchor_a = FRONT_SPRING_ATTACH_CHASSIS, local_anchor_b = vec2(0, 0) }))
Scene:add_spring(merge_tables(spring_common, { object_a = chassis, object_b = rear_wheel, local_anchor_a = REAR_SPRING_ATTACH_CHASSIS, local_anchor_b = vec2(0, 0) }))

-- =============================================================================
-- == Add Driver (Simulon - Unchanged)
-- =============================================================================
local simulon_scale = 0.4
local simulon_pos = seat:get_world_point(vec2(0, SEAT_SIZE.y/2 + 0.3))
local simulon_parts = simulon({ position = simulon_pos, size = simulon_scale, density = 0.5 })
local simulon_body_part = nil
if simulon_parts and simulon_parts.body then
    simulon_body_part = simulon_parts.body
    simulon_parts.body:set_collision_layers(LAYER_GROUND)
    if simulon_parts.head then simulon_parts.head:set_collision_layers(LAYER_GROUND) end
    if simulon_parts.box then simulon_parts.box:set_collision_layers(LAYER_GROUND) end
    local bolt_point = seat:get_world_point(vec2(0, SEAT_SIZE.y / 2))
    core_bolt({ object_a = seat, object_b = simulon_parts.body, point = bolt_point, sound = false, color = Color.TRANSPARENT })
else print("Warning: Failed to create Simulon or find its body part.") end

-- =============================================================================
-- == Add Phasers (Unchanged from v6)
-- =============================================================================
print("Adding phasers (v7)...")
Scene:add_phaser({ object_a = seat, object_b = front_wheel })
Scene:add_phaser({ object_a = seat, object_b = rear_wheel })
if simulon_body_part then
    Scene:add_phaser({ object_a = simulon_body_part, object_b = front_wheel })
    Scene:add_phaser({ object_a = simulon_body_part, object_b = rear_wheel })
end
print("Phasers added.")

-- =============================================================================
-- == Add Controller Component (Unchanged)
-- =============================================================================
if front_wheel and rear_wheel then
    chassis:add_component({ hash = bike_controller_hash, saved_data = { front_wheel_id = front_wheel.id, rear_wheel_id = rear_wheel.id } })
else print("ERROR: Cannot add controller component, wheels missing.") end

print("Motorbike spawned! (Precise Guides v7)")
Scene:push_undo()