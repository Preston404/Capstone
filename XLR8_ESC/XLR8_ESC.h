/*
 * Copyright (c) 2016 Alorium Technology
 * Bryan Craker, info@aloriumtech.com
 *
 * ESC Library for XLR8.
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of either the GNU General Public License version 2
 * or the GNU Lesser General Public License version 2.1, both as
 * published by the Free Software Foundation.
 */

#ifndef _XLR8_ESC_H_INCLUDED
#define _XLR8_ESC_H_INCLUDED

#include <Arduino.h>

/*
#define XLR8_ESC_CTRL _SFR_MEM8(0xE0)
#define XLR8_ESC_SEED _SFR_MEM8(0xE1)
#define XLR8_ESC_DATA _SFR_MEM8(0xE2)
*/

#define XLR8_ESC_PWM _SFR_MEM8(0xE1)

class XLR8_ESCClass {

public:

  XLR8_ESCClass() {}

  ~XLR8_ESCClass() {}
  void __attribute__ ((noinline)) set_pwm(uint8_t pwm) {
    XLR8_ESC_PWM = pwm;
  }

  /*
  void __attribute__ ((noinline)) set_seed(uint8_t seed) {
    XLR8_ESC_SEED = seed;
  }

  uint8_t __attribute__ ((noinline)) get_ESC() {
    return XLR8_ESC_DATA;
  }

  void set_freerunning_mode(boolean freerunning) {
    XLR8_ESC_CTRL = XLR8_ESC_CTRL | freerunning;
  }

  void set_long_heartbeat(boolean long_heartbeat) {
    XLR8_ESC_CTRL = XLR8_ESC_CTRL | (long_heartbeat << 1);
  }
  */

private:

};

extern XLR8_ESCClass XLR8_ESC;

#endif
