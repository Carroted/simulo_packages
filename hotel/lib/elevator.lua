local door = nil;
local button_1 = nil;
local button_2 = nil;
local floors = nil;

local speed = 0;
local target_speed = 2;
local target_floor = 1;
local previous_floor = nil;

local button_colors = {
    inactive = 0xf19b31,
    hover = 0xffae51,
    pressed = 0x854b05,
};

local state = "idle"; -- "idle", "closing", "moving"
local target_is_up = false;

local height = 3.3; -- door height, we make door shrink or grow to open and close
local change = 0; -- how much to adjust door height
local target_change = 0.05; -- target value for change (we lerp change)

function get_floor_y(floor)
    return (floor * 3.5) - 8.15 - 3.5 - 0.2;
end;

local shape = nil;

function lerp(a, b, t)
    return a + (b - a) * t
end;

function set_floor_height(index, height)
    floors[index].height = height;
    if floors[index].height > 3.3 then
        floors[index].height = 3.3;
    elseif floors[index].height < 0.2 then
        floors[index].height = 0.2;
    end;
    shape.points = create_box_polygon(0.2, floors[index].height, vec2(0, 0));
    floors[index].door:set_shape(shape);
    floors[index].door:set_color(floors[index].door:get_color());
end;

function create_box_polygon(width, height, offset)
    local half_width = width / 2;

    return {
        vec2(half_width, 0) + offset,              -- top right
        vec2(-half_width, 0) + offset,             -- top left
        vec2(-half_width, -height) + offset,       -- bottom left
        vec2(half_width, -height) + offset         -- bottom right
    }
end;

function on_start(data)
    door = data.door;
    shape = door:get_shape();

    button_1 = data.button_1;
    button_2 = data.button_2;

    state = data.state;
    change = data.change;
    height = data.height;
    target_is_up = data.target_is_up;
    target_floor = data.target_floor or 1;
    floors = data.floors;

    for i=1,#floors do
        floors[i].door:set_position(vec2(1.5 + 0.2, -10 + 0.1 + (3.5*(i - 1)) + 3.4));
        shape.points = create_box_polygon(0.2, floors[i].height, vec2(0, 0));
        floors[i].door:set_shape(shape);
        floors[i].door:set_color(floors[i].door:get_color());
    end;
end;

function on_save()
    return {
        door = door,
        button_1 = button_1,
        button_2 = button_2,
        state = state,
        change = change,
        height = height,
        target_is_up = target_is_up,
        target_floor = target_floor,
        floors = floors,
    };
end;

function on_step()
    if target_floor > (#floors - 1) then
        target_floor = #floors - 1;
    elseif target_floor < 0 then
        target_floor = 0;
    end;

    height += change;
    if height > 3.3 then
        height = 3.3;
    elseif height < 0.2 then
        height = 0.2;
    end;

    shape.points = create_box_polygon(0.2, height, vec2(1.5, (1.75) - 0.1));
    door:set_shape(shape);

    set_floor_height(target_floor + 1, floors[target_floor + 1].height + change);

    if previous_floor ~= nil then
        set_floor_height(previous_floor + 1, floors[previous_floor + 1].height + change);
    end;

    door:set_color(door:get_color());

    if state == "idle" then
        change = lerp(change, -target_change, 0.2);
    elseif state == "closing" then
        change = lerp(change, target_change, 0.2);

        if height == 3.3 then
            speed = 0;
            state = "moving";
            previous_floor = nil;
            Scene:add_audio({
                clip = "./packages/@carroted/hotel/assets/move.wav",
            });
        end;
    end;

    if state == "moving" then
        --speed = lerp(speed, target_is_up and -target_speed or target_speed, 0.01);
        local target_y = get_floor_y(target_floor);
        local current_y = self:get_position().y
        local distance_to_target = target_y - current_y

        -- Check if we're halfway there
        if math.abs(distance_to_target) < 3.5 / 2 then
            -- Set velocity directly to the remaining distance, clamped between -2 and 2
            self:set_linear_velocity(vec2(0, math.clamp(distance_to_target * 5, -2, 2)))
        else
            -- Slowly interpolate velocity using lerp, clamped between -2 and 2
            speed = lerp(speed, distance_to_target, 0.05)
            self:set_linear_velocity(vec2(0, math.clamp(speed, -2, 2)))
        end

        if math.abs(distance_to_target) < 0.001 then
            state = "idle";
            Scene:add_audio({
                clip = "./packages/@carroted/hotel/assets/ding.wav",
            });
            speed = 0;
            self:set_linear_velocity(vec2(0, distance_to_target) / (1/60));
        end;
    else
        speed = lerp(speed, 0, 0.01);
        self:set_linear_velocity(vec2(0, speed));
    end;
end;

function on_event(id, data)
    if ((previous_floor ~= nil) and (floors[previous_floor + 1].height < 3.3)) then
        Scene:add_audio({
            clip = "./packages/@carroted/hotel/assets/deny.wav",
        });
    elseif id == "@carroted/hotel/elevator/call" then
        if data.floor == target_floor then
            return;
        end;
        state = "closing";
        target_is_up = true;
        previous_floor = target_floor;

        target_floor = data.floor;
        change = 0;
    end;
end;

function on_update()
    local pointer_pos = Input:pointer_pos();
    local pressed = Input:pointer_pressed();
    local just_released = Input:pointer_just_released();
    local just_pressed = Input:pointer_just_pressed();

    if (button_1:get_position() - pointer_pos):magnitude() <= 0.125 then
        if pressed then
            button_1:set_color(button_colors.pressed);
        else
            button_1:set_color(button_colors.hover);
        end;

        if just_pressed then
            Scene:add_audio({
                clip = "./packages/@carroted/hotel/assets/down.wav",
            });
        end;

        if just_released then
            if (target_floor == 0) or ((previous_floor ~= nil) and (floors[previous_floor + 1].height < 3.3)) then
                Scene:add_audio({
                    clip = "./packages/@carroted/hotel/assets/deny.wav",
                });
            else
                state = "closing";
                target_is_up = true;
                previous_floor = target_floor;

                target_floor -= 1;
                change = 0;

                Scene:add_audio({
                    clip = "./packages/@carroted/hotel/assets/up.wav",
                });
            end;
        end;
    else
        button_1:set_color(button_colors.inactive);
    end;

    if (button_2:get_position() - pointer_pos):magnitude() <= 0.125 then
        if pressed then
            button_2:set_color(button_colors.pressed);
        else
            button_2:set_color(button_colors.hover);
        end;

        if just_pressed then
            Scene:add_audio({
                clip = "./packages/@carroted/hotel/assets/down.wav",
            });
        end;

        if just_released then
            if (target_floor == (#floors - 1)) or ((previous_floor ~= nil) and (floors[previous_floor + 1].height < 3.3)) then
                Scene:add_audio({
                    clip = "./packages/@carroted/hotel/assets/deny.wav",
                });
            else
                state = "closing";
                target_is_up = false;
                previous_floor = target_floor;

                target_floor += 1;
                change = 0;

                Scene:add_audio({
                    clip = "./packages/@carroted/hotel/assets/up.wav",
                });
            end;
        end;
    else
        button_2:set_color(button_colors.inactive);
    end;
end;