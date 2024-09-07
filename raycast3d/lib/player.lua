local laser_color = 0xff6a6a;

function rgba_to_hsva(color)
    local r, g, b, a = color.r / 255, color.g / 255, color.b / 255, color.a

    local maxVal = math.max(r, g, b)
    local minVal = math.min(r, g, b)
    local delta = maxVal - minVal

    local h = 0
    if delta ~= 0 then
        if maxVal == r then
            h = (g - b) / delta
        elseif maxVal == g then
            h = 2 + (b - r) / delta
        else
            h = 4 + (r - g) / delta
        end
        h = h * 60
        if h < 0 then
            h = h + 360
        end
    end

    local s = 0
    if maxVal ~= 0 then
        s = delta / maxVal
    end

    local v = maxVal

    -- Convert to the ranges you're using
    h = h -- stays 0-360
    s = s * 255 -- scale to 0-255
    v = v * 255 -- scale to 0-255

    return h, s, v, a
end

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
        radius = 0.05,
        is_static = true,
        color = color,
    });
    c:temp_set_collides(false);
    table.insert(gizmos, c);
end;

function gizmo_raycast(tableo, color)
    draw_line(tableo.origin, tableo.origin + (tableo.direction:normalize() * tableo.distance), 0.05, color, true);
end;

function draw_line(line_start, line_end, thickness, color, static)
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

    table.insert(gizmos, line);

    return line
end;

-- Function to calculate the dot product of two vec2 vectors
local function dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y
end

-- Function to multiply a vec2 by a scalar
local function mul_scalar(v, scalar)
    return vec2(v.x * scalar, v.y * scalar)
end

-- Function to subtract one vec2 from another
local function sub(v1, v2)
    return vec2(v1.x - v2.x, v1.y - v2.y)
end

-- Function to reflect a vector `I` across a surface normal `N`
local function reflect(I, N)
    -- R = I - 2 * (dot(I, N)) * N
    local dotIN = dot(I, N)
    local reflectDir = sub(I, mul_scalar(N, 2 * dotIN))
    return reflectDir
end

local x_move = 0;
local y_move = 0;
local z_spin = 0;
local move_speed = 2;
local spin_speed = 1;

function on_update()
    -- Reset movement and spin values
    x_move = 0;
    y_move = 0;
    z_spin = 0;

    -- Move up
    if Input:key_pressed("W") then
        y_move = move_speed;
    end

    -- Move down
    if Input:key_pressed("S") then
        y_move = -move_speed;
    end

    -- Move left
    if Input:key_pressed("A") then
        x_move = -move_speed;
    end

    -- Move right
    if Input:key_pressed("D") then
        x_move = move_speed;
    end

    -- Spin left
    if Input:key_pressed("ArrowLeft") then
        z_spin = spin_speed;
    end

    -- Spin right
    if Input:key_pressed("ArrowRight") then
        z_spin = -spin_speed;
    end
end;

function transform_vector(vector, angle)
    local x = vector.x * math.cos(angle) - vector.y * math.sin(angle)
    local y = vector.x * math.sin(angle) + vector.y * math.cos(angle)
    return vec2(x, y)
end

function on_step()
    clear_gizmos();

    local angle = self:get_angle();

    -- Combine x_move and y_move into a single vector and transform it based on the camera's angle
    local move_vector = vec2(x_move, y_move)
    local transformed_vector = transform_vector(move_vector, angle)

    self:set_linear_velocity(transformed_vector)
    self:set_angular_velocity(z_spin)

    angle -= 100 * 0.02 * 0.5 - math.rad(90);

    local offset = 0;

    local forward = transform_vector(vec2(0, 1), self:get_angle());
    local right = transform_vector(vec2(-1, 0), self:get_angle());

    local ray_offset = 0;
    local ray_gap = 0.005;

    local self_pos = self:get_position();

    for i=1,150 do
        local realer = step({
            origin = self_pos,
            direction = forward + (right * ray_offset) + (-right * (150 * 0.5) * ray_gap),
            distance = 50,
            closest_only = true,
        }, 0, 0, (i == 1) or (i == 150));

        if realer == nil then
            --[[local box = Scene:add_box({
                position = vec2(0 + offset + (0.25 * 150) - 0.25, 0),
                size = vec2(0.5, 50),
                color = 0x000000,
                is_static = true,
            });
            box:temp_set_collides(false);
            table.insert(gizmos, box);]]
        else
            local box1 = Scene:add_box({
                position = vec2(0 + offset + (0.25 * 150) - 0.25, 0, 0),
                size = vec2(0.5, 50),
                color = Color:mix(Color:rgba(158, 159, 159, 0), Color:hex(0x9e9f9f), math.min(1, realer.reflect_tint * 0.1)),
                is_static = true,
            });
            box1:temp_set_collides(false);
            table.insert(gizmos, box1);

            local box = Scene:add_box({
                position = vec2(0 + offset + (0.25 * 150) - 0.25, 0, 0),
                size = vec2(0.5, math.min(50, 50 / realer.distance)),
                color = realer.color,
                is_static = true,
            });
            box:temp_set_collides(false);
            table.insert(gizmos, box);
        end;

        offset -= 0.5;
        ray_offset += ray_gap;
    end;
end;

function step(cast, distance_so_far, reflect_tint, should_draw)
    if cast.distance <= 0 then
        return;
    end;

    local hits = Scene:raycast(cast);
    if #hits == 0 then
        if should_draw then draw_line(cast.origin, cast.origin + (cast.direction:normalize() * cast.distance), 0.0125, 0xff6a6a, true); end;
        return nil;
    end;

    local distance = (hits[1].point - cast.origin):magnitude();

    --gizmo_raycast(cast, 0xff0000);
    if should_draw then draw_line(cast.origin, hits[1].point, 0.0125, 0xff6a6a, true); end;

    if hits[1].object:get_name() ~= "mirror" then
        return {
            object = hits[1].object,
            distance = distance_so_far + distance,
            color = shade(hits[1].normal, hits[1].object:get_color(), reflect_tint),
            reflect_tint = reflect_tint
        };
    end;

    --draw_line(hits[1].point, hits[1].point + hits[1].normal, 0.05, 0x0000ff, true);

    local reflected = reflect(cast.direction, hits[1].normal);

    --draw_line(hits[1].point, hits[1].point + reflected, 0.05, 0xffff00, true);

    return step({
        origin = hits[1].point,
        direction = reflected,
        distance = cast.distance - distance,
        closest_only = true,
    }, distance_so_far + distance, reflect_tint + 1, should_draw);
end;

function shade(normal, color, reflect_tint)
    -- Step 1: Convert the normal to an angle
    local angle = math.atan2(normal.y, normal.x)

    -- Step 2: Convert angle to a number from 0 to 1
    local factor = math.max(math.min((math.sin(angle) + 1) / 2, 1), 0);

    -- Step 3: Convert the color from RGB to HSVA
    local h, s, v, a = rgba_to_hsva(color)

    -- Adjust V by 0.1 and S by -0.1
    v = math.min(255, math.max(0, v - 40)) -- Clamp v between 0 and 255
    s = math.min(255, math.max(0, s + 40)) -- Clamp s between 0 and 255

    -- Step 4: Mix the original color with the adjusted HSVA color
    local adjusted_color = Color:hsva(h, s, v, a)
    local final_color = Color:mix(color, adjusted_color, factor)

    final_color = Color:mix(final_color, Color:hex(0x9e9f9f), math.min(1, reflect_tint * 0.1));

    -- Step 5: Return the final color
    return final_color
end
