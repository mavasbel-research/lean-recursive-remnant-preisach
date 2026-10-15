import Mathlib.Basic.Real.Basic
import Mathlib.Data.List.Basic
import HysteresisControl.Domain.Model.NonIdealRelay

noncomputable section

namespace HysteresisControl.Domain.Model

open HysteresisControl.Domain.Abstractions

/-- A weighted relay in a discrete Preisach operator distribution. -/
structure WeightedRelay where
  /-- The underlying non-ideal relay operator. -/
  relay : NonIdealRelay
  /-- Weight associated with this relay in the discrete density distribution. -/
  weight : ℝ
  /-- Physical Preisach density is non-negative. -/
  h_weight_nonneg : 0 ≤ weight

/-- Discrete Preisach operator consisting of a finite ensemble of weighted relays. -/
structure DiscretePreisach where
  /-- Relay ensemble. -/
  relays : List WeightedRelay

namespace DiscretePreisach

/-- Global state of the discrete Preisach operator is the binary state tuple of all relays. -/
def State (_p : DiscretePreisach) := List BinaryState

/-- Transition of the collective relay ensemble under input `u`. -/
def transition (p : DiscretePreisach) (states : p.State) (u : ℝ) : p.State :=
  (p.relays.zip states).map (fun ⟨wr, s⟩ => wr.relay.transition s u)

/-- Compute the scalar real output of the discrete Preisach operator:
    y = ∑ μ_i * R_{α_i, β_i}[u]. -/
def output (p : DiscretePreisach) (states : p.State) : ℝ :=
  ((p.relays.zip states).map (fun ⟨wr, s⟩ => wr.weight * s.toReal)).sum

/-- Total positive saturation output (all relays in +1 state). -/
def positiveSaturation (p : DiscretePreisach) : ℝ :=
  (p.relays.map (fun wr => wr.weight)).sum

/-- Total negative saturation output (all relays in -1 state). -/
def negativeSaturation (p : DiscretePreisach) : ℝ :=
  - (p.relays.map (fun wr => wr.weight)).sum

end DiscretePreisach

end HysteresisControl.Domain.Model
