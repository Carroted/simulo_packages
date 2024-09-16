local speed = 3;

local height = 19;
local collide_height = 5;

-- Pixels Per Unit
local ppu = 16;

function mk_body_attachment(name)
    return Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = nil,
        },
        parent = self,
        local_position = vec2(0, (height - collide_height) / ppu / 2),
        local_angle = 0,
        image = "./packages/@carroted/rpg/assets/player/" .. name .. ".png",
        size = 1 / ppu,
        color = Color:rgba(0,0,0,0)
    });
end;

local number = 0;
local direction = "down";
local prev_number = number;
local prev_direction = direction;

local sprites = {
    down = {
        [1] = mk_body_attachment("down_0"),
        [2] = mk_body_attachment("down_1"),
        [3] = mk_body_attachment("down_2"),
    },
    up = {
        [1] = mk_body_attachment("up_0"),
        [2] = mk_body_attachment("up_1"),
        [3] = mk_body_attachment("up_2"),
    },
    left = {
        [1] = mk_body_attachment("left_0"),
        [2] = mk_body_attachment("left_1"),
        [3] = mk_body_attachment("left_2"),
    },
    right = {
        [1] = mk_body_attachment("right_0"),
        [2] = mk_body_attachment("right_1"),
        [3] = mk_body_attachment("right_2"),
    },
};

function update_body()
    sprites[prev_direction][prev_number + 1]:set_color(Color:rgba(0,0,0,0));

    prev_number = number;
    prev_direction = direction;

    sprites[prev_direction][prev_number + 1]:set_color(Color:hex(0xffffff));
end;

local sequence = {0, 1, 0, 2};
local index = 1;
number = sequence[index];

function step_number()
    index = (index % #sequence) + 1;
    number = sequence[index];
end;

local update_cooldown = 0;
local update_interval = 10;

local was_moving = false;

function on_step()
    local velocity = vec2(0, 0);

    if Input:key_pressed("W") then
        velocity += vec2(0, speed);
        direction = "up";
    end;
    if Input:key_pressed("S") then
        velocity -= vec2(0, speed);
        direction = "down";
    end

    if Input:key_pressed("A") then
        velocity -= vec2(speed, 0);
        direction = "left";
    end;
    if Input:key_pressed("D") then
        velocity += vec2(speed, 0);
        direction = "right";
    end;

    if direction ~= prev_direction then
        number = 1;
        index = 2;
        update_body();
        update_cooldown = update_interval;
    end;

    if velocity.x == 0 then
        -- snap to pixel on X

        local pos_x = self:get_position().x;
        local snapped_x = math.floor(pos_x * ppu + 0.5) / ppu;
        self:set_position(vec2(snapped_x, self:get_position().y));
    end;
    if velocity.y == 0 then
        -- snap to pixel on Y
        local pos_y = self:get_position().y;

        local height_offset = (height / 2) / ppu;
        local snapped_y = math.floor((pos_y - height_offset) * ppu + 0.5) / ppu + height_offset;
        self:set_position(vec2(self:get_position().x, snapped_y));
    end;
    

    if velocity.x == 0 and velocity.y == 0 then
        number = 0;
        index = 1;
        update_body();
        was_moving = false;
    else
        if not was_moving then
            index = 2; number = sequence[index];
            update_cooldown = update_interval;
            update_body();
        end;

        update_cooldown -= 1;
        if update_cooldown <= 0 then
            update_cooldown = update_interval;
            step_number();
            update_body();
        end;
        was_moving = true;
    end;

    self:set_linear_velocity(velocity);
end;