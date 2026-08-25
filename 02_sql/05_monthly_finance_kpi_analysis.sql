SET search_path TO revolut_finance;

-- ==========================================
-- 1. MONTHLY FINANCE KPIs
-- ==========================================

CREATE OR REPLACE VIEW vw_monthly_finance_kpis AS
SELECT
    DATE_TRUNC('month', transaction_date)::date AS report_month,

    COUNT(*) AS transaction_count,

    COUNT(*) FILTER (
        WHERE status = 'SETTLED'
    ) AS settled_count,

    COUNT(*) FILTER (
        WHERE status = 'FAILED'
    ) AS failed_count,

    ROUND(
        100.0 *
        COUNT(*) FILTER (WHERE status = 'SETTLED')
        / NULLIF(COUNT(*), 0),
        2
    ) AS settlement_rate_pct,

    ROUND(
        SUM(amount_eur) FILTER (
            WHERE status = 'SETTLED'
        ),
        2
    ) AS payment_volume_eur,

    ROUND(
        SUM(fee_eur) FILTER (
            WHERE status = 'SETTLED'
        ),
        2
    ) AS fee_revenue_eur,

    ROUND(
        AVG(amount_eur) FILTER (
            WHERE status = 'SETTLED'
        ),
        2
    ) AS avg_transaction_eur

FROM transactions

GROUP BY
    DATE_TRUNC('month', transaction_date)::date;


-- ==========================================
-- 2. DAILY RECONCILIATION
-- ==========================================

CREATE OR REPLACE VIEW vw_reconciliation_daily AS
SELECT
    transaction_date,

    COUNT(*) FILTER (
        WHERE status = 'SETTLED'
    ) AS settled_transactions,

    ROUND(
        SUM(expected_settlement_eur) FILTER (
            WHERE status = 'SETTLED'
        ),
        2
    ) AS expected_settlement_eur,

    ROUND(
        SUM(actual_settlement_eur) FILTER (
            WHERE status = 'SETTLED'
        ),
        2
    ) AS actual_settlement_eur,

    ROUND(
        SUM(
            actual_settlement_eur
            - expected_settlement_eur
        ) FILTER (
            WHERE status = 'SETTLED'
        ),
        2
    ) AS net_variance_eur,

    COUNT(*) FILTER (
        WHERE status = 'SETTLED'
        AND ABS(
            actual_settlement_eur
            - expected_settlement_eur
        ) > 0.01
    ) AS exception_count

FROM transactions

GROUP BY transaction_date;


-- ==========================================
-- 3. COUNTRY PERFORMANCE
-- ==========================================

CREATE OR REPLACE VIEW vw_country_performance AS
SELECT
    c.country_code,
    c.country_name,

    COUNT(DISTINCT c.customer_id) AS customers,

    COUNT(t.transaction_id) AS transaction_count,

    ROUND(
        SUM(t.amount_eur) FILTER (
            WHERE t.status = 'SETTLED'
        ),
        2
    ) AS payment_volume_eur,

    ROUND(
        SUM(t.fee_eur) FILTER (
            WHERE t.status = 'SETTLED'
        ),
        2
    ) AS fee_revenue_eur,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE t.status = 'FAILED'
        )
        / NULLIF(COUNT(t.transaction_id), 0),
        2
    ) AS failure_rate_pct

FROM customers c

LEFT JOIN transactions t
    ON t.customer_id = c.customer_id

GROUP BY
    c.country_code,
    c.country_name;


-- ==========================================
-- 4. CUSTOMER VALUE
-- ==========================================

CREATE OR REPLACE VIEW vw_customer_value AS
SELECT
    c.customer_id,
    c.country_code,
    c.plan_type,
    c.risk_rating,

    COUNT(t.transaction_id) AS transaction_count,

    ROUND(
        SUM(t.amount_eur) FILTER (
            WHERE t.status = 'SETTLED'
        ),
        2
    ) AS lifetime_volume_eur,

    ROUND(
        SUM(t.fee_eur) FILTER (
            WHERE t.status = 'SETTLED'
        ),
        2
    ) AS lifetime_fee_revenue_eur,

    MAX(t.transaction_date) AS last_transaction_date

FROM customers c

LEFT JOIN transactions t
    ON t.customer_id = c.customer_id

GROUP BY
    c.customer_id,
    c.country_code,
    c.plan_type,
    c.risk_rating;
	SELECT *
FROM revolut_finance.vw_monthly_finance_kpis
ORDER BY report_month;