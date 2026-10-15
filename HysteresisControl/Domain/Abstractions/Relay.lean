import Mathlib.Basic.Real.Basic
import Mathlib.Order.Monotone.Basic

namespace HysteresisControl.Domain.Abstractions

/-- Discrete internal state of a non-ideal relay operator. -/
inductive BinaryState : Type
  | neg : BinaryState -- corresponds to -1
  | pos : BinaryState -- corresponds to +1
  deriving DecidableEq, Repr

namespace BinaryState

/-- Convert the discrete binary state to real output value {-1, +1}. -/
def toReal : BinaryState → ℝ
  | neg => -1
  | pos => 1

/-- Conversion to integer {-1, +1}. -/
def toInt : BinaryState → ℤ
  | neg => -1
  | pos => 1

@[simp] theorem toReal_neg : (BinaryState.neg).toReal = -1 := rfl
@[simp] theorem toReal_pos : (BinaryState.pos).toReal = 1 := rfl

end BinaryState

/-- Abstract general definition of an input signal over time. -/
def ContinuousInput := ℝ → ℝ

end HysteresisControl.Domain.Abstractions
