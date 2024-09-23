Scene:reset();

local people_colors = {
    [1] = 0xff6262,
    [2] = 0xffcc65,
    [3] = 0x7fcb64,
    [4] = 0x64cba9,
    [5] = 0x7f89e4,
    [6] = 0xca7ce4,
};

function add_person(pos, color, size)
    local person = Scene:add_circle({
        position = pos,
        color = color,
        radius = size / 2,
        is_static = false,
    });

    Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = nil,
        },
        parent = person,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/@carroted/people/assets/face.png",
        size = (1 / 512) * size,
        color = Color:hex(0xffffff),
    });
end;

function add_sprite(sprite, pos, size, image_size)
    local thing = Scene:add_box({
        position = pos,
        color = Color:rgba(0,0,0,0),
        size = size,
        is_static = false,
    });

    local a = Scene:add_attachment({
        name = "Image",
        component = {
            name = "Image",
            code = nil,
        },
        parent = thing,
        local_position = vec2(0, 0),
        local_angle = 0,
        image = "./packages/@carroted/people/assets/" .. sprite .. ".png",
        size = image_size,
        color = Color:hex(0xffffff),
    });

    return thing, a;
end;

local storage = Scene:add_box({
    position = vec2(-10, -3),
    size = vec2(7, 11),
    is_static = true,
    color = 0x0f0f0f,    
});
storage:temp_set_collides(false);

local house = Scene:add_box({
    position = vec2(1, -3),
    size = vec2(12.5, 11),
    is_static = true,
    color = 0x443b46,    
});
house:temp_set_collides(false);

local backyard = Scene:add_box({
    position = vec2(13.6, -3),
    size = vec2(12.5, 11),
    is_static = true,
    color = 0x35522d,    
});
backyard:temp_set_collides(false);

add_sprite("status", vec2(0, 3), vec2(0.9, 0.5), 0.5 / 512):set_body_type(BodyType.Static);
add_sprite("backyard", vec2(10, 2), vec2(1.6, 0.4), 1 / 512 * 0.4):set_body_type(BodyType.Static);
add_sprite("storage", vec2(-10, 1.7), vec2(1.6, 0.4), 1 / 512 * 0.7):set_body_type(BodyType.Static);
add_sprite("winner", vec2(-10, 0), vec2(1.6, 0.4), 1 / 512 * 0.5);

for i=1,#people_colors do
    add_person(vec2(i, -1), people_colors[i], 1);
end;

add_sprite("veto_icon", vec2(-9.5, -3), vec2(0.5, 0.5), 0.5 / 512);
add_sprite("hoh_icon", vec2(-10.5, -3), vec2(0.5, 0.5), 0.5 / 512);
add_sprite("hoh", vec2(-11, -4), vec2(1.65, 0.6), 1 / 512);
add_sprite("veto", vec2(-9, -4), vec2(1.3, 0.6), 1 / 512);
add_sprite("none", vec2(0.8, 3), vec2(0.7, 0.4), 1 / 512 * 0.4);
add_sprite("nominated", vec2(-10, -5), vec2(3.4, 0.5), 1 / 512 * 1);
add_sprite("myself", vec2(-10, -6), vec2(2.5, 1), 1 / 512 * 0.7);
add_sprite("vetoed", vec2(-10, -7), vec2(2.5, 1), 1 / 512 * 0.7);
add_sprite("not_to_use", vec2(-10, -8), vec2(2.7, 0.8), 1 / 512 * 0.7);
for i=1,(#people_colors - 3) do
    add_sprite("vote_to", vec2(-10 + (i * 1.8) - (1.8 * (#people_colors + 1) * 0.25), -1), vec2(1.6, 0.4), 1 / 512 * 0.3);
end;



for i=1,#people_colors do
    add_person(vec2(-10 - (0.3 * (#people_colors + 1) * 0.5) + (i * 0.3), -2), people_colors[i], 0.3);
end;