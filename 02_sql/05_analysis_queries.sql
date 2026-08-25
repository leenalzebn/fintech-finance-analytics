SET search_path TO revolut_finance;

-- Executive monthly KPIs
SELECT * FROM vw_monthly_finance_kpis ORDER BY month;

-- Reconciliation exceptions
SELECT transaction_id,transaction_date,account_id,expected_settlement_eur,actual_settlement_eur,
ROUND(actual_settlement_eur-expected_settlement_eur,2) variance_eur
FROM transactions
WHERE status='SETTLED' AND ABS(actual_settlement_eur-expected_settlement_eur)>.01
ORDER BY ABS(actual_settlement_eur-expected_settlement_eur) DESC;

-- Failure root cause
SELECT failure_reason,channel,COUNT(*) failed_transactions,ROUND(SUM(amount_eur),2) failed_volume_eur
FROM transactions WHERE status='FAILED'
GROUP BY failure_reason,channel ORDER BY failed_transactions DESC;

-- Plan revenue
SELECT c.plan_type,COUNT(DISTINCT c.customer_id) customers,
ROUND(SUM(t.amount_eur) FILTER(WHERE t.status='SETTLED'),2) settled_volume_eur,
ROUND(SUM(t.fee_eur) FILTER(WHERE t.status='SETTLED'),2) fee_revenue_eur
FROM customers c JOIN transactions t ON t.customer_id=c.customer_id
GROUP BY c.plan_type ORDER BY fee_revenue_eur DESC;

-- Chargeback rate by merchant category
SELECT m.merchant_category,
COUNT(DISTINCT t.transaction_id) FILTER(WHERE t.status='SETTLED') settled_card_tx,
COUNT(DISTINCT cb.chargeback_id) chargebacks,
ROUND(100.0*COUNT(DISTINCT cb.chargeback_id)/NULLIF(COUNT(DISTINCT t.transaction_id) FILTER(WHERE t.status='SETTLED'),0),2) chargeback_rate_pct
FROM transactions t JOIN merchants m ON m.merchant_id=t.merchant_id
LEFT JOIN chargebacks cb ON cb.transaction_id=t.transaction_id
WHERE t.transaction_type='card_payment'
GROUP BY m.merchant_category ORDER BY chargeback_rate_pct DESC;

-- MoM volume growth
WITH m AS (SELECT * FROM vw_monthly_finance_kpis)
SELECT month,payment_volume_eur,LAG(payment_volume_eur) OVER(ORDER BY month) previous_month_volume,
ROUND(100.0*(payment_volume_eur-LAG(payment_volume_eur) OVER(ORDER BY month))/NULLIF(LAG(payment_volume_eur) OVER(ORDER BY month),0),2) mom_growth_pct
FROM m ORDER BY month;

-- High-risk customers
SELECT * FROM vw_customer_value WHERE risk_rating='HIGH'
ORDER BY lifetime_volume_eur DESC NULLS LAST LIMIT 100;
