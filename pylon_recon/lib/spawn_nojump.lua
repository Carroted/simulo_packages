local function spawn_nojump(center, count, horizontal)
    local center_count = count - 2;
    
    if center_count < 0 then
        center_count = 0;
        count = 2;
    end;

    local height = 13 / 12;
    height += center_count; -- center height is 12, 12/12 is 1
    height += 13 / 12;

    local box = Scene:add_box({
        position = center,
        size = vec2((14 / 12), height),
        color = 0xff0000,
        body_type = BodyType.Static,
        name = "nojump"
    });
    box:set_restitution(0);
    if horizontal then
        box:set_angle(math.rad(90));
    end;

    Scene:add_attachment({
        name = "Image",
        parent = box,
        local_position = vec2(0, (height / 2) - (13 / 12 / 2)),
        local_angle = 0,
        images = {{
            texture = require("./packages/@carroted/pylon_recon/assets/textures/nojump_top.png"),
            scale = vec2(1/12, 1/12),
        }},
    });

    Scene:add_attachment({
        name = "Image",
        parent = box,
        local_position = vec2(0, (-height / 2) + (13 / 12 / 2)),
        local_angle = 0,
        images = {{
            texture = require("./packages/@carroted/pylon_recon/assets/textures/nojump_bottom.png"),
            scale = vec2(1/12, 1/12),
        }},
    });

    for i=1,center_count do
        Scene:add_attachment({
            name = "Image",
            parent = box,
            local_position = vec2(0, (height / 2) - (13 / 12) - (0.5 * ((i - 0.5) * 2))),
            local_angle = 0,
            images = {{
                texture = require("./packages/@carroted/pylon_recon/assets/textures/nojump_center.png"),
                scale = vec2(1/12, 1/12),
            }},
        });
    end;
end;

return spawn_nojump;