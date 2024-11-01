if Config.Framework == 'ESX' then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded',function(xPlayer, isNew, skin)
        if xPlayer then
            local savedIndex = GetResourceKvpInt(Config.EFFECT_INDEX_KEY)
            if savedIndex ~= 0 and savedIndex <= #Config.availableEffects then
                _G.currentEffectIndex = savedIndex
                Config.currentEffectIndex = savedIndex
            else
                _G.currentEffectIndex = Config.currentEffectIndex
            end
        end
    end)
elseif Config.Framework == 'qb-core' then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        local savedIndex = GetResourceKvpInt(Config.EFFECT_INDEX_KEY)
        if savedIndex ~= 0 and savedIndex <= #Config.availableEffects then
            _G.currentEffectIndex = savedIndex
            Config.currentEffectIndex = savedIndex
        else
            _G.currentEffectIndex = Config.currentEffectIndex
        end
    end)
elseif Config.Framework == 'qbox' then
    RegisterNetEvent('QBox:Client:OnPlayerLoaded')
    AddEventHandler('QBox:Client:OnPlayerLoaded', function()
        local savedIndex = GetResourceKvpInt(Config.EFFECT_INDEX_KEY)
        if savedIndex ~= 0 and savedIndex <= #Config.availableEffects then
            _G.currentEffectIndex = savedIndex
            Config.currentEffectIndex = savedIndex
        else
            _G.currentEffectIndex = Config.currentEffectIndex
        end
    end)
elseif Config.Framework == 'ox_core' then
    RegisterNetEvent('ox:playerLoaded')
    AddEventHandler('ox:playerLoaded', function(playerId, isNew)
        if playerId then
            local savedIndex = GetResourceKvpInt(Config.EFFECT_INDEX_KEY)
            if savedIndex ~= 0 and savedIndex <= #Config.availableEffects then
                _G.currentEffectIndex = savedIndex
                Config.currentEffectIndex = savedIndex
            else
                _G.currentEffectIndex = Config.currentEffectIndex
            end
        end
    end)
end

local particles = {}
local lastShot = 0

local function CreateHeadshotEffect(coords)
    local currentTime = GetGameTimer()
    if currentTime - lastShot < Config.cooldown then
        return
    end

    lastShot = currentTime

    if _G.currentEffectIndex < 1 or _G.currentEffectIndex > #Config.availableEffects then
        _G.currentEffectIndex = 1
    end

    local selectedEffect = Config.availableEffects[_G.currentEffectIndex]
    
    UseParticleFxAssetNextCall("core")
    local primaryEffect = StartParticleFxLoopedAtCoord(
        selectedEffect.primary,
        coords.x, coords.y, coords.z,
        0.0, 0.0, 0.0,
        selectedEffect.scale[1],
        false, false, false, false
    )
    
    UseParticleFxAssetNextCall("core")
    local secondaryEffect = StartParticleFxLoopedAtCoord(
        selectedEffect.secondary,
        coords.x, coords.y, coords.z,
        0.0, 0.0, 0.0,
        selectedEffect.scale[2],
        false, false, false, false
    )
    
    table.insert(particles, primaryEffect)
    table.insert(particles, secondaryEffect)
    
    Citizen.CreateThread(function()
        Citizen.Wait(1000)
        if DoesParticleFxLoopedExist(primaryEffect) then
            StopParticleFxLooped(primaryEffect, 0)
        end
        if DoesParticleFxLoopedExist(secondaryEffect) then
            StopParticleFxLooped(secondaryEffect, 0)
        end
        
        for i = #particles, 1, -1 do
            if particles[i] == primaryEffect or particles[i] == secondaryEffect then
                table.remove(particles, i)
            end
        end
    end)
end

local function CreateEffectMenu()
    local options = {}
    
    for i, effect in ipairs(Config.availableEffects) do
        options[i] = {
            label = effect.label,
            description = '選擇 ' .. effect.label .. ' 作為暴頭特效'
        }
    end
    
    return options
end

local function HandleMenuSelect(selected)
    _G.currentEffectIndex = selected
    SetResourceKvpInt(Config.EFFECT_INDEX_KEY, selected)

    lib.notify({
        title = '特效已更改',
        description = '已選擇: ' .. Config.availableEffects[_G.currentEffectIndex].label,
        type = 'success'
    })
end

local function OpenEffectsMenu()
    local menu = {
        id = 'headshot_effects_menu',
        title = '暴頭特效選擇',
        position = 'top-right',
        options = CreateEffectMenu()
    }
    
    lib.registerMenu(menu, function(selected)
        HandleMenuSelect(selected)
    end)

    lib.showMenu('headshot_effects_menu')
end

RegisterCommand('headshotmenu', function()
    OpenEffectsMenu()
end, false)

AddEventHandler('gameEventTriggered', function(name, data)
    if name == "CEventNetworkEntityDamage" then
        local sourceEntity = data[1]
        local player = data[2]
        if DoesEntityExist(sourceEntity) and GetEntityType(sourceEntity) == 1 then
            if player == PlayerPedId() or (Config.ShowNPC and player == -1) then
                local currentHealth = GetEntityHealth(sourceEntity)
                local bone = GetPedLastDamageBone(sourceEntity)
                local isHeadshot = (bone == 31086)
                
                if not isHeadshot and currentHealth <= 0 then
                    isHeadshot = true
                end

                if isHeadshot then
                    local boneCoords = GetPedBoneCoords(sourceEntity, bone, 0.0, 0.0, 0.0)
                    if boneCoords then
                        local headSize = GetPedHeadBlendData(sourceEntity)
                        local effectOffset = (headSize and headSize.shapeThird * 0.01) or 0.0
                        
                        local effectCoords = vector3(
                            boneCoords.x,
                            boneCoords.y,
                            boneCoords.z + effectOffset
                        )
                        
                        CreateHeadshotEffect(effectCoords)
                    end
                end
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    
    for _, particleId in ipairs(particles) do
        if DoesParticleFxLoopedExist(particleId) then
            StopParticleFxLooped(particleId, 0)
        end
    end
end)