import HysteresisControl.Ports.Inbound.IRemnantControlService
import HysteresisControl.Ports.Outbound.IPreisachModelProvider
import HysteresisControl.Ports.Outbound.ITelemetryEmitter

namespace HysteresisControl.Adapters.Inbound

open HysteresisControl.Ports.Inbound
open HysteresisControl.Ports.Outbound

/-- Recursive Remnant Control Service implementing IRemnantControlService with dependency injection. -/
structure RemnantControlService (P : Type) (T : Type) where
  provider : P
  telemetry : T

namespace RemnantControlService

variable {P T : Type} [IPreisachModelProvider P] [ITelemetryEmitter T]

/-- Recursive control loop implementing the gradient descent iteration u_{k+1} = u_k - κ (f(u_k) - y_d). -/
partial def loop (self : RemnantControlService P T) (k : Nat) (maxK : Nat) (u : Float) (target : Float) (tol : Float) (kappa : Float) : IO RemnantControlResponse := do
  if k >= maxK then
    IPreisachModelProvider.evaluateCurve self.provider u >>= fun currentY => do
      ITelemetryEmitter.emitInfo self.telemetry s!"Maximum iterations {maxK} reached without full convergence."
      pure ⟨u, currentY, k, false⟩
  else
    let currentY ← IPreisachModelProvider.evaluateCurve self.provider u
    let err := currentY - target
    let absErr := if err < 0.0 then -err else err
    ITelemetryEmitter.emitIteration self.telemetry ⟨k, u, currentY, target, err⟩
    if absErr <= tol then
      ITelemetryEmitter.emitInfo self.telemetry s!"Convergence achieved at iteration {k} with error {absErr} <= {tol}."
      pure ⟨u, currentY, k, true⟩
    else
      let nextU := u - kappa * err
      loop self (k + 1) maxK nextU target tol kappa

/-- Synthesize control input implementing IRemnantControlService. -/
def synthesize (self : RemnantControlService P T) (req : RemnantControlRequest) : IO RemnantControlResponse := do
  let params ← IPreisachModelProvider.getBoundaryParams self.provider
  let initialU := req.target / params.gammaMin
  ITelemetryEmitter.emitInfo self.telemetry s!"Starting Remnant Control Synthesis: target={req.target}, tol={req.tolerance}, kappa={params.stepGain}"
  loop self 0 req.maxIterations initialU req.target req.tolerance params.stepGain

instance : IRemnantControlService (RemnantControlService P T) where
  synthesize := RemnantControlService.synthesize

end RemnantControlService

end HysteresisControl.Adapters.Inbound
