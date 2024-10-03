local insitmode = false
local coords = vector4(0.0, 0.0, 0.0, 0.0)
index = 1
local object = nil
local lastcoords = nil
local originalCoords = nil
local disabledCommands = false
local blockedSit = false

local objectName = GetHashKey("prop_ld_can_01")
local maxdistance = 5
local menupiuleft = false
local menupiuright = false


Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', ('/%s'):format(Config.Command), Config.CommandSuggestion, {})
end)

local function enablesitmode()
    local ped = PlayerPedId()
    if insitmode then
        originalCoords = GetEntityCoords(ped)
        if not object then
            while not HasModelLoaded(objectName) do
                RequestModel(objectName)
                Wait(5)
            end
            local pedRot = GetEntityRotation(ped)
            local pedHeading = GetEntityHeading(ped)
            object = CreateObject(objectName, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
            while not DoesEntityExist(object) do
                Wait(0)
            end
            FreezeEntityPosition(object, true)
            FreezeEntityPosition(ped, true)
            SetEntityCollision(object, false, false)
            SetEntityAlpha(object, 0, false)
            SetEntityVisible(object, false, 0)
            SetEntityRotation(object, 0.0, 0.0, pedHeading, 2, false)
            SetEntityHeading(object, pedHeading)
            AttachEntityToEntity(ped, object, ped, 0.0, 0.0, -0.07, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            SetEntityHeading(ped, pedHeading)
        end


        Citizen.CreateThread(function()

            buttons = setupScaleform("instructional_buttons")
        
            currentSpeed = Config.MovementSpeed
        
            while insitmode do
                Citizen.Wait(0)
                DisableControls()
                local xoff = 0.0
                local yoff = 0.0
                local zoff = 0.0

                if not disabledCommands and not blockedSit then
                    FreezeEntityPosition(object, false)

                    DrawScaleformMovieFullscreen(buttons)
        
                    if IsDisabledControlPressed(0, Config.Controls.goForward) then
                        yoff = Config.Offsets.y
                    end
                    
                    if IsDisabledControlPressed(0, Config.Controls.goBackward) then
                        yoff = -Config.Offsets.y
                    end

                    if IsDisabledControlPressed(0, Config.Controls.blockCommands) then
                        blockedSit = true
                        
                        NetworkRegisterEntityAsNetworked(object)
                    end

                    if IsDisabledControlPressed(0, Config.Controls.exitMoveMode) then
                        insitmode = not insitmode
                        -- SetEntityCollision(ped, not insitmode, not insitmode)
                        -- FreezeEntityPosition(ped, insitmode)
                        SetEntityInvincible(ped, insitmode)
                        SetVehicleRadioEnabled(ped, not insitmode)
                        enablesitmode()
                    end

                    if IsDisabledControlPressed(0, Config.Controls.goLeft) then
                        xoff = -Config.Offsets.x
                    end
                    
                    if IsDisabledControlPressed(0, Config.Controls.goRight) then
                        xoff = Config.Offsets.x
                    end
                    
                    if IsDisabledControlPressed(0, Config.Controls.turnLeft) then
                        local pos = GetEntityRotation(object)
                        SetEntityRotation(object, pos.x, pos.y, GetEntityHeading(object)+Config.Offsets.h, 2, false)
                        SetEntityRotation(ped, pos.x, pos.y, GetEntityHeading(object)+Config.Offsets.h, 2, false)
                    end
                    
                    if IsDisabledControlPressed(0, Config.Controls.turnRight) then
                        local pos = GetEntityRotation(object)
                        SetEntityRotation(object, pos.x, pos.y, GetEntityHeading(object)-Config.Offsets.h, 2, false)
                        SetEntityRotation(ped, pos.x, pos.y, GetEntityHeading(object)+Config.Offsets.h, 2, false)
                    end
                    
                    if IsDisabledControlPressed(0, Config.Controls.goUp) then
                        zoff = Config.Offsets.z
                    end
                    
                    if IsDisabledControlPressed(0, Config.Controls.goDown) then
                        zoff = -Config.Offsets.z
                    end
                end
                local newPos = GetOffsetFromEntityInWorldCoords(object, xoff * (currentSpeed), yoff * (currentSpeed), zoff * (currentSpeed))
                local heading = GetEntityHeading(object)

                SetEntityVelocity(object, 0.0, 0.0, 0.0)
                if #(newPos - originalCoords) < maxdistance then
                    SetEntityCoordsNoOffset(object, newPos.x, newPos.y, newPos.z, noclipActive, noclipActive, noclipActive)
                end
                if not IsEntityAttachedToEntity(object, ped) then
                    AttachEntityToEntity(ped, object, ped, 0.0, 0.0, -0.07, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                end
                FreezeEntityPosition(object, true)
                if IsPedInAnyVehicle(ped) then
                    if object then
                        if IsEntityAttachedToEntity(object, ped) then
                            DetachEntity(ped, true, true)
                        end
                        DeleteEntity(object)
                        object = nil
                    end
                    FreezeEntityPosition(ped, false)
                    SetEntityCoords(ped, originalCoords + vector3(0.0, 0.0, -1.0))
                    insitmode = false
                    disabledCommands = false
                    blockedSit = false
                end
                
            end
        end)
    else
        if object then
            if IsEntityAttachedToEntity(object, ped) then
                DetachEntity(ped, true, true)
            end
            DeleteEntity(object)
            object = nil
        end
        FreezeEntityPosition(ped, false)
        SetEntityCoords(ped, originalCoords + vector3(0.0, 0.0, -1.0))
    end
end


exports("DisableCommands", function(bool)
    disabledCommands = bool
    if not disabledCommands then
        if not blockedSit then
            buttons = setupScaleform("instructional_buttons")
        end
    end
end)

RegisterCommand(Config.Command, function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped) then

        if blockedSit then
            if object then
                FreezeEntityPosition(ped, false)
                local pedHeading = GetEntityHeading(object)
                local pedCoords = GetEntityCoords(ped)
                if IsEntityAttachedToEntity(object, ped) then
                    DetachEntity(ped, true, true)
                end
                DeleteEntity(object)
                object = CreateObject(objectName, pedCoords.x, pedCoords.y, pedCoords.z, false, false, false)
                while not DoesEntityExist(object) do
                    Wait(0)
                end
                FreezeEntityPosition(object, true)
                FreezeEntityPosition(ped, true)
                SetEntityCollision(object, false, false)
                -- SetVehicleGravity(object, false)
                SetEntityAlpha(object, 0, false)
                SetEntityVisible(object, false, 0)
                SetEntityRotation(object, 0.0, 0.0, pedHeading, 2, false)
                SetEntityHeading(object, pedHeading)
                AttachEntityToEntity(ped, object, ped, 0.0, 0.0, -0.07, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                SetEntityHeading(ped, pedHeading)
            end
            blockedSit = false
            if not disabledCommands then
                buttons = setupScaleform("instructional_buttons")
            end
        else
            insitmode = not insitmode
            SetEntityInvincible(ped, insitmode)
            SetVehicleRadioEnabled(ped, not insitmode)
            enablesitmode()
        end
    end

end)

exports("CheckSit", function()
    return insitmode
end)

AddEventHandler('onResourceStop', function(rname)
    if GetCurrentResourceName() == rname then
        if originalCoords ~= nil and insitmode then
            local ped = PlayerPedId()
            if object then
                if IsEntityAttachedToEntity(object, ped) then
                    DetachEntity(ped, true, true)
                end
                DeleteEntity(object)
                object = nil
            end
            FreezeEntityPosition(ped, false)
            SetEntityCoords(ped, originalCoords + vector3(0.0, 0.0, -1.0))
        end
    end
end)