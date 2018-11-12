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

import processing.serial.*;
Serial selport;

int FAIL=2;
int TRUE=1; // SEAT
int FALSE=0;  // STAND
int inbyte;
int loc=0;

int[] chaddr = new int[18];
int[] chocpy = new int[18];
int[] indata = new int[32];

void setup() {
  size(270, 640);
  background(102);
  for(int i = 0; i < 18; i++){
    chocpy[i] = FALSE;
  }
  chocpy[8] = FAIL;
  chocpy[17] = FAIL;
  for(int i= 0; i < 3; i++){
    drawtable(85, 8+i*180);
  }
  drawscreen(10,600);
  drawchairarray();
  for (int i = 0; i < Serial.list ().length; i++) {
    println(i);
    println (Serial.list()[i]);
  }
  setchair();
  selport = new Serial(this, Serial.list()[0], 115200);
}

void draw() {
  drawchairarray();
}

void serialEvent(Serial p){
  inbyte = p.read();
  indata[loc] = inbyte;
  if((inbyte == 0x0a) && (loc >= 6)){
    if(
      (indata[loc-1] == 0x0d) &&
      (indata[loc-5] == 0x53) &&
      (indata[loc-6] == 0x24)){
      int f = -1;
      for(int i=0; i < 18; i++){
        if(chaddr[i] == indata[loc-4]){
          f = i;
          break;
        }
      }
      if(f >= 0){
        if(indata[loc-3] == 0){
          chocpy[f] = FALSE;
          println("STAND", f);
        }else{
          chocpy[f] = TRUE;
          println("SEAT", f);
        }
        loc = 0;
      }
    }
  }
  if(loc == 31){
    loc = 0;
  }
  loc++;
}

void drawchairarray(){
  for(int v = 0; v < 9; v++){
    for(int h = 0; h < 2; h++){
      drawchair(10+h*200, 10+v*60, chocpy[v+h*9]);
    }
  }
}

void drawscreen(int x, int y){
  color cscreen = #FFFFFF;
  int screenx = 250;
  int screeny = 10;
  fill(cscreen);
  rect(x, y, screenx, screeny);
}

void drawtable(int x, int y){
  color ctable = #EEEEEE;
  int tablex=100, tabley=175;
  fill(ctable);
  rect(x, y, tablex, tabley);
}

void drawchair(int x, int y, int mode){
  color cfree = #00FF00;
  color cocpy = #FF0000;
  color cfail  = #AAAAAA;
  color chco;
  int chairx = 50, chairy = 50, chairr = 6;
  if(mode == TRUE){
    chco = cocpy;
  }else if(mode == FALSE){
    chco = cfree;
  }else{
    chco = cfail;
  }
  fill(chco);
  rect(x, y, chairx, chairy, chairr, chairr, chairr, chairr);
}

void setchair(){
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

}
