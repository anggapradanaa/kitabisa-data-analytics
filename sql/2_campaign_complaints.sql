-- SOAL 2: Campaign performance with flag status and creator complaint history

WITH

-- 1. Total donasi per campaign (status VERIFIED = 4)
campaign_donation AS (
    SELECT
        campaign_id,
        SUM(amount)  AS total_donation_amount
    FROM `seal-da-test.kitabisa.donation`
    WHERE status = 4
    GROUP BY campaign_id
),

-- 2. Agregasi tiket komplain per user (pembuat campaign)
user_ticket AS (
    SELECT
        user_id,
        COUNT(id)                                           AS no_of_complain,
        COUNTIF(LOWER(priority) = 'high')                  AS no_of_high_priority,
        ROUND(
            COUNTIF(LOWER(priority) = 'high') * 100.0
            / COUNT(id), 2)                                AS pct_high_priority
    FROM `seal-da-test.kitabisa.ticket`
    GROUP BY user_id
)

-- Final result: campaign performance with flags and complaint metrics
SELECT
    c.id                                                    AS campaign_id,
    c.title                                                 AS campaign_name,
    COALESCE(cd.total_donation_amount, 0)                   AS total_donation_amount,
    cf.flag                                                 AS campaign_flag,

    -- Cek apakah pembuat campaign pernah komplain
    CASE
        WHEN ut.user_id IS NOT NULL THEN 'YES'
        ELSE 'NO'
    END                                                     AS is_complain,

    -- Jumlah tiket komplain
    COALESCE(ut.no_of_complain, 0)                          AS no_of_complain,

    -- Persentase tiket high priority
    CASE
        WHEN ut.user_id IS NULL THEN NULL
        ELSE ut.pct_high_priority
    END                                                     AS percentage_of_high_priority_ticket

FROM `seal-da-test.kitabisa.campaign`      c
LEFT JOIN `seal-da-test.kitabisa.campaign_flag` cf ON cf.campaign_id = c.id
LEFT JOIN campaign_donation            cd ON cd.campaign_id = c.id
LEFT JOIN user_ticket                  ut ON ut.user_id     = c.user_id

ORDER BY total_donation_amount DESC
;