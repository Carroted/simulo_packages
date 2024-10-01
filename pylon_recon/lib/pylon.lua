-- Parameters

local hp = 100;

local speed = 4.1;
local jump_force = 5.1;

local gizmo_color = 0xff0000;
local debug = false;

local camera_pos = self:get_position() + vec2(0, 0);
local camera_zoom = 0.02;

-- Imports

require './packages/@carroted/pylon_recon/lib/gizmos.lua';

local weapon_offset = vec2(1.232, 0);
local weapon_cooldown = 0;
local weapon = nil;
local weapon_player_joint = nil;
local weapon_ground_joint = nil;
local ground = nil;
local weapon_blocking_movement = false;

local inventory = {};

function on_save()
    return {
        weapon = weapon,
        weapon_player_joint = weapon_player_joint,
        weapon_ground_joint = weapon_ground_joint,
        weapon_offset = weapon_offset,
        weapon_cooldown = weapon_cooldown,
        ground = ground,
        hp = hp,
        sprite_1 = sprite_1,
        sprite_2 = sprite_2,
    };
end;

function on_start(saved_data)
    if saved_data ~= nil then
        weapon = saved_data.weapon;
        weapon_player_joint = saved_data.weapon_player_joint;
        weapon_ground_joint = saved_data.weapon_ground_joint;
        weapon_offset = saved_data.weapon_offset;
        weapon_cooldown = saved_data.weapon_cooldown;
        ground = saved_data.ground;
        hp = saved_data.hp;
        sprite_1 = saved_data.sprite_1;
        sprite_2 = saved_data.sprite_2;
    end;
end;

-- Physics and Rendering Setup

self:set_angle_locked(true);
self:set_angle(0);
self:set_restitution(0);

local facing_left = false;

function update_sprite()
    local color_1 = 0xffffff;
    local color_2 = Color:rgba(0,0,0,0);

    if facing_left then
        color_1,color_2 = color_2,color_1;
    end;

    sprite_1:set_color(color_1);
    sprite_2:set_color(color_2);
end;

function switch_to_flingstick()
    if inventory["flingstick"] == nil then return; end;
    
    if weapon ~= nil then
        weapon:destroy();
        weapon = nil;
    end;

    local spawn_flingstick = require('./packages/@carroted/pylon_recon/lib/spawn_flingstick.lua');
    local flingstick = spawn_flingstick(self:get_position());

    weapon = flingstick;
    weapon:temp_set_collides(false);
    weapon:set_body_type(BodyType.Static);
end;

function switch_to_none()
    if weapon_player_joint ~= nil then
        weapon_player_joint:destroy();
        weapon_player_joint = nil;
        weapon_ground_joint = nil;
    end;

    if weapon ~= nil then
        weapon:send_event("@carroted/pylon_recon/weapon/set_overlay_enabled", {
            enabled = false,
        });
        weapon:destroy();
        weapon = nil;
    end;
    if ground ~= nil then
        ground:destroy();
    end;
    ground = nil;

    weapon_ground_joint = nil;
    weapon_blocking_movement = false;
end;

-- Events

function on_event(id, data)
    if id == "@carroted/pylon_recon/weapon/pickup" then
        if weapon == nil then
            weapon = Scene:get_object_by_guid(data.guid);
            weapon:temp_set_collides(false);
            weapon:set_body_type(BodyType.Static);
        else
            Scene:get_object_by_guid(data.guid):destroy();
        end;
        print(data.weapon.id);
        inventory[data.weapon.id] = true;
    elseif id == "@carroted/pylon_recon/pylon/init" then
        sprite_1 = Scene:get_attachment_by_guid(data.sprite_1);
        sprite_2 = Scene:get_attachment_by_guid(data.sprite_2);
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
    Camera:set_position(camera_pos);
    Camera:set_orthographic_scale(camera_zoom);

    local current_vel = self:get_linear_velocity();
    local update_vel = false;

    if Input:key_just_pressed("1") then
        switch_to_none();
    end;
    if Input:key_just_pressed("2") then
        switch_to_flingstick();
    end;

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
        update_sprite();
    end;

    local grounded = ground_check();

    if Input:key_pressed("W") and grounded then
        if current_vel.y < jump_force then
            current_vel.y = jump_force;
            update_vel = true;
        end;
    end;

    if update_vel and (not weapon_blocking_movement) then
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
        Scene:add_attachment({
            name = "Image",
            component = {
                name = "Image",
                code = nil,
            },
            parent = ground,
            local_position = vec2(0, 0),
            local_angle = 0,
            image = "./packages/@carroted/pylon_recon/assets/textures/pin.png",
            size = 1 / 12,
            color = Color:hex(0xffffff),
        });

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

        weapon:set_body_type(BodyType.Dynamic);

        weapon:send_event("@carroted/pylon_recon/weapon/set_overlay_enabled", {
            enabled = true,
        });

        weapon_blocking_movement = true;
    end;

    if (Input:pointer_just_released()) and (weapon_player_joint ~= nil) then
        ground:destroy();
        ground = nil;
        weapon_player_joint:destroy();
        weapon_player_joint = nil;
        weapon_ground_joint = nil;
        weapon:set_body_type(BodyType.Static);
        weapon:send_event("@carroted/pylon_recon/weapon/set_overlay_enabled", {
            enabled = false,
        });
        weapon_blocking_movement = false;
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

    Camera:set_position(camera_pos);
    Camera:set_orthographic_scale(camera_zoom);
end;

function ground_check()
    local circles = get_ground_check_circles();
    for i=1,#circles do
        local circle = Scene:get_objects_in_circle({
            position = circles[i],
            radius = 0,
        });
        for i=1,#circle do
            if circle[i]:get_name() ~= "nojump" then
                return true;
            end;
        end;
    end;

    local rays = get_ground_check_rays();
    for i=1,#rays do
        local hits = Scene:raycast(rays[i]);
        for i=1,#hits do
            if hits[i].object:get_name() ~= "nojump" then
                return true;
            end;
        end;
    end;

    return false;
end;