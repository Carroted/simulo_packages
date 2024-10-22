local elevator = nil;
local floor = nil;

function on_start(data)
    elevator = data.elevator;
    floor = data.floor;
end;

function on_save()
    return {
        elevator = elevator,
        floor = floor,
    };
end;

local button_colors = {
    inactive = 0xf19b31,
    hover = 0xffae51,
    pressed = 0x854b05,
};

function on_update()
    local pointer_pos = Input:pointer_pos();
    local pressed = Input:pointer_pressed();
    local just_released = Input:pointer_just_released();
    local just_pressed = Input:pointer_just_pressed();

    if (self:get_position() - pointer_pos):magnitude() <= 0.125 then
        if pressed then
            self:set_color(button_colors.pressed);
        else
            self:set_color(button_colors.hover);
        end;

        if just_pressed then
            Scene:add_audio({
                clip = "./packages/@carroted/hotel/assets/down.wav",
            });
        end;

        if just_released then
            if elevator:is_destroyed() then
                Scene:add_audio({
                    clip = "./packages/@carroted/hotel/assets/deny.wav",
                });
            else
                elevator:send_event("@carroted/hotel/elevator/call", {
                    floor = floor,
                });

                Scene:add_audio({
                    clip = "./packages/@carroted/hotel/assets/call.wav",
                });
            end;
        end;
    else
        self:set_color(button_colors.inactive);
    end;
end;