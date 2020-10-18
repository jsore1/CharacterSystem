-- (wlpm-generated-code start)

-- Warcraft 3 Lua Package Manager 0.7-beta
-- Build time: 2020.10.18 20:38:27 +03:00
-- Module Manager
-- author: ScorpioT1000 / scorpiot1000@yandex.ru / github.com/indaxia/WLPM

local wlpmModules = {}

function wlpmDeclareModule(name, dependenciesOrContext, context)
  local theModule = {
    loaded = false,
    dependencies = {},
    context = nil,
    exports = {},
    exportDefault = nil
  }
  if (type(context) == "function") then
    theModule.context = context
    if (type(dependenciesOrContext) == "table") then
      theModule.dependencies = dependenciesOrContext
    end
  elseif (type(dependenciesOrContext) == "function") then
    theModule.context = dependenciesOrContext
  else  
    print("WLPM Error: wrong module declaration: '" .. name .. "'. Module requires context function callback.")
    return
  end
  wlpmModules[name] = theModule
end

function wlpmLoadModule(name, depth)
  local theModule = wlpmModules[name]
  if (type(depth) == 'number') then
    if (depth > 512) then
      print("WLPM Error: dependency loop detected for the module '" .. name .. "'")
      return
    end
    depth = depth + 1
  else
    local depth = 0
  end
  if (type(theModule) ~= "table") then
    print("WLPM Error: module '" .. name .. "' not exists or not yet loaded. Call importWM at your initialization section")
    return
  elseif (not theModule.loaded) then
    for _, dependency in ipairs(theModule.dependencies) do
      wlpmLoadModule(dependency, depth)
    end
    
    local cb_import = function(moduleOrWhatToImport, moduleToImport) -- import default or import special
      if (type(moduleToImport) ~= "string") then
        return wlpmImportModule(moduleOrWhatToImport)
      end
      return wlpmImportModule(moduleToImport, moduleOrWhatToImport)
    end
    local cb_export = function(whatToExport, singleValue) -- export object or key and value
      if (type(whatToExport) == "table") then
        for k,v in pairs(whatToExport) do theModule.exports[k] = v end -- merges exports
      elseif (type(whatToExport) == "string") then
        theModule.exports[whatToExport] = singleValue
      else
        print("WLPM Error: wrong export syntax in module '" .. name .. "'. Use export() with a single object arg or key-value args")
        return
      end
    end
    local cb_exportDefault = function(defaultExport) -- export default
      if (defaultExport == nil) then
        print("WLPM Error: wrong default export syntax in module '" .. name .. "'. Use exportDefault() with an argument")
        return
      end
      theModule.exportDefault = defaultExport
    end
    
    theModule.context(cb_import, cb_export, cb_exportDefault)
    theModule.loaded = true
  end
  
  return theModule
end

function wlpmImportModule(name, whatToImport)
  theModule = wlpmLoadModule(name)
  if (type(whatToImport) == "string") then
    if(theModule.exports[whatToImport] == nil) then
      print("WLPM Error: name '" .. whatToImport .. "' was never exported by the module '" .. name .. "'")
      return
    end
    return theModule.exports[whatToImport]
  end
  return theModule.exportDefault
end

function wlpmLoadAllModules()
  for name,theModule in pairs(wlpmModules) do wlpmLoadModule(name) end
end

WM = wlpmDeclareModule
importWM = wlpmImportModule
loadAllWMs = wlpmLoadAllModules -- call to disable lazy loading mechanics






-- C:\Users\Yaroslav\Documents\Projects\character-system.w3m\scripts\CharacterClassModule.lua
WM("CharacterClassModule", function(import, export, exportDefault)
    local GAMEUI = import("GAMEUI", "OriginFramesModule")

    -- Класс Персонаж
        -- свойтсво player хранит владельца боевой единицы
        -- свойство unit хранит ссылку на боевую единицу
        -- свойство agility хранит значение ловкости
        -- свойство strength хранит значение силы
        -- свойство intelligence хранит значение интиллекта
        -- свойство inventory хранит таблицу с полями lines, columns, content
        -- свойство equipmentSlots хранит таблицу с полями для хранения предметов экипировки
        -- свойство inventoryFrame хранит таблицу с ссылками на фреймы CharacterBackdrop и CharacterPanel
        -- свойство inventorySlots хранит двумерный массив n на m. Каждая ячейка содержит такие свойства как:
            -- slotBackdrop - ссылка на фрейм с текстурой текущего предмета
            -- buttonFrame - ссылка на фрейм с кнопкой для того, чтобы можно было взаимодействовать с предметом в ячейке
            -- item - ссылка на предмет, который есть в ячейке.
        -- свойство tooltip хранит ссылку на тултип для отображении информации о предмете
        Character = {
            player = nil,
            unit = nil,
            agility = nil,
            strength = nil,
            intelligence = nil,
            inventory = nil,
            equipmentSlots = nil,
            inventoryFrame = nil,
            inventorySlots = nil,
            tooltip = nil,
        }

    -- Функция конструктор Персонажа
    function Character:new (o)
        o = o or {}
        setmetatable(o, self)
        self.__index = self
        o.agility = BlzGetUnitIntegerField(o.unit, UNIT_IF_AGILITY) -- Задаем начальное значение ловкости
        o.strength = BlzGetUnitIntegerField(o.unit, UNIT_IF_STRENGTH) -- Задаем начальное значение силы
        o.intelligence = BlzGetUnitIntegerField(o.unit, UNIT_IF_INTELLIGENCE) -- Задаем начальное значение интиллекта
        o.inventory = {
            lines = 4,
            columns = 5,
            equipmentLines = 3,
            equipmentColumns = 3,
        }

        -- создаем массив с ссылками на фреймы главного окна панели Персонажа
        o.inventoryFrame = {
            BlzCreateFrame("EscMenuBackdrop", GAMEUI, 0, 0),
            BlzCreateFrameByType("FRAME", "CharacterPanel", GAMEUI, "", 0),
        }
        BlzFrameSetSize(o.inventoryFrame[1], 0.236, 0.39)
        BlzFrameSetAllPoints(o.inventoryFrame[2], o.inventoryFrame[1])
        o.inventoryFrame[3] = BlzCreateFrameByType("TEXT", "CharacterPanelTitleText", o.inventoryFrame[2], "EscMenuTitleTextTemplate", 0)
        BlzFrameSetTextColor(o.inventoryFrame[3], BlzConvertColor(1, 255, 255, 255))
        BlzFrameSetText(o.inventoryFrame[3], "Инвентарь")
        BlzFrameSetPoint(o.inventoryFrame[3], FRAMEPOINT_TOP, o.inventoryFrame[2], FRAMEPOINT_TOP, 0, -0.03)
        -- Выставляем позиции фреймам главного окна панели Персонажа
        BlzFrameSetAbsPoint(o.inventoryFrame[1], FRAMEPOINT_CENTER, 0.68, 0.365)
        BlzFrameSetAbsPoint(o.inventoryFrame[2], FRAMEPOINT_CENTER, 0.68, 0.365)

        -- Добавляем в свойство tooltip ссылку на фрейм тултипа
        o.tooltip = {}
        o.tooltip[1] = BlzCreateFrameByType("BACKDROP", "Tooltip", o.inventoryFrame[2], "EscMenuControlBackdropTemplate", 0)
        o.tooltip[2] = BlzCreateFrameByType("TEXT", "TooltipTitle", o.tooltip[1], "", 0)
        BlzFrameSetPoint(o.tooltip[2], FRAMEPOINT_TOPLEFT, o.tooltip[1], FRAMEPOINT_TOPLEFT, 0.01, -0.01)
        BlzFrameSetFont(o.tooltip[2], "Fonts\\NimrodMT.ttf", 0.012, 0)
        BlzFrameSetTextColor(o.tooltip[2], BlzConvertColor(1, 255, 255, 255))
        o.tooltip[3] = BlzCreateFrameByType("TEXT", "TooltipText", o.tooltip[1], "", 0)
        BlzFrameSetPoint(o.tooltip[3], FRAMEPOINT_TOPLEFT, o.tooltip[1], FRAMEPOINT_TOPLEFT, 0.01, -0.02)
        BlzFrameSetFont(o.tooltip[3], "Fonts\\NimrodMT.ttf", 0.012, 0)
        BlzFrameSetTextColor(o.tooltip[3], BlzConvertColor(1, 255, 255, 255))
        BlzFrameSetSize(o.tooltip[1], 0.12, 0.08) -- Задаем размер окну тултипа
        BlzFrameSetLevel(o.tooltip[1], 2)
        BlzFrameSetVisible(o.tooltip[1], false)
        
        o.inventorySlots = {}

        for i = 1, o.inventory.lines do
            o.inventorySlots[i] = {}
            for j = 1, o.inventory.columns do
                o.inventorySlots[i][j] = {}
                o.inventorySlots[i][j]["slotBackdrop"] = BlzCreateFrameByType("BACKDROP", "SlotBackdrop", o.inventoryFrame[2], "", 0)
                BlzFrameSetTexture(o.inventorySlots[i][j]["slotBackdrop"], "images\\emty_slot.blp", 0, true)
                BlzFrameSetSize(o.inventorySlots[i][j]["slotBackdrop"], 0.038, 0.038)
                o.inventorySlots[i][j]["slotItemBackdrop"] = BlzCreateFrameByType("BACKDROP", "SlotItemBackdrop", o.inventoryFrame[2], "", 0)
                BlzFrameSetTexture(o.inventorySlots[i][j]["slotItemBackdrop"], "images\\transparent_slot.blp", 0, true)
                BlzFrameSetSize(o.inventorySlots[i][j]["slotItemBackdrop"], 0.032, 0.032)
                o.inventorySlots[i][j]["buttonFrame"] = BlzCreateFrameByType("BUTTON", "ButtonFrame", o.inventorySlots[i][j]["slotBackdrop"], "", 0)
                o.inventorySlots[i][j]["item"] = Item:new(
                    { 
                        id = nil, 
                        name = "Пусто", 
                        descr = "Пусто", 
                        class = nil,
                        iconPath = nil,
                        abilitys = {},
                        max_stacks = 0,
                        num_of_charges = 0,
                    })
                BlzFrameSetAllPoints(o.inventorySlots[i][j]["buttonFrame"], o.inventorySlots[i][j]["slotBackdrop"])
                BlzFrameSetPoint(o.inventorySlots[i][j]["slotItemBackdrop"], FRAMEPOINT_CENTER, o.inventorySlots[i][j]["slotBackdrop"], FRAMEPOINT_CENTER, 0, 0)
                BlzFrameSetPoint(o.inventorySlots[i][j]["slotBackdrop"], FRAMEPOINT_TOPLEFT, o.inventoryFrame[1], FRAMEPOINT_TOPLEFT, 0.02 + ((j - 1) * 0.0395), (-0.213 + ((i - 1) * -0.0395)))
                BlzFrameSetText(o.tooltip[3], "Пусто")
                BlzFrameSetText(o.tooltip[2], "Пусто")
                o.inventorySlots[i][j]["fr"] = nil -- Для отлова правой кнопки мыши на фрейме
                o.inventorySlots[i][j]["triggers"] = {
                    CreateTrigger(),
                    CreateTrigger(),
                    CreateTrigger(),
                    CreateTrigger(),
                }
                o.inventorySlots[i][j]["events"] = {
                    BlzTriggerRegisterFrameEvent(o.inventorySlots[i][j]["triggers"][1], o.inventorySlots[i][j]["buttonFrame"], FRAMEEVENT_MOUSE_ENTER),
                    BlzTriggerRegisterFrameEvent(o.inventorySlots[i][j]["triggers"][2], o.inventorySlots[i][j]["buttonFrame"], FRAMEEVENT_MOUSE_LEAVE),
                    BlzTriggerRegisterFrameEvent(o.inventorySlots[i][j]["triggers"][3], o.inventorySlots[i][j]["buttonFrame"], FRAMEEVENT_CONTROL_CLICK),
                    TriggerRegisterPlayerMouseEventBJ(o.inventorySlots[i][j]["triggers"][4], Player(0), bj_MOUSEEVENTTYPE_DOWN),
                }
                o.inventorySlots[i][j]["actions"] = {
                    TriggerAddAction(o.inventorySlots[i][j]["triggers"][1], function()
                        o.inventorySlots[i][j]["fr"] = BlzGetTriggerFrame()
                        BlzFrameSetText(o.tooltip[3], o.inventorySlots[i][j]["item"]["descr"])
                        BlzFrameSetText(o.tooltip[2], o.inventorySlots[i][j]["item"]["name"])
                        BlzFrameSetPoint(o.tooltip[1], FRAMEPOINT_TOPRIGHT, o.inventorySlots[i][j]["slotBackdrop"], FRAMEPOINT_TOPLEFT, 0, 0)
                        BlzFrameSetVisible(o.tooltip[1], true)
                    end),
                    TriggerAddAction(o.inventorySlots[i][j]["triggers"][2], function()
                        o.inventorySlots[i][j]["fr"] = nil
                        BlzFrameSetVisible(o.tooltip[1], false)
                        BlzFrameSetText(o.tooltip[3], "")
                        BlzFrameSetText(o.tooltip[2], "")
                    end),
                    TriggerAddAction(o.inventorySlots[i][j]["triggers"][3], function()
                        local temp_item
                        for l = 1, o.inventory.equipmentLines do
                            for m = 1, o.inventory.equipmentColumns do
                                if o.equipmentSlots[l][m]["class"] == o.inventorySlots[i][j]["item"]["class"] then
                                    if o.equipmentSlots[l][m]["item"]["id"] ~= o.inventorySlots[i][j]["item"]["id"] then
                                        temp_item = o.equipmentSlots[l][m]["item"]
                                        o.equipmentSlots[l][m]["item"] = o.inventorySlots[i][j]["item"]
                                        BlzFrameSetTexture(o.equipmentSlots[l][m]["itemBackdrop"], o.equipmentSlots[l][m]["item"]["iconPath"], 0, true)
                                        
                                        for k = 1, #o.equipmentSlots[l][m]["item"]["abilitys"] do
                                            UnitAddAbility(o.unit, o.equipmentSlots[l][m]["item"]["abilitys"][k])
                                        end
                                        if temp_item["id"] == nil then
                                            BlzFrameSetTexture(o.inventorySlots[i][j]["slotItemBackdrop"], "images\\transparent_slot.blp", 0, true)
                                            o.inventorySlots[i][j]["item"] = Item:new(
                                            { 
                                                id = nil, 
                                                name = "Пусто", 
                                                descr = "Пусто", 
                                                class = nil,
                                                iconPath = nil,
                                                abilitys = nil,
                                                max_stacks = nil,
                                                num_of_charges = nil,
                                            })
                                            BlzFrameSetText(o.tooltip[3], o.inventorySlots[i][j]["item"]["descr"])
                                            BlzFrameSetText(o.tooltip[2], o.inventorySlots[i][j]["item"]["name"])
                                        else
                                            for k = 1, #temp_item["abilitys"] do
                                                UnitRemoveAbility(o.unit, temp_item["abilitys"][k])
                                            end
                                            o.inventorySlots[i][j]["item"] = temp_item
                                            BlzFrameSetTexture(o.inventorySlots[i][j]["slotItemBackdrop"], o.inventorySlots[i][j]["item"]["iconPath"], 0, true)
                                            BlzFrameSetText(o.tooltip[3], o.inventorySlots[i][j]["item"]["descr"])
                                            BlzFrameSetText(o.tooltip[2], o.inventorySlots[i][j]["item"]["name"])
                                        end
                                        return
                                    end
                                    return
                                end
                            end
                        end
                        temp_item = nil
                    end),
                    TriggerAddAction(o.inventorySlots[i][j]["triggers"][4], function()
                        if o.inventorySlots[i][j]["fr"] ~= nil and BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
                            print("Получилось")
                            o.inventorySlots[i][j]["fr"] = nil
                        end
                    end)
                }
            end
        end

        -- Инициализируем таблицу со слотами экипировки
        o.equipmentSlots = {}
        for i = 1, o.inventory.equipmentLines do
            o.equipmentSlots[i] = {}
            for j = 1, o.inventory.equipmentColumns do
                o.equipmentSlots[i][j] = {}
                o.equipmentSlots[i][j]["backdrop"] = BlzCreateFrameByType("BACKDROP", "Backdrop", o.inventoryFrame[2], "", 0)
                o.equipmentSlots[i][j]["itemBackdrop"] = BlzCreateFrameByType("BACKDROP", "ItemBackdrop", o.inventoryFrame[2], "", 0)
                o.equipmentSlots[i][j]["buttonFrame"] = BlzCreateFrameByType("BUTTON", "", o.equipmentSlots[i][j]["backdrop"], "", 0)
                o.equipmentSlots[i][j]["item"] = Item:new(
                    { 
                        id = nil, 
                        name = "Пусто", 
                        descr = "Пусто", 
                        class = nil,
                        iconPath = nil,
                        abilitys = {},
                        max_stacks = 0,
                        num_of_charges = 0,
                    })
                o.equipmentSlots[i][j]["triggers"] = {
                    CreateTrigger(),
                    CreateTrigger(),
                    CreateTrigger(),
                }
                o.equipmentSlots[i][j]["events"] ={
                    BlzTriggerRegisterFrameEvent(o.equipmentSlots[i][j]["triggers"][1], o.equipmentSlots[i][j]["buttonFrame"], FRAMEEVENT_MOUSE_ENTER),
                    BlzTriggerRegisterFrameEvent(o.equipmentSlots[i][j]["triggers"][2], o.equipmentSlots[i][j]["buttonFrame"], FRAMEEVENT_MOUSE_LEAVE),
                    BlzTriggerRegisterFrameEvent(o.equipmentSlots[i][j]["triggers"][3], o.equipmentSlots[i][j]["buttonFrame"], FRAMEEVENT_CONTROL_CLICK),
                }
                o.equipmentSlots[i][j]["actions"] = {
                    TriggerAddAction(o.equipmentSlots[i][j]["triggers"][1], function()
                        BlzFrameSetText(o.tooltip[3], o.equipmentSlots[i][j]["item"]["descr"])
                        BlzFrameSetText(o.tooltip[2], o.equipmentSlots[i][j]["item"]["name"])
                        BlzFrameSetPoint(o.tooltip[1], FRAMEPOINT_TOPRIGHT, o.equipmentSlots[i][j]["backdrop"], FRAMEPOINT_TOPLEFT, 0, 0)
                        BlzFrameSetVisible(o.tooltip[1], true)
                    end),
                    TriggerAddAction(o.equipmentSlots[i][j]["triggers"][2], function()
                        BlzFrameSetVisible(o.tooltip[1], false)
                        BlzFrameSetText(o.tooltip[3], "")
                        BlzFrameSetText(o.tooltip[2], "")
                    end),
                    TriggerAddAction(o.equipmentSlots[i][j]["triggers"][3], function()
                        for k = 1, o.inventory.lines do
                            for l = 1, o.inventory.columns do
                                if o.inventorySlots[k][l]["item"]["id"] == nil then
                                    o.inventorySlots[k][l]["item"] = o.equipmentSlots[i][j]["item"]
                                    o.equipmentSlots[i][j]["item"] = Item:new(
                                        { 
                                            id = nil, 
                                            name = "Пусто", 
                                            descr = "Пусто", 
                                            class = nil,
                                            iconPath = nil,
                                            abilitys = nil,
                                            max_stacks = nil,
                                            num_of_charges = nil,
                                        })
                                        for m = 1, #o.inventorySlots[k][l]["item"]["abilitys"] do
                                            UnitRemoveAbility(o.unit, o.inventorySlots[k][l]["item"]["abilitys"][m])
                                        end
                                        BlzFrameSetTexture(o.inventorySlots[k][l]["slotItemBackdrop"], o.inventorySlots[k][l]["item"]["iconPath"], 0, true)
                                        BlzFrameSetText(BlzGetFrameByName("TooltipText",0), o.inventorySlots[k][l]["item"]["descr"])
                                        BlzFrameSetText(BlzGetFrameByName("TooltipTitle",0), o.inventorySlots[k][l]["item"]["name"])
                                        BlzFrameSetTexture(o.equipmentSlots[i][j]["itemBackdrop"], "images\\transparent_slot.blp", 0, true)
                                        BlzFrameSetText(BlzGetFrameByName("TooltipText",0), o.equipmentSlots[i][j]["item"]["descr"])
                                        BlzFrameSetText(BlzGetFrameByName("TooltipTitle",0), o.equipmentSlots[i][j]["item"]["name"])
                                elseif o.inventorySlots[k][l]["item"] == o.inventorySlots[o.inventory.lines][o.inventory.columns]["item"] and o.inventorySlots[k][l]["item"] ~= nil then
                                    print("Инвентарь полон")
                                    --UnitDropItem(o.unit, GetItemTypeId(item))
                                    --RemoveItem(item)
                                end
                            end
                        end
                    end),
                }
                BlzFrameSetTexture(o.equipmentSlots[i][j]["itemBackdrop"], "images\\transparent_slot.blp", 0, true)
                BlzFrameSetSize(o.equipmentSlots[i][j]["backdrop"], 0.038, 0.038)
                BlzFrameSetSize(o.equipmentSlots[i][j]["itemBackdrop"], 0.038, 0.038)
                BlzFrameSetAllPoints(o.equipmentSlots[i][j]["buttonFrame"], o.equipmentSlots[i][j]["backdrop"])
                BlzFrameSetPoint(o.equipmentSlots[i][j]["itemBackdrop"], FRAMEPOINT_CENTER, o.equipmentSlots[i][j]["backdrop"], FRAMEPOINT_CENTER, 0, 0)
                BlzFrameSetPoint(o.equipmentSlots[i][j]["backdrop"], FRAMEPOINT_TOP, o.inventoryFrame[2], FRAMEPOINT_TOP, -0.058 + ((j - 1) * 0.058), -0.05 - ((i - 1) * 0.058))
            end
        end
        BlzFrameSetTexture(o.equipmentSlots[1][1]["backdrop"], "images\\main_hand_slot.blp", 0, true)
        o.equipmentSlots[1][1]["class"] = "MainHand"
        BlzFrameSetTexture(o.equipmentSlots[1][2]["backdrop"], "images\\head_slot.blp", 0, true)
        o.equipmentSlots[1][2]["class"] = "Head"
        BlzFrameSetTexture(o.equipmentSlots[1][3]["backdrop"], "images\\off_hand_slot.blp", 0, true)
        o.equipmentSlots[1][3]["class"] = "OffHand"
        BlzFrameSetTexture(o.equipmentSlots[2][1]["backdrop"], "images\\hands_slot.blp", 0, true)
        o.equipmentSlots[2][1]["class"] = "Hands"
        BlzFrameSetTexture(o.equipmentSlots[2][2]["backdrop"], "images\\chest_slot.blp", 0, true)
        o.equipmentSlots[2][2]["class"] = "Chest"
        BlzFrameSetTexture(o.equipmentSlots[2][3]["backdrop"], "images\\shoulders_slot.blp", 0, true)
        o.equipmentSlots[2][3]["class"] = "Shoulders"
        BlzFrameSetTexture(o.equipmentSlots[3][1]["backdrop"], "images\\neck_slot.blp", 0, true)
        o.equipmentSlots[3][1]["class"] = "Neck"
        BlzFrameSetTexture(o.equipmentSlots[3][2]["backdrop"], "images\\feet_slot.blp", 0, true)
        o.equipmentSlots[3][2]["class"] = "Feet"
        BlzFrameSetTexture(o.equipmentSlots[3][3]["backdrop"], "images\\waist_slot.blp", 0, true)
        o.equipmentSlots[3][3]["class"] = "Waist"
        BlzFrameSetVisible(o.inventoryFrame[1], false)
        BlzFrameSetVisible(o.inventoryFrame[2], false)
        return o
    end

    function Character:addItem(item)
        for i = 1, self.inventory.lines do
            for j = 1, self.inventory.columns do
                if self.inventorySlots[i][j]["item"]["id"] == nil then
                    for k = 1, #itemsDB do
                        if GetItemTypeId(item) == itemsDB[k]["id"] then
                            self.inventorySlots[i][j]["item"] = itemsDB[k]
                            BlzFrameSetTexture(self.inventorySlots[i][j]["slotItemBackdrop"], self.inventorySlots[i][j]["item"]["iconPath"], 0, true)
                            RemoveItem(item)
                            return
                        end
                    end
                elseif self.inventorySlots[i][j]["item"] == self.inventorySlots[4][5]["item"] and self.inventorySlots[i][j]["item"] ~= nil then
                    print("Инвентарь полон")
                    UnitDropItem(self.unit, GetItemTypeId(item))
                    RemoveItem(item)
                end
            end
        end
    end

    print("CharacterClassModule загружен")
end)

-- C:\Users\Yaroslav\Documents\Projects\character-system.w3m\scripts\FunctionsModule.lua
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

-- C:\Users\Yaroslav\Documents\Projects\character-system.w3m\scripts\ItemClassModule.lua
WM("ItemClassModule", function(import, export, exportDefault)
    Item = {
        id = nil,
        name = nil,
        descr = nil,
        class = nil,
        iconPath = nil,
        abilitys = nil,
        max_stacks = nil,
        num_of_charges = nil,
    }

    function Item:new (o)
        o = o or {}
        setmetatable(o, self)
        self.__index = self
        return o
    end
    print("ItemClassModule загружен")
end)

-- C:\Users\Yaroslav\Documents\Projects\character-system.w3m\scripts\ItemsDBModule.lua
WM("ItemsDBModule", function(import, export, exportDefault)
    itemsDB = {}
    local temp_item
    for i = 1, udg_countItems do
        temp_item = CreateItem(FourCC("I00" .. (i - 1)), 0, 0)
        itemsDB[i] = Item:new(
            { 
                id = FourCC("I00" .. (i - 1)), 
                name = GetItemName(temp_item), 
                descr = BlzGetItemDescription(temp_item),
                iconPath = BlzGetItemIconPath(temp_item),
                class = BlzGetItemExtendedTooltip(temp_item),
                abilitys = {},
                max_stacks = 0,
                num_of_charges = 0,
            })
        for j = 1, (#BlzGetItemTooltip(temp_item) / 4) do
            if j == 1 then
                itemsDB[i]["abilitys"][j] = FourCC(BlzGetItemTooltip(temp_item):sub(j, j * 4))
            else
                itemsDB[i]["abilitys"][j] = FourCC(BlzGetItemTooltip(temp_item):sub((j - 1) * 4 + 1, j * 4))
            end
        end
        RemoveItem(temp_item)
    end
    temp_item = nil
    udg_countItems = nil
    print("ItemDBModule загружен")
end)

-- C:\Users\Yaroslav\Documents\Projects\character-system.w3m\scripts\MainModule.lua
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

-- C:\Users\Yaroslav\Documents\Projects\character-system.w3m\scripts\OriginFramesModule.lua
WM("OriginFramesModule", function(import, export, exportDefault)
    export("GAMEUI", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0))
end)
-- (wlpm-generated-code end)
gg_trg_Melee_Initialization = nil
function InitGlobals()
end

function Trig_Melee_Initialization_Actions()
    MeleeStartingVisibility()
    MeleeStartingHeroLimit()
    MeleeGrantHeroItems()
    MeleeStartingResources()
    MeleeClearExcessUnits()
    MeleeStartingUnits()
    MeleeStartingAI()
    MeleeInitVictoryDefeat()
end

function InitTrig_Melee_Initialization()
    gg_trg_Melee_Initialization = CreateTrigger()
    TriggerAddAction(gg_trg_Melee_Initialization, Trig_Melee_Initialization_Actions)
end

function InitCustomTriggers()
    InitTrig_Melee_Initialization()
end

function RunInitializationTriggers()
    ConditionalTriggerExecute(gg_trg_Melee_Initialization)
end

function InitCustomPlayerSlots()
    SetPlayerStartLocation(Player(0), 0)
    SetPlayerColor(Player(0), ConvertPlayerColor(0))
    SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
    SetPlayerRaceSelectable(Player(0), true)
    SetPlayerController(Player(0), MAP_CONTROL_USER)
end

function InitCustomTeams()
    SetPlayerTeam(Player(0), 0)
end

function main()
    SetCameraBounds(-3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    NewSoundEnvironment("Default")
    SetAmbientDaySound("LordaeronSummerDay")
    SetAmbientNightSound("LordaeronSummerNight")
    SetMapMusic("Music", true, 0)
    InitBlizzard()
    InitGlobals()
    InitCustomTriggers()
    RunInitializationTriggers()
end

function config()
    SetMapName("TRIGSTR_003")
    SetMapDescription("TRIGSTR_005")
    SetPlayers(1)
    SetTeams(1)
    SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
    DefineStartLocation(0, -576.0, 384.0)
    InitCustomPlayerSlots()
    SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
    InitGenericPlayerSlots()
end

