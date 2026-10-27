---
id: 1
type: note
created: 2026-10-27
related: []
---

# GMRF exhibit review and updates

Solo session reviewing GMRF exhibits in Obsidian, discussing table status, minimum distance diagnostics, covariance reporting, and next steps for the paper.

## Exhibit review and table status

Reviewed GMRF exhibits in Obsidian (file: 2026-10-27 GMRF exhibit review). Table 2 (counterfactual table) was running; Table 1 still needed work. Key concern: results had been reviewed in isolation before, never compiled into a full exhibit list. Row estimates are relatively stable across specifications, but variance components are shakier.

The giant component shows a lower rho estimate -- possibly less sorting there, but the covariance is actually larger. Covariance and correlation move in opposite directions across subgraphs, because the variance of Z is meaningfully different across subgraphs (identified from firm-to-firm mobility).

## Sigma and minimum distance diagnostics

The minimum distance sigma Z estimate is surprisingly low (0.06 vs. 1.5 for sigma A, ratio ~24). Possible explanation: minimum distance uses the tree assumption; maximum likelihood does not. Non-tree elements may explain the gap between the two estimators.

"A directional check passed: larger variance ratio implies larger gap between sigma A and sigma Z."

Rho mixes shocks, compressing the observable difference. The formula was verified via Google AI.

## Table 1 cleanup and covariance reporting

The correlation is very close to rho numerically (e.g. 1.528 squared is about 2.33 vs. empirical 2.37). Two views on reporting rho in the table:

- Keep rho: emphasizes it is a model parameter, not the correlation
- Drop rho: nearly redundant with the moments

Covariance is worth keeping because it does something distinct: increases where correlation decreases. Plan: move unconditional correlation/covariance to table notes or footnote; add notes to Table 1.

Industry-year demeaning is currently not applied to GMRF estimates. Degree demeaning is also absent. Confirmed not implemented in the bipartite GMRF Julia repo; did not make a big difference historically.

## Next steps and tooling

- Let current runs finish over lunch (fast enough on local machine)
- Request firewall policy change to unblock SSH on Halflinger
- Delete the 2013 patch from the meta file (not used, just taking up space)

"The ratio is like 24. So the ratio in terms of the variance is like 24 squared, which seems to be super big. But directionally though, I think if you... the bigger the ratio, the bigger the gap between sigma A and sigma Z."

On AI tooling: Meta Llama Spark 1.3 (open source, decent), Wonder 1.0 (competitive with GPT/Claude but expensive); Meta entering price competition.

## Action items

- Add notes to Table 1 (currently missing; Table 2 already has notes). Include unconditional covariance and a note clarifying rho vs. correlation.
- Finalize exhibit list including appendices. Appendix should include results with covariates; use the exhibit list to drive remaining to-dos.
- Rerun estimates without industry-year demeaning and compare. Verify whether demeaning is strictly necessary; check makefile flag in chunk.jl.
- Request SSH firewall exception for Halflinger (blocked currently; needed to offload parallel runs from laptop).