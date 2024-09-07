local beam_color = Color:hex(0x33ff47);

local target_beam_length = 2;
local beam_length = 0;
local beam_speed = 0.2;

local point_at_mouse = false;

local enabled = false;
local permanent_controller = false;

function on_event(id, data)
    if id == "@carroted/pylon/permanent_controller" then
        point_at_mouse = true;
        permanent_controller = true;
        local objs = Scene:get_all_objects();
        for i=1,#objs do
            if objs[i]:get_name() == "pylon_weapon_1" then
                objs[i]:temp_set_collides(false);
            end;
        end;
        self:temp_set_collides(false);
    end;
end;

function on_update()
    if Input:key_just_pressed("E") then
        enabled = not enabled;
    end;
    if Input:key_just_pressed("X") then
        if not permanent_controller then
            point_at_mouse = not point_at_mouse;
            local objs = Scene:get_all_objects();
            for i=1,#objs do
                if objs[i]:get_name() == "pylon_weapon_1" then
                    objs[i]:temp_set_collides(not point_at_mouse);
                end;
            end;
            self:temp_set_collides(not point_at_mouse);
        end;
    end;

    if point_at_mouse then
        local self_pos = self:get_position();

        local world_position = Input:pointer_pos();
        local angle = math.atan2(world_position.y - self_pos.y, world_position.x - self_pos.x);
        
        self:set_angle(angle);
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
        is_static = true,
        color = color,
    });
    c:temp_set_collides(false);
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
    local line = Scene:add_box({
        position = pos,
        size = vec2(sx, thickness),
        is_static = static,
        color = color
    });

    line:temp_set_collides(false);
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

        local world_position = Input:pointer_pos();
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
    local direction = vec2(math.cos(angle), math.sin(angle));

    local origin = self:get_position() + (direction * (12.1 * 0.0625));

    local hits = Scene:raycast({
        origin = origin,
        direction = direction,
        distance = beam_length,
        closest_only = false,
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
                component = {
                    name = "Point Light",
                    code = nil,
                },
                parent = line,
                local_position = vec2(0, 0),
                local_angle = 0,
                image = "embedded://textures/point_light.png",
                size = 0.001,
                color = Color:rgba(0,0,0,0),
                light = {
                    color = Color:mix(beam_color, unbeam, i / segments),
                    intensity = 20 * (1 - (i / segments)),
                    radius = 0.18 * (1 - ((i / segments) * 0.5)),
                }
            });
            if i % 5 == 0 then
                Scene:add_attachment({
                    name = "Point Light",
                    component = {
                        name = "Point Light",
                        code = nil,
                    },
                    parent = line,
                    local_position = vec2(0, 0),
                    local_angle = 0,
                    image = "embedded://textures/point_light.png",
                    size = 0.001,
                    color = Color:rgba(0,0,0,0),
                    light = {
                        color = Color:mix(beam_color, unbeam, i / segments),
                        intensity = 0.2 * (1 - ((i / segments) * 0.8)),
                        radius = 1.8,
                        falloff = 10,
                    }
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
            image = "embedded://textures/point_light.png",
            size = 0.001,
            color = Color:rgba(0,0,0,0),
            light = {
                color = Color:mix(beam_color, unbeam, i / segments),
                intensity = 5,
                radius = 0.2,
            }
        });
    end;]]

    local function hit_target(obj, point)
        if obj:get_body_type() ~= BodyType.Static then
            local lin_vel = obj:get_linear_velocity();
            local ang_vel = obj:get_angular_velocity();
            obj:detach();
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
        end;
        if obj:get_name() ~= "Simulo Planet" then
            --gizmo_circle(hits[i].point, Color:rgb(80,80,80), 0.01, "Light");
            local c = gizmo_circle(point, Color:hex(0xffffff), 0.03);
            Scene:add_attachment({
                name = "Point Light",
                component = {
                    name = "Point Light",
                    code = nil,
                },
                parent = c,
                local_position = vec2(0, 0),
                local_angle = 0,
                image = "embedded://textures/point_light.png",
                size = 0.001,
                color = Color:rgba(0,0,0,0),
                light = {
                    color = 0xffffff,
                    intensity = 5,
                    radius = 5,
                    falloff = 10,
                }
            });
        end;
    end;

    for i=1,#hits do
        hit_target(hits[i].object, hits[i].point)
    end;

    local circle = Scene:get_objects_in_circle({
        position = origin,
        radius = 0
    });
    for i=1,#circle do
        if circle[i].guid ~= self.guid then
            hit_target(circle[i], origin);
        end;
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
end;