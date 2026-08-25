WITH monthly AS (
    SELECT
        report_month,
        payment_volume_eur,
        fee_revenue_eur,
        settlement_rate_pct
    FROM revolut_finance.vw_monthly_finance_kpis
)

SELECT
    report_month,
    payment_volume_eur,

    LAG(payment_volume_eur)
        OVER (ORDER BY report_month)
        AS previous_month_volume,

    ROUND(
        (
            payment_volume_eur
            - LAG(payment_volume_eur)
                OVER (ORDER BY report_month)
        )
        /
        NULLIF(
            LAG(payment_volume_eur)
                OVER (ORDER BY report_month),
            0
        ) * 100,
        2
    ) AS mom_growth_pct,

    fee_revenue_eur,
    settlement_rate_pct

FROM monthly

ORDER BY report_month;