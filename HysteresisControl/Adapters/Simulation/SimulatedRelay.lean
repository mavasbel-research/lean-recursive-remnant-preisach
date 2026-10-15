import HysteresisControl.Domain.Abstractions.Relay

namespace HysteresisControl.Adapters.Simulation

open HysteresisControl.Domain.Abstractions

/-- Computable floating-point simulation of a non-ideal relay. -/
structure SimulatedRelay where
  alpha : Float
  beta : Float
  state : BinaryState := BinaryState.neg

namespace SimulatedRelay

/-- Transition rule for simulated float relay. -/
def step (r : SimulatedRelay) (u : Float) : SimulatedRelay :=
  if u <= r.alpha then
    { r with state := BinaryState.neg }
  else if u >= r.beta then
    { r with state := BinaryState.pos }
  else
    r

/-- Output value of simulated relay. -/
def output (r : SimulatedRelay) : Float :=
  match r.state with
  | BinaryState.neg => -1.0
  | BinaryState.pos => 1.0

end SimulatedRelay

/-- Finite Preisach simulation ensemble. -/
structure SimulatedPreisach where
  relays : List (SimulatedRelay × Float) -- relay and weight

namespace SimulatedPreisach

/-- Step all relays and compute aggregate output. -/
def step (sp : SimulatedPreisach) (u : Float) : SimulatedPreisach × Float :=
  let updated := sp.relays.map (fun (r, w) => (r.step u, w))
  let y := updated.foldl (fun acc (r, w) => acc + r.output * w) 0.0
  (⟨updated⟩, y)

end SimulatedPreisach

/-- Computable extremum in the simulated Preisach memory curve. -/
structure SimulatedExtremum where
  val : Float
  isMax : Bool
deriving Inhabited

/-- Computable simulated memory curve with wiping-out dynamics. -/
structure SimulatedMemoryCurve where
  extrema : List SimulatedExtremum := []

namespace SimulatedMemoryCurve

def empty : SimulatedMemoryCurve := ⟨[]⟩

def wipeIncreasing (u : Float) : List SimulatedExtremum → List SimulatedExtremum
  | [] => [⟨u, true⟩]
  | e :: rest =>
    if e.isMax && e.val <= u then
      -- Wipe out previous peak smaller than u
      wipeIncreasing u rest
    else if !e.isMax && rest != [] then
      -- If head is a valley, check if the peak behind it is <= u
      match rest with
      | prevMax :: rest' =>
        if prevMax.val <= u then
          -- Both the previous valley and peak are wiped
          wipeIncreasing u rest'
        else
          ⟨u, true⟩ :: e :: rest
      | [] => ⟨u, true⟩ :: e :: rest
    else
      ⟨u, true⟩ :: e :: rest

def wipeDecreasing (u : Float) : List SimulatedExtremum → List SimulatedExtremum
  | [] => [⟨u, false⟩]
  | e :: rest =>
    if !e.isMax && e.val >= u then
      -- Wipe out previous valley larger than u
      wipeDecreasing u rest
    else if e.isMax && rest != [] then
      -- If head is a peak, check if the valley behind it is >= u
      match rest with
      | prevMin :: rest' =>
        if prevMin.val >= u then
          -- Both the previous peak and valley are wiped
          wipeDecreasing u rest'
        else
          ⟨u, false⟩ :: e :: rest
      | [] => ⟨u, false⟩ :: e :: rest
    else
      ⟨u, false⟩ :: e :: rest

def update (mc : SimulatedMemoryCurve) (u : Float) (increasing : Bool) : SimulatedMemoryCurve :=
  if increasing then
    ⟨wipeIncreasing u mc.extrema⟩
  else
    ⟨wipeDecreasing u mc.extrema⟩

end SimulatedMemoryCurve

end HysteresisControl.Adapters.Simulation
