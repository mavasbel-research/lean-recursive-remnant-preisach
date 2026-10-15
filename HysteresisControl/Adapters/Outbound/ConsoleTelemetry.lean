import HysteresisControl.Ports.Outbound.ITelemetryEmitter

namespace HysteresisControl.Adapters.Outbound

open HysteresisControl.Ports.Outbound

/-- Console adapter for ITelemetryEmitter. -/
structure ConsoleTelemetry where

namespace ConsoleTelemetry

def emitIteration (_self : ConsoleTelemetry) (evt : IterationEvent) : IO Unit := do
  IO.println s!"[TELEMETRY] Iteration {evt.iteration}: u = {evt.inputVal}, y = {evt.currentOutput}, target = {evt.targetOutput}, error = {evt.error}"

def emitInfo (_self : ConsoleTelemetry) (msg : String) : IO Unit := do
  IO.println s!"[TELEMETRY] [INFO] {msg}"

instance : ITelemetryEmitter ConsoleTelemetry where
  emitIteration self evt := self.emitIteration evt
  emitInfo self msg := self.emitInfo msg

end ConsoleTelemetry

end HysteresisControl.Adapters.Outbound
