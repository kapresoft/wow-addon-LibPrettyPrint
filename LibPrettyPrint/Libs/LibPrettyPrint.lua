--- @type LibPrettyPrint_Namespace
local ns           = select(2, ...)
--- @type LibStub
local LibStub      = LibStub
--[[-----------------------------------------------------------------------------
LibPrettyPrint
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'LibPrettyPrint-1.0', 1

--- @class LibPrettyPrint
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
LibPrettyPrint = S; ns.LibPrettyPrint = S

--- @type LibPrettyPrint
local o = S

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
