local speed = 4.1;
local jump_force = 5.1;
local weapon_offset = vec2(0.15, 0);
local weapon_cooldown = 0;
local weapon = nil;
local grenade_count = 0;
local weapon_number = 0;
local grenade_display = nil;
local grenade_display_offset = vec2(0, 1.4 / 2);

local health_bar_fg = nil;
local health_bar_bg = nil;
local health_bar_offset = vec2(0, 0.55);
local health_bar_width = 0.85;
local health_bar_height = 0.06;
local prev_hp_value = 100;

local grabbing = nil;
local spring = nil;
local prev_line = nil;
local ground_body = nil;
local grab_marker = nil;

local sprite = nil;
local facing_left = false;

local crosshair = Scene:add_circle({
    position = vec2(0,0),
    color = Color:rgba(0,0,0,0),
    is_static = true,
    radius = 0.1
});
crosshair:temp_set_collides(false);
--[[
Scene:add_attachment({
    name = "Image",
    component = {
        name = "Image",
        code = temp_load_string('./scripts/core/hinge.lua'),
    },
    parent = crosshair,
    local_position = vec2(0, 0),
    local_angle = 0,
    image = "~/scripts/@carroted/pylon_recon/assets/textures/crosshair.png",
    size = 1 / 12 * 0.7,
    color = Color:hex(0xffffff),
});]]

self:set_angle_locked(true);
self:set_restitution(0);

function redraw_sprite()
    if sprite ~= nil then
        sprite:destroy();
    end;

    sprite = Scene:add_attachment({
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
end;

redraw_sprite();

local debug = false;

local camera_pos = self:get_position() + vec2(0, 0);
local camera_zoom = 0.02;

function lerp_vec2(v1, v2, t)
    return vec2(
        v1.x + (v2.x - v1.x) * t,
        v1.y + (v2.y - v1.y) * t
    );
end;

local gizmos = {};

function clear_gizmos()
    for i=1,#gizmos do
        gizmos[i]:destroy();
    end;
    gizmos = {};
end;

function gizmo_circle(pos, color)
    local c = Scene:add_circle({
        position = pos,
        radius = 0.01,
        is_static = true,
        color = color,
    });
    c:temp_set_collides(false);
    table.insert(gizmos, c);
end;

function gizmo_raycast(tableo, color)
    local line = line(tableo.origin, tableo.origin + (tableo.direction:normalize() * tableo.distance), 0.01, color, true);
    table.insert(gizmos, line);
end;

function line(line_start,line_end,thickness,color,static)
    local pos = (line_start+line_end)/2
    local sx = (line_start-line_end):magnitude()
    local relative_line_end = line_end-pos
    local rotation = math.atan(relative_line_end.y/relative_line_end.x)
    local line = Scene:add_box({
        position = pos,
        size = vec2(sx, thickness),
        is_static = static,
        color = color
    });

    line:temp_set_collides(false);
    line:set_angle(rotation)

    return line
end;

local contacts = 0;
local touching_wall = false;

-- Segment patterns for each digit, true means the segment is on
local digits = {
    ['0'] = {
        {true, true, true},
        {true, false, true},
        {true, false, true},
        {true, false, true},
        {true, true, true}
    },
    ['1'] = {
        {false, false, true},
        {false, false, true},
        {false, false, true},
        {false, false, true},
        {false, false, true}
    },
    ['2'] = {
        {true, true, true},
        {false, false, true},
        {true, true, true},
        {true, false, false},
        {true, true, true}
    },
    ['3'] = {
        {true, true, true},
        {false, false, true},
        {true, true, true},
        {false, false, true},
        {true, true, true}
    },
    ['4'] = {
        {true, false, true},
        {true, false, true},
        {true, true, true},
        {false, false, true},
        {false, false, true}
    },
    ['5'] = {
        {true, true, true},
        {true, false, false},
        {true, true, true},
        {false, false, true},
        {true, true, true}
    },
    ['6'] = {
        {true, true, true},
        {true, false, false},
        {true, true, true},
        {true, false, true},
        {true, true, true}
    },
    ['7'] = {
        {true, true, true},
        {false, false, true},
        {false, false, true},
        {false, false, true},
        {false, false, true}
    },
    ['8'] = {
        {true, true, true},
        {true, false, true},
        {true, true, true},
        {true, false, true},
        {true, true, true}
    },
    ['9'] = {
        {true, true, true},
        {true, false, true},
        {true, true, true},
        {false, false, true},
        {true, true, true}
    },
    ['-'] = {
        {false, false, false},
        {false, false, false},
        {true, true, true},
        {false, false, false},
        {false, false, false},
    }
}

local function draw_digit(pos, size, color, digit)
    local digit_pattern = digits[digit]
    local objects = {}

    for y = 1, #digit_pattern do
        for x = 1, #digit_pattern[y] do
            if digit_pattern[y][x] then
                local offset = vec2((x - 1) * size, -(y - 1) * size) / 2;
                local box = Scene:add_box({
                    position = pos + offset,
                    size = vec2(size / 2, size / 2),
                    color = color,
                    is_static = true,
                });
                box:temp_set_collides(false);
                table.insert(objects, {
                    obj = box,
                    offset = offset,
                });
            end;
        end
    end

    return objects
end

local function draw_seven_segment_display(pos, size, color, number)
    local objects = {}
    local num_str = tostring(number);
    pos = pos - (vec2((((#num_str / 2) * 4) - 1) * size, -2 * size)) / 2;

    local final_offset = 0;
    local first_char = num_str:sub(1, 1);
    if first_char == "1" then
        final_offset = -size;
    end;

    for i = 1, #num_str do
        local digit = num_str:sub(i, i)
        local digit_objects = draw_digit(vec2(pos.x + final_offset + (i - 1) * 4 * size, pos.y), size, color, digit)
        for _, data in ipairs(digit_objects) do
            table.insert(objects, {
                obj = data.obj,
                offset = data.offset + (vec2((i - 1) * 4 * size, 0) - vec2((((#num_str / 2) * 4) - 1) * size, -2 * size) + vec2(final_offset, 0)) / 2
            })
        end
    end

    return objects
end;

function move_display(objects, new_pos)
    for _, data in ipairs(objects) do
        data.obj:set_position(new_pos + data.offset);
    end
end;

function update_grenade_display()
    if grenade_display ~= nil then
        for _, data in ipairs(grenade_display) do
            data.obj:destroy();
        end;
    end;
    if grenade_count ~= 0 then
        grenade_display = draw_seven_segment_display(self:get_position() + grenade_display_offset, 0.05, 0x50a050, grenade_count);
    else
        grenade_display = nil;
    end;
end;

function update_health_bar(value)
    if health_bar_fg ~= nil and (not health_bar_fg:is_destroyed()) then
        health_bar_fg:destroy();
    end;
    if health_bar_bg ~= nil and (not health_bar_bg:is_destroyed()) then
        health_bar_bg:destroy();
    end;
    health_bar_bg = Scene:add_box({
        position = self:get_position() + health_bar_offset,
        size = vec2(health_bar_width, health_bar_height),
        color = Color:rgba(0,0,0,0),
        is_static = true,
    });
    health_bar_bg:temp_set_collides(false);
    health_bar_fg = Scene:add_box({
        position = self:get_position() + health_bar_offset + (vec2(((value / 100.0) * health_bar_width) - health_bar_width, 0)) / 2,
        size = vec2((value / 100.0) * health_bar_width, health_bar_height),
        color = Color:rgba(0,0,0,0),
        is_static = true,
    });
    health_bar_fg:temp_set_collides(false);
end;

update_health_bar(100);
update_grenade_display();

function get_weapon_1(obj)
    if weapon ~= nil then
        weapon:temp_set_is_static(false);
        weapon:temp_set_collides(true);
        weapon:set_position(weapon:get_position() + vec2(-1, 0));
        weapon:set_linear_velocity(self:get_linear_velocity());
    end;
    weapon = obj;
    weapon:temp_set_is_static(true);
    weapon:temp_set_collides(false);
    weapon_offset = vec2(0.15, 0);
    weapon_cooldown = 0;
    weapon_number = 1;
end;

function get_weapon_2(obj)
    if weapon ~= nil then
        weapon:temp_set_is_static(false);
        weapon:temp_set_collides(true);
        weapon:set_position(weapon:get_position() + vec2(-1, 0));
        weapon:set_linear_velocity(self:get_linear_velocity());
    end;
    weapon = obj;
    weapon:temp_set_is_static(true);
    weapon:temp_set_collides(false);
    weapon_offset = vec2(0.1, 0);
    weapon_cooldown = 0;
    weapon_number = 2;
end;

function get_gravgun(obj)
    if weapon ~= nil then
        weapon:temp_set_is_static(false);
        weapon:temp_set_collides(true);
        weapon:set_position(weapon:get_position() + vec2(-1, 0));
        weapon:set_linear_velocity(self:get_linear_velocity());
    end;
    weapon = obj;
    weapon:temp_set_is_static(true);
    weapon:temp_set_collides(false);
    weapon_offset = vec2(0.1, 0);
    weapon_cooldown = 0;
    weapon_number = 3;
end;

local touching_grabbing = false;

function on_collision_start(data)
    if grabbing ~= nil then
        if grabbing.guid == data.other.guid then
            touching_grabbing = true;
            return;
        end;
    end;

    contacts += 1;

    if data.other:get_name() == "Wall" then
        touching_wall = true;
    end;
    if (data.other:get_name() == "Weapon 1") and (weapon_number ~= 1) then
        get_weapon_1(data.other);
    end;
    if (data.other:get_name() == "Weapon 2") and (weapon_number ~= 2) then
        get_weapon_2(data.other);
    end;
    if (data.other:get_name() == "Gravity Gun") and (weapon_number ~= 3) then
        get_gravgun(data.other);
    end;
    if data.other:get_name() == "health_fruit" then
        local hp_value = tonumber(string.match(self:get_name(), "player_(%d+)"))
        if hp_value then
            hp_value = hp_value + 10;
            if hp_value > 100 then
                hp_value = 100;
            end;
            
            self:set_name("player_" .. hp_value);
        end;
        data.other:destroy();
    end;
    if data.other:get_name() == "grenade" then
        grenade_count += 1;
        update_grenade_display();
        data.other:destroy();
    end;
end;

function on_collision_end(data)
    if grabbing ~= nil then
        if grabbing.guid == data.other.guid then
            if not touching_grabbing then
                contacts -= 1;
            end;
            touching_grabbing = false;
            return;
        end;
    end;

    contacts -= 1;
    if contacts < 0 then
        contacts = 0;
    end;
    if data.other:get_name() == "Wall" then
        touching_wall = false;
    end;
end;

--[[
local weapon_item = Scene:add_box({
    position = self:get_position() + vec2(15, 1),
    size = vec2(0.9, 0.2),
    color = 0x50a050,
    is_static = false,
    name = "Weapon 2"
});]]

function spawn_health(pos)
    local health_fruit = Scene:add_box({
        position = pos,
        size = vec2(0.2, 0.2),
        color = 0x00ff00,
        is_static = false,
        name = "health_fruit"
    });
end;

local proj_hash = Scene:add_component({
    name = "Projectile",
    id = "@carroted/platformer/projectile",
    version = "0.1.0",
    code = temp_load_string('./scripts/@carroted/platformer/projectile.lua')
});

local enemy_hash = Scene:add_component({
    name = "Enemy",
    id = "@carroted/platformer/enemy",
    version = "0.1.0",
    code = temp_load_string('./scripts/@carroted/platformer/enemy.lua')
});

local grenade_hash = Scene:add_component({
    name = "Grenade",
    id = "@carroted/platformer/grenade",
    version = "0.1.0",
    code = temp_load_string('./scripts/@carroted/platformer/grenade.lua')
});

function on_start()
    print("start!!");
end;

function spawn_enemy(pos)
    local enemy = Scene:add_box({
        name = "Enemy_100",
        position = pos,
        size = vec2(0.5, 0.5),
        is_static = false,
        color = 0xffa0a0,
    });
    enemy:add_component(enemy_hash);
end;

function spawn_grenade(pos)
    Scene:add_box({
        position = pos,
        size = vec2(0.15, 0.2),
        color = 0x50a050,
        is_static = false,
        name = "grenade",
    });
end;

function on_update()
    crosshair:set_position(Input:pointer_pos());

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

    Scene:temp_set_camera_pos(camera_pos);
    Scene:temp_set_camera_zoom(camera_zoom);

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

    self:set_angle(0);

    --[[
    weapon:set_position(self:get_position() + weapon_offset);

    -- this code rotates weapon from center :( we want it rotate from different point (self position) instead
    local world_position = Input:pointer_pos();
    local global_pos = weapon:get_position();
    weapon:set_angle(math.atan2(world_position.y - global_pos.y, world_position.x - global_pos.x));
    ]]

    if weapon ~= nil then
        local player_pos = self:get_position()
        weapon:set_position(player_pos + weapon_offset)

        -- Adjust rotation to use the player position as the pivot
        local world_position = Input:pointer_pos()
        local angle = math.atan2(world_position.y - player_pos.y, world_position.x - player_pos.x)
        
        -- Set weapon's angle
        weapon:set_angle(angle)
        
        -- Calculate the new position of the weapon based on the angle
        local rotated_offset = vec2(
            weapon_offset.x * math.cos(angle) - weapon_offset.y * math.sin(angle),
            weapon_offset.x * math.sin(angle) + weapon_offset.y * math.cos(angle)
        )
        weapon:set_position(player_pos + rotated_offset)

        if Input:pointer_pressed() then
            if weapon_number ~= 3 then
                if weapon_cooldown <= 0 then
                    launch_projectile();
                end;
            end;
        end;

        if Input:pointer_just_released() and weapon_number == 3 then
            if grabbing ~= nil then
                if prev_line ~= nil then
                    prev_line:destroy();
                end;

                ground_body:destroy();

                prev_line = nil;
                ground_body = nil;
                grabbing = nil;
                spring = nil;
            end;
        end;

        if Input:pointer_just_pressed() and weapon_number == 3 then
            if grabbing == nil then
                local player_pos = self:get_position()
                
                -- Calculate the end point of the weapon
                local weapon_length = 1 -- Length of the weapon (same as size.x in the weapon creation)
                local angle = weapon:get_angle()
                local end_point = player_pos + vec2(
                    weapon_length * math.cos(angle),
                    weapon_length * math.sin(angle)
                );

                local objects_in_circle = Scene:get_objects_in_circle({
                    position = end_point,
                    radius = 0,
                });

                if objects_in_circle[1] ~= nil then
                    if not objects_in_circle[1]:temp_get_is_static() then
                        grabbing = objects_in_circle[1];
                        ground_body = Scene:add_circle({
                            position = end_point,
                            radius = 0.0125,
                            is_static = true,
                            color = 0xffffff,
                        });
                        spring = Scene:add_drag_spring({
                            point = end_point,
                            object_a = ground_body,
                            object_b = grabbing,
                            strength = 200,
                            damping = 1,
                        });
                        ground_body:temp_set_collides(false);
                    end;
                end;
            end;
        end;
    end;

    if grabbing ~= nil then
        if ground_body ~= nil and grabbing ~= nil then
            if prev_line ~= nil then
                prev_line:destroy();
            end;

            local player_pos = self:get_position()
            
            -- Calculate the end point of the weapon
            local weapon_length = 1 -- Length of the weapon (same as size.x in the weapon creation)
            local angle = weapon:get_angle()
            local end_point = player_pos + vec2(
                weapon_length * math.cos(angle),
                weapon_length * math.sin(angle)
            );

            spring:set_target(end_point);
            ground_body:set_position(end_point);

            prev_line = line(end_point,spring:get_world_point_on_object(),0.05,0xffffff,true);
        end;
    end;

    if Input:key_just_pressed("C") then
        spawn_enemy(Input:pointer_pos());
    end;
    if Input:key_just_pressed("V") then
        spawn_health(Input:pointer_pos());
    end;
    if Input:key_just_pressed("E") then
        launch_grenade();
    end;
    if Input:key_just_pressed("G") then
        spawn_grenade(Input:pointer_pos());
    end;
    if Input:key_just_pressed("Q") then
        if weapon ~= nil then
            weapon:temp_set_is_static(false);
            weapon:temp_set_collides(true);
            weapon:set_position(weapon:get_position() + vec2(-1, 0));
            weapon:set_linear_velocity(self:get_linear_velocity());
        end;
        weapon = nil;
        weapon_number = 0;
    end;

    if (weapon_number ~= 3) and (grab_marker ~= nil) then
        grab_marker:destroy();
        grab_marker = nil;
    end;
    if (weapon_number == 3) and (grab_marker == nil) then
        local player_pos = self:get_position()
        -- Calculate the end point of the weapon
        local weapon_length = 1  -- Length of the weapon (same as size.x in the weapon creation)
        local angle = weapon:get_angle()
        local end_point = player_pos + vec2(
            weapon_length * math.cos(angle),
            weapon_length * math.sin(angle)
        );
        grab_marker = Scene:add_circle({
            position = end_point,
            radius = 0.025,
            is_static = true,
            color = 0xffffff,
        });
        grab_marker:temp_set_collides(false);
    elseif weapon_number == 3 then
        local player_pos = self:get_position()
        -- Calculate the end point of the weapon
        local weapon_length = 1  -- Length of the weapon (same as size.x in the weapon creation)
        local angle = weapon:get_angle()
        local end_point = player_pos + vec2(
            weapon_length * math.cos(angle),
            weapon_length * math.sin(angle)
        );
        grab_marker:set_position(end_point);
    end;
end;

function rgb_to_color(r, g, b)
    return r * 0x10000 + g * 0x100 + b;
end

function on_step()
    clear_gizmos();

    local hp_value = tonumber(string.match(self:get_name(), "player_(%d+)"))
    if hp_value then
        --self.color = rgb_to_color(0, math.ceil((hp_value / 100.0) * 255), math.ceil((hp_value / 100.0) * 255));
        if hp_value <= 0 then
            if grenade_display ~= nil then
                for _, data in ipairs(grenade_display) do
                    data.obj:destroy();
                end;
            end;
            if health_bar_fg ~= nil then
                health_bar_fg:destroy();
            end;
            if health_bar_bg ~= nil then
                health_bar_bg:destroy();
            end;
            if weapon ~= nil then
                weapon:temp_set_is_static(false);
                weapon:temp_set_collides(true);
                weapon:set_position(weapon:get_position());
                weapon:set_linear_velocity(self:get_linear_velocity());
            end;
            self:destroy();
            return;
        end;
    end;

    --weapon:set_position(self:get_position() + weapon_offset);
    self:set_angle(0);

    if weapon ~= nil then
        local player_pos = self:get_position()
        weapon:set_position(player_pos + weapon_offset)

        -- Adjust rotation to use the player position as the pivot
        local world_position = Input:pointer_pos()
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
    end;

    if grenade_display ~= nil then
        move_display(grenade_display, self:get_position() + grenade_display_offset);
    end;
    if hp_value ~= prev_hp_value then
        update_health_bar(hp_value);
    elseif health_bar_bg ~= nil then
        health_bar_bg:set_position(self:get_position() + health_bar_offset);
        health_bar_fg:set_position(self:get_position() + health_bar_offset + (vec2(((hp_value / 100.0) * health_bar_width) - health_bar_width, 0)) / 2);
    end;

    prev_hp_value = hp_value;

    if debug then
        --[[for _, offset in ipairs(ground_check_points) do
            gizmo_circle(self:get_position() - offset, 0xff0000);
        end;]]
        gizmo_raycast({
            origin = self:get_position() + vec2((-5.5 * (1 / 12)) - 0.01, -4 * (1 / 12)),
            direction = vec2(0, -1),
            distance = (2 / 12) + 0.01,
            closest_only = false,
        }, 0xff0000);
        gizmo_raycast({
            origin = self:get_position() + vec2((5.5 * (1 / 12)) + 0.01, -4 * (1 / 12)),
            direction = vec2(0, -1),
            distance = (2 / 12) + 0.01,
            closest_only = false,
        }, 0xff0000);
        gizmo_raycast({
            origin = self:get_position() + vec2((-5.5 * (1 / 12)) - 0.01, (-4 * (1 / 12)) - (2 / 12) - 0.01),
            direction = vec2(1, 0),
            distance = (11 * (1 / 12)) + 0.02,
            closest_only = false,
        }, 0xff0000);
        gizmo_circle(self:get_position() + vec2((-5.5 * (1 / 12)) - 0.01, -4 * (1 / 12)), 0xff0000);
        gizmo_circle(self:get_position() + vec2((5.5 * (1 / 12)) + 0.01, -4 * (1 / 12)), 0xff0000);
    end;

    camera_pos = lerp_vec2(camera_pos, self:get_position(), 0.08);

    Scene:temp_set_camera_pos(camera_pos);
    Scene:temp_set_camera_zoom(camera_zoom);
end;

function ground_check()
    local hits1 = Scene:raycast({
        origin = self:get_position() + vec2((-5.5 * (1 / 12)) - 0.01, -4 * (1 / 12)),
        direction = vec2(0, -1),
        distance = (2 / 12) + 0.01,
        closest_only = false,
    });
    if #hits1 > 0 then return true; end;

    local hits2 = Scene:raycast({
        origin = self:get_position() + vec2((5.5 * (1 / 12)) + 0.01, -4 * (1 / 12)),
        direction = vec2(0, -1),
        distance = (2 / 12) + 0.01,
        closest_only = false,
    });
    if #hits2 > 0 then return true; end;

    local hits3 = Scene:raycast({
        origin = self:get_position() + vec2((-5.5 * (1 / 12)) - 0.01, (-4 * (1 / 12)) - (2 / 12) - 0.01),
        direction = vec2(1, 0),
        distance = (11 * (1 / 12)) + 0.02,
        closest_only = false,
    });
    if #hits3 > 0 then return true; end;

    local circle1 = Scene:get_objects_in_circle({
        position = self:get_position() + vec2((-5.5 * (1 / 12)) - 0.01, -4 * (1 / 12)),
        radius = 0,
    });
    if #circle1 > 0 then return true; end;
    local circle2 = Scene:get_objects_in_circle({
        position = self:get_position() + vec2((5.5 * (1 / 12)) + 0.01, -4 * (1 / 12)),
        radius = 0,
    });
    if #circle2 > 0 then return true; end;

    return false;
end

function launch_projectile()
    weapon_cooldown = 4;
    -- Get the player's position and velocity
    local player_pos = self:get_position()
    local player_vel = self:get_linear_velocity()
    
    -- Calculate the end point of the weapon
    local weapon_length = 1.1 / 2 -- Length of the weapon (same as size.x in the weapon creation)
    local angle = weapon:get_angle()
    local end_point = player_pos + vec2(
        weapon_length * math.cos(angle),
        weapon_length * math.sin(angle)
    )

    -- Add the projectile at the calculated end point
    local name = "Projectile";
    local projectile_speed = 10;
    if weapon_number == 2 then
        name = "Rocket";
        projectile_speed = 20;
        weapon_cooldown = 120;
    end;
    print(tostring(end_point));
    local proj = Scene:add_circle({
        position = end_point,
        radius = 0.05,
        color = 0xffa000,
        is_static = false,
        name = name,
    });

    proj:temp_set_group_index(-69);
    proj:set_restitution(1);
    proj:set_friction(0);

    proj:add_component(proj_hash);
    
    -- Calculate the projectile velocity
    local velocity = vec2(
        projectile_speed * math.cos(angle),
        projectile_speed * math.sin(angle)
    ) / 2;
    
    -- Add the player's velocity to the projectile's velocity
    velocity = velocity + player_vel
    
    -- Set the projectile's velocity
    proj:set_linear_velocity(velocity)
end

function launch_grenade()
    if grenade_count < 1 then
        return;
    end;

    grenade_count -= 1;
    update_grenade_display();

    -- Get the player's position and velocity
    local player_pos = self:get_position()
    local player_vel = self:get_linear_velocity()
    
    -- Calculate the end point of the weapon
    local weapon_length = 1.1 / 2 -- Length of the weapon (same as size.x in the weapon creation)
    local world_position = Input:pointer_pos();
    local angle = math.atan2(world_position.y - player_pos.y, world_position.x - player_pos.x);
        
    local end_point = player_pos + vec2(
        weapon_length * math.cos(angle),
        weapon_length * math.sin(angle)
    )

    -- Add the projectile at the calculated end point
    local proj = Scene:add_box({
        position = end_point,
        size = vec2(0.15, 0.2),
        color = 0x50a050,
        is_static = false,
        name = "Grenade",
    });
    proj:set_angle(math.random() * 2 * math.pi);
    local function random_angular_velocity(max)
        local sign = (math.random(0, 1) == 0) and -1 or 1;
        return sign * math.random() * max;
    end
    proj:set_angular_velocity(random_angular_velocity(10));
    proj:temp_set_group_index(-69);
    proj:set_restitution(0);
    proj:set_friction(1);

    proj:add_component(grenade_hash);
    
    -- Calculate the projectile velocity
    local projectile_speed = 10  -- Set the desired speed for the projectile
    local velocity = vec2(
        projectile_speed * math.cos(angle),
        projectile_speed * math.sin(angle)
    ) / 2;
    
    -- Add the player's velocity to the projectile's velocity
    velocity = velocity + player_vel
    
    -- Set the projectile's velocity
    proj:set_linear_velocity(velocity)
end
