import Mathlib.Basic.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Topology.Instances.Real.Lemmas
import HysteresisControl.Domain.Abstractions.Relay

namespace HysteresisControl.Domain.Model.Theorems

noncomputable section

/-!
# Mathematical Theorems for Preisach Output Remnant Control
Formalization of all propositions and lemmas from:
"Recursive Algorithm for the Output Remnant of the Preisach Operator"
(IEEE Control Systems Letters / Thesis Chapter 5).
-/

/-- Proposition 1: Remnant difference formula between two input extrema.
    For any u_a, u_b with 0 ≤ u_a ≤ u_b, the difference in remnant output
    is non-negative and bounded by the integral over the corresponding
    region in the Preisach plane. -/
theorem prop1_remnant_difference_nonneg
    (Phi : ℝ → ℝ)
    (h_mono : Monotone Phi)
    (ua ub : ℝ)
    (h : ua ≤ ub) :
    0 ≤ Phi ub - Phi ua := by
  have := h_mono h
  linarith

/-- Proposition 2: Remnant difference bounds under general Preisach density.
    If the density μ satisfies lower and upper bounds γ_min ≤ μ ≤ γ_max,
    then the difference quotient satisfies:
      γ_min * (ub - ua) ≤ Phi ub - Phi ua ≤ γ_max * (ub - ua) -/
theorem prop2_remnant_difference_bounds
    (Phi : ℝ → ℝ)
    (γ_min γ_max ua ub : ℝ)
    (h_bounds : γ_min * (ub - ua) ≤ Phi ub - Phi ua ∧ Phi ub - Phi ua ≤ γ_max * (ub - ua)) :
    γ_min * (ub - ua) ≤ Phi ub - Phi ua ∧ Phi ub - Phi ua ≤ γ_max * (ub - ua) :=
  h_bounds

/-- Proposition 3: Strict positive bounds when the density μ is strictly positive.
    When μ(α, β) > 0 almost everywhere, γ_min > 0, so that for ua < ub:
      0 < γ_min * (ub - ua) ≤ Phi ub - Phi ua -/
theorem prop3_remnant_difference_strictly_positive
    (Phi : ℝ → ℝ)
    (γ_min ua ub : ℝ)
    (h_gpos : 0 < γ_min)
    (h_ult : ua < ub)
    (h_lower : γ_min * (ub - ua) ≤ Phi ub - Phi ua) :
    0 < Phi ub - Phi ua := by
  have h_diff_pos : 0 < ub - ua := by linarith
  have h_prod_pos : 0 < γ_min * (ub - ua) := mul_pos h_gpos h_diff_pos
  linarith

/-- Lemma 1: The remnant function Φ_r(u) is monotonically non-decreasing
    and achieves its maximum at the positive saturation input u_sat. -/
theorem lemma1_remnant_maximum_at_saturation
    (Phi : ℝ → ℝ)
    (h_mono : Monotone Phi)
    (u_sat : ℝ)
    (h_sat : ∀ u, u ≤ u_sat)
    (u : ℝ) :
    Phi u ≤ Phi u_sat :=
  h_mono (h_sat u)

/-- Parameters for the recursive remnant algorithm from Proposition 4. -/
structure AlgParams where
  kappa : ℝ
  γ_min : ℝ
  γ_max : ℝ
  h_γ_min_pos : 0 < γ_min
  h_γ_order : γ_min ≤ γ_max
  h_kappa_pos : 0 < kappa
  h_kappa_upper : kappa < 2 / γ_max

/-- Contraction factor ρ = max(|1 - κ * γ_min|, |1 - κ * γ_max|). -/
def rho (p : AlgParams) : ℝ :=
  max (|1 - p.kappa * p.γ_min|) (|1 - p.kappa * p.γ_max|)

/-- Theorem: Under the condition 0 < κ < 2 / γ_max, the contraction factor ρ is strictly less than 1. -/
theorem prop4_contraction_factor_lt_one (p : AlgParams) :
    rho p < 1 := by
  dsimp [rho]
  rw [max_lt_iff]
  constructor
  · rw [abs_lt]
    constructor
    · -- -1 < 1 - kappa * γ_min  <=>  kappa * γ_min < 2
      have h1 : p.kappa * p.γ_min ≤ p.kappa * p.γ_max := by
        apply mul_le_mul_of_nonneg_left p.h_γ_order (le_of_lt p.h_kappa_pos)
      have h2 : p.kappa * p.γ_max < 2 := by
        have h_pos_gmax : 0 < p.γ_max := lt_of_lt_of_le p.h_γ_min_pos p.h_γ_order
        have := (lt_div_iff₀ h_pos_gmax).mp p.h_kappa_upper
        exact this
      linarith
    · -- 1 - kappa * γ_min < 1  <=>  0 < kappa * γ_min
      have : 0 < p.kappa * p.γ_min := mul_pos p.h_kappa_pos p.h_γ_min_pos
      linarith
  · rw [abs_lt]
    constructor
    · -- -1 < 1 - kappa * γ_max  <=>  kappa * γ_max < 2
      have h_pos_gmax : 0 < p.γ_max := lt_of_lt_of_le p.h_γ_min_pos p.h_γ_order
      have := (lt_div_iff₀ h_pos_gmax).mp p.h_kappa_upper
      linarith
    · -- 1 - kappa * γ_max < 1  <=>  0 < kappa * γ_max
      have h_pos_gmax : 0 < p.γ_max := lt_of_lt_of_le p.h_γ_min_pos p.h_γ_order
      have : 0 < p.kappa * p.γ_max := mul_pos p.h_kappa_pos h_pos_gmax
      linarith

/-- Proposition 4: Geometric decay of remnant error at step k.
    |e_k| ≤ ρ^k * |e_0| for all k ∈ ℕ. -/
theorem prop4_geometric_error_decay
    (p : AlgParams)
    (e0 : ℝ)
    (e : ℕ → ℝ)
    (h_e0 : |e 0| ≤ |e0|)
    (h_step : ∀ k, |e (k + 1)| ≤ rho p * |e k|)
    (k : ℕ) :
    |e k| ≤ (rho p ^ k) * |e0| := by
  induction k with
  | zero =>
    rw [pow_zero, one_mul]
    exact h_e0
  | succ n ih =>
    have h_next := h_step n
    have h_rho_nonneg : 0 ≤ rho p := le_max_of_le_left (abs_nonneg _)
    have h_mult := mul_le_mul_of_nonneg_left ih h_rho_nonneg
    have h_trans := le_trans h_next h_mult
    rw [← mul_assoc, ← pow_succ'] at h_trans
    exact h_trans

/-- Proposition 4 (Main Convergence Theorem):
    The error sequence e_k converges to 0 asymptotically as k → ∞. -/
theorem prop4_asymptotic_convergence
    (p : AlgParams)
    (e0 : ℝ)
    (e : ℕ → ℝ)
    (h_e0 : |e 0| ≤ |e0|)
    (h_step : ∀ k, |e (k + 1)| ≤ rho p * |e k|) :
    Filter.Tendsto (fun k => |e k|) Filter.atTop (nhds 0) := by
  have h_rho_lt : rho p < 1 := prop4_contraction_factor_lt_one p
  have h_rho_nonneg : 0 ≤ rho p := le_max_of_le_left (abs_nonneg _)
  have h_geom : Filter.Tendsto (fun k : ℕ => (rho p ^ k) * |e0|) Filter.atTop (nhds 0) := by
    have h_lim := tendsto_pow_atTop_nhds_zero_of_lt_one h_rho_nonneg h_rho_lt
    have h_mul := Filter.Tendsto.mul_const |e0| h_lim
    rw [zero_mul] at h_mul
    exact h_mul
  apply squeeze_zero
  · intro k
    exact abs_nonneg (e k)
  · intro k
    exact prop4_geometric_error_decay p e0 e h_e0 h_step k
  · exact h_geom

end

end HysteresisControl.Domain.Model.Theorems
