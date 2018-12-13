/**
 * Chair Occupation Check 
 * 
 * Chair 4 Technomoll Version
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

int TRUE=1; // SEAT
int FALSE=0;  // STAND
int inbyte;
int loc=0;
float ms=1.0;
int[] chaddr = new int[5];
int[] chocpy = new int[5];
int[] chtype = new int[5];
int[] indata = new int[32];

PImage chairempty, chairseat;

int winx = 400;
int winy = 200;

void setup() {
  surface.setResizable(true);
  size(400, 200);
  changeWindowSize((int)(winx*0.99), (int)(winy*0.99));
  background(102);
  for (int i = 0; i < 4; i++) {
    chtype[i] = FALSE;
  }
  for (int i = 0; i < 4; i++) {
    chocpy[i] = chtype[i];
  }
  for (int i = 0; i < Serial.list ().length; i++) {
    println(i);
    println (Serial.list()[i]);
  }
  setchair();
  selport = new Serial(this, Serial.list()[2], 115200);
  chairempty = loadImage("isu_chair.png");
  chairseat = loadImage("chair_boy.png");
}

void keyPressed() {
  if (key=='1') {
    changeWindowSize((int)(winx*0.5), (int)(winy*0.5));
  }
  if (key=='2') {
    changeWindowSize((int)(winx*0.69), (int)(winy*0.69));
  }
  if (key=='3') {
    changeWindowSize(winx, winy);
  }
  if (key=='4') {
    changeWindowSize((int)(winx*1.5), (int)(winy*1.5));
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
  if(chocpy[4] != 0){
    drawtable(20, 20, true);
  }else{
    drawtable(20, 20, false);
  }
  drawchairarray(40, 200);
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
      println("RECV", hex(indata[loc-4]));
      for (int i=0; i < 19; i++) {
        if (chaddr[i] == indata[loc-4]) {
          f = i;
          break;
        }
      }
      if (f >= 0) {
        if (indata[loc-3] == 0) {
          chocpy[f] = chtype[f];
          println("STAND", f, " " , hex(indata[loc-4]));
        } else {
          chocpy[f] = TRUE;
          println("SEAT", f, " " , hex(indata[loc-4]));
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
  for (int h = 0; h < 4; h++) {
    drawchair(x+h*300, y+60, chocpy[h]);
  }
}

void drawtable(int x, int y, boolean f) {
  color ctable = #EEEEEE;
  if(f){
    ctable = #FF0000;
  }else{
    ctable = #FFFFFF;
  }
  int tablex=1200, tabley=180;
  fill(ctable);
  rect(x*ms, y*ms, tablex*ms, tabley*ms);
}

void drawchair(int x, int y, int mode) {
  int chairx = 300, chairy = 300;
  fill(103);
  stroke(103);
  rect(x*ms, y*ms, chairx*ms, chairy*ms);
  stroke(0);
  if (mode == TRUE) {
    image(chairseat, x*ms, y*ms, chairx*ms, chairy*ms);
  } else if (mode == FALSE) {
    image(chairempty, x*ms, y*ms, chairx*ms, chairy*ms);
  }
}

void setchair() {
  chaddr[0] = 0x50;
  chaddr[1] = 0x44;
  chaddr[2] = 0x70;
  chaddr[3] = 0x48;
  chaddr[4] = 0x60;
}
