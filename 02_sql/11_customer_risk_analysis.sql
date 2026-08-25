SELECT
    c.risk_rating,

    COUNT(DISTINCT c.customer_id) AS customers,

    COUNT(t.transaction_id) AS transactions,

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
        SUM(t.amount_eur) FILTER (
            WHERE t.status = 'SETTLED'
        )
        /
        SUM(
            SUM(t.amount_eur) FILTER (
                WHERE t.status = 'SETTLED'
            )
        ) OVER (),
        2
    ) AS volume_share_pct

FROM revolut_finance.customers c

JOIN revolut_finance.transactions t
    ON c.customer_id = t.customer_id

GROUP BY c.risk_rating

ORDER BY payment_volume_eur DESC;