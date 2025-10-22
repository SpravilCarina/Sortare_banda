#!/usr/bin/env python3
"""
Integracja sistem de sortare inteligenta pentru comunicare cu sistemul MATLAB/Simulink.
Interfață Python pentru citire/scriere date și control via API.
"""

import requests
import json
import sqlite3
from datetime import datetime

class SortingSystemInterface:
    def __init__(self, config_file='config.json'):
        # Încarcă configurația (adresa serverului MATLAB)
        with open(config_file, 'r') as f:
            self.config = json.load(f)
        # Inițializează conexiunea la baza de date
        self.conn = sqlite3.connect('data/sorting_system.db')
        self.create_tables()

    def create_tables(self):
        cursor = self.conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS classifications (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT,
                object_type TEXT,
                predicted_type TEXT,
                confidence REAL,
                color_r INTEGER,
                color_g INTEGER,
                color_b INTEGER,
                length_mm REAL,
                width_mm REAL,
                height_mm REAL,
                processing_time_ms INTEGER,
                belt_speed_ms REAL
            );
        ''')
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS system_stats (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT,
                total_objects INTEGER,
                plastic_count INTEGER,
                metal_count INTEGER,
                glass_count INTEGER,
                accuracy_percent REAL,
                avg_processing_time_ms REAL
            );
        ''')
        self.conn.commit()

    def classify_object(self, features):
        """Trimite caracteristicile obiectului către API-ul MATLAB și primește clasificarea."""
        url = self.config['matlab_server']
        payload = {'features': features.tolist()}
        try:
            response = requests.post(f'{url}/classify', json=payload, timeout=1.0)
            if response.status_code == 200:
                result = response.json()
                self.log_classification(result)
                return result
            else:
                print(f'Erroare: răspuns cu cod {response.status_code}')
        except Exception as e:
            print(f'Exceptie: {e}')
        return None

    def log_classification(self, result):
        """Înregistrează rezultatul clasificării în baza de date."""
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT INTO classifications (
                timestamp, object_type, predicted_type, confidence,
                color_r, color_g, color_b,
                length_mm, width_mm, height_mm,
                processing_time_ms, belt_speed_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            datetime.now().isoformat(),
            result.get('object_type'),
            result.get('predicted_type'),
            result.get('confidence'),
            result.get('features')[0],
            result.get('features')[1],
            result.get('features')[2],
            result.get('features')[3],
            result.get('features')[4],
            result.get('features')[5],
            result.get('processing_time_ms'),
            result.get('belt_speed_ms')
        ))
        self.conn.commit()

    def close(self):
        self.conn.close()

# Exemplu de utilizare
if __name__ == '__main__':
    api = SortingSystemInterface()
    test_features = [150, 120, 100, 0.15, 0.12, 0.08]  # Exemplu de caracteristici
    result = api.classify_object(test_features)
    print(f'Rezultatul clasificarii: {result}')
    api.close()
