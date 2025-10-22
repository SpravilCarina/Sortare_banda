CREATE TABLE IF NOT EXISTS object_classification (
  id INT PRIMARY KEY AUTO_INCREMENT,
  timestamp DATETIME,
  object_type VARCHAR(10),
  confidence FLOAT,
  features TEXT
);
