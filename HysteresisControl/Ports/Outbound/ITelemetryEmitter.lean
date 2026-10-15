namespace HysteresisControl.Ports.Outbound

/-- Telemetry payload for a control iteration step. -/
structure IterationEvent where
  iteration : Nat
  inputVal : Float
  currentOutput : Float
  targetOutput : Float
  error : Float

/-- Outbound Port: Telemetry and observability emitter. -/
class ITelemetryEmitter (T : Type) where
  /-- Emit iteration event. -/
  emitIteration : T → IterationEvent → IO Unit
  /-- Emit info message. -/
  emitInfo : T → String → IO Unit

end HysteresisControl.Ports.Outbound
