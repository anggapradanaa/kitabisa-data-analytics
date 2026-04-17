-- SOAL 4: User acquisition analysis for behavioral insights

-- Tren user baru per bulan: Melihat pola pertumbuhan registrasi user dari waktu ke waktu
SELECT
    FORMAT_DATE('%Y-%m', DATE(TIMESTAMP_SECONDS(created))) AS year_month,
    COUNT(id)                                               AS total_new_user,
    COUNTIF(type = 'PERSONAL')                             AS new_personal_user,
    COUNTIF(type = 'ORGANIZATION')                         AS new_org_user
FROM `seal-da-test.kitabisa.user`
GROUP BY 1
ORDER BY 1
;

-- Distribusi user baru berdasarkan provinsi: Melihat sebaran geografis user untuk strategi akuisisi regional
SELECT
    province,
    COUNT(id)                                      AS total_user,
    ROUND(COUNT(id) * 100.0 / SUM(COUNT(id)) OVER(), 2) AS pct_of_total
FROM `seal-da-test.kitabisa.user`
GROUP BY province
ORDER BY total_user DESC
LIMIT 20
;

-- Konversi user baru ke donasi pertama: Berapa lama user baru sebelum melakukan donasi pertama kali dan Indikator efektivitas onboarding
WITH first_donation AS (
    SELECT
        user_id,
        MIN(DATE(TIMESTAMP_SECONDS(created))) AS first_donation_date
    FROM `seal-da-test.kitabisa.donation`
    WHERE status = 4  
    GROUP BY user_id
)

SELECT
    u.id                                                            AS user_id,
    DATE(TIMESTAMP_SECONDS(u.created))                             AS register_date,
    fd.first_donation_date,
    DATE_DIFF(fd.first_donation_date,
              DATE(TIMESTAMP_SECONDS(u.created)), DAY)             AS days_to_first_donation,
    CASE
        WHEN fd.user_id IS NULL THEN 'Never Donated'
        WHEN DATE_DIFF(fd.first_donation_date,
                       DATE(TIMESTAMP_SECONDS(u.created)), DAY) = 0 THEN 'Same Day'
        WHEN DATE_DIFF(fd.first_donation_date,
                       DATE(TIMESTAMP_SECONDS(u.created)), DAY) <= 7 THEN 'Within 1 Week'
        WHEN DATE_DIFF(fd.first_donation_date,
                       DATE(TIMESTAMP_SECONDS(u.created)), DAY) <= 30 THEN 'Within 1 Month'
        ELSE 'More Than 1 Month'
    END                                                            AS conversion_bucket
FROM `seal-da-test.kitabisa.user`        u
LEFT JOIN first_donation         fd ON fd.user_id = u.id
ORDER BY register_date DESC
;

-- Platform donasi pertama user baru: Dari platform mana (android/ios/web/pwa) user baru pertama donasi
WITH first_donation AS (
    SELECT
        user_id,
        platform,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created ASC) AS rn
    FROM `seal-da-test.kitabisa.donation`
    WHERE status = 4
)

SELECT
    platform,
    COUNT(user_id)                                          AS total_first_time_donor,
    ROUND(COUNT(user_id) * 100.0 / SUM(COUNT(user_id)) OVER(), 2) AS pct_share
FROM first_donation
WHERE rn = 1
GROUP BY platform
ORDER BY total_first_time_donor DESC
;

-- Category campaign yang paling banyak menarik donasi dari user yang baru pertama kali donasi
-- Untuk mengetahui kategori campaign mana yang efektif mengkonversi user baru
WITH first_donation AS (
    SELECT
        user_id,
        campaign_id,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created ASC) AS rn
    FROM `seal-da-test.kitabisa.donation`
    WHERE status = 4
)

SELECT
    c.category,
    COUNT(fd.user_id)                                               AS total_first_time_donor,
    ROUND(COUNT(fd.user_id) * 100.0 / SUM(COUNT(fd.user_id)) OVER(), 2) AS pct_share,
    SUM(d.amount)                                                   AS total_donation_amount
FROM first_donation                    fd
JOIN `seal-da-test.kitabisa.campaign`           c  ON c.id = fd.campaign_id
JOIN `seal-da-test.kitabisa.donation`           d  ON d.user_id = fd.user_id
                                          AND d.campaign_id = fd.campaign_id
                                          AND d.status = 4
WHERE fd.rn = 1
GROUP BY c.category
ORDER BY total_first_time_donor DESC
;

-- Retensi - user baru yang donasi lebih dari sekali: Mengukur loyalitas user setelah akuisisi pertama
WITH user_donation_count AS (
    SELECT
        user_id,
        COUNT(id)   AS total_donations,
        SUM(amount) AS total_amount
    FROM `seal-da-test.kitabisa.donation`
    WHERE status = 4
    GROUP BY user_id
)

SELECT
    CASE
        WHEN total_donations = 1 THEN '1x (One-time)'
        WHEN total_donations = 2 THEN '2x'
        WHEN total_donations BETWEEN 3 AND 5 THEN '3-5x'
        ELSE '6x+'
    END                     AS donation_frequency_bucket,
    COUNT(user_id)           AS total_user,
    ROUND(COUNT(user_id) * 100.0 / SUM(COUNT(user_id)) OVER(), 2) AS pct_share,
    ROUND(AVG(total_amount), 0) AS avg_total_amount_per_user
FROM user_donation_count
GROUP BY 1
ORDER BY total_user DESC
;