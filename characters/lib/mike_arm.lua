local stick = require('@carroted/characters/assets/sounds/stick6.flac');
local release = require('@carroted/characters/assets/sounds/release.flac');

local normal_color = Color:hex(0x423847);
local sticky_color = Color:hex(0x8ec25e);

local sticky_hinges = {};

local sticky = false;

local cooldown = 10;
local current_cooldown = 0;

local prev_angle = self:get_angle();

local proj_hash = Scene:add_component_def({
    name = "Projectile",
    id = "@carroted/characters/projectile",
    version = "0.1.0",
    code = require('./packages/@carroted/characters/lib/projectile.lua', 'string')
});

function on_update()
    if Scene:get_host():key_just_pressed("Z") then
        sticky = not sticky;
        if sticky then
            self:set_color(sticky_color);
        else
            if #sticky_hinges ~= 0 then
                Scene:add_audio({
                    asset = release,
                    position = self:get_position(),
                });
            end;

            for i=1,#sticky_hinges do
                sticky_hinges[i]:destroy();
            end;
            sticky_hinges = {};
            self:set_color(normal_color);
        end;
    end;

    if Scene:get_host():key_pressed("Q") and (current_cooldown <= 0) then
        current_cooldown = cooldown;

        local player_pos = self:get_position()
        local player_vel = self:get_linear_velocity()
        
        -- Calculate the end point of the weapon
        local weapon_length = 0.5; -- Length of the weapon (same as size.x in the weapon creation)
        local angle = (self:get_angle() + prev_angle) * 0.5;
        local end_point = player_pos + vec2(
            weapon_length * math.cos(angle),
            weapon_length * math.sin(angle)
        );

        -- Add the projectile at the calculated end point
        local name = "Projectile";
        local projectile_speed = 50;

        local proj_color = Color:hex(0xffffff);
        
        local proj = Scene:add_circle({
            position = end_point,
            radius = 0.05,
            color = proj_color,
            name = name,
        });
        proj:set_density(10);
        proj:set_angle(angle);
        proj:set_restitution(1);
        proj:set_friction(0);

        proj:add_component({ hash = proj_hash });
        
        -- Calculate the projectile velocity
        local velocity = vec2(
            projectile_speed * math.cos(angle),
            projectile_speed * math.sin(angle)
        ) / 2;
        
        -- Set the projectile's velocity
        proj:set_linear_velocity(velocity)

        self:apply_force_to_center(-velocity * 5);
    end;
end;

function on_hit(data)
    if sticky then
        if #sticky_hinges == 0 then
            Scene:add_audio({
                asset = stick,
                position = data.point,
            });
        end;

        table.insert(sticky_hinges, Scene:add_hinge({
            local_anchor_a = self:get_local_point(data.point),
            local_anchor_b = data.other:get_local_point(data.point),
            object_a = self,
            object_b = data.other,
            motor_enabled = false,
            motor_speed = 0, -- radians per second
            max_motor_torque = 1.25, -- maximum torque for the motor, in newton-meters
            collide_connected = true,
            color = Color:rgba(0,0,0,0),
        }));
    end;
end;

function on_step()
    if current_cooldown > 0 then
        current_cooldown -= 1;
        if current_cooldown < 0 then
            current_cooldown = 0;
        end;
    end;

    prev_angle = self:get_angle();
end;
