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
        position = 'rpgonline',
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

BUILD = GetGameBuildNumber()
AddEventHandler('gameEventTriggered', function(eventName, data)
    if eventName == 'CEventNetworkEntityDamage' then
        local victim = data[1]
        local attacker = data[2]
        
        if attacker ~= PlayerPedId() and victim ~= PlayerPedId() then
            return
        end

        local offset = 0
        if BUILD >= 2060 then
            offset = offset + 1
            if BUILD >= 2189 then
                offset = offset + 1
            end
        end

        if entity ~= victim then
            local is_ped, bone = GetPedLastDamageBone(victim)
            if is_ped == 1 then
                position = GetPedBoneCoords(victim, bone)
                if bone == 31086 then
                    CreateHeadshotEffect(position)
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

    local savedIndex = GetResourceKvpInt(Config.EFFECT_INDEX_KEY)
    if savedIndex ~= 0 and savedIndex <= #Config.availableEffects then
        _G.currentEffectIndex = savedIndex
        Config.currentEffectIndex = savedIndex
    else
        _G.currentEffectIndex = Config.currentEffectIndex
    end
end)
