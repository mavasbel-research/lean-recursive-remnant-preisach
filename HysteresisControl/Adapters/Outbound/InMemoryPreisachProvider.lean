import HysteresisControl.Ports.Outbound.IPreisachModelProvider

namespace HysteresisControl.Adapters.Outbound

open HysteresisControl.Ports.Outbound

/-- In-memory implementation of IPreisachModelProvider. -/
structure InMemoryPreisachProvider where
  params : BoundaryCurveParams := ⟨0.5, 1.5, 1.0⟩

namespace InMemoryPreisachProvider

def getBoundaryParams (self : InMemoryPreisachProvider) : IO BoundaryCurveParams :=
  pure self.params

/-- Linear approximation of ascending boundary curve f(u) = 0.5 * u + 0.1 * u^2 + ... -/
def evaluateCurve (self : InMemoryPreisachProvider) (u : Float) : IO Float :=
  pure (self.params.gammaMin * u + 0.5 * (self.params.gammaMax - self.params.gammaMin) * u)

instance : IPreisachModelProvider InMemoryPreisachProvider where
  getBoundaryParams self := self.getBoundaryParams
  evaluateCurve self u := self.evaluateCurve u

end InMemoryPreisachProvider

end HysteresisControl.Adapters.Outbound
