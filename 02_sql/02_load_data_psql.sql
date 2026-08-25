-- Run in psql. Replace C:/PATH/TO/PROJECT.
\copy revolut_finance.customers FROM 'C:/PATH/TO/PROJECT/01_data/customers.csv' CSV HEADER;
\copy revolut_finance.accounts FROM 'C:/PATH/TO/PROJECT/01_data/accounts.csv' CSV HEADER;
\copy revolut_finance.cards FROM 'C:/PATH/TO/PROJECT/01_data/cards.csv' CSV HEADER;
\copy revolut_finance.merchants FROM 'C:/PATH/TO/PROJECT/01_data/merchants.csv' CSV HEADER;
\copy revolut_finance.fx_rates FROM 'C:/PATH/TO/PROJECT/01_data/fx_rates.csv' CSV HEADER;
\copy revolut_finance.transactions FROM 'C:/PATH/TO/PROJECT/01_data/transactions.csv' CSV HEADER;
\copy revolut_finance.ledger_entries FROM 'C:/PATH/TO/PROJECT/01_data/ledger_entries.csv' CSV HEADER;
\copy revolut_finance.chargebacks FROM 'C:/PATH/TO/PROJECT/01_data/chargebacks.csv' CSV HEADER;
ANALYZE revolut_finance.transactions;
