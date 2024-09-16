local speed = 3;

local ball = nil;
local ball_power = 1;
local ball_light_intensity = 1;
local ball_restitution = 1;
local ball_attachment = nil;

function on_event(id, data)
    if id == "@carroted/ping_pong/ball" then
        ball = Scene:get_object_by_guid(data.guid);
        Scene:add_attachment({
            name = "Point Light",
            component = {
                name = "Point Light",
                code = nil,
            },
            parent = ball,
            local_position = vec2(0, 0),
            local_angle = 0,
            image = "./packages/core/assets/textures/point_light.png",
            size = 0.001,
            color = Color:rgba(0,0,0,0),
            light = {
                color = Color:hex(0xffb36b),
                intensity = ball_power,
                radius = 2,
            }
        });
    end;
end;

-- Segment patterns for each digit, true means the segment is on
local digits = {
    ['0'] = {
        {true, true, true},
        {true, false, true},
        {true, false, true},
        {true, false, true},
        {true, true, true}
    },
    ['1'] = {
        {false, false, true},
        {false, false, true},
        {false, false, true},
        {false, false, true},
        {false, false, true}
    },
    ['2'] = {
        {true, true, true},
        {false, false, true},
        {true, true, true},
        {true, false, false},
        {true, true, true}
    },
    ['3'] = {
        {true, true, true},
        {false, false, true},
        {true, true, true},
        {false, false, true},
        {true, true, true}
    },
    ['4'] = {
        {true, false, true},
        {true, false, true},
        {true, true, true},
        {false, false, true},
        {false, false, true}
    },
    ['5'] = {
        {true, true, true},
        {true, false, false},
        {true, true, true},
        {false, false, true},
        {true, true, true}
    },
    ['6'] = {
        {true, true, true},
        {true, false, false},
        {true, true, true},
        {true, false, true},
        {true, true, true}
    },
    ['7'] = {
        {true, true, true},
        {false, false, true},
        {false, false, true},
        {false, false, true},
        {false, false, true}
    },
    ['8'] = {
        {true, true, true},
        {true, false, true},
        {true, true, true},
        {true, false, true},
        {true, true, true}
    },
    ['9'] = {
        {true, true, true},
        {true, false, true},
        {true, true, true},
        {false, false, true},
        {true, true, true}
    },
    ['-'] = {
        {false, false, false},
        {false, false, false},
        {true, true, true},
        {false, false, false},
        {false, false, false},
    },
    ['.'] = {
        {false, false, false},
        {false, false, false},
        {false, false, false},
        {false, false, false},
        {false, true, false},
    },
    ['e'] = {
        {true, true, true},
        {true, false, false},
        {true, true, true},
        {true, false, false},
        {true, true, true},
    },
    ['+'] = {
        {false, false, false},
        {false, true, false},
        {true, true, true},
        {false, true, false},
        {false, false, false},
    },
    ['i'] = {
        {false, true, false},
        {false, false, false},
        {false, true, false},
        {false, true, false},
        {false, true, false},
    },
    ['n'] = {
        {false, false, false},
        {false, false, false},
        {true, true, true},
        {true, false, true},
        {true, false, true},
    },
    ['f'] = {
        {false, true, true},
        {true, false, false},
        {true, true, true},
        {true, false, false},
        {true, false, false},
    },
}

local function draw_digit(pos, size, color, digit)
    local digit_pattern = digits[digit]
    local objects = {}

    if digit_pattern == nil then
        print('digit was ' .. digit);
        return {};
    end;

    for y = 1, #digit_pattern do
        for x = 1, #digit_pattern[y] do
            if digit_pattern[y][x] then
                local offset = vec2((x - 1) * size, -(y - 1) * size) / 2;
                local box = Scene:add_box({
                    position = pos + offset,
                    size = vec2(size / 2, size / 2),
                    color = color,
                    is_static = true,
                });
                box:temp_set_collides(false);
                table.insert(objects, {
                    obj = box,
                    offset = offset,
                });
            end;
        end
    end

    return objects
end

local function draw_seven_segment_display(pos, size, color, number)
    local objects = {}
    local num_str = tostring(number);

    pos = pos - (vec2((((#num_str / 2) * 4) - 1) * size, -2 * size)) / 2;

    local final_offset = 0;
    local first_char = num_str:sub(1, 1);
    if first_char == "1" then
        final_offset = -size;
    end;

    for i = 1, #num_str do
        local digit = num_str:sub(i, i)
        local digit_objects = draw_digit(vec2(pos.x + final_offset + (i - 1) * 4 * size, pos.y), size, color, digit)
        for _, data in ipairs(digit_objects) do
            table.insert(objects, {
                obj = data.obj,
                offset = data.offset + (vec2((i - 1) * 4 * size, 0) - vec2((((#num_str / 2) * 4) - 1) * size, -2 * size) + vec2(final_offset, 0)) / 2
            })
        end
    end

    return objects
end;

function move_display(objects, new_pos)
    for _, data in ipairs(objects) do
        data.obj:set_position(new_pos + data.offset);
    end
end;

local computer_display = nil;
local player_display = nil;

function set_player_display(value)
    if player_display ~= nil then
        for _, data in ipairs(player_display) do
            if not data.obj:is_destroyed() then
                data.obj:destroy();
            end;
        end;
    end;
    player_display = draw_seven_segment_display(vec2(0, -1.7), 0.15, Color:rgba(215,215,215,255), value);
    move_display(player_display, vec2(0, -1.7));
end;

function set_computer_display(value)
    if computer_display ~= nil then
        for _, data in ipairs(computer_display) do
            if not data.obj:is_destroyed() then
                data.obj:destroy();
            end;
        end;
    end;
    computer_display = draw_seven_segment_display(vec2(0, 1.7), 0.15, Color:rgba(215,215,215,255), value);
    move_display(computer_display, vec2(0, 1.7));
end;

local player_score = 0;
local computer_score = 0;

set_player_display(0);
set_computer_display(0);

local hit_first_time = true;
local hit_right = math.random() > 0.5;
local hit_first_time_delay = 50;
local hit_first_time_counter = hit_first_time_delay;

function on_update()
    if ball == nil then return; end;
    if ball:is_destroyed() then return; end;

    local ball_pos = ball:get_position();
    local self_pos = self:get_position();

    local ball_vel = ball:get_linear_velocity();
    if math.abs(ball_vel.y) < 0.1 then
        ball:set_linear_velocity(vec2(3, 3));
        ball_power *= 2;
        ball_restitution += 0.15;
        ball_light_intensity *= 10;
        ball:set_restitution(ball_restitution);
        if ball_attachment ~= nil then
            ball_attachment:destroy();
        end;
        ball_attachment = Scene:add_attachment({
            name = "Point Light",
            component = {
                name = "Point Light",
                code = nil,
            },
            parent = ball,
            local_position = vec2(0, 0),
            local_angle = 0,
            image = "./packages/core/assets/textures/point_light.png",
            size = 0.001,
            color = Color:rgba(0,0,0,0),
            light = {
                color = Color:hex(0xffb36b),
                intensity = ball_power,
                radius = 2,
            }
        });
    end;

    if ball_pos.y < (-6.8 / 2) then
        ball:set_position(vec2(0, 0));
        ball:set_linear_velocity(vec2(0, 3));
        ball:set_angular_velocity(0);
        self:set_position(vec2(0, 3));
        ball_pos = ball:get_position();
        hit_first_time = true;
        hit_right = math.random() > 0.5;
        hit_first_time_counter = hit_first_time_delay;
        computer_score += ball_power;
        set_computer_display(computer_score);
        reset_ball_power();
    end;

    if ball_pos.y > (6.8 / 2) then
        ball:set_position(vec2(0, 0));
        ball:set_linear_velocity(vec2(0, -3));
        ball:set_angular_velocity(0);
        self:set_position(vec2(0, 3));
        ball_pos = ball:get_position();
        hit_first_time_counter = 0;
        hit_first_time = false;
        player_score += ball_power;
        set_player_display(player_score);
        reset_ball_power();
    end;

    if hit_first_time then
        if hit_first_time_counter <= 0 then
            if hit_right then
                self:set_linear_velocity(vec2(speed, 0));
            else
                self:set_linear_velocity(vec2(-speed, 0));
            end;
        end;
        return;
    end;

    local vel = vec2(0, 0);

    if math.abs(ball_pos.x - self_pos.x) > 0.1 then
        if ball_pos.x > self_pos.x then
            vel += vec2(speed, 0);
        end;
        if ball_pos.x < self_pos.x then
            vel -= vec2(speed, 0);
        end;
    end;

    self:set_linear_velocity(vel);
end;

function on_collision_start(data)
    hit_first_time = false;
    hit_first_time_counter = 0;
end;

function on_step()
    if hit_first_time_counter > 0 then
        hit_first_time_counter -= 1;
    end;
end;

function reset_ball_power()
    ball_power = 1;
    ball_restitution = 1;
    ball_light_intensity = 1;
    ball:set_restitution(ball_restitution);
    if ball_attachment ~= nil then
        ball_attachment:destroy();
    end;
    ball_attachment = Scene:add_attachment({
        name = "Point Light",
        component = {
            name = "Point Light",
            code = nil,
        },
        parent = ball,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/core/assets/textures/point_light.png",
        size = 0.001,
        color = Color:rgba(0,0,0,0),
        light = {
            color = Color:hex(0xffb36b),
            intensity = ball_light_intensity,
            radius = 2,
        }
    });
end;