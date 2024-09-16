local count = 4;

function on_step()
    count -= 1;
    if count <= 0 then
        self:destroy();
    end;
end;