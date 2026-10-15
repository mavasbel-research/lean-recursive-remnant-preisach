import Mathlib.Basic.Real.Basic
import Mathlib.Order.Monotone.Basic
import HysteresisControl.Domain.Abstractions.Relay

namespace HysteresisControl.Domain.Abstractions

/-- General rate-independent hysteresis operator abstraction.
    Takes a time-indexed input signal and maps to an output signal,
    preserving rate independence (invariance under strictly monotonic time-scaling). -/
structure RateIndependentOperator where
  /-- Input signal domain: continuous or piecewise monotone paths. -/
  InputSignal : Type
  /-- Internal memory state representing active hysteresis history. -/
  MemoryState : Type
  /-- Output value type (typically ℝ). -/
  OutputValue : Type
  /-- State update given previous state and input trajectory segment. -/
  update : MemoryState → InputSignal → MemoryState
  /-- Readout function computing current output value. -/
  evaluate : MemoryState → OutputValue

/-- Abstract property of Monotonic Output Response.
    If input increases while state is fixed, output non-decreases. -/
def IsMonotoneResponse {State : Type} (f : State → ℝ → ℝ) : Prop :=
  ∀ (s : State) ⦃u₁ u₂ : ℝ⦄, u₁ ≤ u₂ → f s u₁ ≤ f s u₂

/-- Abstract Hysteresis Loop geometry in the (u, y) plane. -/
structure HysteresisLoop where
  /-- Ascending branch function: output as input increases from u_min to u_max. -/
  ascending : ℝ → ℝ
  /-- Descending branch function: output as input decreases from u_max to u_min. -/
  descending : ℝ → ℝ
  /-- Lower turning point. -/
  uMin : ℝ
  /-- Upper turning point. -/
  uMax : ℝ
  /-- Strict ordering of turning points. -/
  h_order : uMin < uMax

/-- A loop is a classical (counter-clockwise) hysteresis loop if
    the ascending branch lies below the descending branch everywhere in the interior. -/
def IsClassicalLoop (loop : HysteresisLoop) : Prop :=
  ∀ u, loop.uMin < u → u < loop.uMax → loop.ascending u ≤ loop.descending u

/-- A loop is a Butterfly Loop if the ascending and descending branches intersect
    at at least one point in the interior (uMin, uMax). -/
def IsButterflyLoop (loop : HysteresisLoop) : Prop :=
  ∃ u, loop.uMin < u ∧ u < loop.uMax ∧ loop.ascending u = loop.descending u

end HysteresisControl.Domain.Abstractions
