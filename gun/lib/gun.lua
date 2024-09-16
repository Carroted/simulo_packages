local cooldown = 0;
local cooldown_value = 10;

function explosion(point)
    local hash = Scene:add_component({
        code = require('./packages/@carroted/characters/lib/explosion.lua', 'string')
    });
    local c = Scene:add_circle({
        position = point,
        radius = 0.2,
        color = 0xffffff,
        is_static = true;
    });
    c:temp_set_collides(false);
    c:add_component(hash);
    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = nil,
        },
        parent = c,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/core/assets/textures/point_light.png",
        size = 0.5 / 512,
        color = Color:rgba(0,0,0,0),
        light = {
            color = 0xffffff,
            intensity = 15,
            radius = 20,
            falloff = 4,
        }
    });
end;

local hash = Scene:add_component({
    name = "Laser",
    id = "@carroted/gun/laser",
    version = "0.1.0",
    code = require('./packages/@carroted/gun/lib/laser.lua', 'string')
});

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

    line:add_component(hash);

    return line
end;

function step(cast, distance_so_far, reflect_tint, should_draw)
    if cast.distance <= 0 then
        return;
    end;

    local hits = Scene:raycast(cast);
    if #hits == 0 then
        if should_draw then draw_line(cast.origin, cast.origin + (cast.direction:normalize() * cast.distance), 0.0125, 0xffffff, true); end;
        return nil;
    end;

    local distance = (hits[1].point - cast.origin):magnitude();

    --gizmo_raycast(cast, 0xff0000);
    if should_draw then draw_line(cast.origin, hits[1].point, 0.0125, 0xffffff, true); end;

    if hits[1].object:get_name() ~= "mirror" then
        return {
            object = hits[1].object,
            distance = distance_so_far + distance,
            color = hits[1].object:get_color(),
            reflect_tint = reflect_tint,
            point = hits[1].point,
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

function on_update()
    cooldown -= 1;
    if Input:key_just_pressed("F") then
        cooldown = 0;
    end;

    if cooldown <= 0 then
        if Input:key_pressed("F") then
            cooldown = cooldown_value;
            local realer = step({
                origin = self:get_world_point(vec2(0.25, 0.114)),
                direction = self:get_right_direction(),
                distance = 50,
                closest_only = true,
            }, 0, 0, true);
            self:apply_linear_impulse_to_center(-self:get_right_direction() / 10);
            if realer ~= nil then
                explosion(realer.point);
            end;
        end;
    end;
end;