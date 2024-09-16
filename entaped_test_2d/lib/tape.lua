local parent = nil;
local size = nil;

function on_event(id, data)
    if id == "@carroted/entaped_test_2d/tape/init" then
        parent = Scene:get_object_by_guid(data.guid);
        size = data.size;
    end;
end;

function on_collision_start(data)
    for i=1,#data.points do
        parent:send_event("@carroted/entaped_test_2d/tape/collision", {
            point = data.points[i],
            guid = self.guid,
            size = size,
        });
    end;
end;