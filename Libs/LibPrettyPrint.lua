--- @type LibPrettyPrint_Namespace
local ns = select(2, ...).LibPrettyPrint; if not ns then return end

--[[-----------------------------------------------------------------------------
LibPrettyPrint
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'LibPrettyPrint-1.0', 5

--- @class LibPrettyPrint
local o = LibStub:NewLibrary(MAJOR, MINOR); if not o then return end
LibPrettyPrint = o

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param config LibPrettyPrint_PrinterConfig|nil @Optional
--- @return LibPrettyPrint_Printer
function o:Printer(config, predicateFn)
    return ns.O.Printer:New(config, predicateFn)
end

--- @param config LibPrettyPrint_FormatterConfig|nil
--- @return LibPrettyPrint_Formatter
function o:Formatter(config)
    return ns.O.Formatter:New(config)
end
