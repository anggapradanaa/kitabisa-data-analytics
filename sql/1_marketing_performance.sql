-- SOAL 1: Daily campaign performance including ads spend, donation, traffic, and conversion metrics

WITH

-- 1. Agregasi donasi harian per campaign (status VERIFIED = 4)
daily_donation AS (
    SELECT
        d.campaign_id,
        DATE(TIMESTAMP_SECONDS(d.created)) AS date,
        SUM(d.amount)                       AS donation_amount,
        COUNT(d.id)                         AS total_donation,
        COUNT(DISTINCT d.user_id)           AS total_donor
    FROM `seal-da-test.kitabisa.donation` d
    WHERE d.status = 4   -- VERIFIED
    GROUP BY 1, 2
),

-- 2. Agregasi ads spending harian per campaign (berdasarkan campaign URL)
daily_ads AS (
    SELECT
        c.id          AS campaign_id,
        a.date_id     AS date,
        SUM(a.spend)  AS ads_spending,
        SUM(a.impression) AS total_impression
    FROM `seal-da-test.kitabisa.ads_spent`  a
    JOIN `seal-da-test.kitabisa.campaign`   c ON c.url = a.short_url
    GROUP BY 1, 2
),

-- 3. Agregasi pageview harian per campaign (berdasarkan campaign URL)
daily_visit AS (
    SELECT
        c.id              AS campaign_id,
        v.date_id         AS date,
        SUM(v.pageview)   AS total_pageview,
        SUM(v.unique_user) AS total_unique_visitor
    FROM `seal-da-test.kitabisa.visit`    v
    JOIN `seal-da-test.kitabisa.campaign` c ON c.url = v.campaign_url
    GROUP BY 1, 2
),

-- 4. User baru per hari (berdasarkan created date user)
daily_new_user AS (
    SELECT
        DATE(TIMESTAMP_SECONDS(created)) AS date,
        COUNT(id)                         AS total_new_user
    FROM `seal-da-test.kitabisa.user`
    GROUP BY 1
)

-- Final result: daily campaign performance
SELECT
    COALESCE(dd.date, da.date, dv.date)           AS date,
    c.id                                           AS campaign_id,
    c.title                                        AS campaign_name,
    c.category                                     AS campaign_category,

    -- Donation metrics
    COALESCE(dd.donation_amount, 0)                AS donation_amount,
    COALESCE(dd.total_donation, 0)                 AS total_donation,
    COALESCE(dd.total_donor, 0)                    AS total_donor,

    -- Ads metrics
    COALESCE(da.ads_spending, 0)                   AS ads_spending,
    COALESCE(da.total_impression, 0)               AS total_impression,

    -- Visit metrics
    COALESCE(dv.total_pageview, 0)                 AS total_pageview,

    -- New user (level harian)
    COALESCE(dnu.total_new_user, 0)                AS total_new_user,

    -- Conversion rate: total_donation / total_pageview * 100
    CASE
        WHEN COALESCE(dv.total_pageview, 0) = 0 THEN 0
        ELSE ROUND(
            COALESCE(dd.total_donation, 0) * 100.0
            / dv.total_pageview, 2)
    END AS conversion_rate_pct,

    -- % spending per donation amount: ads_spending / donation_amount * 100
    CASE
        WHEN COALESCE(dd.donation_amount, 0) = 0 THEN NULL
        ELSE ROUND(
            COALESCE(da.ads_spending, 0) * 100.0
            / dd.donation_amount, 2)
    END AS pct_spending_per_donation_amount

FROM `seal-da-test.kitabisa.campaign` c

LEFT JOIN daily_donation  dd  ON dd.campaign_id = c.id
LEFT JOIN daily_ads       da  ON da.campaign_id = c.id  AND da.date  = dd.date
LEFT JOIN daily_visit     dv  ON dv.campaign_id = c.id  AND dv.date  = dd.date
LEFT JOIN daily_new_user  dnu ON dnu.date = dd.date

WHERE dd.date IS NOT NULL

ORDER BY date DESC, campaign_id
;