-- Create database
CREATE DATABASE IF NOT EXISTS pustu_db;
USE pustu_db;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('patient', 'admin', 'petugas') NOT NULL DEFAULT 'patient',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Queues table
CREATE TABLE IF NOT EXISTS queues (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    queue_number INT NOT NULL,
    status ENUM('waiting', 'called', 'completed') NOT NULL DEFAULT 'waiting',
    arrival_time DATETIME NOT NULL,
    called_at DATETIME NULL,
    estimated_wait INT NOT NULL COMMENT 'Estimated wait time in minutes',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Feedbacks table
CREATE TABLE IF NOT EXISTS feedbacks (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Add indexes for better performance
CREATE INDEX idx_queue_status ON queues(status);
CREATE INDEX idx_queue_number ON queues(queue_number);
CREATE INDEX idx_user_email ON users(email);
