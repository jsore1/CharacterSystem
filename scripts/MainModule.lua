WM("MainModule", function(import, export, exportDefault)
    BlzLoadTOCFile("frames\\framedef.toc")
    
    -- Функция для создания кнопок
    local createButton = import("CreateButton", "FunctionsModule")
    -- Функция для добавления кнопке события
    local buttonAddAction = import("ButtonAddAction", "FunctionsModule")
    
    local x, y = GetPlayerStartLocationX(GetLocalPlayer()), GetPlayerStartLocationY(GetLocalPlayer())
    local hero = CreateUnit(GetLocalPlayer(), FourCC("Hblm"), x, y, 270)
    SelectUnit(hero, true)
    local HeroCharacter = Character:new({ unit = hero, player = GetLocalPlayer() })

    -- Создаем кнопку инвентаря
    local inventoryButtonFrame = createButton("InventoryButton", "ReplaceableTextures\\CommandButtons\\BTNDust.blp", 0.215, 0.14, 0.024, 0.024)
    -- Добавляем кнопке инвентаря событие нажатия
    buttonAddAction(inventoryButtonFrame, function()
        local visible = BlzFrameIsVisible(HeroCharacter.inventoryFrame[1])
        BlzFrameSetVisible(HeroCharacter.inventoryFrame[1], not visible)
        BlzFrameSetVisible(HeroCharacter.inventoryFrame[2], not visible)
        --print("InventoryButton Clicked")
        if GetLocalPlayer() == GetTriggerPlayer() then
            BlzFrameSetEnable(BlzGetTriggerFrame(), false)
            BlzFrameSetEnable(BlzGetTriggerFrame(), true)
        end
    end)

    local tr = CreateTrigger()
    TriggerRegisterUnitEvent(tr, hero, EVENT_UNIT_PICKUP_ITEM)
    TriggerAddAction(tr, function ()
        --print(BlzGetItemTooltip(GetManipulatedItem()))
        HeroCharacter:addItem(GetManipulatedItem())
    end)

    local tr1 = CreateTrigger()
    TriggerRegisterPlayerChatEvent(tr1, GetLocalPlayer(), "test", true)
    TriggerAddAction(tr1, function ()
        HeroCharacter:putOn(1, 1)
        --BlzFrameSetVisible(HeroCharacter.inventoryFrame[1], false)
        --BlzFrameSetVisible(HeroCharacter.inventoryFrame[2], false)
    end)

    print("MainModule загружен")
end)