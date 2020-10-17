WM("FunctionsModule", function(import, export, exportDefault)
    local GAMEUI = import("GAMEUI", "OriginFramesModule")

    -- Принимает два параметра: Кнопку и действие
    export("ButtonAddAction", function(buttonFrame, buttonClickAction)
        local buttonEventTrigger = CreateTrigger()
        TriggerAddAction(buttonEventTrigger, buttonClickAction)
        BlzTriggerRegisterFrameEvent(buttonEventTrigger, buttonFrame, FRAMEEVENT_CONTROL_CLICK)
    end)

    -- Принимает шесть параметров: Название кнопки, путь к изображению иконки
    -- расположение кнопки по x, расположение кнопки по y, ширина кнопки, высота кнопки
    -- Возвращает созданную кнопку
    export("CreateButton", function(buttonName, iconPath, x, y, width, height)
        local ButtonFrame = BlzCreateFrameByType("GLUEBUTTON", buttonName, GAMEUI, "ScoreScreenTabButtonTemplate", 0)
        local ButtonIconFrame = BlzCreateFrameByType("BACKDROP", (buttonName.."Icon"), ButtonFrame, "", 0)
        BlzFrameSetAllPoints(ButtonIconFrame, ButtonFrame)
        BlzFrameSetTexture(ButtonIconFrame, iconPath, 0, true)
        BlzFrameSetAbsPoint(ButtonFrame, FRAMEPOINT_BOTTOM, x, y)
        BlzFrameSetSize(ButtonFrame, width, height)
        return ButtonFrame
    end)
end)