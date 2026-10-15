import HysteresisControl.Adapters.Simulation.SimulatedRelay

namespace Tests.Live

open HysteresisControl.Adapters.Simulation

def runLiveTest : IO UInt32 := do
  IO.println "=== [LIVE TEST] Memory Curve & Wiping-Out Property ==="
  let mc0 := SimulatedMemoryCurve.empty

  -- Step 1: Input rises to 3.0
  let mc1 := mc0.update 3.0 true
  if mc1.extrema.length != 1 then
    IO.eprintln "FAILED: expected 1 extremum after first rise"
    return 1
  IO.println "✓ Single peak registered"

  -- Step 2: Input drops to -1.0
  let mc2 := mc1.update (-1.0) false
  if mc2.extrema.length != 2 then
    IO.eprintln "FAILED: expected 2 extrema after drop"
    return 1
  IO.println "✓ Alternating valley registered"

  -- Step 3: Input rises to 4.0 (should wipe previous peak 3.0 and valley -1.0)
  let mc3 := mc2.update 4.0 true
  if mc3.extrema.length != 1 then
    IO.eprintln s!"FAILED: expected wiping-out to reduce length to 1, got {mc3.extrema.length}"
    return 1
  let topVal := mc3.extrema.head!.val
  if (topVal - 4.0).abs > 1e-6 then
    IO.eprintln s!"FAILED: expected top extremum 4.0, got {topVal}"
    return 1
  IO.println "✓ Wiping-out property verified: smaller loops erased"

  IO.println "Live tests passed: 3/3."
  return 0

end Tests.Live
