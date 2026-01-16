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
function o:Printer(printerConfig)
    local f = self:Formatter(printerConfig.formatterConfig)
    return ns.O.Printer:New(printerConfig, f)
end

--- @param formatterConfig LibPrettyPrint_FormatterConfig|nil
function o:Formatter(formatterConfig)
    print('xx formatterConfig:', ns.O.pprint.pformat(formatterConfig))
    return ns.O.Formatter:New(formatterConfig)
end
