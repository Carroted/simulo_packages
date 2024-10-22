local parent = nil;
local size = nil;

function on_event(id, data)
    if id == "@carroted/entaped_test_2d/tape/init" then
        parent = Scene:get_object_by_guid(data.guid);
        size = data.size;
    end;
end;

function on_hit(data)
    parent:send_event("@carroted/entaped_test_2d/tape/collision", {
        point = data.point,
        guid = self.guid,
        size = size,
    });
end;