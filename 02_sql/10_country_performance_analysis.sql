SELECT
    country_name,
    customers,
    transaction_count,
    payment_volume_eur,
    fee_revenue_eur,
    failure_rate_pct

FROM revolut_finance.vw_country_performance

ORDER BY payment_volume_eur DESC;