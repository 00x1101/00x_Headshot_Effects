Config = {
    Framework = 'ESX', -- ESX or qb-core or qbox or ox_core
    EFFECT_INDEX_KEY = "headshot_effect_index", -- 使用kvp保存
    cooldown = 50, -- 毫秒
    ShowNPC = true,
    currentEffectIndex = 1, --預設索引
    availableEffects = {
        {
            label = "血液濺射",
            primary = "blood_stab",
            secondary = "ent_sht_blood",
            scale = {1.5, 2.0}
        },
        {
            label = "爆炸特效",
            primary = "exp_grd_grenade_smoke",
            secondary = "exp_air_molotov",
            scale = {0.5, 0.7}
        },
        {
            label = "電擊效果",
            primary = "ent_sht_electrical_box",
            secondary = "ent_dst_electrical",
            scale = {1.0, 1.2}
        },
        -- 新增更多
    }
}

