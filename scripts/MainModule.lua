WM("MainModule", function(import, export, exportDefault)
    BlzLoadTOCFile("frames\\framedef.toc")
    
    -- Функция для создания кнопок
    local createButton = import("CreateButton", "FunctionsModule")
    -- Функция для добавления кнопке события
    local buttonAddAction = import("ButtonAddAction", "FunctionsModule")
    
    local x = {}
    local y = {}
    x[1], y[1] = GetPlayerStartLocationX(Player(0)), GetPlayerStartLocationY(Player(0))
    x[2], y[2] = GetPlayerStartLocationX(Player(1)), GetPlayerStartLocationY(Player(1))

    local hero = {}
    hero[1] = CreateUnit(Player(0), FourCC("Hblm"), x[1], y[1], 270)
    hero[2] = CreateUnit(Player(1), FourCC("Hblm"), x[2], y[2], 270)
    
    local HeroCharacter = {}
    HeroCharacter[1] = Character:new({ unit = hero[1], player = Player(0) })
    HeroCharacter[2] = Character:new({ unit = hero[2], player = Player(1) })

    -- Создаем кнопку инвентаря
    local inventoryButtonFrame = createButton("InventoryButton", "ReplaceableTextures\\CommandButtons\\BTNDust.blp", 0.215, 0.14, 0.024, 0.024)
    -- Добавляем кнопке инвентаря событие нажатия
    buttonAddAction(inventoryButtonFrame, function()
        for i = 1, #HeroCharacter do
            if GetLocalPlayer() == GetTriggerPlayer() and HeroCharacter[i].player == GetTriggerPlayer() then
                local visible = BlzFrameIsVisible(HeroCharacter[i].inventoryFrame[1])
                BlzFrameSetVisible(HeroCharacter[i].inventoryFrame[1], not visible)
                BlzFrameSetVisible(HeroCharacter[i].inventoryFrame[2], not visible)
                --print("InventoryButton Clicked")
                BlzFrameSetEnable(BlzGetTriggerFrame(), false)
                BlzFrameSetEnable(BlzGetTriggerFrame(), true)
                print(GetTriggerPlayer())
            end
        end
    end)

    local triggerUnitPickupItem = {}
    for i = 1, #HeroCharacter do
        triggerUnitPickupItem[i] = CreateTrigger()
        TriggerRegisterUnitEvent(triggerUnitPickupItem[i], hero[i], EVENT_UNIT_PICKUP_ITEM)
        TriggerAddAction(triggerUnitPickupItem[i], function ()
            --print(BlzGetItemTooltip(GetManipulatedItem()))
            HeroCharacter[i]:addItem(GetManipulatedItem())
        end)
    end

    print("MainModule загружен")
end)