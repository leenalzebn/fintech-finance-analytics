DROP SCHEMA IF EXISTS revolut_finance CASCADE;
CREATE SCHEMA revolut_finance;
SET search_path TO revolut_finance;

CREATE TABLE customers (customer_id varchar(10) PRIMARY KEY,country_code char(2) NOT NULL,country_name varchar(80) NOT NULL,region varchar(40) NOT NULL,signup_date date NOT NULL,age_band varchar(10),risk_rating varchar(10) NOT NULL,kyc_status varchar(12) NOT NULL,plan_type varchar(12) NOT NULL);
CREATE TABLE accounts (account_id varchar(12) PRIMARY KEY,customer_id varchar(10) NOT NULL REFERENCES customers(customer_id),currency char(3) NOT NULL,account_type varchar(20) NOT NULL,opened_date date NOT NULL,account_status varchar(10) NOT NULL,opening_balance numeric(18,2) NOT NULL DEFAULT 0);
CREATE TABLE cards (card_id varchar(14) PRIMARY KEY,customer_id varchar(10) NOT NULL REFERENCES customers(customer_id),card_type varchar(10) NOT NULL,card_status varchar(10) NOT NULL,issued_date date NOT NULL);
CREATE TABLE merchants (merchant_id varchar(10) PRIMARY KEY,merchant_name varchar(80) NOT NULL,mcc varchar(4) NOT NULL,merchant_category varchar(50) NOT NULL,country_code char(2) NOT NULL,country_name varchar(80) NOT NULL);
CREATE TABLE fx_rates (rate_date date NOT NULL,currency char(3) NOT NULL,to_eur_rate numeric(18,6) NOT NULL,PRIMARY KEY(rate_date,currency));
CREATE TABLE transactions (transaction_id varchar(12) PRIMARY KEY,customer_id varchar(10) NOT NULL REFERENCES customers(customer_id),account_id varchar(12) NOT NULL REFERENCES accounts(account_id),merchant_id varchar(10) REFERENCES merchants(merchant_id),transaction_date date NOT NULL,transaction_type varchar(25) NOT NULL,channel varchar(25) NOT NULL,direction varchar(6) NOT NULL,status varchar(10) NOT NULL,currency char(3) NOT NULL,amount numeric(18,2) NOT NULL,amount_eur numeric(18,2) NOT NULL,fee_eur numeric(18,2) NOT NULL,expected_settlement_eur numeric(18,2) NOT NULL,actual_settlement_eur numeric(18,2) NOT NULL,failure_reason varchar(30));
CREATE TABLE ledger_entries (ledger_entry_id varchar(14) PRIMARY KEY,transaction_id varchar(12) NOT NULL REFERENCES transactions(transaction_id),entry_date date NOT NULL,account_id varchar(12) NOT NULL REFERENCES accounts(account_id),ledger_account varchar(30) NOT NULL,amount_eur numeric(18,2) NOT NULL,currency char(3) NOT NULL);
CREATE TABLE chargebacks (chargeback_id varchar(12) PRIMARY KEY,transaction_id varchar(12) NOT NULL REFERENCES transactions(transaction_id),customer_id varchar(10) NOT NULL REFERENCES customers(customer_id),merchant_id varchar(10) NOT NULL REFERENCES merchants(merchant_id),chargeback_date date NOT NULL,chargeback_amount_eur numeric(18,2) NOT NULL,chargeback_status varchar(8) NOT NULL);
CREATE INDEX idx_tx_date ON transactions(transaction_date);
CREATE INDEX idx_tx_customer ON transactions(customer_id);
CREATE INDEX idx_tx_account ON transactions(account_id);
CREATE INDEX idx_tx_status ON transactions(status);
CREATE INDEX idx_ledger_tx ON ledger_entries(transaction_id);
