import Lake
open Lake DSL

package "HysteresisControl" where
  version := v!"0.1.0"
  keywords := #["math"]
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩,
    ⟨`relaxedAutoImplicit, false⟩,
    ⟨`maxSynthPendingDepth, .ofNat 3⟩,
    ⟨`weak.linter.mathlibStandardSet, false⟩,
  ]

require "leanprover-community" / "mathlib" @ git "v4.35.0"

@[default_target]
lean_lib «HysteresisControl» where
  roots := #[`HysteresisControl]

lean_lib «Tests» where
  srcDir := "."
  roots := #[
    `tests.unit.TestRelay,
    `tests.unit.TestTheorems,
    `tests.component.TestPreisach,
    `tests.live.TestMemory,
    `tests.e2e.TestRemnantControl
  ]

lean_exe «run_tests» where
  root := `tests.Main

lean_exe «hysteresis_cli» where
  root := `HysteresisControl.Main
