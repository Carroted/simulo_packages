local hp = 100;

local left_eye = nil;
local right_eye = nil;

local enabled = false;
local permanent_controller = false;

function on_event(id, data)
    if id == "damage" then
        if (data ~= nil) and (data.amount ~= nil) then
            hp -= data.amount;
            update_health_bar(hp);
            print('damaged, new hp is ' .. tostring(hp));
        end;
    elseif id == "@carroted/pylon/objects" then
        left_eye = Scene:get_object_by_guid(data.left_eye);
        right_eye = Scene:get_object_by_guid(data.right_eye);
    elseif id == "@carroted/pylon/permanent_controller" then
        enabled = true;
        permanent_controller = true;

        self:set_angle_locked(true);
        self:set_angle(0);

        left_eye:detach();
        right_eye:detach();
        left_eye:temp_set_collides(false);
        right_eye:temp_set_collides(false);
        left_eye:set_body_type(BodyType.Static);
        right_eye:set_body_type(BodyType.Static);

        update_health_bar(hp);
    end;
end;

local speed = 4.1;
local jump_force = 5.1;

local debug = false;

local camera_pos = self:get_position() + vec2(0, 0.8);
local camera_zoom = 0.02;

function screen_to_world(pos)
    return (pos / 216) + camera_pos;
end;

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
    health_bar_fg = nil;

    if not enabled then
        health_bar_bg = nil;
        return;
    end;

    health_bar_bg = Scene:add_box({
        position = health_bg_pos(value),
        size = vec2(health_bar_width, health_bar_height),
        color = 0x000000,
        is_static = true,
    });
    health_bar_bg:temp_set_collides(false);
    if value > 0 then
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
end;

--update_health_bar(hp);

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

function on_update()
    if Input:key_just_pressed("R") then
        require('./packages/@carroted/pylon/scripts/demo/main.lua');
        return;
    end;

    if Input:key_just_pressed("X") then
        if not permanent_controller then
            enabled = not enabled;
            self:set_angle_locked(enabled);
            if enabled then self:set_angle(0); end;

            if enabled then
                left_eye:detach();
                right_eye:detach();
                left_eye:temp_set_collides(false);
                right_eye:temp_set_collides(false);
                left_eye:set_body_type(BodyType.Static);
                right_eye:set_body_type(BodyType.Static);
                camera_pos = self:get_position() + vec2(0, 0.8);
            else
                left_eye:set_position(self:get_position() + vec2(-1.8 * 0.0625, (10 * 0.0625)));
                right_eye:set_position(self:get_position() + vec2(1.8 * 0.0625, (10 * 0.0625)));
                left_eye:temp_set_collides(true);
                right_eye:temp_set_collides(true);
                left_eye:set_body_type(BodyType.Dynamic);
                right_eye:set_body_type(BodyType.Dynamic);
                left_eye:bolt_to(self);
                right_eye:bolt_to(self);
            end;

            update_health_bar(hp);
        end;
    end;

    if Input:key_just_pressed("Q") then
        debug = not debug;
    end;

    if not enabled then return; end;

    if health_bar_fg ~= nil then
        health_bar_fg:set_position(health_fg_pos(100));
    end;
    health_bar_bg:set_position(health_bg_pos(100));

    Camera:set_position(camera_pos);
    Camera:set_orthographic_scale(camera_zoom);

    local current_vel = self:get_linear_velocity();
    local update_vel = false;

    if Input:key_pressed("D") then
        if current_vel.x < speed then
            current_vel.x = speed;
            update_vel = true;
        end;
    end;
    if Input:key_pressed("A") then
        if current_vel.x > -speed then
            current_vel.x = -speed;
            update_vel = true;
        end;
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
end;

function on_step()
    clear_gizmos();

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

        if health_bar_fg ~= nil then
            health_bar_fg:set_position(health_fg_pos(hp));
        end;
        health_bar_bg:set_position(health_bg_pos(hp));

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