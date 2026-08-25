SELECT
    COUNT(*) AS reconciliation_exceptions,

    ROUND(
        SUM(
            ABS(
                actual_settlement_eur
                - expected_settlement_eur
            )
        ),
        2
    ) AS total_absolute_variance_eur,

    ROUND(
        AVG(
            ABS(
                actual_settlement_eur
                - expected_settlement_eur
            )
        ),
        2
    ) AS avg_variance_eur,

    ROUND(
        MAX(
            ABS(
                actual_settlement_eur
                - expected_settlement_eur
            )
        ),
        2
    ) AS largest_variance_eur

FROM revolut_finance.transactions

WHERE status = 'SETTLED'

AND ABS(
    actual_settlement_eur
    - expected_settlement_eur
) > 0.01;