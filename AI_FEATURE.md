# Lunch Lens – Smart Helper

**Method:** rule-based statistical helper (not a trained AI model).
**Benefit:** a transparent estimate of what the next purchase of a saved meal will cost.

## How it works
| Item | Implementation |
|---|---|
| Inputs | Up to 5 most recent purchases for the meal with amount > 0 (cents) |
| Logic | Arithmetic mean, rounded to cents; recalculated whenever purchases change |
| Output | "Estimated next cost: $8.20" + "Based on 3 recent purchases. This is an estimate, not a guarantee." |
| Baseline | Most recent purchase price ("Last paid") |
| Outlier warning | Shown when any sample is more than 2× the median (needs ≥ 3 samples) |
| User control | *Use as draft* fills the amount field only; nothing is saved until the user taps Save. *Dismiss* hides the card until purchases change |
| No data | "Log a purchase to get an estimate." |

Code: `lib/helper/lunch_lens.dart`, `lib/widgets/lunch_lens_card.dart`.

## Evaluation
Run `flutter test test/evaluation_report_test.dart`. Expected output:

| Case | n | Helper | Baseline | Actual | Helper err | Baseline err |
|---|---|---|---|---|---|---|
| 1 Normal | 3 | $8.20 | $8.10 | $8.30 | $0.10 | $0.20 |
| 2 Empty history | 0 | n/a | n/a | n/a | n/a | n/a |
| 3 Invalid amounts ignored | 1 | $9.00 | $9.00 | $9.00 | $0.00 | $0.00 |
| 4 Boundary (>5 purchases) | 5 | $10.00 | $12.00 | $11.00 | $1.00 | $1.00 |
| 5 Outlier | 5 | $11.40 | $25.00 | $8.00 | $3.40 | $17.00 |
| 6 Counterexample (price rise) | 3 | $8.50 | $9.50 | $9.50 | $1.00 | $0.00 |

Mean absolute error over 5 scored cases: helper $1.10, baseline $3.64.

## Findings and limitations
- The helper beats the baseline when prices vary randomly or one price is unusual (cases 1, 5).
- The baseline wins when a price changes permanently (case 6): the mean lags for up to 5 purchases.
- Promotions, portion changes and one-off high prices can mislead the estimate; the outlier warning flags the last of these.
- These are 6 hand-built cases, so results show behaviour, not real-world accuracy.

## Tests
- `test/lunch_lens_test.dart` – helper logic, absolute error, outlier flag, evaluation runner
- `test/lunch_lens_card_test.dart` – widget behaviour (empty state, draft, dismiss, warning)
- `test/evaluation_report_test.dart` – reproducible evaluation table
