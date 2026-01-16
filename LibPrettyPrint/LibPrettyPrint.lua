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
LibPrettyPrint = S

--- @type LibPrettyPrint
local o = S

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param printerConfig LibPrettyPrint_PrinterConfig|nil @Optional
--- @param formatterConfig LibPrettyPrint_Formatter|nil @Optional
function o:Printer(printerConfig, formatterConfig)
    return ns.O.Printer:New(printerConfig, formatterConfig)
end

--- @param formatterConfig LibPrettyPrint_FormatterConfig|nil
function o:Formatter(formatterConfig)
    return ns.O.Formatter:New({ depth_limit = 1 })
end


