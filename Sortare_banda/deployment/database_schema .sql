CREATE DATABASE IF NOT EXISTS sorting_system;

USE sorting_system;

CREATE TABLE IF NOT EXISTS objects_processed (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    object_type ENUM('Plastic', 'Metal', 'Glass') NOT NULL,
    predicted_type ENUM('Plastic', 'Metal', 'Glass') NOT NULL,
    confidence DECIMAL(5,2) NOT NULL,
    color_r INT NOT NULL,
    color_g INT NOT NULL,
    color_b INT NOT NULL,
    length_mm DECIMAL(8,2) NOT NULL,
    width_mm DECIMAL(8,2) NOT NULL,
    height_mm DECIMAL(8,2) NOT NULL,
    processing_time_ms INT NOT NULL,
    belt_speed_ms DECIMAL(5,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS system_stats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    total_objects INT NOT NULL,
    plastic_count INT NOT NULL,
    metal_count INT NOT NULL,
    glass_count INT NOT NULL,
    accuracy_percent DECIMAL(5,2) NOT NULL,
    avg_processing_time_ms DECIMAL(8,2) NOT NULL
);
