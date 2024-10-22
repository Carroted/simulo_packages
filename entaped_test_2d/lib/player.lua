self:temp_set_group_index(-1340134);

local tapes = {};
local hinge = nil;
local last_point = nil;
local last_linvel = nil;
local last_angvel = nil;
local detached = true;
local sprite = Scene:add_attachment({
    name = "Image",
    component = {
        name = "Image",
        code = nil,
    },
    parent = self,
    local_position = vec2(0, 0),
    local_angle = 0,
    image = "./packages/@carroted/entaped_test_2d/assets/dispenser.png",
    size = 0.8 / 926,
    color = Color:hex(0xffffff),
});

local tape_color = Color:hex(0xe7ccab);
tape_color.a = 120;

local hash = Scene:add_component({
    name = "Tape",
    id = "@carroted/entaped_test_2d/tape",
    version = "0.1.0",
    code = require('./packages/@carroted/entaped_test_2d/lib/tape.lua', 'string')
});

function draw_line(line_start, line_end, thickness, color, static, obj)
    local pos = (line_start + line_end) / 2;
    local sx = (line_start - line_end):magnitude();
    local relative_line_end = line_end - pos;
    local rotation = math.atan(relative_line_end.y / relative_line_end.x)
    local line = Scene:add_box({
        position = pos,
        size = vec2(sx, thickness),
        is_static = static,
        color = color
    });
    line:temp_set_group_index(-1340134);
    line:set_is_bullet(true);

    --line:temp_set_collides(false);
    line:set_angle(rotation);
    line:bolt_to(self);
    self:apply_force(-self:get_up_direction() * 2, self:get_position());

    line:add_component({ hash = hash });

    line:send_event("@carroted/entaped_test_2d/tape/init", {
        guid = self.guid,
        size = sx,
    });

    local ceil = obj;
    hinge = Scene:add_hinge_at_world_point({
        point = line_end,
        object_a = ceil,
        object_b = line,
        collide_connected = true,
    });

    return line
end;

function on_event(id, data)
    if id == "@carroted/entaped_test_2d/tape/collision" then
        -- just split that tape into 2
        local tape = Scene:get_object_by_guid(data.guid);
        local angle = tape:get_angle();
        local size = data.size;
        local local_point = tape:get_local_point(data.point);
        if last_point ~= nil then
            if (last_point - data.point):magnitude() < 0.1 then
                return;
            end;
        end;
        last_point = data.point;
        --[[Scene:add_circle({
            position = data.point,
            radius = 0.05,
            is_static = true,
            color = 0xffffff
        }):temp_set_collides(false);]]
        local sx_1 = local_point.x + (size / 2);
        local sx_2 = size - sx_1;

        -- First piece (left of the split)
        local pos_1 = tape:get_world_point(vec2(local_point.x, 0) - vec2(sx_1 / 2, 0));
        local new_tape_1 = Scene:add_box({
            position = pos_1,
            size = vec2(sx_1, 0.025),
            is_static = false,
            color = tape_color
        });
        new_tape_1:temp_set_group_index(-1340134);
        new_tape_1:set_angle(angle);
        new_tape_1:set_is_bullet(true);

        -- Second piece (right of the split)
        local pos_2 = tape:get_world_point(vec2(local_point.x, 0) + vec2(sx_2 / 2, 0));
        local new_tape_2 = Scene:add_box({
            position = pos_2,
            size = vec2(sx_2, 0.025),
            is_static = false,
            color = tape_color
        });
        new_tape_2:set_is_bullet(true);
        new_tape_2:temp_set_group_index(-1340134);
        new_tape_2:set_angle(angle);

        -- find Closest one
        local self_pos = self:get_position();
        local distance_1 = (pos_1 - self_pos):magnitude();
        local distance_2 = (pos_2 - self_pos):magnitude();

        local closest_tape = new_tape_1;
        local other_tape = new_tape_2;
        local closest_sx = sx_1;
        if distance_2 < distance_1 then
            closest_tape = new_tape_2;
            other_tape = new_tape_1;
            closest_sx = sx_2;
        end;

        if hinge ~= nil then
            hinge:destroy();
            hinge = nil;
        end;
        Scene:add_hinge_at_world_point({
            point = data.point,
            object_a = closest_tape,
            object_b = other_tape,
            collide_connected = true,
        });
        if not detached then
            self:bolt_to(closest_tape);
        end;
        other_tape:set_body_type(BodyType.Static);

        closest_tape:add_component({ hash = hash });

        closest_tape:send_event("@carroted/entaped_test_2d/tape/init", {
            guid = self.guid,
            size = closest_sx,
        });

        tape:destroy();

        if not detached then
            self:set_linear_velocity(last_linvel);
            self:set_angular_velocity(last_angvel);
        end;
    end;
end;

local steps_to_restatic = 0;

function on_step()
    last_linvel = self:get_linear_velocity();
    last_angvel = self:get_angular_velocity();

    if steps_to_restatic > 0 then
        if steps_to_restatic == 1 then
            self:temp_set_collides(true);
            sprite:set_color(Color:rgba(255,255,255,255));
        end;
        steps_to_restatic -= 1;
    end;
end;

function on_update()
    if Input:key_just_pressed("E") then
        if detached then
            detached = false;
            print('hoy');
            local cast = {
                origin = self:get_world_point(vec2(0.4, 0)),
                direction = self:get_right_direction(),
                distance = 1000,
                closest_only = true,
            };

            local hits = Scene:raycast(cast);
            if #hits == 0 then
                --draw_line(cast.origin, cast.origin + (cast.direction:normalize() * cast.distance), 0.025, tape_color, false);
            else
                draw_line(cast.origin, hits[1].point, 0.025, tape_color, false, hits[1].object);
            end;
        else
            detached = true;
            last_linvel = self:get_linear_velocity();
            last_angvel = self:get_angular_velocity();
            --self:temp_set_collides(false);
            self:detach();
            self:set_linear_velocity(last_linvel);
            self:set_angular_velocity(last_angvel * 3);
        end;
    end;

    if detached then
        -- Adjust rotation to use the player position as the pivot
        local player_pos = self:get_position();
        local world_position = Input:pointer_pos();
        local angle = math.atan2(world_position.y - player_pos.y, world_position.x - player_pos.x)
        
        -- Set weapon's angle
        self:set_angle(angle);
    end;
--[[
    if Input:key_just_pressed("E") then
        detached = true;
        last_linvel = self:get_linear_velocity();
        last_angvel = self:get_angular_velocity();
        --self:temp_set_collides(false);
        self:detach();
        self:set_linear_velocity(last_linvel);
        self:set_angular_velocity(last_angvel * 3);
        --steps_to_restatic = 10;
        --sprite:set_color(Color:rgba(255,255,255,64));
    end;]]
end;