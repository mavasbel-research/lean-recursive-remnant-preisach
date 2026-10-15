import Mathlib.Basic.Real.Basic
import Mathlib.Data.List.Basic
import HysteresisControl.Domain.Abstractions.Relay
import HysteresisControl.Domain.Model.NonIdealRelay

noncomputable section

namespace HysteresisControl.Domain.Model

open HysteresisControl.Domain.Abstractions

/-- Discrete weighted non-ideal relay pair in a finite Preisach approximation. -/
structure WeightedRelay where
  /-- The elementary non-ideal relay operator. -/
  relay : NonIdealRelay
  /-- Positive density/weight of this relay. -/
  weight : ℝ

/-- Discrete Preisach Hysteresis Operator formed by a finite collection of weighted relays.
    Approximates the continuous double integral over the Preisach triangle Π. -/
structure DiscretePreisachOperator where
  /-- Collection of weighted elementary relays. -/
  relays : List WeightedRelay

namespace DiscretePreisachOperator

/-- Compute state transition for all relays given an input value `u`. -/
def transition (op : DiscretePreisachOperator) (states : List BinaryState) (u : ℝ) : List BinaryState :=
  (op.relays.zip states).map (fun ⟨w, s⟩ => w.relay.transition s u)

/-- Compute the aggregated real output y = ∑ μ_i * R_i[u]. -/
def output (op : DiscretePreisachOperator) (states : List BinaryState) : ℝ :=
  ((op.relays.zip states).map (fun ⟨w, s⟩ => w.weight * s.toReal)).sum

/-- Initial saturation state where all relays are negative. -/
def negSaturation (op : DiscretePreisachOperator) : List BinaryState :=
  op.relays.map (fun _ => BinaryState.neg)

/-- Initial saturation state where all relays are positive. -/
def posSaturation (op : DiscretePreisachOperator) : List BinaryState :=
  op.relays.map (fun _ => BinaryState.pos)

end DiscretePreisachOperator

end HysteresisControl.Domain.Model
