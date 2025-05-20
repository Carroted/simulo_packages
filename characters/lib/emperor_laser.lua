local beam_color = Color:hex(0xe07641);

local player = Scene:get_host();

local target_beam_length = 3.5;
local beam_length = 0;
local beam_speed = 0.2;

local crackle = Scene:add_audio({
    asset = require('@carroted/characters/assets/sounds/static3.flac'),
    position = self:get_position(),
    looping = true,
    volume = 0,
    pitch = 2,
});
local crackle2 = Scene:add_audio({
    asset = require('core/assets/sounds/spark.flac'),
    position = self:get_position(),
    looping = true,
    volume = 0,
    pitch = 1.1,
});

local enabled = false;

function on_update()
    if player:key_just_pressed("F") then
        enabled = not enabled;
    end;
end;

local gizmos = {};

local beam_parts = nil;

function clear_gizmos()
    for i=1,#gizmos do
        gizmos[i]:destroy();
    end;
    gizmos = {};
end;

function gizmo_circle(pos, color, r)
    local c = Scene:add_circle({
        position = pos,
        radius = r,
        body_type = BodyType.Static,
        collision_layers = {},
        color = color,
    });
    table.insert(gizmos, c);
    return c;
end;

function gizmo_raycast(tableo, color)
    draw_line(tableo.origin, tableo.origin + (tableo.direction:normalize() * tableo.distance), 0.05, color, true, true);
end;

function draw_line(line_start, line_end, thickness, color, static, gizmo)
    local pos = (line_start + line_end) / 2;
    local sx = (line_start - line_end):magnitude();
    local relative_line_end = line_end - pos;
    local rotation = math.atan(relative_line_end.y / relative_line_end.x)
    local body_type = BodyType.Dynamic;
    if static then
        body_type = BodyType.Static;
    end;
    local line = Scene:add_box({
        position = pos,
        size = vec2(sx, thickness),
        body_type = body_type,
        collision_layers = {},
        color = color
    });

    line:set_angle(rotation);

    if gizmo then
        table.insert(gizmos, line);
    end;

    return line
end;

function vec2_dot(v1, v2)
    return (v1.x * v2.x) + (v1.y * v2.y);
end;

function on_step()
    clear_gizmos();

    if point_at_mouse then
        local self_pos = self:get_position();

        local world_position = player:pointer_pos();
        local angle = math.atan2(world_position.y - self_pos.y, world_position.x - self_pos.x);
        
        self:set_angle(angle);
    end;

    if enabled then
        beam_length += beam_speed;
        beam_length = math.min(beam_length, target_beam_length);
    else
        beam_length -= beam_speed;
        beam_length = math.max(beam_length, 0);
    end;

    if beam_length < 0.05 then
        if beam_parts ~= nil then
            for i=1,#beam_parts do
                beam_parts[i]:destroy();
            end;
            beam_parts = nil;
        end;
        return;
    end;

    local angle = self:get_angle();
    local direction = self:get_right_direction();

    local origin = self:get_world_point(vec2(0.47 / 2, 0));

    local hits = Scene:raycast({
        origin = origin,
        direction = direction,
        distance = beam_length,
        closest_only = false,
        collision_layers = self:get_collision_layers(),
    });

    local segments = 50;

    local unbeam = Color:rgba(beam_color.r, beam_color.g, beam_color.b, 0);

    if beam_parts == nil then
        beam_parts = {};
        print("initllaizizigng beamparts")
        
        for i=1,segments do
            local line = draw_line(origin + (((direction * target_beam_length) / segments) * (i - 1)), origin + (((direction * target_beam_length) / segments) * i), 0.03, Color:mix(beam_color, unbeam, i / segments), true, false);
            Scene:add_attachment({
                name = "Point Light",
                parent = line,
                local_position = vec2(0, 0),
                local_angle = 0,
                lights = {{
                    color = Color:mix(beam_color, unbeam, i / segments),
                    intensity = 20 * (1 - (i / segments)),
                    radius = 0.18 * (1 - ((i / segments) * 0.5)),
                }},
            });
            if i % 5 == 0 then
                Scene:add_attachment({
                    name = "Point Light",
                    parent = line,
                    local_position = vec2(0, 0),
                    local_angle = 0,
                    lights = {{
                        color = Color:mix(beam_color, unbeam, i / segments),
                        intensity = 0.2 * (1 - ((i / segments) * 0.8)),
                        radius = 1.8,
                        falloff = 10,
                    }},
                });
            end;
            table.insert(beam_parts, line);
        end;
    end;

    for i=1,#beam_parts do
        beam_parts[i]:set_position(origin + (((direction * target_beam_length) / segments) * (i - 0.5)));
        beam_parts[i]:set_angle(angle);
    end;

    --[[
    local segments = 100;

    local unbeam = Color:rgba(beam_color.r, beam_color.g, beam_color.b, 0);
    
    for i=1,segments do
        local line = draw_line(origin + (((direction * beam_length) / segments) * (i - 1)), origin + (((direction * beam_length) / segments) * i), 0.03, Color:mix(beam_color, unbeam, i / segments), true);
        Scene:add_attachment({
            name = "Point Light",
            component = {
                name = "Point Light",
                code = nil,
            },
            parent = line,
            local_position = vec2(0, 0),
            local_angle = 0,
            image = "./packages/core/assets/textures/point_light.png",
            size = 0.001,
            color = Color:rgba(0,0,0,0),
            light = {
                color = Color:mix(beam_color, unbeam, i / segments),
                intensity = 5,
                radius = 0.2,
            }
        });
    end;]]

    local hit_anything = false;

    local function hit_target(obj, point)
        if obj:get_body_type() ~= BodyType.Static then
            local lin_vel = obj:get_linear_velocity();
            local ang_vel = obj:get_angular_velocity();
            --obj:detach();
            obj:set_linear_velocity(lin_vel);
            obj:set_angular_velocity(ang_vel);

            local object_position = obj:get_position();
            local hit_to_origin = object_position - origin;

            -- Determine the perpendicular direction
            local perp_direction = vec2(-direction.y, direction.x); -- Perpendicular direction
            local dot_product = vec2_dot(hit_to_origin, perp_direction);

            -- Decide which direction to push based on the dot product
            local push_direction = perp_direction
            if dot_product < 0 then
                push_direction = -perp_direction
            end

            obj:apply_force_to_center(push_direction * 1);

            obj:send_event("damage", {
                amount = 80
            });
            obj:send_event("activate", {
                power = 150,
                points = {point},
            });

            local joints = obj:get_joints();
            for i=1,#joints do
                joints[i]:destroy();
            end;

            hit_anything = true;
        end;
        if obj:get_name() ~= "Simulo Planet" then
            --gizmo_circle(hits[i].point, Color:rgb(80,80,80), 0.01, "Light");
            local c = gizmo_circle(point, Color:hex(0xffffff), 0.03);
            Scene:add_attachment({
                name = "Point Light",
                parent = c,
                local_position = vec2(0, 0),
                local_angle = 0,
                lights = {{
                    color = 0xffffff,
                    intensity = 5,
                    radius = 5,
                    falloff = 10,
                }},
            });
            hit_anything = true;
        end;
    end;

    for i=1,#hits do
        hit_target(hits[i].object, hits[i].point)
    end;

    local circle = Scene:get_objects_in_circle({
        position = origin,
        radius = 0,
        collision_layers = self:get_collision_layers(),
    });
    for i=1,#circle do
        if circle[i].guid ~= self.guid then
            hit_target(circle[i], origin);
        end;
    end;

    if hit_anything then
        crackle:set_volume(0.05);
        crackle2:set_volume(0.4);
    else
        crackle:set_volume(0);
        crackle2:set_volume(0);
    end;
end;

function on_destroy()
    if beam_parts ~= nil then
        for i=1,#beam_parts do
            beam_parts[i]:destroy();
        end;
        beam_parts = nil;
    end;
    clear_gizmos();
    crackle:destroy();
    crackle2:destroy();
end;