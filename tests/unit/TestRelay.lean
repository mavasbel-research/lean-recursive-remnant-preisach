import HysteresisControl.Domain.Abstractions.Relay
import HysteresisControl.Adapters.Simulation.SimulatedRelay

namespace Tests.Unit

open HysteresisControl.Domain.Abstractions
open HysteresisControl.Adapters.Simulation

/-- Unit tests for Non-Ideal Relay switching logic and memory preservation. -/
def runUnitTest : IO UInt32 := do
  IO.println "[UNIT] Running Non-Ideal Relay unit tests..."
  let mut failed := false

  -- Relay with threshold α = -1.0, β = 1.0, initial state = neg
  let r0 : SimulatedRelay := ⟨-1.0, 1.0, BinaryState.neg⟩

  -- Test 1: In deadband (-1.0 < u < 1.0), memory should be preserved as neg
  let r1 := r0.step 0.0
  let y1 := r1.output
  if r1.state != BinaryState.neg || y1 != -1.0 then
    IO.println s!"Test 1 FAILED: Expected state neg, output -1.0; got state {repr r1.state}, output {y1}"
    failed := true

  -- Test 2: Input u >= beta (1.5 >= 1.0), state must switch to pos (+1)
  let r2 := r1.step 1.5
  let y2 := r2.output
  if r2.state != BinaryState.pos || y2 != 1.0 then
    IO.println s!"Test 2 FAILED: Expected state pos, output 1.0; got state {repr r2.state}, output {y2}"
    failed := true

  -- Test 3: Input returns to deadband (0.5), memory must be preserved as pos (+1)
  let r3 := r2.step 0.5
  let y3 := r3.output
  if r3.state != BinaryState.pos || y3 != 1.0 then
    IO.println s!"Test 3 FAILED: Expected state pos preserved, output 1.0; got state {repr r3.state}, output {y3}"
    failed := true

  -- Test 4: Input drops below alpha (-1.5 <= -1.0), state must switch to neg (-1)
  let r4 := r3.step (-1.5)
  let y4 := r4.output
  if r4.state != BinaryState.neg || y4 != -1.0 then
    IO.println s!"Test 4 FAILED: Expected state neg, output -1.0; got state {repr r4.state}, output {y4}"
    failed := true

  if failed then
    IO.println "[UNIT] Relay tests: FAILED"
    return 1
  else
    IO.println "[UNIT] Relay tests: PASSED"
    return 0

end Tests.Unit
