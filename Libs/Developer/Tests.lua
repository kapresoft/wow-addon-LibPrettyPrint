--[[-----------------------------------------------------------------------------
Dev-only tests, run from LuaDevKit; never packaged
-------------------------------------------------------------------------------]]
local lpp = LibPrettyPrint

--- @class LibPrettyPrint_Tests
local o = {}; lpp_tests = o

--- @return LibPrettyPrint_Printer
local function newPrinter()
  return lpp:Printer({
    prefix = 'LibPrettyPrint', sub_prefix = 'Tests', formatter = { depth_limit = 3 },
  })
end

--- Arithmetic on a secret errors in addon code, which is always tainted
--- ### Example:
--- ```lua
--- lpp_tests:SecretArithmetic_Example()
--- ```
--- @param n? number @Value to wrap; defaults to 42
function o:SecretArithmetic_Example(n)
  if not (secretwrap and issecretvalue) then
    return print('SecretArithmetic_Example: no secret values on this client')
  end
  local secret = secretwrap(n or 42)
  print('SecretArithmetic_Example: issecretvalue =', issecretvalue(secret))
  local ok, err = pcall(function() return secret + 1 end)
  print('  secret + 1 ->', ok and 'no error' or err)
end

--- Raises the Lua error itself, for BugSack or the error frame
--- ### Example:
--- ```lua
--- lpp_tests:SecretArithmeticError()
--- ```
--- @param n? number @Value to wrap; defaults to 42
--- @return number
function o:SecretArithmeticError(n)
  local secret = secretwrap(n or 42)
  return secret + 1
end

--- Prints a table holding a secret, then a wrapped table
--- ### Example:
--- ```lua
--- lpp_tests:SecretTable_ShouldPass()
--- ```
function o:SecretTable_ShouldPass()
  local p = newPrinter()
  local unit = { name = 'target', health = secretwrap(100), power = { mana = secretwrap(50) } }
  p('Secret fields:', unit)
  p('Wrapped table:', secretwrap({ a = 1 }))
end

--- KeyValues path: ValueFormatter and pushKeyValues, not pprint
--- ### Example:
--- ```lua
--- lpp_tests:SecretKeyValues_ShouldPass()
--- ```
function o:SecretKeyValues_ShouldPass()
  local kv = lpp:Formatter():KeyValues()
  print('Secret field:', kv({ name = 'target', hp = secretwrap(100) }))
  print('Wrapped table:', kv(secretwrap({ a = 1 })))
end

--- A non-table arg skips the formatter and goes straight to print
--- ### Example:
--- ```lua
--- lpp_tests:SecretPrintArg_ShouldPass()
--- ```
function o:SecretPrintArg_ShouldPass()
  newPrinter()('hp:', secretwrap(100))
end

--- The copy must keep the cycle, not overflow the stack
--- ### Example:
--- ```lua
--- lpp_tests:SecretCycle_ShouldPass()
--- ```
function o:SecretCycle_ShouldPass()
  local t = { hp = secretwrap(1) }
  t.self = t
  newPrinter()('Cycle:', t)
end

--- Formatter called directly; pformat's top-level check
--- ### Example:
--- ```lua
--- lpp_tests:SecretFormatterCall_ShouldPass()
--- ```
function o:SecretFormatterCall_ShouldPass()
  print('Formatter:', lpp:Formatter()(secretwrap(1)))
end

--- Only _ShouldPass tests; the rest raise or are demos
local ALL = {
  'SecretTable_ShouldPass', 'SecretKeyValues_ShouldPass',
  'SecretCycle_ShouldPass', 'SecretFormatterCall_ShouldPass', 'SecretPrintArg_ShouldPass',
}

--- Runs every test; a failing one reports and the rest still run
--- ### Example:
--- ```lua
--- lpp_tests:TestAll()
--- ```
function o:TestAll()
  for _, name in ipairs(ALL) do
    print(('--- %s'):format(name))
    local ok, err = pcall(self[name], self)
    if not ok then print(('    FAILED: %s'):format(err)) end
  end
end
