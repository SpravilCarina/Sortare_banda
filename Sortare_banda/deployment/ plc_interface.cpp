// PLC Interface for Intelligent Sorting System
// Modbus RTU communication example with Arduino

#include <ModbusRTU.h>
#include <SoftwareSerial.h>

// Crearea obiectului Modbus RTU, folosind SoftwareSerial pe pini specifici
SoftwareSerial mySerial(2, 3); // RX, TX pins
ModbusRTU mb;

#define REG_BELT_SPEED      100
#define REG_SORT_COMMAND    101
#define REG_OBJECT_CLASS    102
#define REG_SYSTEM_STATUS   103
#define REG_ERROR_CODE      104

// Variabile pentru stocarea comenzilor și statusului
uint16_t belt_speed_setpoint = 0;
uint16_t sort_command = 0;
uint16_t last_classified_object = 0;
uint16_t system_status = 1;
uint16_t error_code = 0;

void setup() {
  mySerial.begin(9600);
  mb.begin(&mySerial);
  mb.slave(1);  // Adresa slave Modbus
  Serial.begin(115200);
  Serial.println("PLC Interface started");
}

void loop() {
  mb.task();

  // Citirea comenzilor Modbus din registrele holding
  belt_speed_setpoint = mb.Hreg(REG_BELT_SPEED);
  sort_command = mb.Hreg(REG_SORT_COMMAND);
  
  // Procesarea comenzilor primite
  process_commands();

  // Actualizarea registrelor Modbus cu starea curenta
  mb.Hreg(REG_SYSTEM_STATUS, system_status);
  mb.Hreg(REG_OBJECT_CLASS, last_classified_object);
  mb.Hreg(REG_ERROR_CODE, error_code);
}

// Funcție simplă pentru procesarea comenzilor primite prin Modbus
void process_commands() {
  // Exemplu: schimbă viteza benzii în funcție de comanda primită
  switch (sort_command) {
    case 0:
      stop_belt();
      system_status = 0;
      break;
    case 1:
      start_belt(belt_speed_setpoint);
      system_status = 1;
      break;
    default:
      error_code = 1; // Comandă invalidă
      system_status = 0;
      break;
  }
  
  // Exemplu actualizare ultim obiect clasificat
  last_classified_object = read_last_classified_object_from_sensor();
}

void start_belt(uint16_t speed) {
  // Aici se va pune codul hardware pentru a seta viteza benzii
  Serial.print("Starting belt with speed: ");
  Serial.println(speed);
}

void stop_belt() {
  // Aici se va opri banda transportoare
  Serial.println("Stopping belt");
}

// Funcție fictivă pentru demonstrație - trebuie înlocuită cu citirea reală
uint16_t read_last_classified_object_from_sensor() {
  // Returnează o valoare simulată (ex: 1=Plastic, 2=Metal, 3=Sticlă)
  return random(1, 4);
}
