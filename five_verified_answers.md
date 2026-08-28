# Five Verified Answers

## The Last-Touch Trap — Q2 2026

## 1. Under last-touch attribution, which channel is credited with the most conversions?

**Answer: Brand Search**

| Channel | Last-Touch Conversions | Share |
|---|---:|---:|
| **Brand Search** | **2,055** | **34.60%** |
| Retargeting | 1,423 | 23.96% |
| Direct | 719 | 12.11% |
| Email | 677 | 11.40% |
| Organic Search | 464 | 7.81% |
| Referral | 264 | 4.45% |
| Paid Social | 173 | 2.91% |
| YouTube | 106 | 1.78% |
| Display | 58 | 0.98% |

---

## 2. How many unique customers converted in the Q2 window?

**Answer: 5,939**

The conversion export contains 6,422 rows and 5,939 unique customers. Because customers can resubscribe, each customer is counted once using their first conversion.

---

## 3. Under last-touch, what share of converting customers is credited to Paid Social?

Paid Social receives 173 last-touch conversions from 5,939 converting customers.

```text
173 / 5,939 × 100 = 2.91%
```

**Answer: 2.9%**

---

## 4. Under first-touch, what share of converting customers did Paid Social originate?

Paid Social was the first attributable touch for 1,621 converting customers.

```text
1,621 / 5,939 × 100 = 27.29%
```

**Answer: 27.3%**

---

## 5. Should Meridian cut the Paid Social budget?

**Answer: Keep it — it originates the most journeys**

Paid Social originated 1,621 converting journeys, or 27.29% of converting customers.

It also appeared somewhere in 2,063 converting customer journeys:

```text
2,063 / 5,939 = 34.74%
```

Exposure analysis:

| Group | Customers | Converters | Conversion Rate |
|---|---:|---:|---:|
| Paid Social Exposed | 14,797 | 2,311 | **15.62%** |
| No Paid Social Exposure | 25,203 | 3,628 | **14.40%** |

Observed difference:

```text
15.62% - 14.40% = +1.22 percentage points
```

Statistical check:

```text
Standard error = 0.003714
Z-score = 3.29
```

The observed difference is statistically significant at the 5% level. However, this is an observational comparison, not a randomized experiment, so it does not prove causal incremental lift.

---

# Final Five Answers

1. **Brand Search**
2. **5939**
3. **2.9%**
4. **27.3%**
5. **Keep it — it originates the most journeys**

---

# Supporting Validation

| Metric | Result |
|---|---:|
| Touch rows | 89,102 |
| Unique customers in touches | 40,000 |
| Conversion rows | 6,422 |
| Unique converting customers | 5,939 |
| First conversions used | 5,939 |
| Eligible 30-day touches | 20,533 |
| Paid Social last-touch conversions | 173 |
| Paid Social last-touch share | 2.91% |
| Paid Social first-touch conversions | 1,621 |
| Paid Social first-touch share | 27.29% |
| Converting journeys containing Paid Social | 2,063 |
| Paid Social journey presence | 34.74% |
| Paid Social exposed customers | 14,797 |
| Paid Social exposed converters | 2,311 |
| Paid Social exposed conversion rate | 15.62% |
| Non-exposed customers | 25,203 |
| Non-exposed converters | 3,628 |
| Non-exposed conversion rate | 14.40% |
| Observed conversion-rate difference | +1.22 pp |
| Z-score | 3.29 |

# Method Notes

1. Restrict conversions to the Q2 2026 window.
2. Deduplicate conversions by `customer_id`.
3. Keep the first conversion for each customer.
4. Build the 30-day attribution window before that first conversion.
5. Only touches on or before the conversion are eligible.
6. Assign the latest eligible touch for last-touch attribution.
7. Assign the earliest eligible touch for first-touch attribution.
8. Keep non-converting customers in the exposure analysis.
9. Compare Paid Social exposed vs. non-exposed conversion rates.
10. Treat the exposure comparison as observational rather than causal.

## Key Takeaway

Last-touch attribution gives Paid Social only **2.9%** of conversion credit, while first-touch attribution shows that it originated **27.3%** of converting journeys.

The appropriate decision is to **keep Paid Social funded**, improve attribution measurement, and run a randomized incrementality/holdout test before making a major budget reallocation.
