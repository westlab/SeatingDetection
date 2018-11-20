/**
 * Chair Occupation Check 
 * 
 * Chair 9x2 
 * Serial COM3 115200, 8bit, NONE, 1bit, NONE
 * 24 53 = prefix
 * xx = ID
 * 40/00 = Seat(Push) 40 / Stand(Pull) 00
 * 01 - 05 # of signal
 * 0D 0A = suffix *
 *
 * EXAMPLE
 * 24 53 60 40 01 0D 0A
 * 24 53 60 00 02 0D 0A
 * ID ID ID CH SE ?? ??
 */

import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import processing.serial.*;
Serial selport;

boolean frontview = false;
boolean headview = false;

int FAIL=2;
int TRUE=1; // SEAT
int FALSE=0;  // STAND
int inbyte;
int loc=0;
float ms=1.0;
int[] chaddr = new int[18];
int[] chocpy = new int[18];
int[] indata = new int[32];

void setup() {
  surface.setResizable(true);
  size(270, 640);

  background(102);
  for (int i = 0; i < 18; i++) {
    chocpy[i] = FALSE;
  }
  if (headview) {
    chocpy[8] = FAIL;
    chocpy[17] = FAIL;
  } else {
    chocpy[0] = FAIL;
    chocpy[9] = FAIL;
  }
  for (int i= 0; i < 3; i++) {
    drawtable(85, 8+i*180);
  }
  for (int i = 0; i < Serial.list ().length; i++) {
    println(i);
    println (Serial.list()[i]);
  }
  setchair();
  selport = new Serial(this, Serial.list()[0], 115200);
}

void keyPressed() {
  if (key=='1') {
    changeWindowSize(270, 640);
  }
  if (key=='2') {
    changeWindowSize((int)(270*1.5), (int)(640*1.5));
  }
}

void changeWindowSize(int w, int h) {
  frame.setSize( w + frame.getInsets().left + frame.getInsets().right, h + frame.getInsets().top + frame.getInsets().bottom );
  size(w, h);
}

void draw() throws IllegalArgumentException {
  ms = height/640.0;
  fill(#EEEEEE);
  text( width + ", " + height + ", " + ms, 0, 10 );
  if (headview) {
    drawscreen(10, 600);
    for (int i= 0; i < 3; i++) {
      drawtable(85, 8+i*180);
    }
    drawchairarray(10, 10);
  } else {
    drawscreen(10, 20);
    for (int i= 0; i < 3; i++) {
      drawtable(85, 98+i*180);
    }
    drawchairarray(10, 100);
  }
}

void serialEvent(Serial p) {
  inbyte = p.read();
  indata[loc] = inbyte;
  if ((inbyte == 0x0a) && (loc >= 6)) {
    if (
      (indata[loc-1] == 0x0d) &&
      (indata[loc-5] == 0x53) &&
      (indata[loc-6] == 0x24)) {
      int f = -1;
      for (int i=0; i < 18; i++) {
        if (chaddr[i] == indata[loc-4]) {
          f = i;
          break;
        }
      }
      if (f >= 0) {
        if (indata[loc-3] == 0) {
          chocpy[f] = FALSE;
          println("STAND", f);
        } else {
          chocpy[f] = TRUE;
          println("SEAT", f);
        }
        loc = 0;
      }
    }
  }
  if (loc == 31) {
    loc = 0;
  }
  loc++;
}

void drawchairarray(int x, int y) {
  for (int v = 0; v < 9; v++) {
    for (int h = 0; h < 2; h++) {
      drawchair(x+h*200, y+v*60, chocpy[v+h*9]);
    }
  }
}

void drawscreen(int x, int y) {
  color cscreen = #FFFFFF;
  int screenx = 250;
  int screeny = 10;
  fill(cscreen);
  rect(x*ms, y*ms, screenx*ms, screeny*ms);
}

void drawtable(int x, int y) {
  color ctable = #EEEEEE;
  int tablex=100, tabley=175;
  fill(ctable);
  rect(x*ms, y*ms, tablex*ms, tabley*ms);
}

void drawchair(int x, int y, int mode) {
  color cfree = #00FF00;
  color cocpy = #FF0000;
  color cfail  = #AAAAAA;
  color chco;
  int chairx = 50, chairy = 50, chairr = 6;
  if (mode == TRUE) {
    chco = cocpy;
  } else if (mode == FALSE) {
    chco = cfree;
  } else {
    chco = cfail;
  }
  fill(chco);
  rect(x*ms, y*ms, chairx*ms, chairy*ms, chairr*ms, chairr*ms, chairr*ms, chairr*ms);
}

void setchair() {
  if (frontview) {
    chaddr[0] = 0x50;
    chaddr[1] = 0x44;
    chaddr[2] = 0x38;
    chaddr[3] = 0x71;
    chaddr[4] = 0x13;
    chaddr[5] = 0x5D;
    chaddr[6] = 0x37;
    chaddr[7] = 0x46;
    chaddr[8] = 0xFF;
    chaddr[9] = 0x70;
    chaddr[10] = 0x48;
    chaddr[11] = 0x35;
    chaddr[12] = 0x5E;
    chaddr[13] = 0x59;
    chaddr[14] = 0x4F;
    chaddr[15] = 0x05;
    chaddr[16] = 0x3D;
    chaddr[17] = 0x60;
  } else {
    if (headview) {
      chaddr[9] = 0x50;
      chaddr[10] = 0x44;
      chaddr[11] = 0x38;
      chaddr[12] = 0x71;
      chaddr[13] = 0x13;
      chaddr[14] = 0x5D;
      chaddr[15] = 0x37;
      chaddr[16] = 0x46;
      chaddr[17] = 0xFF;
      chaddr[0] = 0x70;
      chaddr[1] = 0x48;
      chaddr[2] = 0x35;
      chaddr[3] = 0x5E;
      chaddr[4] = 0x59;
      chaddr[5] = 0x4F;
      chaddr[6] = 0x05;
      chaddr[7] = 0x3D;
      chaddr[8] = 0x60;
    } else {
      chaddr[17] = 0x50;
      chaddr[16] = 0x44;
      chaddr[15] = 0x38;
      chaddr[14] = 0x71;
      chaddr[13] = 0x13;
      chaddr[12] = 0x5D;
      chaddr[11] = 0x37;
      chaddr[10] = 0x46;
      chaddr[9] = 0xFF;
      chaddr[8] = 0x70;
      chaddr[7] = 0x48;
      chaddr[6] = 0x35;
      chaddr[5] = 0x5E;
      chaddr[4] = 0x59;
      chaddr[3] = 0x4F;
      chaddr[2] = 0x05;
      chaddr[1] = 0x3D;
      chaddr[0] = 0x60;
    }
  }
}
