local takeover = 0;
local color = self:get_color();
local shake = true;
local color_change = true;
local mutation_amount = 0;
local shake_speed = 1;
local takeover_to = 1;
local takeover_equal = false;

local colliding_objects = {};

local virus_data = nil;

function lerp(a, b, t)
    return a + t * (b - a)
end

function on_collision_start(data)
    table.insert(colliding_objects, data.other);
end;

function on_collision_end(data)
    for i, obj in ipairs(colliding_objects) do
        if obj.guid == data.other.guid then
            table.remove(colliding_objects, i);
            break;
        end
    end
end;

function on_collision_stay(obj)
    if math.random() < takeover then
        if obj:get_body_type() == BodyType.Dynamic then
            virus_data = nil;

            obj:send_event("@carroted/viruses/request_data", {
                guid = self.guid,
            });

            if virus_data ~= nil then
                if (
                    (not takeover_equal) and
                    (virus_data.takeover >= takeover)
                ) or
                (
                    takeover_equal and
                    (virus_data.takeover > takeover)
                ) then
                    return;
                end;
            end;
            if color_change then
                obj:set_color(Color:mix(obj:get_color(), color, 1 / 60 / 0.1 / shake_speed));
            end;

            if virus_data == nil then
                obj:add_component({ hash = self_hash });
                print('added a realer');
                obj:send_event("@carroted/viruses/request_data", {
                    guid = self.guid,
                });
            end;
            virus_data.takeover_equal = takeover_equal;
            virus_data.takeover = lerp(virus_data.takeover, takeover_to, 1 / 60 / 2 / shake_speed);
            if virus_data.color ~= color then
                virus_data.takeover = 0;
            end;
            virus_data.color = color;
            if virus_data.shake ~= shake then
                virus_data.takeover = 0;
            end;
            virus_data.shake = shake;
            virus_data.mutation_amount = mutation_amount;
            if virus_data.shake_speed ~= shake_speed then
                virus_data.takeover = 0;
            end;
            virus_data.shake_speed = shake_speed;
            virus_data.color_change = color_change;
            virus_data.takeover_to = takeover_to;
            
            obj:send_event("@carroted/viruses/set_data", virus_data);
        end;
    end;
end;

function on_step()
    for i=1,#colliding_objects do
        if not colliding_objects[i]:is_destroyed() then
            on_collision_stay(colliding_objects[i]);
        end;
    end;

    if (math.random() < takeover) and shake then
        local random_force = vec2(math.random() * shake_speed - shake_speed / 2, math.random() * shake_speed - shake_speed / 2);
        local random_torque = math.random() * shake_speed * 20 - shake_speed * 10;

        self:apply_force_to_center(random_force);
        self:apply_torque(random_torque);
    end;
end;

function on_event(id, data)
    if id == "@carroted/viruses/request_data" then
        Scene:get_object_by_guid(data.guid):send_event("@carroted/viruses/response_data", {
            takeover = takeover,
            color = color,
            shake = shake,
            color_change = color_change,
            mutation_amount = mutation_amount,
            shake_speed = shake_speed,
            takeover_to = takeover_to,
            takeover_equal = takeover_equal,
        });
    elseif id == "@carroted/viruses/response_data" then
        virus_data = data;
    elseif id == "@carroted/viruses/set_data" then
        takeover = data.takeover;
        color = data.color;
        shake = data.shake;
        color_change = data.color_change;
        mutation_amount = data.mutation_amount;
        shake_speed = data.shake_speed;
        takeover_to = data.takeover_to;
        takeover_equal = data.takeover_equal;
    end;
end;