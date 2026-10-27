---
id: 2
type: note
created: 2026-10-27
related: []
---

# Covariance analysis plan

Solo afternoon session planning and executing the covariance decay regression analysis for GMRF, running two AI agents in parallel.

## Regression table plan

Each column is an MLE regression; main specification is columns 3-4. Variables to include (same column):

- Firm age and firm age squared
- Manager experience and experience squared
- Geography (quadratic + interaction term)
- Industry/year and firm-manager degree controls (placement TBD)
- No-function dummy confirmed as useful

Separate table for covariance decay regression (Y1 x Y2). No intercept enforced in main MLE. Exponential decay form: rho squared x H. Channels: firm-to-firm, mixed, person-to-person. Column ordering: H + distance, then H + distance + industry, then full controls.

## Covariance estimation results

Rho is positive after including controls -- a good sign. Same-industry dummy raises covariance by factor ~3.7 (exp(1.3)). It reduces rho but rho remains high.

Geographic distance coefficient near zero (-0.06 to +0.04 range). Distance is not monotonically increasing with mobility distance (A-to-C is about as large as A-to-B). "The geography coefficient is basically just zero. I think that zero -- we wrote a lot of code for it."

Mobility distance and geographic distance are negatively correlated, supporting the processing argument.

Two agents were running in parallel: red agent (full estimation) was suspiciously slow, no new estimates appearing. Green agent (covariance regression) completed; results roughly consistent (~200k vs. ~180k pairs, small data gap).

## Tooling and code issues

DuckDB version mismatch causing load errors; wrong version installed, unclear which is correct. The extension is only compatible with the bundled version; upgrade to 2.0 deferred.

EOV/EUV coordinate data missing or not properly normalized; ~99%+ of data retained, not a blocker.

"I don't know why it's taking so long. The red agent is still working. It's been working for some time now. What's even more worrisome is that I don't see any new estimates showing up."

Firm geography branch (PR 182) already merged to main; the AI agent should find it.

LaTeX compilation taking longer than estimation; considered switching to Typst but deferred.

Plan: clean up supplementary appendices next, then take a break from GMRF.