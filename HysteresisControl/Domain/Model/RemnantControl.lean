import Mathlib.Basic.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Topology.Instances.Real.Lemmas

noncomputable section

namespace HysteresisControl.Domain.Model

/-- Slope bounds on the memory curve branch [Γ_min, Γ_max] with 0 < Γ_min ≤ Γ_max. -/
structure MemorySlopeBounds where
  /-- Strictly positive minimum slope along the Preisach memory branch. -/
  Γ_min : ℝ
  /-- Finite maximum slope along the Preisach memory branch. -/
  Γ_max : ℝ
  /-- Positivity requirement: 0 < Γ_min. -/
  h_pos : 0 < Γ_min
  /-- Ordering: Γ_min ≤ Γ_max. -/
  h_le : Γ_min ≤ Γ_max

/-- Parameter configuration for the recursive remnant control algorithm (Algorithm 1). -/
structure RemnantControlParams where
  /-- Step gain parameter κ > 0. -/
  κ : ℝ
  /-- Slope bounds of the underlying Preisach operator. -/
  bounds : MemorySlopeBounds
  /-- Strict positivity of gain: κ > 0. -/
  h_κ_pos : 0 < κ
  /-- Contraction upper bound: κ < 2 / Γ_max. -/
  h_κ_upper : κ < 2 / bounds.Γ_max

namespace RemnantControlParams

/-- The exact contraction factor ρ(κ) = max(|1 - κ * Γ_min|, |1 - κ * Γ_max|). -/
def contractionFactor (p : RemnantControlParams) : ℝ :=
  max (|1 - p.κ * p.bounds.Γ_min|) (|1 - p.κ * p.bounds.Γ_max|)

/-- Theorem: The contraction factor is strictly less than 1 whenever 0 < κ < 2 / Γ_max.
    (Theorem on Convergence Rate of Recursive Remnant Control, Thesis Chapter 5 / L-CSS 2021). -/
theorem contractionFactor_lt_one (p : RemnantControlParams) :
    p.contractionFactor < 1 := by
  dsimp [contractionFactor]
  rw [max_lt_iff]
  constructor
  · rw [abs_lt]
    constructor
    · -- -1 < 1 - κ * Γ_min ↔ κ * Γ_min < 2
      have h1 : p.κ * p.bounds.Γ_min ≤ p.κ * p.bounds.Γ_max := by
        exact mul_le_mul_of_nonneg_left p.bounds.h_le (le_of_lt p.h_κ_pos)
      have h_pos_g : 0 < p.bounds.Γ_max := lt_of_lt_of_le p.bounds.h_pos p.bounds.h_le
      have h2 : p.κ * p.bounds.Γ_max < 2 := (lt_div_iff₀ h_pos_g).mp p.h_κ_upper
      linarith
    · -- 1 - κ * Γ_min < 1 ↔ 0 < κ * Γ_min
      have h_pos_prod : 0 < p.κ * p.bounds.Γ_min := mul_pos p.h_κ_pos p.bounds.h_pos
      linarith
  · rw [abs_lt]
    constructor
    · -- -1 < 1 - κ * Γ_max ↔ κ * Γ_max < 2
      have h_pos_g : 0 < p.bounds.Γ_max := lt_of_lt_of_le p.bounds.h_pos p.bounds.h_le
      have h2 : p.κ * p.bounds.Γ_max < 2 := (lt_div_iff₀ h_pos_g).mp p.h_κ_upper
      linarith
    · -- 1 - κ * Γ_max < 1 ↔ 0 < κ * Γ_max
      have h_pos_g : 0 < p.bounds.Γ_max := lt_of_lt_of_le p.bounds.h_pos p.bounds.h_le
      have h_pos_prod : 0 < p.κ * p.bounds.Γ_max := mul_pos p.h_κ_pos h_pos_g
      linarith

/-- One-step error contraction under intermediate slope γ ∈ [Γ_min, Γ_max]. -/
theorem step_contraction (p : RemnantControlParams) {γ : ℝ}
    (h_γ_low : p.bounds.Γ_min ≤ γ) (h_γ_high : γ ≤ p.bounds.Γ_max) (ε : ℝ) :
    |(1 - p.κ * γ) * ε| ≤ p.contractionFactor * |ε| := by
  rw [abs_mul]
  have h_gain_le : |1 - p.κ * γ| ≤ p.contractionFactor := by
    dsimp [contractionFactor]
    have h1 : 1 - p.κ * p.bounds.Γ_max ≤ 1 - p.κ * γ := by
      have : p.κ * γ ≤ p.κ * p.bounds.Γ_max :=
        mul_le_mul_of_nonneg_left h_γ_high (le_of_lt p.h_κ_pos)
      linarith
    have h2 : 1 - p.κ * γ ≤ 1 - p.κ * p.bounds.Γ_min := by
      have : p.κ * p.bounds.Γ_min ≤ p.κ * γ :=
        mul_le_mul_of_nonneg_left h_γ_low (le_of_lt p.h_κ_pos)
      linarith
    rw [abs_le]
    constructor
    · have h_max_r : |1 - p.κ * p.bounds.Γ_max| ≤ p.contractionFactor := le_max_right _ _
      have h_abs_r := abs_le.mp h_max_r
      exact le_trans h_abs_r.1 h1
    · have h_max_l : |1 - p.κ * p.bounds.Γ_min| ≤ p.contractionFactor := le_max_left _ _
      have h_abs_l := abs_le.mp h_max_l
      exact le_trans h2 h_abs_l.2
  exact mul_le_mul_of_nonneg_right h_gain_le (abs_nonneg ε)

end RemnantControlParams

/-- Computable/Executable implementation of Algorithm 1 (Recursive Remnant Control)
    for numeric execution in simulation and tests over Float. -/
def remnantControl (y_desired : Float) (remnantMap : Float → List Float → Float)
    (u_init : Float) (history : List Float) (max_iter : Nat) : List Float :=
  let rec loop (i : Nat) (u_curr : Float) (hist : List Float) (acc : List Float) : List Float :=
    match i with
    | 0 => acc.reverse
    | i' + 1 =>
      let y_curr := remnantMap u_curr hist
      let err := y_desired - y_curr
      let gain := 0.5
      let u_next := u_curr + gain * err
      loop i' u_next (u_next :: hist) (u_next :: acc)
  loop max_iter u_init history []

end HysteresisControl.Domain.Model
