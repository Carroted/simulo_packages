function on_collision_start(data)
    data.other:send_event("@carroted/pylon_recon/weapon", {
        id = "flingstick",
        guid = self.guid,
    });
end;