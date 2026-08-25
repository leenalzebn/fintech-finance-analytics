# Power BI Data Model
Import customers, accounts, transactions, merchants, chargebacks and vw_reconciliation_daily from PostgreSQL.

Relationships:
- customers[customer_id] 1:* accounts[customer_id]
- customers[customer_id] 1:* transactions[customer_id]
- accounts[account_id] 1:* transactions[account_id]
- merchants[merchant_id] 1:* transactions[merchant_id]
- transactions[transaction_id] 1:* chargebacks[transaction_id]

Create a Date table and relate Date[Date] to transactions[transaction_date].
Use transactions as the primary fact table.
