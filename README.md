# The Last-Touch Trap

## Marketing Attribution Analysis — Q2 2026

A direct-to-consumer sleep brand's dashboard uses **last-touch attribution**, and Paid Social receives less than 3% of conversion credit. The proposed action was to cut Paid Social budget by 60% and move the money to channels receiving more last-touch credit.

This analysis tests whether that conclusion is supported by the underlying customer journeys.

---

## Executive Summary

**Recommendation: Keep Paid Social. Do not approve the proposed 60% budget cut based on last-touch attribution alone.**

Under last-touch attribution, Paid Social receives only **2.9%** of converting customers' credit, with **173 of 5,939** first conversions attributed to the channel.

That headline is misleading when the full customer journey is considered.

Paid Social appeared somewhere in **34.7%** of converting customer journeys and was the **first attributable touch for 27.3%** of converting customers — the largest first-touch contribution among the channels.

An exposure analysis also found:

- Paid Social exposed: **15.62%** conversion rate
- No Paid Social exposure: **14.40%** conversion rate
- Observed difference: **+1.22 percentage points**
- Two-proportion z-score: **3.29**

The exposure result is statistically significant, but it is **observational rather than randomized**, so it should not be presented as proof of causal incremental lift.

### CEO decision

**Keep Paid Social — do not cut the budget by 60% based on last-touch attribution.**

Instead, Meridian should maintain the channel while improving attribution measurement and run a randomized **incrementality/holdout test** before making a major budget reallocation.

---

# 1. Business Problem

The dashboard makes Paid Social look ineffective because it receives only a small share of last-touch conversion credit.

The question is:

> **Is Paid Social actually weak, or is last-touch attribution hiding its contribution earlier in the customer journey?**

The analysis therefore compares:

1. Last-touch attribution
2. First-touch attribution
3. Multi-touch journey presence
4. Paid Social exposure vs. non-exposure
5. Statistical evidence
6. The limitations of observational attribution

---

# 2. Data and Scope

## Tables

### `touches`

Marketing interaction data containing:

- `customer_id`
- `touched_at`
- `channel`
- additional touch-level fields

A customer can have multiple touches across multiple channels.

### `conversions`

Subscription-start records containing:

- `customer_id`
- `converted_at`
- conversion information

A customer can appear more than once because of resubscriptions.

## Analysis window

**1 April 2026 through 30 June 2026 UTC**

## Attribution window

A touch is eligible for attribution when it occurred:

- on or before the conversion; and
- within **30 days before the conversion**.

---

# 3. Data Validation

The raw data contains:

```text
Touches:
89,102 rows
40,000 unique customers

Conversions:
6,422 rows
5,939 unique customers
```

Because the conversion export includes resubscriptions, customers must be deduplicated before calculating conversion-level attribution.

The analysis therefore retains the **first conversion per customer**.

Final conversion population:

```text
5,939 unique converting customers
```

This prevents repeat subscriptions from receiving multiple conversion credits.

---

# 4. Attribution Method

For every customer's first conversion:

1. Find touches belonging to that customer.
2. Keep touches occurring on or before the conversion.
3. Restrict touches to the 30-day attribution window.
4. Identify the earliest eligible touch for first-touch attribution.
5. Identify the latest eligible touch for last-touch attribution.
6. Count each converting customer once.

This makes the attribution base explicit and prevents resubscriptions or out-of-window touches from distorting the result.

---

# 5. Official Five Verified Answers

## Question 1 — Under last-touch attribution, which channel is credited with the most conversions?

### Answer: **Brand Search**

Brand Search receives the largest number of last-touch conversions:

| Channel | Last-touch conversions | Share |
|---|---:|---:|
| **Brand Search** | **2,055** | **34.60%** |
| Retargeting | 1,423 | 23.96% |
| Direct | 719 | 12.11% |
| Email | 677 | 11.40% |
| Organic Search | 464 | 7.81% |
| Referral | 264 | 4.45% |
| **Paid Social** | **173** | **2.91%** |
| YouTube | 106 | 1.78% |
| Display | 58 | 0.98% |

The last-touch dashboard therefore makes Brand Search and Retargeting appear much stronger than Paid Social.

---

# 6. Question 2 — How many unique customers converted in the Q2 window?

### Answer: **5,939**

The conversion export contains:

```text
6,422 conversion rows
5,939 unique customers
```

After keeping the first conversion per customer:

```text
5,939 first conversions
```

This is the correct denominator for the five verified answers.

---

# 7. Question 3 — Under last-touch, what share of converting customers is credited to Paid Social?

Paid Social receives:

```text
173 last-touch conversions
```

out of:

```text
5,939 converting customers
```

Calculation:

```text
173 / 5,939 × 100
= 2.91%
```

Rounded to one decimal place:

### **2.9%**

---

# 8. Question 4 — Under first-touch, what share of converting customers did Paid Social originate?

Paid Social is the earliest attributable touch for:

```text
1,621 converting customers
```

Calculation:

```text
1,621 / 5,939 × 100
= 27.29%
```

Rounded to one decimal place:

### **27.3%**

---

# 9. Multi-Touch Journey Evidence

Paid Social appeared somewhere in the eligible journey for:

```text
2,063 / 5,939
= 34.74%
```

So:

> Paid Social was present in approximately **one-third of converting customer journeys**, despite receiving only **2.9%** of last-touch credit.

Its observed journey roles were:

| Paid Social role | Customers | Share |
|---|---:|---:|
| First Touch | 1,621 | 27.29% |
| Assisting Touch | 314 | 5.29% |
| Last Touch | 128 | 2.15% |
| First and Last | 45 | 0.76% |

The important point is that **last-touch attribution systematically favors channels that occur later in the journey**, while Paid Social often starts or assists the journey.

---

# 10. Paid Social Exposure Analysis

To further investigate whether Paid Social is associated with stronger conversion, customers were split into two groups:

| Group | Customers | Converters | Conversion Rate |
|---|---:|---:|---:|
| Paid Social Exposed | 14,797 | 2,311 | **15.62%** |
| No Paid Social Exposure | 25,203 | 3,628 | **14.40%** |

Observed difference:

```text
15.62% - 14.40%
= +1.22 percentage points
```

Customers exposed to Paid Social converted at an observed rate **1.22 percentage points higher** than customers without Paid Social exposure.

---

# 11. Statistical Check

A two-proportion z-test was used to check whether the observed conversion-rate difference was likely to be due to random sampling variation.

```text
Paid Social exposed rate = 15.62%
Non-exposed rate          = 14.40%

Observed difference       = +1.22 pp
Standard error             = 0.003714
Z-score                    = 3.29
```

Since:

```text
|3.29| > 1.96
```

the observed difference is statistically significant at the 5% level.

### Important limitation

This comparison is **observational**.

Customers were not randomly assigned to Paid Social exposure.

Therefore:

> **The +1.22 pp difference is evidence of association, not proof that Paid Social caused a +1.22 pp incremental lift.**

A randomized holdout/incrementality experiment is needed to establish causality.

---

# 12. Why Last-Touch Attribution Misleads Here

The results show a large gap between first-touch and last-touch measurement:

| Metric | Paid Social |
|---|---:|
| Last-touch share | **2.9%** |
| First-touch share | **27.3%** |
| Journey presence | **34.7%** |

This suggests that Paid Social commonly appears **earlier in the customer journey**.

Other channels, particularly Brand Search and Retargeting, are more likely to appear near the final purchase decision.

For example:

```text
Paid Social
      ↓
Organic Search
      ↓
Brand Search
      ↓
Retargeting
      ↓
Conversion
```

A last-touch system would give the conversion to Retargeting, even though Paid Social may have been involved at the beginning of the journey.

That does not mean Paid Social deserves 100% credit. It means **last-touch alone cannot measure its full contribution**.

---

# 13. Recommendation

## Keep Paid Social.

**Do not cut the Paid Social budget by 60% based on last-touch attribution.**

The last-touch result says Paid Social receives only 2.9% of credit.

But the broader analysis shows:

- Paid Social originates **27.3%** of converting journeys.
- Paid Social appears in **34.7%** of converting journeys.
- Paid Social exposed customers have a **1.22 pp higher observed conversion rate**.
- The exposure difference has a **z-score of 3.29**.

The exposure analysis is not causal, but together these findings are strong enough to reject the idea that Paid Social is simply "not converting."

### What Meridian should do instead

1. Keep Paid Social investment in place.
2. Stop using last-touch credit as the sole basis for channel budget decisions.
3. Report first-touch, assisting-touch, and last-touch metrics together.
4. Run a randomized Paid Social holdout/incrementality test.
5. Measure incremental conversions and revenue.
6. Reallocate budget only after causal evidence is available.

---

# 14. What Would You Tell the CEO?

**I would not approve the proposed 60% Paid Social budget cut.** Last-touch attribution gives Paid Social only 2.9% of converting customers, but the same data shows it originated 27.3% of converting journeys and appeared in 34.7% of them. Customers exposed to Paid Social also had a 15.62% conversion rate versus 14.40% without exposure, a statistically significant 1.22 pp observed difference (z = 3.29). That exposure result is observational, so it does not prove causal incremental lift. The bigger issue is measurement: last-touch systematically favors channels appearing near the final purchase step and understates channels that introduce or assist customers earlier. I would keep Paid Social funded, improve the attribution view, and run a randomized incrementality/holdout test. The next budget decision should be based on incremental conversions and revenue, not simply on which channel touched the customer last.

---

# 15. Repository Structure

```text
The-Last-Touch-Trap/
│
├── README.md
├── five_verified_answers.md
│
├── data/
│   ├── touches.csv
│   └── conversions.csv
│
└── sql/
    ├── 01_create_tables.sql
    ├── 02_insert_data.sql
    ├── 03_data_validation.sql
    ├── 04_first_conversion.sql
    ├── 05_30_day_attribution.sql
    ├── 06_last_touch_attribution.sql
    ├── 07_first_touch_attribution.sql
    ├── 08_paid_social_journey_analysis.sql
    ├── 09_paid_social_exposure_analysis.sql
    └── 10_final_validation.sql
```

---

# 16. SQL Workflow

```text
Raw Data
   ↓
Data Validation
   ↓
First Conversion per Customer
   ↓
30-Day Attribution Window
   ↓
Last-Touch Attribution
   ↓
First-Touch Attribution
   ↓
Multi-Touch Journey Analysis
   ↓
Paid Social Exposure Analysis
   ↓
Statistical Validation
   ↓
Business Recommendation
```

---

## Key Takeaway

> **Last-touch attribution says Paid Social is small. The customer journey says Paid Social is an important acquisition channel.**

The correct business response is **not** to blindly shift budget based on the last touch. Keep the channel funded, improve measurement, and validate incremental impact through a randomized test.
