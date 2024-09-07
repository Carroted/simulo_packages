local function spawn_small_crate(pos)
    local crate = Scene:add_box({
        position = pos,
        size = vec2(11/12, 11/12),
        color = Color:rgba(0,0,0,0),
        is_static = false,
    });
    crate:set_friction(0.75);
    crate:set_restitution(0);

    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = nil,
        },
        parent = crate,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "~/packages/@carroted/pylon_recon/assets/textures/crate_small.png",
        size = 1 / 12,
        color = Color:hex(0xffffff),
    });
end;

return spawn_small_crate;