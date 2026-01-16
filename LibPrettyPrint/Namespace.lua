--- @type string
local addon
--- @class LibPrettyPrint_Namespace
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
--- @field pprint LibPrettyPrint_pprint
--- @field Printer LibPrettyPrint_Printer
--- @field Formatter LibPrettyPrint_Formatter
local O = {}

ns.M = modules; ns.O = O

function ns:register(name, obj)
    assert(name, 'Module name required')
    assert(obj, ('Module instance is invalid. val=%s'):format(tostring(obj)))
    O[name] = obj
    return obj
end

function ns:log()

end


LibPrettyPrint_Namespace = ns
