-- if LibPrettyPrint exists, it's already been loaded
if LibPrettyPrint then return end

--- @type string
local addon

--- @class PrivateNamespace
--- @field LibPrettyPrint LibPrettyPrint_Namespace
local parentNs

--- @class LibPrettyPrint_Namespace
--- @field settings LibPrettyPrint_Settings
--- @field name string The addon Name
--- @field O LibPrettyPrint_NamespaceObjects
--- @field O LibPrettyPrint_Formatter
local ns = {}

addon, parentNs = ...; parentNs.LibPrettyPrint = ns; ns.name = addon

--- @class LibPrettyPrint_ModuleNames
local modules = {
    pprint = '',
    Printer = '',
    Formatter = '',
}; for moduleName in pairs(modules) do modules[moduleName] = moduleName end

--- @class LibPrettyPrint_NamespaceObjects
--- @field LibPrettyPrint LibPrettyPrint
--- @field pprint LibPrettyPrint_pprint
--- @field Printer LibPrettyPrint_PrinterImpl
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
function ns:Table_Copy(tbl, shallow)
    if tbl == nil then return nil end
    local copy = {};
    for k, v in pairs(tbl) do
        if type(v) == "table" and not shallow then
            copy[k] = self:Table_Copy(v);
        else
            copy[k] = v;
        end
    end
    return copy;
end

--- Applies non-nil values from {right} over {left}.
--- {left} values act as defaults.
--- Returns a new table; inputs are not modified.
--- #### Example:
--- ```
--- local mergedConfig = Table_MergeWithDefaults(DEFAULT, userConfig)
--- ```
--- @param left table|nil The default values
--- @param right table  The override values; overrides values of {left} if non-nil
--- @return table
function ns:Table_MergeWithDefaults(left, right)
    assert(type(right) == 'table', "The param [right] must be a table.")
    if left == nil then return self:Table_Copy(right, false) end
    local result = self:Table_Copy(left, false)
    
    -- apply override values over defaults
    for k, v in pairs(right) do
        if type(v) == "table" then
            local destSub = type(result[k]) == "table" and result[k] or nil
            result[k] = self:Table_MergeWithDefaults(destSub, v)
        else
            if v ~= nil then result[k] = v end
        end
    end
    return result
end

--- Checks whether value is an instance of class
--- @param value any
--- @param class table  @The class / metatable
--- @return boolean
function ns:IsType(value, class)
    return type(value) == "table" and getmetatable(value) == class
end

LibPrettyPrint_Namespace = ns
