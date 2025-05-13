local function spawn_small_crate(pos)
    local crate = Scene:add_box({
        position = pos,
        size = vec2(11/12, 11/12),
        color = Color:rgba(0,0,0,0),
        friction = 0.75,
        restitution = 0,
    });

    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = "",
            id = "wanda",
            version = "0.1.0",
        },
        parent = crate,
        local_position = vec2(0, 0),
        local_angle = 0,
        images = {{
            texture = require("./packages/@carroted/pylon_recon/assets/textures/crate_small.png"),
            scale = vec2(1/12, 1/12),
        }},
        collider = { shape_type = "circle", radius = 0.1, }
    });
end;

return spawn_small_crate;
