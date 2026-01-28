local x = {
  function()
    local lpp = LibPrettyPrint
    print('LibPrettyPrint:', tostring(lpp))
    local p  = lpp:Printer({ prefix = 'Test' })
    local p2 = p:WithSubPrefix('p2')
    p('xx hello')
    p2('xx hello')
  end
}
