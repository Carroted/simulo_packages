local hp = 100;

local weapon = nil;

local fire_cooldown = 5;
local current_cooldown = 0;

function on_event(id, data)
    if id == "damage" then
        if (data ~= nil) and (data.amount ~= nil) then
            hp -= data.amount;
            --update_health_bar(hp);
            if hp <= 0 then
                weapon:temp_set_collides(true);
                for i=1,10 do
                    Scene:add_circle({
                        position = self:get_position() + vec2(0, 0.55),
                        radius = 0.1,
                        is_static = false,
                        color = self:get_color()
                    });
                end;
                self:destroy();
            end;
        end;
    elseif id == "@carroted/pylon/objects" then
        weapon = Scene:get_object_by_guid(data.weapon);
    end;
end;

local target = nil;

local speed = 4;
local jump_force = 5.1;

local debug = false;

local health_bar_fg = nil;
local health_bar_bg = nil;
local health_bar_width = 0.8 * 3;
local health_bar_height = 0.05 * 2;

function health_fg_pos(value)
    return screen_to_world(vec2(-1920, 1080))
        + (vec2(health_bar_width, -health_bar_height) / 2)
        + vec2(0.2,-0.2)
        + (vec2(((value / 100.0) * health_bar_width) - health_bar_width, 0)) / 2;
end;

function health_bg_pos(value)
    return screen_to_world(vec2(-1920, 1080))
        + (vec2(health_bar_width, -health_bar_height) / 2)
        + vec2(0.2,-0.2);
end;

function update_health_bar(value)
    if health_bar_fg ~= nil and (not health_bar_fg:is_destroyed()) then
        health_bar_fg:destroy();
    end;
    if health_bar_bg ~= nil and (not health_bar_bg:is_destroyed()) then
        health_bar_bg:destroy();
    end;
    health_bar_bg = Scene:add_box({
        position = health_bg_pos(value),
        size = vec2(health_bar_width, health_bar_height),
        color = 0x000000,
        is_static = true,
    });
    health_bar_bg:temp_set_collides(false);
    health_bar_fg = Scene:add_box({
        position = health_fg_pos(value),
        size = vec2((value / 100.0) * health_bar_width, health_bar_height),
        color = 0xff9a52,
        is_static = true,
    });
    health_bar_fg:temp_set_collides(false);

    for i=1,10 do
        Scene:add_attachment({
            name = "Point Light",
            component = {
                name = "Point Light",
                code = nil,
            },
            parent = health_bar_fg,
            local_position = vec2((((i - 0.5) / 10) * health_bar_width) - (health_bar_width / 2), 0),
            local_angle = 0,
            image = "embedded://textures/point_light.png",
            size = 0.001,
            color = Color:rgba(0,0,0,0),
            light = {
                color = 0xff9a52,
                intensity = 1,
                radius = 0.3,
            }
        });
    end;
end;

--update_health_bar(hp);

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

function on_update()
    self:set_angle_locked(hp > 0);

    if Input:key_just_pressed("Q") then
        debug = not debug;
    end;

    if hp <= 0 then return; end;

    --health_bar_fg:set_position(health_fg_pos(100));
    --health_bar_bg:set_position(health_bg_pos(100));

    if target ~= nil then
        local target_pos = target:get_position();
        local self_pos = self:get_position();

        local current_vel = self:get_linear_velocity();
        local update_vel = false;

        if target_pos.x > self_pos.x then
            if current_vel.x < speed then
                current_vel.x = speed;
                update_vel = true;
            end;
        end;
        if target_pos.x < self_pos.x then
            if current_vel.x > -speed then
                current_vel.x = -speed;
                update_vel = true;
            end;
        end;

        local grounded = ground_check();

        if (target_pos.y > self_pos.y) and grounded then
            if current_vel.y < jump_force then
                current_vel.y = jump_force;
                update_vel = true;
            end;
        end;

        if update_vel then
            self:set_linear_velocity(current_vel);
        end;
    end;
end;

function on_step()
    clear_gizmos();

    target = nil;
    local objs = Scene:get_objects_in_circle({
        position = self:get_position(),
        radius = 7,
    });
    for i=1,#objs do
        if objs[i]:get_name() == "Pylon" then
            target = objs[i];
            break;
        end;
    end;

    if (target ~= nil) and (hp > 0) then
        local self_pos = weapon:get_position();

        local world_position = target:get_position() + vec2(0, 0.55);
        local angle = math.atan2(world_position.y - self_pos.y, world_position.x - self_pos.x);
        
        weapon:set_angle(angle);

        if current_cooldown <= 0 then
            current_cooldown = fire_cooldown;
            local direction = vec2(math.cos(angle), math.sin(angle));

            local origin = weapon:get_position() + (direction * (12.1 * 0.0625));

            local circle = Scene:get_objects_in_circle({
                position = origin,
                radius = 0
            });

            if #circle == 0 then
                local hits = Scene:raycast({
                    origin = origin,
                    direction = direction,
                    distance = 10,
                    closest_only = false,
                });
                gizmo_raycast({
                    origin = origin,
                    direction = direction,
                    distance = 10,
                    closest_only = false,
                }, 0xff0000);

                for i=1,#hits do
                    if hits[i].object:get_name() == "Pylon" then
                        hits[i].object:send_event("damage", {
                            amount = 1
                        });
                    end;
                end;
            else
                for i=1,#circle do
                    if circle[i]:get_name() == "Pylon" then
                        circle[i]:send_event("damage", {
                            amount = 1
                        });
                    end;
                end;
            end;
        else
            current_cooldown -= 1;
        end;
    end;

    if debug then
        --[[for _, offset in ipairs(ground_check_points) do
            gizmo_circle(self:get_position() - offset, 0xff0000);
        end;]]
        gizmo_raycast({
            origin = self:get_position() + vec2(-0.46875 - 0.01, (-4 * (1 / 12) + 0.5)),
            direction = vec2(0, -1),
            distance = (2 / 12) + 0.01,
            closest_only = false,
        }, 0xff0000);
        gizmo_raycast({
            origin = self:get_position() + vec2(0.46875 + 0.01, (-4 * (1 / 12) + 0.5)),
            direction = vec2(0, -1),
            distance = (2 / 12) + 0.01,
            closest_only = false,
        }, 0xff0000);
        gizmo_raycast({
            origin = self:get_position() + vec2(-0.46875 - 0.01, (-4 * (1 / 12) + 0.5) - (2 / 12) - 0.01),
            direction = vec2(1, 0),
            distance = 0.9375 + 0.02,
            closest_only = false,
        }, 0xff0000);
        gizmo_circle(self:get_position() + vec2(-0.46875 - 0.01, (-4 * (1 / 12) + 0.5)), 0xff0000);
        gizmo_circle(self:get_position() + vec2(0.46875 + 0.01, (-4 * (1 / 12) + 0.5)), 0xff0000);
    end;

    if enabled then
        --local x_offset = 0;
        --if Input:key_pressed("D") then

        local self_pos = self:get_position();

        camera_pos = lerp_vec2(camera_pos, self:get_position() + vec2(self:get_linear_velocity().x / 2, 0.8), 0.02);

        health_bar_fg:set_position(health_fg_pos(100));
        health_bar_bg:set_position(health_bg_pos(100));

        Camera:set_position(camera_pos);
        Camera:set_orthographic_scale(camera_zoom);

        local left_eye_pos = self_pos + vec2(-1.8 * 0.0625, (10 * 0.0625));
        local right_eye_pos = self_pos + vec2(1.8 * 0.0625, (10 * 0.0625));

        left_eye_pos = lerp_vec2(left_eye_pos, Input:pointer_pos(), 0.007);
        right_eye_pos = lerp_vec2(right_eye_pos, Input:pointer_pos(), 0.007);

        left_eye:set_position(left_eye_pos);
        right_eye:set_position(right_eye_pos);
    end;
end;

function ground_check()
    local hits1 = Scene:raycast({
        origin = self:get_position() + vec2(-0.46875 - 0.01, (-4 * (1 / 12) + 0.5)),
        direction = vec2(0, -1),
        distance = (2 / 12) + 0.01,
        closest_only = false,
    });
    if #hits1 > 0 then return true; end;

    local hits2 = Scene:raycast({
        origin = self:get_position() + vec2(0.46875 + 0.01, (-4 * (1 / 12) + 0.5)),
        direction = vec2(0, -1),
        distance = (2 / 12) + 0.01,
        closest_only = false,
    });
    if #hits2 > 0 then return true; end;

    local hits3 = Scene:raycast({
        origin = self:get_position() + vec2(-0.46875 - 0.01, (-4 * (1 / 12) + 0.5) - (2 / 12) - 0.01),
        direction = vec2(1, 0),
        distance = 0.9375 + 0.02,
        closest_only = false,
    });
    if #hits3 > 0 then return true; end;

    local circle1 = Scene:get_objects_in_circle({
        position = self:get_position() + vec2(-0.46875 - 0.01, (-4 * (1 / 12) + 0.5)),
        radius = 0,
    });
    if #circle1 > 0 then return true; end;
    local circle2 = Scene:get_objects_in_circle({
        position = self:get_position() + vec2(0.46875 + 0.01, (-4 * (1 / 12) + 0.5)),
        radius = 0,
    });
    if #circle2 > 0 then return true; end;

    return false;
end;