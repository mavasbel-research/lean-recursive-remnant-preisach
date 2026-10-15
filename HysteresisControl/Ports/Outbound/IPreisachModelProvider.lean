namespace HysteresisControl.Ports.Outbound

/-- Model parameters defining Preisach boundary curves. -/
structure BoundaryCurveParams where
  /-- Minimum derivative bound Γ_min > 0 of boundary curve. -/
  gammaMin : Float
  /-- Maximum derivative bound Γ_max > 0 of boundary curve. -/
  gammaMax : Float
  /-- Optimal step size gain κ = 2 / (Γ_min + Γ_max). -/
  stepGain : Float := 2.0 / (gammaMin + gammaMax)

/-- Outbound Port: Provider for Preisach operator model parameters. -/
class IPreisachModelProvider (P : Type) where
  /-- Get boundary curve parameters. -/
  getBoundaryParams : P → IO BoundaryCurveParams
  /-- Evaluate boundary curve function f(u) at input u. -/
  evaluateCurve : P → Float → IO Float

end HysteresisControl.Ports.Outbound
