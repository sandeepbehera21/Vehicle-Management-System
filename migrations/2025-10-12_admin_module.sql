-- Admin Module Database Schema
USE vehicle;

-- Create admin table
CREATE TABLE IF NOT EXISTS admin (
  admin_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(100) NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create maintenance_history table
CREATE TABLE IF NOT EXISTS maintenance_history (
  maintenance_id INT AUTO_INCREMENT PRIMARY KEY,
  vehicle_id INT NOT NULL,
  maintenance_type VARCHAR(100) NOT NULL,
  description TEXT,
  cost DECIMAL(10,2) DEFAULT 0.00,
  maintenance_date DATE NOT NULL,
  performed_by VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id) ON DELETE CASCADE
);

-- Add approval status to users and owners
ALTER TABLE users ADD COLUMN IF NOT EXISTS status ENUM('Active', 'Pending', 'Suspended') DEFAULT 'Active';
ALTER TABLE owner ADD COLUMN IF NOT EXISTS status ENUM('Active', 'Pending', 'Suspended') DEFAULT 'Active';

-- Insert default admin user (password: admin123)
INSERT IGNORE INTO admin (username, password, email, full_name) VALUES 
('admin', '$2a$10$9/LMhg3bHzgVjYG3Hf.qJO7VL.F7D8bQ4qH5hH6rD3nL8vE2kT4gK', 'admin@vehicle.com', 'System Administrator');

-- Insert sample maintenance records
INSERT IGNORE INTO maintenance_history (vehicle_id, maintenance_type, description, cost, maintenance_date, performed_by) VALUES
(1, 'Oil Change', 'Regular engine oil change and filter replacement', 2500.00, '2025-10-01', 'Service Center A'),
(2, 'Brake Service', 'Brake pad replacement and brake fluid change', 3000.00, '2025-10-05', 'Service Center B');