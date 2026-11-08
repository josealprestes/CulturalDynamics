# Model Description

## Overview

CulturalDynamics.jl implements an agent-based model for simulating compliance/adherence to processes, procedures, and norms. The model extends Axelrod's cultural dissemination model with motivation theory, social contagion, and habit formation.

## Agents

Each agent represents an individual in an organization with:

- **Compliance vector**: `features = [f1, ..., fF]` where `fi ∈ {1, ..., Q}`
- **Motivation force**: `motivation ∈ [0, 1]` (Vroom's expectancy theory)
- **Openness**: `openness ∈ [0, 1]` (receptiveness to social influence)
- **Expressiveness**: `expressiveness ∈ [0, 1]` (influence on others)
- **System 2 weight**: `system2_weight ∈ [0, 1]` (deliberate vs. habitual)
- **Team ID**: Team membership identifier
- **Social rank**: Hierarchical position `∈ [0, 1]`

## Interaction Rule

Each agent step (`compliance_agent_step!`):

1. Normative audit, if `NormSanctions` is active (`monitoring_rate`).
2. Fatigue: motivation decays and, with probability `fatigue_rate`, one trait
   above 1 decrements ("cutting corners when tired").
3. Vroom motivation update, if active.
4. A valid neighbor is drawn (grid, network overlay or barrier-aware).
5. Similarity `s` = fraction of equal traits.
6. Bounded-confidence gate: similarity `< ε` blocks the interaction.
7. Copy of **one** differing trait with probability `p(s)` (`copy_probability`;
   pure Axelrod when `textbook=true`).
8. On copy: social contagion, mutation and `system2_weight` decay.

Each model step (`compliance_model_step!`): directional training
(`DirectedTraining`), shift boundary (motivation reset + turnover),
metric recording at `recording_interval`, absorption check.

## Extensions

### Bounded Confidence (Hegselmann-Krause 2002)
Agents with similarity below threshold ε do not interact.

### Social Contagion (Sharpanskykh 2016)
Influence weighted by: `γ = openness × expressiveness × channel_strength`

### Vroom's Expectancy Theory
Motivation force: `F = Σ(expectancy × instrumentality × valence)`

### Dual Process (Kahneman 2011)
System 2 (deliberate) → System 1 (habitual) transition over time.

## Metrics

Outcome metrics (`count_regions`, `compliance_rate`, `partial_compliance`)
plus runtime metadata (`step_count`, `absorbed_at`, `effective_interactions`):

- Overall and per-dimension compliance
- Number of regions (Union-Find over identical full feature vectors)
- Largest region size and share, mean region size
- Mean motivation and openness
- System 1 fraction (`system2_weight < 0.5`)
- Interaction counters (`effective` / `attempted`)
