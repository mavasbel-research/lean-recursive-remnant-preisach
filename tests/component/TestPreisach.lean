import HysteresisControl.Domain.Abstractions.Relay
import HysteresisControl.Adapters.Simulation.SimulatedRelay

namespace Tests.Component

open HysteresisControl.Domain.Abstractions
open HysteresisControl.Adapters.Simulation

/-- Component tests for finite Preisach operator ensembles. -/
def runComponentTest : IO UInt32 := do
  IO.println "=== [COMPONENT TEST] Preisach Ensemble Model ==="
  let mut allPassed := true

  -- Assemble a 3-relay Preisach model with weights
  let r1 : SimulatedRelay := ⟨-2.0, 2.0, BinaryState.neg⟩
  let r2 : SimulatedRelay := ⟨-1.0, 1.0, BinaryState.neg⟩
  let r3 : SimulatedRelay := ⟨-0.5, 0.5, BinaryState.neg⟩
  let sp : SimulatedPreisach := ⟨[(r1, 0.2), (r2, 0.3), (r3, 0.5)]⟩

  -- Test negative saturation output: ∑ w_i * (-1) = -(0.2+0.3+0.5) = -1.0
  let (sp0, y0) := sp.step (-3.0)
  if (y0 + 1.0).abs > 1e-6 then
    IO.eprintln s!"FAILED: Negative saturation output expected -1.0, got {y0}"
    allPassed := false

  -- Test partial ascending switching: input = 0.8 switches r3 (+0.5) and retains others
  let (sp1, y1) := sp0.step 0.8
  if y1.abs > 1e-6 then
    IO.eprintln s!"FAILED: Partial hysteresis switching expected 0.0, got {y1}"
    allPassed := false

  -- Test positive saturation: input = 3.0 switches all to +1
  let (_, y2) := sp1.step 3.0
  if (y2 - 1.0).abs > 1e-6 then
    IO.eprintln s!"FAILED: Positive saturation expected 1.0, got {y2}"
    allPassed := false

  if allPassed then
    IO.println "✓ Preisach ensemble component tests: 3/3 PASSED"
    return 0
  else
    return 1

end Tests.Component
