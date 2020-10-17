WM("FunctionsModule", function(import, export, exportDefault)
    local GAMEUI = import("GAMEUI", "OriginFramesModule")

    -- Принимает два параметра: Кнопку и действие
    export("ButtonAddAction", function(buttonFrame, buttonClickAction)
        local buttonEventTrigger = CreateTrigger()
        TriggerAddAction(buttonEventTrigger, buttonClickAction)
        BlzTriggerRegisterFrameEvent(buttonEventTrigger, buttonFrame, FRAMEEVENT_CONTROL_CLICK)
    end)
end)