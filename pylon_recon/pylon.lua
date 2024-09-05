-- Parameters

local hp = 100;

local speed = 4.1;
local jump_force = 5.1;

local gizmo_color = 0xff0000;
local debug = false;

local camera_pos = self:get_position() + vec2(0, 0);
local camera_zoom = 0.02;

-- Imports

require './scripts/@carroted/pylon_recon/lib/gizmos.lua';

local weapon_offset = vec2(1.232, 0);
local weapon_cooldown = 0;
local weapon = nil;
local weapon_player_joint = nil;
local weapon_ground_joint = nil;
local ground = nil;

-- Physics and Rendering Setup

self:set_angle_locked(true);
self:set_angle(0);
self:set_restitution(0);

local sprite = Scene:add_attachment({
    name = "Image",
    component = {
        name = "Image",
        code = temp_load_string('./scripts/core/hinge.lua'),
    },
    parent = self,
    local_position = vec2(0, 0),
    local_angle = 0,
    image = "~/scripts/@carroted/pylon_recon/assets/textures/entities/cone.png",
    size = 1 / 12,
    color = Color:hex(0xffffff),
    flip_x = facing_left,
});

local facing_left = false;

function redraw_sprite()
    sprite:set_flip_x(facing_left);
end;

redraw_sprite();

-- Events

function on_event(id, data)
    if id == "@carroted/pylon_recon/weapon/pickup" then
        if weapon == nil then
            weapon = Scene:get_object_by_guid(data.guid);
            weapon:temp_set_collides(false);
            weapon:temp_set_is_static(true);
        end;
    end;
end;

function lerp_vec2(v1, v2, t)
    return vec2(
        v1.x + (v2.x - v1.x) * t,
        v1.y + (v2.y - v1.y) * t
    );
end;

function update_weapon()
    if (weapon ~= nil) and (weapon_player_joint == nil) then
        local player_pos = self:get_position() + vec2(0, -0.114);
        weapon:set_position(player_pos + weapon_offset);

        -- Adjust rotation to use the player position as the pivot
        local world_position = Input:pointer_pos();
        local angle = math.atan2(world_position.y - player_pos.y, world_position.x - player_pos.x)
        
        -- Set weapon's angle
        weapon:set_angle(angle)
        
        -- Calculate the new position of the weapon based on the angle
        local rotated_offset = vec2(
            weapon_offset.x * math.cos(angle) - weapon_offset.y * math.sin(angle),
            weapon_offset.x * math.sin(angle) + weapon_offset.y * math.cos(angle)
        )
        weapon:set_position(player_pos + rotated_offset)

        if weapon_cooldown > 0 then
            weapon_cooldown -= 1;
        end;
    elseif (weapon ~= nil) and (weapon_player_joint ~= nil) then
        local player_pos = self:get_position() + vec2(0, -0.114);
        local world_position = Input:pointer_pos();
        local angle = math.atan2(world_position.y - player_pos.y, world_position.x - player_pos.x) % math.rad(360);

        local current_angle = weapon:get_angle() % math.rad(360);

        local max_angle = math.rad(15);

        local diff = angle - current_angle;

        if diff > math.pi then
            diff = diff - 2 * math.pi
        elseif diff < -math.pi then
            diff = diff + 2 * math.pi
        end

        if math.abs(diff) > max_angle then
            weapon:set_angular_velocity(weapon:get_angular_velocity() + (diff * 0.2));
        end;
    end;
end;

function on_update()
    Scene:temp_set_camera_pos(camera_pos);
    Scene:temp_set_camera_zoom(camera_zoom);

    local current_vel = self:get_linear_velocity();
    local update_vel = false;

    if Input:key_just_pressed("Q") then
        debug = not debug;
    end;

    local prev_facing_left = facing_left;

    if Input:key_pressed("D") then
        if current_vel.x < speed then
            current_vel.x = speed;
            update_vel = true;
        end;
        facing_left = false;
    end;
    if Input:key_pressed("A") then
        if current_vel.x > -speed then
            current_vel.x = -speed;
            update_vel = true;
        end;
        facing_left = true;
    end;

    if facing_left ~= prev_facing_left then
        redraw_sprite();
    end;

    local grounded = ground_check();

    if Input:key_pressed("W") and grounded then
        if current_vel.y < jump_force then
            current_vel.y = jump_force;
            update_vel = true;
        end;
    end;

    if update_vel then
        self:set_linear_velocity(current_vel);
    end;

    update_weapon();

    if (Input:pointer_just_pressed()) and (weapon ~= nil) then
        ground = Scene:add_circle({
            position = weapon:get_position(),
            color = Color:rgba(0,0,0,0),
            is_static = true,
            radius = 0.1
        });
        ground:temp_set_collides(false);

        weapon_player_joint = Scene:add_hinge_at_world_point({
            point = self:get_position() + vec2(0, -0.114),
            object_a = self,
            object_b = weapon,
        });

        weapon_ground_joint = Scene:add_hinge_at_world_point({
            point = weapon:get_position(),
            object_a = ground,
            object_b = weapon,
        });

        weapon:temp_set_is_static(false);

        weapon:send_event("@carroted/pylon_recon/weapon/set_overlay_enabled", {
            enabled = true,
        });
    end;

    if (Input:pointer_just_released()) and (weapon_player_joint ~= nil) then
        ground:destroy();
        ground = nil;
        weapon_player_joint:destroy();
        weapon_player_joint = nil;
        weapon_ground_joint = nil;
        weapon:temp_set_is_static(true);
        weapon:send_event("@carroted/pylon_recon/weapon/set_overlay_enabled", {
            enabled = false,
        });
    end;
end;

function get_ground_check_rays()
    return {
        [1] = {
            origin = self:get_position() + vec2((-5.5 * (1 / 12)) - 0.01, -4 * (1 / 12)),
            direction = vec2(0, -1),
            distance = (2 / 12) + 0.01,
            closest_only = false,
        },
        [2] = {
            origin = self:get_position() + vec2((5.5 * (1 / 12)) + 0.01, -4 * (1 / 12)),
            direction = vec2(0, -1),
            distance = (2 / 12) + 0.01,
            closest_only = false,
        },
        [3] = {
            origin = self:get_position() + vec2((-5.5 * (1 / 12)) - 0.01, (-4 * (1 / 12)) - (2 / 12) - 0.01),
            direction = vec2(1, 0),
            distance = (11 * (1 / 12)) + 0.02,
            closest_only = false,
        },
    };
end;

function get_ground_check_circles()
    return {
        [1] = self:get_position() + vec2((-5.5 * (1 / 12)) - 0.01, -4 * (1 / 12)),
        [2] = self:get_position() + vec2((5.5 * (1 / 12)) + 0.01, -4 * (1 / 12)),
    };
end;

function on_step()
    clear_gizmos();

    update_weapon();

    if debug then
        local rays = get_ground_check_rays();
        for i=1,#rays do
            gizmo_raycast(rays[i], gizmo_color);
        end;

        local circles = get_ground_check_circles();
        for i=1,#circles do
            gizmo_circle(circles[i], gizmo_color);
        end;
    end;

    camera_pos = lerp_vec2(camera_pos, self:get_position(), 0.08);

    Scene:temp_set_camera_pos(camera_pos);
    Scene:temp_set_camera_zoom(camera_zoom);
end;

function ground_check()
    local circles = get_ground_check_circles();
    for i=1,#circles do
        local circle = Scene:get_objects_in_circle({
            position = circles[i],
            radius = 0,
        });
        if #circle > 0 then return true; end;
    end;

    local rays = get_ground_check_rays();
    for i=1,#rays do
        local hits = Scene:raycast(rays[i]);
        if #hits > 0 then return true; end;
    end;

    return false;
end;