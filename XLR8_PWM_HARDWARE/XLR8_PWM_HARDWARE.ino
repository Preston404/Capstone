#include "XLR8_ESC.h"

char base_pwm = 0x28; // 40

void setup() {
  // put your setup code here, to run once:
  delay(10000);
}

void loop() {
  // put your main code here, to run repeatedly:

  char i = 0;
  for (i = 0; i<15; i++){
      XLR8_ESC.set_pwm(base_pwm + i); 
      delay(500);
  }
  for (i = 15; i>0; i--){
      XLR8_ESC.set_pwm(base_pwm + i); 
      delay(500);
  }
}
