local overlay = Scene:add_attachment({
    name = "Image",
    component = {
        name = "Image",
        code = nil,
    },
    parent = self,
    local_position = vec2(0, 0),
    local_angle = 0,
    image = "./packages/@carroted/pylon_recon/assets/textures/weapons/flingstick_overlay.png",
    size = 1 / 12,
    color = Color:rgba(0,0,0,0),
});

local light_overlay = nil;

function on_save()
    return {
        overlay = overlay,
        light_overlay = light_overlay,
    };
end;

function on_start(saved_data)
    if saved_data ~= nil then
        overlay = saved_data.overlay;
        light_overlay = saved_data.light_overlay;
    end;
end;

function set_overlay_enabled(enabled)
    if enabled then
        overlay:set_color(Color:hex(0xffffff));

        if light_overlay ~= nil then
            light_overlay:destroy();
        end;

        light_overlay = Scene:add_attachment({
            name = "Image",
            component = {
                name = "Image",
                code = nil,
            },
            parent = self,
            local_position = vec2(-9.5/12, 0),
            local_angle = 0,
            image = "./packages/@carroted/pylon_recon/assets/textures/weapons/flingstick_overlay.png",
            size = 1 / 12,
            color = Color:rgba(0,0,0,0),
            light = {
                color = Color:hex(0xca67ff),
                intensity = 0.3,
                radius = 2
            },
        });
    else
        overlay:set_color(Color:rgba(0,0,0,0));
        if light_overlay ~= nil then
            light_overlay:destroy();
        end;
        light_overlay = nil;
    end;
end;

function on_collision_start(data)
    data.other:send_event("@carroted/pylon_recon/weapon/pickup", {
        weapon = {
            id = "flingstick",
            -- ...
        },
        guid = self.guid,
    });
end;

function on_event(id, data)
    if id == "@carroted/pylon_recon/weapon/set_overlay_enabled" then
        set_overlay_enabled(data.enabled);
    end;
end;