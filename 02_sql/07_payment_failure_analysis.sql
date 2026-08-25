SELECT
    failure_reason,
    COUNT(*) AS failed_transactions,
    ROUND(SUM(amount_eur), 2) AS failed_volume_eur,
    ROUND(AVG(amount_eur), 2) AS avg_failed_transaction_eur,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_failures

FROM revolut_finance.transactions

WHERE status = 'FAILED'

GROUP BY failure_reason

ORDER BY failed_transactions DESC;