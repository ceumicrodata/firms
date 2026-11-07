---
id: 3
type: note
created: 2026-11-06
related: []
---

# GMRF Table 1 re-estimation with Ulrich

Pair session with Ulrich Wohak covering the Amazon Research Awards submission (separate note) and a review of Ulrich's re-estimation of GMRF Table 1. The main topics were the timing of year/degree adjustment relative to pruning, a discrepancy in the minimum-distance rho estimate, and next steps for the paper.

## Year and degree adjustment timing

Ulrich re-estimated Table 1 (firm-average MLE and minimum distance) with the full AR(1) already done. The question was whether year mean removal and degree demeaning should happen before or after pruning. The difference is negligible -- rho shifts less than 0.001 across all combinations.

> "Spoiler, it doesn't really make a big difference. So it doesn't really make a big difference."

The decision was to do adjustment after pruning, for consistency with the MLE stage which does not know about pruning. Miklos: "Let's be consistent with, because I think in other specifications, we can do it in the maximum likelihood estimation stage, and then it doesn't know that it has been pruned so I guess it's after pruning then."

## Minimum-distance rho discrepancy

A discrepancy was flagged in the minimum-distance rho estimate. Ulrich's minimum-distance rho was approximately 0.48, compared to the current Table 1 value of approximately 0.63 on main. Ulrich was unable to fully reproduce Miklos's data despite reloading BEAT fresh:

> "I tried for like an hour and a half to rebuild your data and I couldn't do it even with reloading the beat fresh."

The other two estimators (firm-average MLE at ~0.55, AR(1) at ~0.63) aligned well between their runs. The resolution is to run the same code without touching anything, match Julia versions and BEAT reload exactly, and compare outputs. It is suspected to be a minor data fluke since the other estimates match.

Ulrich also noted confusion from a previous result: "Yeah, but I think this is some error because look, Miklos, like we have here this... And here we have, because this is what I remember, like there's no big difference." After reviewing, they concluded the earlier comparison was sound and the current discrepancy needed systematic isolation.

## Pull request #185

PR #185 ("Rebuild Table 1 and compare year and degree adjustment timing") shows the re-estimation results. The timing comparison table reports across before/after pruning combinations: minimum-distance rho 0.6084--0.6140, AR(1) MLE 0.4896--0.5097, and firm-average MLE 0.5532--0.5600. The current Table 1 on main reports 0.6136, 0.6342, and 0.5011 respectively.

## Next steps

- Reproduce Table 1 discrepancy using identical code and Julia environment (Ulrich). Match runtime exactly (BEAT reload, Julia version) to isolate why minimum-distance rho diverges from current main.
- Build and commit final Table 1 artifact after pruning (Ulrich). Clean up table notes, then decide whether to replace the current main version.
- Send full exhibit list to Christina. Coordinate with Sophie on DTC and appendixes; target next week.