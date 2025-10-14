-- Migration: add vehicle_model and status fields
USE vehicle;

ALTER TABLE vehicle
  ADD COLUMN vehicle_model VARCHAR(100) NULL AFTER vehicle_name,
  ADD COLUMN status ENUM('Available','On Trip','Maintenance') NOT NULL DEFAULT 'Available' AFTER availability;

-- Backfill existing rows
UPDATE vehicle SET status = CASE WHEN availability = 1 THEN 'Available' ELSE 'On Trip' END WHERE status IS NULL;
