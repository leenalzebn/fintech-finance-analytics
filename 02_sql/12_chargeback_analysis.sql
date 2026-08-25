SELECT
    m.merchant_category,

    COUNT(DISTINCT t.transaction_id)
        FILTER (WHERE t.status = 'SETTLED')
        AS settled_card_transactions,

    COUNT(DISTINCT cb.chargeback_id)
        AS chargebacks,

    ROUND(
        SUM(cb.chargeback_amount_eur),
        2
    ) AS chargeback_amount_eur,

    ROUND(
        100.0 *
        COUNT(DISTINCT cb.chargeback_id)
        /
        NULLIF(
            COUNT(DISTINCT t.transaction_id)
                FILTER (WHERE t.status = 'SETTLED'),
            0
        ),
        2
    ) AS chargeback_rate_pct

FROM revolut_finance.transactions t

JOIN revolut_finance.merchants m
    ON t.merchant_id = m.merchant_id

LEFT JOIN revolut_finance.chargebacks cb
    ON t.transaction_id = cb.transaction_id

WHERE t.transaction_type = 'card_payment'

GROUP BY m.merchant_category

ORDER BY chargeback_rate_pct DESC;