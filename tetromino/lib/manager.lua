local width = 10;
local height = 20;

local pixels = {};

local pixel_lights = {};

function clear_lights()
    for i=1,#pixel_lights do
        pixel_lights[i]:destroy();
    end;
    pixel_lights = {};
end;

for y=1,height do
    for x=1,width do
        local px = Scene:add_box({
            position = vec2((x / 2) - ((width + 2) * 0.47 / 2), (y / 2) - 7),
            size = vec2(0.47, 0.47),
            color = 0x412e4a,
            is_static = true,
        });
        table.insert(pixels, px);
    end;
end;

pieces = {
    { -- O
        {0,0,0,0},
        {0,1,1,0},
        {0,1,1,0},
        {0,0,0,0}
    },
    { -- I
        {0,0,0,0},
        {0,0,0,0},
        {2,2,2,2},
        {0,0,0,0}
    },
    { -- L
        {0,0,0,0},
        {0,0,3,0},
        {3,3,3,0},
        {0,0,0,0}
    },
    { -- J
        {0,0,0,0},
        {0,4,0,0},
        {0,4,4,4},
        {0,0,0,0}
    },
    { -- S
        {0,0,0,0},
        {0,0,5,5},
        {0,5,5,0},
        {0,0,0,0}
    },
    { -- Z
        {0,0,0,0},
        {6,6,0,0},
        {0,6,6,0},
        {0,0,0,0}
    },
    { -- T
        {0,0,0,0},
        {0,0,7,0},
        {0,7,7,7},
        {0,0,0,0}
    }
};


local colors = {
    [0] = Color:hex(0x412e4a),
    [1] = Color:hex(0xffbc5e),
    [2] = Color:hex(0x7b8fff),
    [3] = Color:hex(0xff9b59),
    [4] = Color:hex(0xff8bb7),
    [5] = Color:hex(0xff6a80),
    [6] = Color:hex(0xbaf063),
    [7] = Color:hex(0xb66cff),
};

function set_pixel(x, y, color)
    if x < width then
        pixels[1 + x + (width * y)]:set_color(color);
        if (color.r ~= colors[0].r) and (color.g ~= colors[0].g) and (color.b ~= colors[0].b) then
            table.insert(pixel_lights, Scene:add_attachment({
                name = "Point Light",
                component = {
                    name = "Point Light",
                    code = nil,
                },
                parent = pixels[1 + x + (width * y)],
                local_position = vec2(0, 0),
                local_angle = 0,
                image = "./packages/core/assets/textures/point_light.png",
                size = 0.001,
                color = Color:rgba(0,0,0,0),
                light = {
                    color = color,
                    intensity = 1.5,
                    radius = 1,
                }
            }));
        end;
    end;
end;

local function draw_piece(piece, x_offset, y_offset)
    for y, row in ipairs(piece) do
        for x, cell in ipairs(row) do
            if cell ~= 0 then
                set_pixel(x + x_offset, y + y_offset, colors[cell])
            end
        end
    end
end

local function clear_piece(piece, x_offset, y_offset)
    for y, row in ipairs(piece) do
        for x, cell in ipairs(row) do
            if cell ~= 0 then
                set_pixel(x + x_offset, y + y_offset, colors[0])
            end
        end
    end
end

local function can_place(piece, x_offset, y_offset)
    for y, row in ipairs(piece) do
        for x, cell in ipairs(row) do
            if cell ~= 0 then
                local px, py = x + x_offset, y + y_offset
                print('checking ' .. tostring(px) .. ', ' .. tostring(py))
                if px < 0 or px >= width or py >= height or (py >= 0 and pixels[1 + px + (width * py)]:get_color() ~= colors[0]) or (py < 0) then
                    print('False.')
                    return false
                end
            end
        end
    end
    print('True')
    return true
end

local function rotate_piece(piece)
    local rotated = {}
    local piece_size = #piece
    for x = 1, piece_size do
        rotated[x] = {}
        for y = 1, piece_size do
            rotated[x][y] = piece[piece_size - y + 1][x]
        end
    end
    return rotated
end

local function place_piece(piece, x_offset, y_offset)
    draw_piece(piece, x_offset, y_offset)
end

local function remove_full_lines()
    for y = 0, height - 1 do
        local is_full_line = true
        for x = 1, width do
            if pixels[1 + x + (width * y)]:get_color() == colors[0] then
                is_full_line = false
                break
            end
        end
        if is_full_line then
            -- Remove the full line and move everything above down
            for remove_y = y, height - 1 do
                for x = 1, width do
                    pixels[1 + x + (width * remove_y)]:set_color(pixels[1 + x + (width * (remove_y + 1))]:get_color());
                end
            end
            -- Clear the top line
            for x = 1, width do
                pixels[1 + x + (width * height)]:set_color(colors[0]);
            end
            -- Check the same line again since it now contains the next line up
            y = y - 1
        end
    end
end


local active_piece = pieces[math.random(1, #pieces)]
local piece_x, piece_y = 3, 15
local piece_color = colors[active_piece[1][1]]

function game_update()
    clear_lights();
    clear_piece(active_piece, piece_x, piece_y)

    piece_y = piece_y - 1

    -- if we cant go where we are now
    if not can_place(active_piece, piece_x, piece_y) then
        piece_y = piece_y + 1 -- back to where we just were
        place_piece(active_piece, piece_x, piece_y)
        remove_full_lines()
        active_piece = pieces[math.random(1, #pieces)]
        piece_x, piece_y = 3, 15
        if not can_place(active_piece, piece_x, piece_y) then
            -- Game over
            --Scene:add_text("Game Over", vec2(4, 10), vec2(3, 1), 0xff0000)
            print("its joever");
            return
        end
    else
        place_piece(active_piece, piece_x, piece_y)
    end;
end

function game_keypressed(key)
    clear_lights();
    clear_piece(active_piece, piece_x, piece_y)

    if key == "left" then
        if can_place(active_piece, piece_x - 1, piece_y) then
            piece_x = piece_x - 1
        end
    elseif key == "right" then
        if can_place(active_piece, piece_x + 1, piece_y) then
            piece_x = piece_x + 1
        end
    elseif key == "down" then
        while can_place(active_piece, piece_x, piece_y - 1) do
            piece_y = piece_y - 1
        end
    elseif key == "up" then
        local rotated = rotate_piece(active_piece)
        if can_place(rotated, piece_x, piece_y) then
            active_piece = rotated
        end
    end

    place_piece(active_piece, piece_x, piece_y)
end

local counter = 0;

local input_counter = 0;

function on_update()
    if Input:key_just_pressed("ArrowUp") then
        game_keypressed("up");
    end;
    if Input:key_just_pressed("ArrowDown") then
        game_keypressed("down");
    end;
    if Input:key_just_pressed("ArrowLeft") then
        game_keypressed("left");
        input_counter = 15;
    end;
    if Input:key_just_pressed("ArrowRight") then
        game_keypressed("right");
        input_counter = 15;
    end;
end;

function on_step()
    if counter == 0 then
        game_update();
        counter = 30;
    end;
    if input_counter == 0 then
        if Input:key_pressed("ArrowLeft") then
            game_keypressed("left");
        end;
        if Input:key_pressed("ArrowRight") then
            game_keypressed("right");
        end;
        input_counter = 5;
    end;

    counter -= 1;
    input_counter -= 1;
end;