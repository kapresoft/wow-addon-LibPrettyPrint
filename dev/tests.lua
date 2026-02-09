local x = {
  --- One liners (Formatter)
  function()
    -- /dump LibPrettyPrint:Formatter().config
    -- /dump LibPrettyPrint:Formatter({ prefix = 'Test' }).config
    -- /dump LibPrettyPrint:Formatter({ prefix = 'Test', multiline_tables=true }).config
    -- /run
    (function() local fmt = LibPrettyPrint:Formatter(); print('ctimer::', fmt(C_Timer)) end)()
    -- /run
    (function() local fmt = LibPrettyPrint:Formatter({ multiline_tables = true }); print('ctimer::', fmt(C_Timer)) end)()
  end,
  --- One liners (Printer)
  function()
    -- /dump LibPrettyPrint:Printer({ prefix = 'Test' }).config
    -- /run
    (function() local p = LibPrettyPrint:Printer() p('xx:', 'hello') end)()
    -- /run
    (function() local p = LibPrettyPrint:Printer({ prefix = 'Test', sub_prefix = 'Dev' }) p('xx:', hello) end)()
    -- /run
    (function() local p = LibPrettyPrint:Printer({ prefix = 'Test', sub_prefix = 'Dev' }); p('xx:', hello) local pp = p:WithSubPrefix('Prod'); pp('ppxx', { hello='world' })
    end)()
  end,
  function()
    local lpp = LibPrettyPrint
    print('LibPrettyPrint:', tostring(lpp))
    local p  = lpp:Printer({ prefix = 'Test' })
    local p2 = p:WithSubPrefix('p2')
    p('xx hello')
    p2('xx hello')
  end
}
