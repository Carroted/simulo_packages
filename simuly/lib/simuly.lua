local simulon = require('core/lib/simulon.lua');

local smile = require("@carroted/simuly/assets/smile.png");

local function simuly(tbl)
    local position = tbl.position or vec2(0, 0);
    local color = tbl.color or Color.SIMULO_GREEN;
    local size = tbl.size or 1;

    local parts = simulon({
        color = color,
        size = size,
    });

    local head = parts.head;

    local img_scale = (0.51656626506 / (512));

    local atch = Scene:add_attachment({
        name = "Face",
        component = {
            name = "Face",
            version = "0.1.0",
            id = "@carroted/simuly/face",
            code = [==[
                local faces = nil;

                function on_start(saved_data)
                    if saved_data == nil then
                        faces = {
                            smile = require("@carroted/simuly/assets/smile.png");
                            sad = require("@carroted/simuly/assets/sad.png");
                            neutral = require("@carroted/simuly/assets/neutral.png");
                            diagonal = require("@carroted/simuly/assets/diagonal.png");
                            shocked = require("@carroted/simuly/assets/shocked.png");
                        };
                    else
                        faces = saved_data;
                    end;
                end;

                function on_event(id, data)
                    if id == "property_changed" then
                        if data == "color" then
                            local imgs = self:get_images();
                            for i = 1, #imgs do
                                imgs[i].color = self:get_property("color").value;
                            end;
                            self:set_images(imgs);
                        elseif data == "mood" then
                            local imgs = self:get_images();
                            imgs[1].texture = faces[self:get_property("mood").value] or faces["neutral"];
                            self:set_images(imgs);
                        end;
                    end;
                end;
            ]==],
            properties = {
                {
                    id = "color",
                    name = "Color",
                    input_type = "color",
                    default_value = 0xffffff,
                },
                {
                    id = "mood",
                    name = "Mood",
                    input_type = "text",
                    multi_line = false,
                    default_value = "smile",
                },
            },
        },
        parent = head,
        local_position = vec2(0, 0),
        local_angle = 0,
        images = {
            {
                texture = smile,
                scale = vec2(img_scale, img_scale) * size,
                color = color,
            },
        },
        collider = { shape_type = "circle", radius = 0.1 * size, }
    });

    return parts, atch;
end;

    --simuly({ position = vec2(0, 0) });
return simuly;
