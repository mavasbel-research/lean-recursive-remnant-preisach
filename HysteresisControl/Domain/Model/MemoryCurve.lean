import Mathlib.Basic.Real.Basic
import Mathlib.Data.List.Basic
import HysteresisControl.Domain.Abstractions.Relay

noncomputable section

namespace HysteresisControl.Domain.Model

/-- A memory peak/valley extremum in the Preisach memory curve. -/
structure Extremum where
  /-- The real input value at the extremum. -/
  val : ℝ
  /-- Peak (local maximum) or Valley (local minimum). -/
  isMax : Bool

instance : Inhabited Extremum := ⟨⟨0, false⟩⟩

/-- Preisach alternating memory curve represented as a list of active dominant extrema. -/
structure MemoryCurve where
  /-- Active alternating extrema history, newest extremum at head. -/
  extrema : List Extremum

instance : Inhabited MemoryCurve := ⟨⟨[]⟩⟩

namespace MemoryCurve

/-- Initial empty memory state (virgin state). -/
def empty : MemoryCurve := ⟨[]⟩

/-- The Wiping-Out operation for an increasing input `u`:
    Iteratively removes all past extrema whose value is strictly exceeded or matched by `u`. -/
def wipeIncreasing (u : ℝ) : List Extremum → List Extremum
  | [] => [⟨u, true⟩]
  | e :: rest =>
    if e.val ≤ u then
      wipeIncreasing u rest
    else
      ⟨u, true⟩ :: e :: rest

/-- The Wiping-Out operation for a decreasing input `u`:
    Iteratively removes all past extrema whose value undercuts or matches `u`. -/
def wipeDecreasing (u : ℝ) : List Extremum → List Extremum
  | [] => [⟨u, false⟩]
  | e :: rest =>
    if u ≤ e.val then
      wipeDecreasing u rest
    else
      ⟨u, false⟩ :: e :: rest

/-- Update memory curve under new input `u`, given monotonic direction `increasing : Bool`. -/
def update (mc : MemoryCurve) (u : ℝ) (increasing : Bool) : MemoryCurve :=
  if increasing then
    ⟨wipeIncreasing u mc.extrema⟩
  else
    ⟨wipeDecreasing u mc.extrema⟩

/-! ### Wiping-Out Property Theorems -/

/-- For an increasing input, any wiped extremum had value strictly less than or equal to u. -/
theorem wipeIncreasing_dominance (u : ℝ) (e : Extremum) (rest : List Extremum) (h : e.val ≤ u) :
    wipeIncreasing u (e :: rest) = wipeIncreasing u rest := by
  rw [wipeIncreasing]
  simp [h]

/-- For a decreasing input, any wiped extremum had value strictly greater than or equal to u. -/
theorem wipeDecreasing_dominance (u : ℝ) (e : Extremum) (rest : List Extremum) (h : u ≤ e.val) :
    wipeDecreasing u (e :: rest) = wipeDecreasing u rest := by
  rw [wipeDecreasing]
  simp [h]

end MemoryCurve

end HysteresisControl.Domain.Model
