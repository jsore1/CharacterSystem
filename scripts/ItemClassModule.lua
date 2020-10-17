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