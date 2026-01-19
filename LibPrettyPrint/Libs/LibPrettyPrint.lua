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
--- @param printerConfig LibPrettyPrint_PrinterConfig|nil @Optional
--- @return LibPrettyPrint_Printer
--- @param formatter LibPrettyPrint_Formatter
function o:Printer(printerConfig, formatter, predicateFn)
    local f = self:Formatter()
    if formatter then
        f = formatter
    elseif printerConfig and printerConfig.formatter then
        f = self:Formatter(printerConfig.formatter)
    end
    return ns.O.Printer:New(printerConfig, f, predicateFn)
end

--- @param formatterConfig LibPrettyPrint_FormatterConfig|nil
--- @return LibPrettyPrint_Formatter
function o:Formatter(formatterConfig)
    return ns.O.Formatter:New(formatterConfig)
end
