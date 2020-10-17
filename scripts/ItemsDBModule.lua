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