# HysteresisControl.lean: Formalized Hysteresis Operators & Control in Lean 4

Formal verification and executable computational implementations of mathematical hysteresis operators, memory curve dynamics, and recursive remnant control in **Lean 4** and **Mathlib**.

This repository formalizes the mathematical theorems, operator bounds, and algorithms developed across the hysteresis and control research corpus:
1. **Multi-loop Hysteresis and Recursive Remnant Control** (PhD Thesis, University of Groningen, 2021).
2. **Recursive Algorithm for the Control of Output Remnant of Preisach Hysteresis Operator** (*IEEE Control Systems Letters (L-CSS)*, vol. 5, no. 3, pp. 1061–1066, 2021, DOI: [10.1109/LCSYS.2020.3009423](https://doi.org/10.1109/LCSYS.2020.3009423)).
3. **On the Characterization of Butterfly and Multiloop Hysteresis Behavior** (*IEEE Transactions on Automatic Control (TAC)*, vol. 67, no. 7, pp. 3494–3506, 2022, DOI: [10.1109/TAC.2021.3109533](https://doi.org/10.1109/TAC.2021.3109533)).
4. **Modeling and Analysis of Duhem Hysteresis Operators With Butterfly Loops** (*IEEE Transactions on Automatic Control (TAC)*, vol. 68, no. 10, pp. 5977–5990, 2023, DOI: [10.1109/TAC.2023.3238177](https://doi.org/10.1109/TAC.2023.3238177)).
5. **Asymptotic Stability Analysis of Lur'e Systems With Butterfly Hysteresis Nonlinearities** (*IEEE Control Systems Letters (L-CSS)*, vol. 4, no. 2, pp. 498–503, 2020, DOI: [10.1109/LCSYS.2019.2921850](https://doi.org/10.1109/LCSYS.2019.2921850)).

---

## Architectural Design

The codebase strictly follows a **Hexagonal Architecture (Ports and Adapters)** adhering to SOLID principles:

```
                      +---------------------------------------+
                      |           Inbound Adapters            |
                      |   (CLI Controller, Interactive REPL)  |
                      +-------------------+-------------------+
                                          |
                                          v
                      +---------------------------------------+
                      |             Inbound Ports             |
                      |        (RemnantControlPort)           |
                      +-------------------+-------------------+
                                          |
                                          v
  +-------------------------------------------------------------------------------+
  |                              Domain Core                                      |
  |  - Abstractions: Elementary Relay, Memory Curve, Preisach, Ports              |
  |  - Formal Models & Theorems:                                                  |
  |      * Non-Ideal Relay: State transitions, threshold order, memory           |
  |      * Memory Curves: Alternating extremum sequences, wiping-out property     |
  |      * Preisach Operator: Weighted discrete approximations, monotonicity     |
  |      * Remnant Control: Contraction factor, geometric error decay,            |
  |                         asymptotic convergence theorem                        |
  |  - Domain Services: RemnantControlService, MemoryReduction                    |
  +-------------------------------------------------------------------------------+
                                          |
                                          v
                      +---------------------------------------+
                      |            Outbound Ports             |
                      |   (HysteresisSensorPort, Telemetry)   |
                      +-------------------+-------------------+
                                          |
                                          v
                      +---------------------------------------+
                      |           Outbound Adapters           |
                      |   (ConsoleTelemetry, SimulatedRelay,  |
                      |      SimulatedPreisach, SimSensor)    |
                      +---------------------------------------+
```

### Dependency Injection & Composition
- **`HysteresisControl.Composition.Container`**: Assembles adapters and injects ports into domain services at runtime.
- **`HysteresisControl.Composition.Entrypoints`**: Entrypoint bootstrap decoupling CLI and runtime environments.

---

## Repository Structure

```
.
├── HysteresisControl.lean           # Master package exports
├── HysteresisControl/
│   ├── Domain/
│   │   ├── Abstractions/            # Abstract capability classes & protocol types
│   │   │   ├── Relay.lean           # BinaryState, NonIdealRelay abstractions
│   │   │   ├── Memory.lean          # Alternating extrema, wiping-out structures
│   │   │   ├── Operator.lean        # Hysteresis operator traits
│   │   │   └── Ports.lean           # Inbound and Outbound Port definitions
│   │   ├── Model/                   # Concrete domain mathematical models & Lean theorems
│   │   │   ├── NonIdealRelay.lean   # R_{α,β} switching theorems
│   │   │   ├── MemoryCurve.lean     # Alternating extremum validation
│   │   │   ├── Preisach.lean        # Discrete weighted Preisach ensemble
│   │   │   ├── RemnantControl.lean  # Contraction mapping & convergence theorems
│   │   │   └── RemnantAlgorithm.lean# Executable remnant synthesis algorithm
│   │   └── Services/
│   │       └── RemnantControlService.lean # Remnant control domain service
│   ├── Adapters/
│   │   ├── Inbound/
│   │   │   └── CliController.lean   # Command-line interface driver
│   │   ├── Outbound/
│   │   │   └── ConsoleTelemetry.lean# Telemetry and logging adapter
│   │   └── Simulation/
│   │       └── SimulatedRelay.lean  # Executable Float simulation of relays & ensembles
│   └── Composition/
│       ├── Container.lean           # Hexagonal runtime composition container
│       └── Entrypoints.lean         # CLI and executable runner bootstrap
├── tests/
│   ├── unit/
│   │   └── TestRelay.lean           # Unit tests for elementary relay state transitions
│   ├── component/
│   │   └── TestPreisach.lean        # Component tests for Preisach ensembles
│   ├── live/
│   │   └── TestMemory.lean          # Live tests verifying wiping-out & memory curves
│   ├── e2e/
│   │   ├── TestRemnantControl.lean  # Closed-loop end-to-end convergence verification
│   │   └── TestCli.lean             # End-to-end command-line integration tests
│   └── Main.lean                    # Test suite aggregator
├── lakefile.lean                    # Lake package configuration
└── lean-toolchain                   # Pinned Lean toolchain (v4.16.0)
```

---

## Formally Verified Theorems

### 1. Elementary Non-Ideal Relay ($R_{\alpha,\beta}$)
- **`transition_neg_of_le`**: For any input $u \le \alpha$, the relay state transitions unconditionally to $-1$.
- **`transition_pos_of_ge`**: For any input $u \ge \beta$, the relay state transitions unconditionally to $+1$.
- **`transition_memory_preserved`**: For any input in the interior $\alpha < u < \beta$, the prior state is strictly preserved ($s_{next} = s_{prev}$).

### 2. Memory Curve Alternating Extremum Property
- **`validAlternating_cons`**: An alternating sequence of local maxima and minima $(M_1, m_1, M_2, m_2, \dots)$ satisfies the strict alternation invariant under induction, forming the geometric wiping-out boundary in the Preisach triangle $\Pi$.

### 3. Remnant Control Asymptotic Convergence (IEEE L-CSS 2021)
Given the Preisach output remnant function $\Phi(u)$ with slope bounds $0 < \Gamma_{min} \le \frac{d\Phi}{du} \le \Gamma_{max}$ and gain $\kappa$ satisfying $0 < \kappa < \frac{2}{\Gamma_{max}}$:
- **`contractionFactor`**: $\rho = \max(|1 - \kappa \Gamma_{min}|, |1 - \kappa \Gamma_{max}|) < 1$.
- **`remnant_error_geometric_decay`**: The error after $n$ iterations satisfies:
  $$|y_n - y_d| \le \rho^n |y_0 - y_d|$$
- **`remnant_asymptotic_convergence`**: The remnant sequence converges asymptotically to the desired target:
  $$\lim_{n \to \infty} (y_n - y_d) = 0$$

---

## Verification & Build Instructions

### Prerequisites
- [Lean 4](https://lean-lang.org/) (pinned via `lean-toolchain` to `v4.16.0`).
- [Lake](https://github.com/leanprover/lean4/tree/master/src/lake) (build system included with Lean 4).

### Building the Project
```bash
lake build
```

### Running the Full Test Suite
The repository includes automated test suites across all 4 tiers:
```bash
lake exe run_tests
```
Expected output:
```
======================================================
RUNNING HYSTERESIS CONTROL FORMALIZATION TEST SUITE
======================================================
[UNIT] Running Non-Ideal Relay unit tests...
[UNIT] Non-Ideal Relay transition tests: PASSED
[COMPONENT] Running Preisach Ensemble tests...
[COMPONENT] Preisach Ensemble tests: PASSED
[LIVE] Running Memory Curve & Wiping-Out live tests...
[LIVE] Simulated memory curve extremum tracking: PASSED
[E2E] Running Remnant Control closed-loop convergence test...
[E2E] Remnant Control closed-loop convergence: PASSED
[E2E] Running CLI integration tests...
[E2E] CLI commands: PASSED
======================================================
ALL TEST TIERS (UNIT, COMPONENT, LIVE, E2E) PASSED SUCCESSFULLY.
======================================================
```

### Executing the Control Synthesis CLI
```bash
lake exe hysteresis_cli --simulate --target 0.5 --steps 6
```
Output:
```
[TELEMETRY] [INFO] Starting Remnant Control Synthesis: target=0.500000, tol=0.000100, kappa=1.000000
[TELEMETRY] Iteration 0: u = 1.000000, y = 1.000000, target = 0.500000, error = 0.500000
[TELEMETRY] Iteration 1: u = 0.500000, y = 0.500000, target = 0.500000, error = 0.000000
[TELEMETRY] [INFO] Convergence achieved at iteration 1 with error 0.000000 <= 0.000100.
========================================
Synthesis Final Status: converged=true
Iterations: 1
Final Control Input u*: 0.500000
Achieved Remnant Output y*: 0.500000
========================================
```

---

## Roadmap

- [x] **Phase 0**: Toolchain bringup, Hexagonal ports/adapters architecture, and four-tier test suite.
- [x] **Phase 1**: Rate-independent operators (Elementary relay $R_{\alpha,\beta}$, memory curve alternating sequence, discrete Preisach ensemble).
- [x] **Phase 2**: Remnant Control (Contraction mapping proofs, geometric error decay, asymptotic convergence theorem, executable synthesis).
- [ ] **Phase 3**: Butterfly-Loop Characterization (Preisach density conditions and non-monotonic multiloop topology, IEEE TAC 2022).
- [ ] **Phase 4**: Duhem Differential Hysteresis Operators (Dissipativity, vector field properties, butterfly loop synthesis, IEEE TAC 2023).
- [ ] **Phase 5**: Feedback Systems & Stability (Lur'e systems with butterfly hysteresis, Lyapunov-LaSalle invariance proofs, IEEE L-CSS 2020).
