-- --------------------------------------------------------
-- Database: vehicle
-- --------------------------------------------------------
DROP DATABASE IF EXISTS vehicle;
CREATE DATABASE vehicle;
USE vehicle;

-- --------------------------------------------------------
-- Table structure for table `owner`
-- --------------------------------------------------------
CREATE TABLE owner (
  owner_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  address VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------------------------------
-- Table structure for table `vehicle`
-- --------------------------------------------------------
CREATE TABLE vehicle (
  vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
  owner_id INT,
  vehicle_name VARCHAR(100) NOT NULL,
  vehicle_type VARCHAR(50),
  vehicle_number VARCHAR(50) UNIQUE,
  image_url VARCHAR(255),
  rent_per_day DECIMAL(10,2),
  availability BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (owner_id) REFERENCES owner(owner_id) ON DELETE CASCADE
);

-- --------------------------------------------------------
-- Table structure for table `users`
-- --------------------------------------------------------
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  address VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------------------------------
-- Table structure for table `booking`
-- --------------------------------------------------------
CREATE TABLE booking (
  booking_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  vehicle_id INT,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  total_amount DECIMAL(10,2),
  status ENUM('Pending', 'Approved', 'Rejected', 'Completed') DEFAULT 'Pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id) ON DELETE CASCADE
);

-- --------------------------------------------------------
-- Insert sample owners
-- --------------------------------------------------------
INSERT INTO owner (name, email, password, phone, address) VALUES
('Rahul Sharma', 'rahul@example.com', 'rahul@123', '9876543210', 'Pune, Maharashtra'),
('Priya Singh', 'priya@example.com', 'priya@123', '9988776655', 'Mumbai, Maharashtra');

-- --------------------------------------------------------
-- Insert sample users
-- --------------------------------------------------------
INSERT INTO users (name, email, password, phone, address) VALUES
('Amit Verma', 'amit@example.com', 'amit@123', '9090909090', 'Delhi, India'),
('Sneha Patil', 'sneha@example.com', 'sneha@123', '9191919191', 'Nagpur, Maharashtra');

-- --------------------------------------------------------
-- Insert sample vehicles
-- --------------------------------------------------------
INSERT INTO vehicle (owner_id, vehicle_name, vehicle_type, vehicle_number, rent_per_day, availability) VALUES
(1, 'Maruti Swift', 'Car', 'MH12AB1234', 1500.00, TRUE),
(1, 'Honda Activa', 'Scooter', 'MH12XY9876', 500.00, TRUE),
(2, 'Royal Enfield Classic', 'Bike', 'MH14QQ1111', 900.00, TRUE),
(2, 'Tata Nexon', 'Car', 'MH14WW2222', 2000.00, TRUE);

-- --------------------------------------------------------
-- Insert sample bookings
-- --------------------------------------------------------
INSERT INTO booking (user_id, vehicle_id, start_date, end_date, total_amount, status) VALUES
(1, 1, '2025-10-01', '2025-10-03', 3000.00, 'Completed'),
(2, 3, '2025-10-05', '2025-10-06', 1800.00, 'Pending');
