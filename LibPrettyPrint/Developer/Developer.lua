local addon, ns = ...
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

--- @class Developer
local o = {}; lpp_dev = o

C_Timer.After(1, function()
    print(('xxx %s::Developer loaded...'):format(addon))
end)

function o:test()
    local lpp = LibPrettyPrint
    local pcf = { use_newline = true }
    local pc1 = { prefix ="P", sub_prefix ="S", show_all = true,
                  use_dump_tool = false, formatterConfig =pcf }
    local pc2 = { prefix="P2", sub_prefix="S2"  }
    local fc = { use_newline = true }

    f = lpp:Formatter(fc)
    ff        = lpp:Formatter()
    p         = lpp:Printer(pc1)
    pp        = lpp:Printer(pc2)
end
