function starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end;

local objs = Scene:get_objects_in_circle({
    position = self:get_position(),
    radius = 0.2,
});

for i=1,#objs do
    if objs[i].guid ~= self.guid then
        local other = objs[i];
        if starts(other:get_name(), "Enemy_") then
            -- Extract the HP value from the enemy's name
            local hp_value = tonumber(string.match(other:get_name(), "Enemy_(%d+)"))
            if hp_value then
                -- Reduce HP by 70
                hp_value = hp_value - 70;
                if hp_value < 0 then
                    hp_value = 0;
                end;
                
                -- Update the enemy's name with the new HP value
                other:set_name("Enemy_" .. hp_value);

                print("Exploded enemy and lowered HP to " .. tostring(hp_value));
            end;
        end;
        if starts(other:get_name(), "player_") then
            local hp_value = tonumber(string.match(other:get_name(), "player_(%d+)"))
            if hp_value then
                -- Reduce HP by 70
                hp_value = hp_value - 70;
                if hp_value < 0 then
                    hp_value = 0;
                end;
                
                other:set_name("player_" .. hp_value);
            end;
        end;
        if (other:get_name() ~= "Simulo Planet") and (other:get_name() ~= "hammer_1") and (other:get_name() ~= "hammer_2") then
            other:detach();
            other:set_body_type(BodyType.Dynamic);
        end;
    end;
end;

Scene:explode({
    position = self:get_position(),
    radius = 0.2,
    impulse = 1,
});

self:temp_set_collides(false);

local counter = 4;

function on_step()
    counter -= 1;
    if counter <= 0 then
        self:destroy();
    end;
end;