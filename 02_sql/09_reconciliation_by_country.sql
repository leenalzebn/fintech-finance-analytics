SELECT
    c.country_name,

    COUNT(*) AS exception_count,

    ROUND(
        SUM(
            ABS(
                t.actual_settlement_eur
                - t.expected_settlement_eur
            )
        ),
        2
    ) AS total_variance_eur,

    ROUND(
        AVG(
            ABS(
                t.actual_settlement_eur
                - t.expected_settlement_eur
            )
        ),
        2
    ) AS avg_variance_eur

FROM revolut_finance.transactions t

JOIN revolut_finance.customers c
    ON t.customer_id = c.customer_id

WHERE t.status = 'SETTLED'

AND ABS(
    t.actual_settlement_eur
    - t.expected_settlement_eur
) > 0.01

GROUP BY c.country_name

ORDER BY exception_count DESC;