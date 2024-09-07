function on_collision_start(data)
    if data.other:get_body_type() ~= BodyType.Static then
        data.other:bolt_to(self);
    end;
end;