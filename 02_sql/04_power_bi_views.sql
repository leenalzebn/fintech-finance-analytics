SET search_path TO revolut_finance;

CREATE OR REPLACE VIEW vw_monthly_finance_kpis AS
SELECT DATE_TRUNC('month',transaction_date)::date month,
COUNT(*) transaction_count,
COUNT(*) FILTER(WHERE status='SETTLED') settled_count,
COUNT(*) FILTER(WHERE status='FAILED') failed_count,
ROUND(100.0*COUNT(*) FILTER(WHERE status='SETTLED')/NULLIF(COUNT(*),0),2) settlement_rate_pct,
ROUND(SUM(amount_eur) FILTER(WHERE status='SETTLED'),2) payment_volume_eur,
ROUND(SUM(fee_eur) FILTER(WHERE status='SETTLED'),2) fee_revenue_eur,
ROUND(AVG(amount_eur) FILTER(WHERE status='SETTLED'),2) avg_transaction_eur
FROM transactions GROUP BY 1;

CREATE OR REPLACE VIEW vw_reconciliation_daily AS
SELECT transaction_date,
COUNT(*) FILTER(WHERE status='SETTLED') settled_transactions,
ROUND(SUM(expected_settlement_eur) FILTER(WHERE status='SETTLED'),2) expected_settlement_eur,
ROUND(SUM(actual_settlement_eur) FILTER(WHERE status='SETTLED'),2) actual_settlement_eur,
ROUND(SUM(actual_settlement_eur-expected_settlement_eur) FILTER(WHERE status='SETTLED'),2) net_variance_eur,
COUNT(*) FILTER(WHERE status='SETTLED' AND ABS(actual_settlement_eur-expected_settlement_eur)>.01) exception_count
FROM transactions GROUP BY transaction_date;

CREATE OR REPLACE VIEW vw_country_performance AS
SELECT c.country_code,c.country_name,COUNT(DISTINCT c.customer_id) customers,COUNT(t.transaction_id) transaction_count,
ROUND(SUM(t.amount_eur) FILTER(WHERE t.status='SETTLED'),2) payment_volume_eur,
ROUND(SUM(t.fee_eur) FILTER(WHERE t.status='SETTLED'),2) fee_revenue_eur,
ROUND(100.0*COUNT(*) FILTER(WHERE t.status='FAILED')/NULLIF(COUNT(*),0),2) failure_rate_pct
FROM customers c LEFT JOIN transactions t ON t.customer_id=c.customer_id
GROUP BY c.country_code,c.country_name;

CREATE OR REPLACE VIEW vw_customer_value AS
SELECT c.customer_id,c.country_code,c.plan_type,c.risk_rating,COUNT(t.transaction_id) transaction_count,
ROUND(SUM(t.amount_eur) FILTER(WHERE t.status='SETTLED'),2) lifetime_volume_eur,
ROUND(SUM(t.fee_eur) FILTER(WHERE t.status='SETTLED'),2) lifetime_fee_revenue_eur,
MAX(t.transaction_date) last_transaction_date
FROM customers c LEFT JOIN transactions t ON t.customer_id=c.customer_id
GROUP BY c.customer_id,c.country_code,c.plan_type,c.risk_rating;
