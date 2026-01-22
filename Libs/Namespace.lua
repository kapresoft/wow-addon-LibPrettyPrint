--- @type string
local addon
--- @class LibPrettyPrint_Namespace
--- @field settings LibPrettyPrint_Settings
--- @field name string The addon Name
--- @field O LibPrettyPrint_NamespaceObjects
--- @field O LibPrettyPrint_Formatter
local ns
addon, ns = ...; ns.name = addon

--- @class LibPrettyPrint_ModuleNames
local modules = {
    pprint = '',
    Printer = '',
    Formatter = '',
}; for moduleName in pairs(modules) do modules[moduleName] = moduleName end

--- @class LibPrettyPrint_NamespaceObjects
--- @field LibPrettyPrint LibPrettyPrint
--- @field pprint LibPrettyPrint_pprint
--- @field Printer LibPrettyPrint_Printer
--- @field Formatter LibPrettyPrint_Formatter
local O        = {}

ns.M           = modules; ns.O = O

--- @class LibPrettyPrint_Settings
--- @field developer boolean @if true, enables developer mode
local settings = {
    developer = false
}; ns.settings = settings

--- @return boolean
function ns:IsDev() return self.settings.developer == true end

function ns:register(name, obj)
    assert(name, 'Module name required')
    assert(obj, ('Module instance is invalid. val=%s'):format(tostring(obj)))
    O[name] = obj
    return obj
end


--- @param rgbHex RGBHex|nil    @Optional
--- @return fun(key:string) : string The color formatted key
function ns:colorFn(rgbHex)
    return function(text)
        local c = CreateColorFromRGBHexString(rgbHex)
        assert(c, ('Invalid RGBHex color: %s'):format(rgbHex))
        return c:WrapTextInColorCode(text)
    end
end

--- @param s string
--- @return string|nil
function ns:str_trim(s)
    return type(s) == "string" and s:match("^%s*(.-)%s*$") or s
end

--- @param ... vararg
--- @return table
function ns:SafePack(...)
    local tbl = { ... };
    tbl.n     = select("#", ...)
    return tbl
end

--- Unpacks a table that was constructed using SafePack.
--- @param tbl table
--- @param startIndex number
--- @return any, any, any, any
function ns:SafeUnpack(tbl, startIndex) return unpack(tbl, startIndex or 1, tbl.n) end

--- @param tbl table
--- @param shallow boolean
--- @return table The copied table
function ns:CopyTable(tbl, shallow)
    local copy = {};
    for k, v in pairs(tbl) do
        if type(v) == "table" and not shallow then
            copy[k] = self:CopyTable(v);
        else
            copy[k] = v;
        end
    end
    return copy;
end

--- Merges source into destination; Overwrites existing fields.
--- Modifies and returns destination.
--- @param destination table
--- @param source table
--- @return table
function ns:MergeTable(destination, source)
    for k, v in pairs(source) do
        if type(v) == "table" then
            destination[k] = self:CopyTable(v, false)
        else
            destination[k] = v
        end
    end
    return destination
end

--- Apply source into destination.
--- Only fills missing destination values.
--- Replacement occurs only when destination has no value.
--- Table values are deep-copied.
--- Modifies and returns destination.
--- @param destination table
--- @param source table
--- @return table
function ns:ApplyTableDefaults(destination, source)
    for k, v in pairs(source) do
        local dv = destination[k]

        if dv == nil then
            if type(v) == "table" then
                destination[k] = self:CopyTable(v, false)
            else
                destination[k] = v
            end
        end
        -- else: destination already has a value → never replace
    end
    return destination
end

--- Checks whether value is an instance of class
--- @param value any
--- @param class table  @The class / metatable
--- @return boolean
function ns:IsType(value, class)
    return type(value) == "table" and getmetatable(value) == class
end

LibPrettyPrint_Namespace = ns
