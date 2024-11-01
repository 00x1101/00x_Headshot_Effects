## 頭部射擊粒子效果
**伺服器中的玩家提供了在射擊命中頭部時觸發粒子效果的功能
當玩家射擊命中目標頭部時，會立即出現一組粒子效果，以強化擊中瞬間的視覺反饋。**
## 多框架支援
> ** 支援多種框架，包括ESX、qb-core、qbox和ox_core>**
## 使用方式
> **玩家可以通過指令/headshotmenu開啟特效選單，自行選擇頭部特效**
> **所有變更均會儲存在伺服器的KVP資料庫中**
## 安裝方式
> **將腳本下載放入資源資料夾
> 修改 Config.lua 設定
> 加入至 server.cfg 
> ensure 00x_Headshot_Effects**
## 依賴
> **ox_lib [下載連結](https://github.com/overextended/ox_lib/releases/latest/download/ox_lib.zip)
> ESX、qb-core、qbox、ox_core 根據您的伺服器框架選擇**
## Config
```lua
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
```
