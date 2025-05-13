local overlay = Scene:add_attachment({
    name = "Image",
    parent = self,
    local_position = vec2(0, 0),
    local_angle = 0,
    images = {{
        texture = require("./packages/@carroted/pylon_recon/assets/textures/weapons/flingstick_overlay.png"),
        scale = vec2(1/12, 1/12),
        color = Color:rgba(0,0,0,0),
    }}
});

local audio = Scene:add_audio({
    position = vec2(0, 0),
    asset = require("./packages/@carroted/pylon_recon/assets/sounds/FLINGSTICK.wav"),
    looping = true,
    volume = 0,
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

function on_step()
    if light_overlay ~= nil then
        audio:set_volume(1);
    else
        audio:set_volume(0);
    end;

    audio:set_position(self:get_position());
end;

function set_overlay_enabled(enabled)
    if enabled then
        local imgs = overlay:get_images();
        imgs[1].color = Color:hex(0xffffff);
        overlay:set_images(imgs);

        if light_overlay ~= nil then
            light_overlay:destroy();
        end;

        light_overlay = Scene:add_attachment({
            name = "Image",
            parent = self,
            local_position = vec2(-9.5/12, 0),
            local_angle = 0,
            images = {{
                texture = require("./packages/@carroted/pylon_recon/assets/textures/weapons/flingstick_overlay.png"),
                scale = vec2(1/12, 1/12),
                color = Color:rgba(0,0,0,0),
            }},
            lights = {{
                color = Color:hex(0xca67ff),
                intensity = 0.3,
                radius = 2
            }},
        });
    else
        local imgs = overlay:get_images();
        imgs[1].color = Color:rgba(0,0,0,0);
        overlay:set_images(imgs);

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
            offset = vec2(1.232, 0),
            -- ...
        },
        object = self,
    });
end;

function on_event(id, data)
    if id == "@carroted/pylon_recon/weapon/set_overlay_enabled" then
        set_overlay_enabled(data.enabled);
    end;
end;