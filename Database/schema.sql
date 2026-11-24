-- 1. CUSTOMER TABLE
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- 2. ACCOUNT TABLE
CREATE TABLE account (
    account_id VARCHAR(20) PRIMARY KEY,
    customer_id INT NOT NULL,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    account_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_account_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id),

    CONSTRAINT chk_account_balance
        CHECK (balance >= 0),

    CONSTRAINT chk_account_status
        CHECK (account_status IN ('ACTIVE', 'INACTIVE'))
) ENGINE=InnoDB;


-- 3. TRANSACTION TABLE
CREATE TABLE bank_transaction (
    transaction_id VARCHAR(50) PRIMARY KEY,
    transaction_type VARCHAR(20) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    source_account_id VARCHAR(20),
    destination_account_id VARCHAR(20),
    transaction_status VARCHAR(20) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_txn_source
        FOREIGN KEY (source_account_id)
        REFERENCES account(account_id),

    CONSTRAINT fk_txn_destination
        FOREIGN KEY (destination_account_id)
        REFERENCES account(account_id),

    CONSTRAINT chk_txn_amount
        CHECK (amount > 0),

    CONSTRAINT chk_txn_type
        CHECK (transaction_type IN ('DEPOSIT', 'WITHDRAWAL', 'TRANSFER')),

    CONSTRAINT chk_txn_status
        CHECK (transaction_status IN ('SUCCESS', 'FAILED', 'REJECTED')),

    INDEX idx_txn_source (source_account_id),
    INDEX idx_txn_destination (destination_account_id),
    INDEX idx_txn_created (created_at)
) ENGINE=InnoDB;


-- 4. TRANSACTION AUDIT TABLE
CREATE TABLE transaction_audit (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(50) NOT NULL,
    event_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    thread_name VARCHAR(100),
    operation VARCHAR(50),
    result VARCHAR(30),
    duration_ms BIGINT,
    details TEXT,

    CONSTRAINT fk_audit_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES bank_transaction(transaction_id),

    INDEX idx_audit_transaction (transaction_id)
) ENGINE=InnoDB;


-- 5. FAILED TRANSACTION TABLE
CREATE TABLE failed_transaction (
    failure_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(50) NOT NULL,
    error_category VARCHAR(100) NOT NULL,
    failure_reason VARCHAR(500),
    event_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_failed_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES bank_transaction(transaction_id),

    UNIQUE KEY uq_failed_transaction (transaction_id),
    INDEX idx_failure_category (error_category)
) ENGINE=InnoDB;