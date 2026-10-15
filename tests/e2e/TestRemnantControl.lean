import HysteresisControl.Ports.Inbound.IRemnantControlService
import HysteresisControl.Adapters.Inbound.RemnantControlService
import HysteresisControl.Adapters.Outbound.InMemoryPreisachProvider
import HysteresisControl.Adapters.Outbound.ConsoleTelemetry

namespace Tests.E2E

open HysteresisControl.Ports.Inbound
open HysteresisControl.Adapters.Inbound
open HysteresisControl.Adapters.Outbound

/-- End-to-end test verifying the Recursive Remnant Control algorithm convergence. -/
def runE2ETest : IO UInt32 := do
  IO.println "[E2E] Running Recursive Remnant Control End-to-End Test..."

  -- Instantiate outbound adapters (inversion of control & dependency injection)
  let provider : InMemoryPreisachProvider := ⟨⟨0.5, 1.5, 0.8⟩⟩
  let telemetry : ConsoleTelemetry := ⟨⟩

  -- Instantiate inbound service with injected adapters
  let service : RemnantControlService InMemoryPreisachProvider ConsoleTelemetry := ⟨provider, telemetry⟩

  -- Request target remnant state
  let req : RemnantControlRequest := ⟨0.75, 1e-4, 50⟩
  let resp ← service.synthesize req

  IO.println s!"[E2E] Synthesis Result: Converged={resp.converged}, Iterations={resp.iterations}, u*={resp.finalInput}, y*={resp.achievedOutput}"

  let mut passed := true
  if !resp.converged then
    IO.println "[E2E] FAILED: Service did not converge within maximum iterations"
    passed := false

  let err := (resp.achievedOutput - req.target).abs
  if err > req.tolerance then
    IO.println s!"[E2E] FAILED: Final error {err} exceeds tolerance {req.tolerance}"
    passed := false

  if passed then
    IO.println "[E2E] Recursive Remnant Control End-to-End Test: PASSED"
    return 0
  else
    return 1

end Tests.E2E
