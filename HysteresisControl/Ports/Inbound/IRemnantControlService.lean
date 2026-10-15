namespace HysteresisControl.Ports.Inbound

/-- Input parameters for remnant control query. -/
structure RemnantControlRequest where
  /-- Desired remnant output target y_d. -/
  target : Float
  /-- Tolerance error bound ε > 0. -/
  tolerance : Float
  /-- Maximum allowed iterations. -/
  maxIterations : Nat := 50

/-- Result of the remnant control synthesis. -/
structure RemnantControlResponse where
  /-- Converged final input control value u*. -/
  finalInput : Float
  /-- Achieved remnant output y*. -/
  achievedOutput : Float
  /-- Number of iterations performed. -/
  iterations : Nat
  /-- Whether convergence was achieved within tolerance. -/
  converged : Bool

/-- Inbound Port: Interface for remnant control synthesis services. -/
class IRemnantControlService (S : Type) where
  /-- Synthesize control input to reach desired target remnant. -/
  synthesize : S → RemnantControlRequest → IO RemnantControlResponse

end HysteresisControl.Ports.Inbound
