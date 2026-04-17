-- SOAL 3: Daily metrics for management dashboard (Looker Studio)

WITH

-- Hanya donasi VERIFIED (status = 4)
verified_donation AS (
    SELECT
        id,
        campaign_id,
        user_id,
        amount,
        platform,
        status,
        DATE(TIMESTAMP_SECONDS(created)) AS donation_date
    FROM `seal-da-test.kitabisa.donation`
    WHERE status = 4
),

-- GDV, total donasi, total donor unik per hari
daily_donation_metrics AS (
    SELECT
        donation_date                       AS date,
        SUM(amount)                         AS total_gdv,
        COUNT(id)                           AS total_donation,
        COUNT(DISTINCT user_id)             AS total_donate_user
    FROM verified_donation
    GROUP BY donation_date
),

-- Total new user per hari
daily_new_user AS (
    SELECT
        DATE(TIMESTAMP_SECONDS(created))    AS date,
        COUNT(id)                           AS total_new_user
    FROM `seal-da-test.kitabisa.user`
    GROUP BY 1
),

-- Total campaign launched per hari
daily_campaign_launched AS (
    SELECT
        DATE(TIMESTAMP_SECONDS(created))    AS date,
        COUNT(id)                           AS total_campaign_launched
    FROM `seal-da-test.kitabisa.campaign`
    GROUP BY 1
),

-- First-time donor per hari
first_donation_per_user AS (
    SELECT
        user_id,
        MIN(donation_date)                  AS first_donation_date
    FROM verified_donation
    GROUP BY user_id
),

daily_first_time_donor AS (
    SELECT
        first_donation_date                 AS date,
        COUNT(user_id)                      AS total_first_time_donor
    FROM first_donation_per_user
    GROUP BY 1
),

-- Average donation amount per hari
daily_avg_donation AS (
    SELECT
        donation_date                       AS date,
        ROUND(AVG(amount), 0)               AS avg_donation_amount
    FROM verified_donation
    GROUP BY donation_date
),

-- Donation success rate per hari
daily_all_donation AS (
    SELECT
        DATE(TIMESTAMP_SECONDS(created))        AS date,
        COUNT(id)                               AS total_all_donation,
        COUNTIF(status = 4)                     AS total_verified_donation,
        ROUND(COUNTIF(status = 4) * 100.0
            / NULLIF(COUNT(id), 0), 2)          AS donation_success_rate_pct
    FROM `seal-da-test.kitabisa.donation`
    GROUP BY 1
),

-- Distribusi platform donasi per hari
daily_platform AS (
    SELECT
        donation_date                               AS date,
        COUNTIF(LOWER(platform) = 'android')        AS donation_android,
        COUNTIF(LOWER(platform) = 'ios')            AS donation_ios,
        COUNTIF(LOWER(platform) = 'web')            AS donation_web,
        COUNTIF(LOWER(platform) = 'pwa')            AS donation_pwa
    FROM verified_donation
    GROUP BY donation_date
),

-- Pageview, unique visitor & platform kunjungan harian
daily_visit AS (
    SELECT
        date_id                                         AS date,
        SUM(pageview)                                   AS total_pageview,
        SUM(unique_user)                                AS total_unique_visitor,
        COUNTIF(LOWER(platform) = 'app')                AS visit_app,
        COUNTIF(LOWER(platform) = 'web')                AS visit_web,
        COUNTIF(LOWER(platform) = '3rd party')          AS visit_3rdparty
    FROM `seal-da-test.kitabisa.visit`
    GROUP BY date_id
),

-- Tiket komplain & satisfaction rating per hari
daily_ticket AS (
    SELECT
        DATE(TIMESTAMP_SECONDS(created))                    AS date,
        COUNT(id)                                           AS total_ticket,
        COUNTIF(LOWER(priority) = 'high')                   AS total_high_priority_ticket,
        COUNTIF(LOWER(satisfication_rating) = 'good')       AS rating_good,
        COUNTIF(LOWER(satisfication_rating) = 'normal')     AS rating_normal,
        COUNTIF(LOWER(satisfication_rating) = 'bad')        AS rating_bad
    FROM `seal-da-test.kitabisa.ticket`
    GROUP BY 1
),

-- Distribusi campaign per kategori per hari
daily_campaign_category AS (
    SELECT
        DATE(TIMESTAMP_SECONDS(created))                        AS date,
        COUNTIF(category = 'Bantuan Medis & Kesehatan')         AS camp_medis,
        COUNTIF(category = 'Sarana & Infrastruktur')            AS camp_sarana,
        COUNTIF(category = 'Zakat')                             AS camp_zakat,
        COUNTIF(category = 'Hadiah & Apresiasi')                AS camp_hadiah
    FROM `seal-da-test.kitabisa.campaign`
    GROUP BY 1
)

-- Final dataset untuk dashboard
SELECT
    COALESCE(
        dm.date, dnu.date, dcl.date,
        dftd.date, dv.date, dt.date,
        dal.date, dcc.date
    )                                               AS date,

    COALESCE(dm.total_gdv, 0)                       AS total_gdv,
    COALESCE(dm.total_donation, 0)                  AS total_donation,
    COALESCE(dm.total_donate_user, 0)               AS total_donate_user,
    COALESCE(dnu.total_new_user, 0)                 AS total_new_user,
    COALESCE(dcl.total_campaign_launched, 0)        AS total_campaign_launched,
    COALESCE(dftd.total_first_time_donor, 0)        AS total_first_time_donor,

    COALESCE(dad.avg_donation_amount, 0)            AS avg_donation_amount,
    COALESCE(dal.total_all_donation, 0)             AS total_all_donation,
    COALESCE(dal.donation_success_rate_pct, 0)      AS donation_success_rate_pct,

    COALESCE(dp.donation_android, 0)                AS donation_android,
    COALESCE(dp.donation_ios, 0)                    AS donation_ios,
    COALESCE(dp.donation_web, 0)                    AS donation_web,
    COALESCE(dp.donation_pwa, 0)                    AS donation_pwa,

    COALESCE(dv.total_pageview, 0)                  AS total_pageview,
    COALESCE(dv.total_unique_visitor, 0)            AS total_unique_visitor,
    COALESCE(dv.visit_app, 0)                       AS visit_app,
    COALESCE(dv.visit_web, 0)                       AS visit_web,
    COALESCE(dv.visit_3rdparty, 0)                  AS visit_3rdparty,

    COALESCE(dt.total_ticket, 0)                    AS total_ticket,
    COALESCE(dt.total_high_priority_ticket, 0)      AS total_high_priority_ticket,
    COALESCE(dt.rating_good, 0)                     AS ticket_rating_good,
    COALESCE(dt.rating_normal, 0)                   AS ticket_rating_normal,
    COALESCE(dt.rating_bad, 0)                      AS ticket_rating_bad,

    COALESCE(dcc.camp_medis, 0)                     AS camp_medis,
    COALESCE(dcc.camp_sarana, 0)                    AS camp_sarana,
    COALESCE(dcc.camp_zakat, 0)                     AS camp_zakat,
    COALESCE(dcc.camp_hadiah, 0)                    AS camp_hadiah

FROM daily_donation_metrics             dm
FULL OUTER JOIN daily_new_user          dnu  ON dnu.date  = dm.date
FULL OUTER JOIN daily_campaign_launched dcl  ON dcl.date  = dm.date
FULL OUTER JOIN daily_first_time_donor  dftd ON dftd.date = dm.date
FULL OUTER JOIN daily_avg_donation      dad  ON dad.date  = dm.date
FULL OUTER JOIN daily_all_donation      dal  ON dal.date  = dm.date
FULL OUTER JOIN daily_platform          dp   ON dp.date   = dm.date
FULL OUTER JOIN daily_visit             dv   ON dv.date   = dm.date
FULL OUTER JOIN daily_ticket            dt   ON dt.date   = dm.date
FULL OUTER JOIN daily_campaign_category dcc  ON dcc.date  = dm.date

ORDER BY date DESC
;