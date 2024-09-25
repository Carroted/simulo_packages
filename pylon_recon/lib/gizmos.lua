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

function gizmo_line(line_start,line_end,thickness,color,static)
    local line = line(line_start,line_end,thickness,color,static);
    table.insert(gizmos, line);
end;