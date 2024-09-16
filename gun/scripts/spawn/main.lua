local gun = Scene:add_box({
    position = vec2(0, -9),
    size = vec2(0.5, 412 / 512 / 2),
    color = Color:rgba(0,0,0,0),
    is_static = false,
});

Scene:add_attachment({
    name = "Image",
    component = {
        name = "Image",
        code = nil,
    },
    parent = gun,
    local_position = vec2(0, 0),
    local_angle = 0,
    image = "./packages/@carroted/gun/assets/gun.png",
    size = 0.5 / 512,
    color = Color:hex(0xffffff),
});

local hash = Scene:add_component({
    name = "Gun",
    id = "@carroted/gun/gun",
    version = "0.1.0",
    code = require('./packages/@carroted/gun/lib/gun.lua', 'string')
});

gun:add_component(hash);