import tests.unit.TestRelay
import tests.unit.TestTheorems
import tests.component.TestPreisach
import tests.live.TestMemory
import tests.e2e.TestRemnantControl

def main : IO UInt32 := do
  IO.println "=========================================================="
  IO.println "   Running HysteresisControl Lean 4 Test Verification"
  IO.println "=========================================================="
  
  let res0 ← Tests.Unit.runTheoremsTest
  if res0 != 0 then
    IO.println "Formal Theorems Unit tests FAILED"
    return res0

  let res1 ← Tests.Unit.runUnitTest
  if res1 != 0 then
    IO.println "Unit tests FAILED"
    return res1

  let res2 ← Tests.Component.runComponentTest
  if res2 != 0 then
    IO.println "Component tests FAILED"
    return res2

  let res3 ← Tests.Live.runLiveTest
  if res3 != 0 then
    IO.println "Live memory curve tests FAILED"
    return res3

  let res4 ← Tests.E2E.runE2ETest
  if res4 != 0 then
    IO.println "E2E Remnant Control tests FAILED"
    return res4

  IO.println "=========================================================="
  IO.println "   ALL TESTS PASSED"
  IO.println "=========================================================="
  return 0
