SET search_path TO revolut_finance;
SELECT 'customers' table_name,COUNT(*) row_count FROM customers
UNION ALL SELECT 'accounts',COUNT(*) FROM accounts
UNION ALL SELECT 'transactions',COUNT(*) FROM transactions
UNION ALL SELECT 'ledger_entries',COUNT(*) FROM ledger_entries
UNION ALL SELECT 'chargebacks',COUNT(*) FROM chargebacks;

SELECT transaction_id,COUNT(*) FROM transactions GROUP BY transaction_id HAVING COUNT(*)>1;

SELECT COUNT(*) AS orphan_transactions
FROM transactions t LEFT JOIN accounts a ON a.account_id=t.account_id
WHERE a.account_id IS NULL;

SELECT
COUNT(*) FILTER(WHERE status='SETTLED') AS settled_transactions,
COUNT(*) FILTER(WHERE status='SETTLED' AND ABS(actual_settlement_eur-expected_settlement_eur)>.01) AS reconciliation_exceptions,
ROUND(100.0*COUNT(*) FILTER(WHERE status='SETTLED' AND ABS(actual_settlement_eur-expected_settlement_eur)>.01)/NULLIF(COUNT(*) FILTER(WHERE status='SETTLED'),0),3) AS exception_rate_pct
FROM transactions;

SELECT COUNT(*) AS ledger_orphans
FROM ledger_entries l LEFT JOIN transactions t ON t.transaction_id=l.transaction_id
WHERE t.transaction_id IS NULL;
