--- @type LibPrettyPrint_Namespace
local ns             = select(2, ...)
local lpp, dev_suite = LibPrettyPrint, DEV_SUITE

--- @class Developer
local o = {}; lpp_dev = o

function o:clear()
    dev_suite:BINDING_DEVS_CLEAR_DEBUG_CONSOLE()
    return dev_suite and dev_suite:BINDING_DEVS_CLEAR_DEBUG_CONSOLE()
end

local val = {
  hello   = 'world', level = 12, helper = function() end,
  handler = {
    name = 'mouseEventHandler', callback = function() end
  },
  values  = { 1, 2, 3 }
}

--- Formatter test
function o:test1Formatters()
  --- @type LibPrettyPrint_FormatterConfig
  local fc1 = { depth_limit = 1, }
  --- @type LibPrettyPrint_FormatterConfig
  local fc2 = { multiline_tables = true, depth_limit = 2,
                table_ref_color = 'FFFC16',
                table_key_color = 'FD62FF' }
  local f1 = LibPrettyPrint:Formatter():New(fc1)
  local f2 = LibPrettyPrint:Formatter():New(fc2)
  local f3 = f2:Compact()
  return f1, f2, f3, val
end

function o:test2Single()
  --- @type LibPrettyPrint_FormatterConfig
  local fc1 = { multiline_tables = false, depth_limit = 3, }

  --- @type LibPrettyPrint_Formatter
  local f1 = lpp:Formatter(fc1)

  --- @type LibPrettyPrint_PrinterConfig
  local pc1 = { prefix= "MacroPlus", sub_prefix = "Options", show_all = true,
                prefix_color = 'FF95A8', sub_prefix_color = 'FFFA0E',
                xformatter = f1, use_dump_tool = false, }

  local p1  = lpp:Printer(pc1)
  local p2 = p1:WithSubPrefix('ButtonUI')
  return p1, p2, val
end

--- Printer Test
function o:test2Printers()
  --- @type LibPrettyPrint_PrinterConfig
  local pc1 = {
    prefix = 'AddonSuite', sub_prefix = 'Namespace',
    show_timestamp = true,
    prefix_color   = 'B2FF79', sub_prefix_color = 'FFFA0E',
    formatter = {  multiline_tables = true },
  }

  local p1  = lpp:Printer(pc1, nil, function() return ns:IsDev() end)
  local p2  = lpp:Printer()

  return p1, p2, val
end

--- @return LibPrettyPrint_Formatter
function o:test3()
    local lpp = LibPrettyPrint

    --- @type LibPrettyPrint_FormatterConfig
    local fc1 = { multiline_tables = false, depth_limit = 3, }

    --- @type LibPrettyPrint_FormatterConfig
    local fc2 = { multiline_tables = true, depth_limit = 3,
                  table_key_color = '88CCFF' }

    local f1 = lpp:Formatter(fc1)
    local f2 = lpp:Formatter(fc2)
    local f3 = lpp:Formatter()

    --- @type LibPrettyPrint_PrinterConfig
    local pc1 = { prefix= "MacroPlus", sub_prefix = "Options", show_all = true,
                  prefix_color = 'FF95A8', sub_prefix_color = 'FFFA0E',
                  formatter = f1,
                  use_dump_tool = false, }

    --- @type LibPrettyPrint_PrinterConfig
    local pc2 = { prefix="Gears", sub_prefix="Namespace", formatter = fc2,
                  show_timestamp = true }

    local p1 = lpp:Printer(pc1, function() return ns:IsDev() end)
    local p2 = lpp:Printer(pc2)
    local p3 = lpp:Printer({ show_timestamp = false })
    return f1, f2, f3, p1, p2, p3, val
end


