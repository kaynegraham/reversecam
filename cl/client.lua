cameraEnabled = false
revcam = nil 
 
-- Command -- 
RegisterCommand(Config.command, function()
    ReverseCam()
end)

-- Keymapping -- 
RegisterKeyMapping(Config.command, "Enable Reverse Camera", "keyboard", "Y")

-- Function -- 
function ReverseCam()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    -- If not in a vehicle don't allow the camera
    if not veh or veh == 0 then
        TriggerEvent('chat:addMessage', { color = {0, 255, 0}, args = {"[Reverse Camera]", "You are not in a vehicle."}}) 
        return 
    end

    -- Show camera if not enabled
    if not cameraEnabled then
        cameraEnabled = true
        local pos = GetEntityCoords(veh)
        local heading = GetEntityHeading(veh) - 180

    -- Create camera
        revcam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(revcam, pos.x, pos.y, pos.z + 1.0) 
        SetCamRot(revcam, 0.0, 0.0, heading, 2)
        SetCamFov(revcam, 60.0)
        SetCamActive(revcam, true)
        RenderScriptCams(true, false, 1, true, true)

        -- Update Camera
        CreateThread(function()
            while cameraEnabled do
                Wait(0)

                if not IsPedInAnyVehicle(PlayerPedId(), false) then
                    cameraEnabled = false
                    SetCamActive(revcam, false)
                    DestroyCam(revcam, false)
                    RenderScriptCams(false, false, 1, false, false)
                    break
                end

                -- Follow car movements
                local newPos = GetEntityCoords(veh)
                local newHeading = GetEntityHeading(veh) - 180

                local camOffset = GetOffsetFromEntityInWorldCoords(veh, 0.0, -0.7, 1.0)
                SetCamCoord(revcam, camOffset.x, camOffset.y, camOffset.z)
                SetCamRot(revcam, 0.0, 0.0, newHeading, 2)
            end
        end)
    else
        -- Disable Camera
        cameraEnabled = false
        SetCamActive(revcam, false)
        DestroyCam(revcam, false)
        RenderScriptCams(false, false, 1, false, false)
    end
end 

-- On Resource Stop -- 
AddEventHandler("onResourceStop", function(resource)
    if (GetCurrentResourceName() ~= resource) then
      return
    end

    RenderScriptCams(false, false, 1, false, false) 
    DestroyCam(revcam, 0)
end)