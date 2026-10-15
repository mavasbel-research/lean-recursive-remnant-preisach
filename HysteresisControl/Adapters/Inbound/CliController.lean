import HysteresisControl.Ports.Inbound.IRemnantControlService
import HysteresisControl.Adapters.Inbound.RemnantControlService
import HysteresisControl.Adapters.Outbound.InMemoryPreisachProvider
import HysteresisControl.Adapters.Outbound.ConsoleTelemetry

namespace HysteresisControl.Adapters.Inbound

open HysteresisControl.Ports.Inbound
open HysteresisControl.Adapters.Outbound

/-- Simple float parser from string. -/
def parseFloatD (s : String) (dflt : Float) : Float :=
  match s.splitOn "." with
  | [intPart] =>
    match intPart.toNat? with
    | some n => Float.ofNat n
    | none => dflt
  | [intPart, fracPart] =>
    match intPart.toNat?, fracPart.toNat? with
    | some i, some f =>
      let len := fracPart.length
      let rec pow10 (k : Nat) : Float :=
        match k with
        | 0 => 1.0
        | k + 1 => 10.0 * pow10 k
      Float.ofNat i + (Float.ofNat f) / pow10 len
    | _, _ => dflt
  | _ => dflt

/-- Main CLI controller wiring the hexagonal ports and adapters. -/
def runCli (args : List String) : IO UInt32 := do
  let target := match args.head? with
    | some s => parseFloatD s 0.5
    | none => 0.5
  let tol := 1e-4

  let provider : InMemoryPreisachProvider := { params := ⟨0.5, 1.5, 1.0⟩ }
  let telemetry : ConsoleTelemetry := ⟨⟩
  let service : RemnantControlService InMemoryPreisachProvider ConsoleTelemetry := ⟨provider, telemetry⟩

  let req : RemnantControlRequest := ⟨target, tol, 50⟩
  let res ← service.synthesize req

  IO.println "========================================"
  IO.println s!"Synthesis Final Status: converged={res.converged}"
  IO.println s!"Iterations: {res.iterations}"
  IO.println s!"Final Control Input u*: {res.finalInput}"
  IO.println s!"Achieved Remnant Output y*: {res.achievedOutput}"
  IO.println "========================================"

  if res.converged then pure 0 else pure 1

end HysteresisControl.Adapters.Inbound
