import Mathlib.Basic.Real.Basic
import HysteresisControl.Domain.Abstractions.Relay

noncomputable section

namespace HysteresisControl.Domain.Model

open HysteresisControl.Domain.Abstractions

/-- Elementary Non-Ideal Relay R_{α, β} parameterized by lower threshold α and upper threshold β.
    Hypothesis: α < β. -/
structure NonIdealRelay where
  /-- Lower switching threshold. -/
  α : ℝ
  /-- Upper switching threshold. -/
  β : ℝ
  /-- Switching thresholds are strictly ordered. -/
  h_order : α < β

namespace NonIdealRelay

/-- State transition rule for the non-ideal relay R_{α, β}.
    Given current state `s` and new input value `u`:
    - If u ≤ α, switches to neg (-1)
    - If u ≥ β, switches to pos (+1)
    - If α < u < β, retains previous state s. -/
def transition (r : NonIdealRelay) (s : BinaryState) (u : ℝ) : BinaryState :=
  if u ≤ r.α then
    BinaryState.neg
  else if u ≥ r.β then
    BinaryState.pos
  else
    s

/-- Real output of the relay R_{α, β}[u] given current state `s`. -/
def output (r : NonIdealRelay) (s : BinaryState) (u : ℝ) : ℝ :=
  (r.transition s u).toReal

/-! ### Fundamental Theorems of the Non-Ideal Relay -/

/-- If input exceeds or equals upper threshold β, relay state is definitively pos (+1). -/
theorem transition_pos_of_ge (r : NonIdealRelay) (s : BinaryState) {u : ℝ} (h : u ≥ r.β) :
    r.transition s u = BinaryState.pos := by
  have h_not_le : ¬ (u ≤ r.α) := by
    intro h_le
    exact not_le_of_gt r.h_order (le_trans h h_le)
  unfold transition
  simp [h_not_le, h]

/-- If input is below or equals lower threshold α, relay state is definitively neg (-1). -/
theorem transition_neg_of_le (r : NonIdealRelay) (s : BinaryState) {u : ℝ} (h : u ≤ r.α) :
    r.transition s u = BinaryState.neg := by
  unfold transition
  simp [h]

/-- Inside the hysteresis deadband (α < u < β), the relay preserves its internal memory. -/
theorem transition_memory_preserved (r : NonIdealRelay) (s : BinaryState) {u : ℝ}
    (h_low : r.α < u) (h_high : u < r.β) :
    r.transition s u = s := by
  have h1 : ¬ (u ≤ r.α) := not_le_of_gt h_low
  have h2 : ¬ (u ≥ r.β) := not_le_of_gt h_high
  unfold transition
  simp [h1, h2]

/-- Transition rule is idempotent for repeated identical inputs. -/
theorem transition_idempotent (r : NonIdealRelay) (s : BinaryState) (u : ℝ) :
    r.transition (r.transition s u) u = r.transition s u := by
  by_cases h_le : u ≤ r.α
  · have h1 : r.transition s u = BinaryState.neg := transition_neg_of_le r s h_le
    rw [h1]
    exact transition_neg_of_le r BinaryState.neg h_le
  · by_cases h_ge : u ≥ r.β
    · have h2 : r.transition s u = BinaryState.pos := transition_pos_of_ge r s h_ge
      rw [h2]
      exact transition_pos_of_ge r BinaryState.pos h_ge
    · push Not at h_le
      push Not at h_ge
      have h3 : r.transition s u = s := transition_memory_preserved r s h_le h_ge
      rw [h3]
      exact transition_memory_preserved r s h_le h_ge

end NonIdealRelay

end HysteresisControl.Domain.Model
