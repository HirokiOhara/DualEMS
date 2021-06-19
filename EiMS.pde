/*

GUI and Software for "EiMS"
ver. 1.2

This is audio output ver. software for EMS & IFC.
Most of this software based on wavEMS.

Designed by Hiroki OHARA, Tokyo Tech
不許複製・無断転載 © Hiroki Ohara All Rights Reserved

*/


import g4p_controls.*;
import controlP5.*;
import java.awt.Font;
import java.util.Map;
import ddf.minim.*;
import ddf.minim.ugens.*;
import javax.sound.sampled.*;

PFont font;
float pulseH = 50;
HashMap<String, Integer> settings;
/* settings = {TYPE=0, POLE=0, PERIOD=0, PULSE=0, f1=0, f2=0, TIME=0, L_inver=0, R_inver=0} */
HashMap<Integer, Float> times;
Boolean stop_flg;
float sampleRate = 44100f;
float gainSin = 2;
float gainSaw = 6;
float gainSquare = -2;
float[] pulseWidths;

Minim minim;
AudioSample pulse;
AudioFormat format = new AudioFormat(
  sampleRate, // sample rate
  16, // sample size in bits
  2, // channels for STEREO sound
  true, // signed
  true   // littleEndian which depends on CPU
  );

float x_calib;
float y_calib;

/* "b_" means button */
Font b_font;
GButton b_sin;
GButton b_saw;
GButton b_square;
GButton b_mono;
GButton b_bi;
GButton b_1s;
GButton b_2s;
GButton b_5s;
GButton b_pulse;
GButton b_stop;
GButton b_inver_l;
GButton b_inver_r;

/* "i_" means input field */
ControlP5 i_period;
ControlP5 i_pulse;
ControlP5 i_f1;  // f1: Left Speaker
ControlP5 i_f2;  // f2: Right Speaker

/* Variables for TEST */
//long t_setup_s;
//long t_setup_e;
//long t_draw_s;
//long t_draw_e;
//Survey survey = new Survey();


void setup() {
  //t_setup_s = System.currentTimeMillis();
  
  //size(1300, 837);
  fullScreen(2);
  x_calib = (displayWidth-1200)/2;
  y_calib = (displayHeight-787)/2;
  
  font = createFont( "SansSerif", 18 );
  textFont( font );
  textAlign( LEFT, TOP );
  createButtonAndInputFieldOnGUI();

  minim = new Minim(this);

  settings = new HashMap<String, Integer>();
  /* initialize
     TYPE --- 0:Sin, 1:Saw, 2:Square
     POLE --- 0:Mono, 1:Bi
     TIME --- 0:1[s], 1:2[s], 2:5[s] */
  settings.put("TYPE", 0);
  settings.put("POLE", 0);
  settings.put("PERIOD", 0);
  settings.put("PULSE", 0);
  settings.put("f1", 0);
  settings.put("f2", 0);
  settings.put("TIME", 0);
  settings.put("L_inver", 0);
  settings.put("R_inver", 0);

  times = new HashMap<Integer, Float>();
  times.put(0, 1f);
  times.put(1, 2f);
  times.put(2, 5f);

  stop_flg = false;

  /* pulseが0である音を出力するように設定する */
  float[] zeroPulse = new float[int(sampleRate)];
  for (int i = 0; i < int(sampleRate); i++){
    zeroPulse[i] = 0;
  }
  pulse = minim.createSample(zeroPulse, zeroPulse, format);
  
  /* f1とf2のパルス幅[usec]がどれくらいの大きさなのかを格納する*/
  pulseWidths = new float[2];
  for (int i = 0; i < pulseWidths.length; i++) {
    pulseWidths[i] = 0;
  }
  
  frameRate(120);
  //survey = new Survey();
  //t_setup_e = System.currentTimeMillis();
  //println("Time for setting up is " + (t_setup_e - t_setup_s) + "msec");
}



void draw() {
  //t_draw_s = System.currentTimeMillis();
  
  createBackgroundOnGUI();
  createDisplaysOnGUI();
  createTextOnGUI();
  createStatusOnGUI();
  updateParametersFromInputFields();
  if (stop_flg == true) {
    pulse.stop();
    stop_flg = false;
  }
  
  //println(settings);
  //survey.print_();
  //t_draw_e = System.currentTimeMillis();
  //println("Time for drawing is " + (t_draw_e - t_draw_s) + "msec");
}


void createButtonAndInputFieldOnGUI() { 
  b_font = new Font( Font.SANS_SERIF, Font.PLAIN, 18 );
  GButton.useRoundCorners( false );

  //button for TYPE
  b_sin = new GButton( this, x_calib + 228, y_calib + 50, 71, 30, "Sin" );
  b_saw = new GButton( this, x_calib + 301, y_calib + 50, 71, 30, "Saw" );
  b_square = new GButton( this, x_calib + 374, y_calib + 50, 71, 30, "Square" );
  b_sin.setLocalColorScheme( 9 );
  b_saw.setLocalColorScheme( 8 );
  b_square.setLocalColorScheme( 8 );
  b_sin.setFont(b_font);
  b_saw.setFont(b_font);
  b_square.setFont(b_font);

  //button for POLE
  b_mono = new GButton( this, x_calib + 228, y_calib + 84, 107.5, 30, "Mono" );
  b_bi = new GButton( this, x_calib + 337.5, y_calib + 84, 107.5, 30, "Bi" );
  b_mono.setLocalColorScheme( 9 );
  b_bi.setLocalColorScheme( 8 );
  b_mono.setFont(b_font);
  b_bi.setFont(b_font);

  //button for Pulse Inversion
  b_inver_l = new GButton( this, x_calib + 228, y_calib + 152, 107.5, 30, "L" );
  b_inver_r = new GButton( this, x_calib + 337.5, y_calib + 152, 107.5, 30, "R" );
  b_inver_l.setLocalColorScheme( 8 );
  b_inver_r.setLocalColorScheme( 8 );
  b_inver_l.setFont(b_font);
  b_inver_r.setFont(b_font);
  
  //button for 1[s], 2[s], 5[s]
  b_1s = new GButton( this, x_calib + 883, y_calib + 84, 71, 30, "1 sec" );
  b_2s = new GButton( this, x_calib + 956, y_calib + 84, 71, 30, "2 sec" );
  b_5s = new GButton( this, x_calib + 1029, y_calib + 84, 71, 30, "5 sec" );
  b_1s.setLocalColorScheme( 9 );
  b_2s.setLocalColorScheme( 8 );
  b_5s.setLocalColorScheme( 8 );
  b_1s.setFont(b_font);
  b_2s.setFont(b_font);
  b_5s.setFont(b_font);

  //button for Pulse
  b_pulse = new GButton( this, x_calib + 883, y_calib + 118, 144, 30, "Pulse" );
  b_pulse.setLocalColorScheme( 10 );
  b_pulse.setFont(b_font);
  //button for Stop
  b_stop = new GButton( this, x_calib + 1029, y_calib + 118, 71, 30, "Stop" );
  b_stop.setLocalColorScheme( 11 );
  b_stop.setFont(b_font);

  //input field for PERIOD:PULSE
  i_period = new ControlP5(this);
  i_pulse = new ControlP5(this);
  i_f1 = new ControlP5(this);
  i_f2 = new ControlP5(this);
  i_period.addTextfield("PERIOD")
    .setPosition(x_calib + 228, y_calib + 118)
    .setSize(100, 30)
    .setAutoClear(false)
    .setFont(font)
    .setColor(color(64, 64, 64))
    .setColorCursor(color(64, 64, 64))
    .setColorActive(color(254, 107, 53))
    .setColorForeground(color(254, 107, 53))
    .setColorBackground(color(255, 255, 255))
    .setCaptionLabel("");
  i_pulse.addTextfield("PULSE")
    .setPosition(x_calib + 345, y_calib + 118)
    .setSize(100, 30)
    .setAutoClear(false)
    .setFont(font)
    .setColor(color(64, 64, 64))
    .setColorCursor(color(64, 64, 64))
    .setColorActive(color(254, 107, 53))
    .setColorForeground(color(254, 107, 53))
    .setColorBackground(color(255, 255, 255))
    .setCaptionLabel("");

  //input field for FREQ
  i_f1.addTextfield("f1")
    .setPosition(x_calib + 228, y_calib + 316.5)
    .setSize(100, 30)
    .setAutoClear(false)
    .setFont(font)
    .setColor(color(64, 64, 64))
    .setColorCursor(color(64, 64, 64))
    .setColorActive(color(254, 107, 53))
    .setColorForeground(color(254, 107, 53))
    .setColorBackground(color(255, 255, 255))
    .setCaptionLabel("");
  i_f2.addTextfield("f2")
    .setPosition(x_calib + 228, y_calib + 479.5)
    .setSize(100, 30)
    .setAutoClear(false)
    .setFont(font)
    .setColor(color(64, 64, 64))
    .setColorCursor(color(64, 64, 64))
    .setColorActive(color(254, 107, 53))
    .setColorForeground(color(254, 107, 53))
    .setColorBackground(color(255, 255, 255))
    .setCaptionLabel("");
}



void createBackgroundOnGUI() {
  background(255, 255, 255);
  fill(255, 255, 255);
  noStroke();
  //AREA-1
  rect(x_calib, y_calib, 779, 198);
  //AREA-2
  rect(x_calib, y_calib + 202, 1200, 585);
  //AREA-3
  fill(64, 64, 64);
  rect(x_calib + 783, y_calib, 417, 198);
}



void createTextOnGUI() {
  //AREA-1
  fill(64, 64, 64);
  text("Type", x_calib + 100, y_calib + 53);
  text("Pole", x_calib + 100, y_calib + 87);
  text("PI:PW", x_calib + 100, y_calib + 121);  //Pulse Width per Pulse Interval
  text(":", x_calib + 333.5, y_calib + 121);
  text("INV", x_calib + 100, y_calib + 155);
  text("Pulse Width", x_calib + 520, y_calib + 53);
  for (int i=0; i < pulseWidths.length; i++) {
    text("f"+(i+1)+":", x_calib + 520, y_calib + 87 + i*34);
    text("usec", x_calib + 620, y_calib + 87 + i*34);
  }
  for (int i=0; i < pulseWidths.length; i++) {
    if (pulseWidths[i] > 0) {
      text((int)pulseWidths[i], x_calib + 550, y_calib + 87 + i*34);
    }
  }
  //AREA-2
  text("FREQ", x_calib + 100, y_calib + 252);
  text("Beat", x_calib + 100, y_calib + 578);
  text("f1", x_calib + 150, y_calib + 319.5);
  text("f2", x_calib + 150, y_calib + 482.5);
  text("|f1-f2|", x_calib + 150, y_calib + 645.5);
  text("Hz", x_calib + 332, y_calib + 319.5);
  text("Hz", x_calib + 332, y_calib + 482.5);
  text("Hz", x_calib + 332, y_calib + 645.5);
}



void createDisplaysOnGUI() {
  fill(255, 255, 255);
  //"Pulse Width"
  rect(x_calib + 520, y_calib + 50, 159, 98);
  //"FREQ"
  rect(x_calib + 410, y_calib + 252, 686, 159);
  rect(x_calib + 410, y_calib + 415, 686, 159);
  //"BEAT"
  rect(x_calib + 228, y_calib + 642.5, 100, 30);
  rect(x_calib + 410, y_calib + 578, 686, 159);
  if (settings.get("f1") != 0 && settings.get("f2") != 0) {
    fill(64, 64, 64);
    text(Math.abs( settings.get("f1") - settings.get("f2") ), x_calib + 228, y_calib + 645.5);
  }
  if (pulse != null) {
    stroke( 68, 11, 212);
    for (int i = 0; i < 686; i++) {
      line(x_calib + 410 + i, y_calib + 331.5 - pulse.left.get(i) * pulseH, x_calib + 410 + i+1, y_calib + 331.5 - pulse.left.get(i+1) * pulseH);
    }
    stroke(255, 32, 121);
    for (int i = 0; i < 686; i++) {
      line(x_calib + 410 + i, y_calib + 494.5 - pulse.right.get(i) * pulseH, x_calib + 410 + i+1, y_calib + 494.5 - pulse.right.get(i+1) * pulseH);
    }
    stroke( (68 + 255) / 2, (11 + 32) / 2, (212 + 121) / 2);
    for (int i = 0; i < 686; i++) {
      line(x_calib + 410 + i, y_calib + 657.5 - ( pulse.right.get(i) + pulse.left.get(i) ) * pulseH, x_calib + 410 + i+1, y_calib + 657.5 - ( pulse.right.get(i+1) + pulse.left.get(i+1) ) * pulseH);
    }
    stroke(255, 255, 255);
  }
}



void createStatusOnGUI() {
  if ( settings.get("PERIOD") > 0 && settings.get("PULSE") > 0 && settings.get("PERIOD") > settings.get("PULSE")) {
    if ( (settings.get("f1") >= 20 && settings.get("f2") == 0)
      || (settings.get("f1") == 0 && settings.get("f2") >= 20)
      || (settings.get("f1") >= 20 && settings.get("f2") >= 20)) {
      fill(127, 255, 0);
      text("Ready", x_calib + 883, y_calib + 50);
      
      b_pulse.setEnabled(true);
      b_stop.setEnabled(true);
      b_pulse.setLocalColorScheme( 12 );
      b_stop.setLocalColorScheme( 11 );
    } else {
      fill(0, 0, 0);
      text("Unprepared", x_calib + 883, y_calib + 50);
      b_pulse.setEnabled(false);
      b_stop.setEnabled(false);
      b_pulse.setLocalColorScheme( 10 );
      b_stop.setLocalColorScheme( 10 );
    }
  } else {
    fill(0, 0, 0);
    text("Unprepared", x_calib + 883, y_calib + 50);
    b_pulse.setEnabled(false);
    b_stop.setEnabled(false);
    b_pulse.setLocalColorScheme( 10 );
    b_stop.setLocalColorScheme( 10 );
  }
}



void handleButtonEvents(GButton button, GEvent event) {
  if (event == GEvent.CLICKED) {
    if (button == b_pulse) {
      float[] pulse_f1 = new float[int(sampleRate * times.get(settings.get("TIME")))];
      float[] pulse_f2 = new float[int(sampleRate * times.get(settings.get("TIME")))];
      float cycle_f1 = sampleRate / (float)settings.get("f1");
      float cycle_f2 = sampleRate / (float)settings.get("f2");
      if (settings.get("TYPE") == 0) {
        generateSinWaves(settings, pulse_f1, pulse_f2, cycle_f1, cycle_f2);
        pulse.setGain(gainSin);
        pulse.trigger();
      } else if (settings.get("TYPE") == 1) {
        generateSawWaves(settings, pulse_f1, pulse_f2, cycle_f1, cycle_f2);
        pulse.setGain(gainSaw);
        pulse.trigger();
      } else if (settings.get("TYPE") == 2) {
        generateSquareWaves(settings, pulse_f1, pulse_f2, cycle_f1, cycle_f2);
        pulse.setGain(gainSaw);
        pulse.trigger();
      }
    } else if (button == b_stop) {
      stop_flg = true;
    } else if (button == b_sin) {
      b_sin.setLocalColorScheme( 9 );
      b_saw.setLocalColorScheme( 8 );
      b_square.setLocalColorScheme( 8 );
      settings.put("TYPE", 0);
    } else if (button == b_saw) {
      b_sin.setLocalColorScheme( 8 );
      b_saw.setLocalColorScheme( 9 );
      b_square.setLocalColorScheme( 8 );
      settings.put("TYPE", 1);
    } else if (button == b_square) {
      b_sin.setLocalColorScheme( 8 );
      b_saw.setLocalColorScheme( 8 );
      b_square.setLocalColorScheme( 9 );
      settings.put("TYPE", 2);
    } else if (button == b_mono) {
      b_mono.setLocalColorScheme( 9 );
      b_bi.setLocalColorScheme( 8 );
      settings.put("POLE", 0);
    } else if (button == b_bi) {
      b_mono.setLocalColorScheme( 8 );
      b_bi.setLocalColorScheme( 9 );
      settings.put("POLE", 1);
    } else if (button == b_1s) {
      b_1s.setLocalColorScheme( 9 );
      b_2s.setLocalColorScheme( 8 );
      b_5s.setLocalColorScheme( 8 );
      settings.put("TIME", 0);
    } else if (button == b_2s) {
      b_1s.setLocalColorScheme( 8 );
      b_2s.setLocalColorScheme( 9 );
      b_5s.setLocalColorScheme( 8 );
      settings.put("TIME", 1);
    } else if (button == b_5s) {
      b_1s.setLocalColorScheme( 8 );
      b_2s.setLocalColorScheme( 8 );
      b_5s.setLocalColorScheme( 9 );
      settings.put("TIME", 2);
    } else if (button == b_inver_l) {
      if (settings.get("L_inver") == 0) {
        b_inver_l.setLocalColorScheme( 9 );
        settings.put("L_inver", 1);
      } else {
        b_inver_l.setLocalColorScheme( 8 );
        settings.put("L_inver", 0);
      }
    } else if (button == b_inver_r) {
      if (settings.get("R_inver") == 0) {
        b_inver_r.setLocalColorScheme( 9 );
        settings.put("R_inver", 1);
      } else {
        b_inver_r.setLocalColorScheme( 8 );
        settings.put("R_inver", 0);
      }
    }
  }
}



void updateParametersFromInputFields() {
  String pi = i_period.get(Textfield.class, "PERIOD").getText();
  String pw = i_pulse.get(Textfield.class, "PULSE").getText();
  String f1 = i_f1.get(Textfield.class, "f1").getText();
  String f2 = i_f2.get(Textfield.class, "f2").getText();
  settings.put("PERIOD", int(pi));
  settings.put("PULSE", int(pw));
  settings.put("f1", int(f1));
  settings.put("f2", int(f2));
  if (pi != "0") {
    if (f1 != "0") {
      //Calculate pulse width using "usec" unit
      pulseWidths[0] = (1/float(f1))*(float(pw)/float(pi)) * (float)pow(10,6);
    }
    if (f2 != "0") {
      pulseWidths[1] = floor((1/float(f2))*(float(pw)/float(pi)) * (float)pow(10,6));
    }
  }
}



void generateSinWaves(HashMap set, float[] LPulse, float[] RPulse, float LCyc, float RCyc) {
  float pulseWidth_f1 = sampleRate / float(set.get("f1").toString());
  float pulseWidth_f2 = sampleRate / float(set.get("f2").toString());
  float wavelength_f1 = pulseWidth_f1 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString());
  float wavelength_f2 = pulseWidth_f2 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString());
  //Check the pole
  if (int(set.get("POLE").toString()) == 1) {
    //LPulse
    for (int j = 0; j < (int)LPulse.length/LCyc; j++) {
      //Create sin wave (whose cycle is "2*wavelength_f1")
      for (int i = 0; i < (int)wavelength_f1*2; i++) {
        LPulse[i+(int)LCyc*j] = 0.5 * (float)Math.sin(i/wavelength_f1 * 1 * Math.PI);
      }
      //In the wave length, set the amplitude as Zero except the sin wave section
      for (int ii = 0; ii < int(LCyc - ( wavelength_f1 * (int(set.get("POLE").toString())+1)) ); ii++) {
        LPulse[(int)wavelength_f1*(int(set.get("POLE").toString())+1) + ii +(int)LCyc*j] = 0;
      }
    }
    //RPulse
    for (int j = 0; j < (int)RPulse.length/RCyc; j++) {
      for (int i = 0; i < (int)wavelength_f2*2; i++) { 
        RPulse[i+(int)RCyc*j] = 0.5 * (float)Math.sin(i/wavelength_f2 * 1 * Math.PI);
      }
      for (int ii = 0; ii < int(RCyc - (wavelength_f2 * (int(set.get("POLE").toString())+1))); ii++) {
        RPulse[(int)wavelength_f2*(int(set.get("POLE").toString())+1) + ii +(int)RCyc*j] = 0;
      }
    }
  } else {
    //LPulse
    for (int j = 0; j < (int)LPulse.length/LCyc; j++) {
      //Create half sin wave (whose cycle is "wavelength_f1")
      for (int i = 0; i < (int)wavelength_f1; i++) { 
        LPulse[i+(int)LCyc*j] = 0.5 * (float)Math.sin(i/wavelength_f1 * 1 * Math.PI);
      }
      for (int ii = 0; ii < int(LCyc - ( wavelength_f1 * (int(set.get("POLE").toString())+1)) ); ii++) {
        LPulse[(int)wavelength_f1*(int(set.get("POLE").toString())+1) + ii +(int)LCyc*j] = 0;
      }
    }
    //RPulse
    for (int j = 0; j < (int)RPulse.length/RCyc; j++) {
      for (int i = 0; i < (int)wavelength_f2; i++) { 
        RPulse[i+(int)RCyc*j] = 0.5 * (float)Math.sin(i/wavelength_f2 * 1 * Math.PI);
      }
      for (int ii = 0; ii < int(RCyc - (wavelength_f2 * (int(set.get("POLE").toString())+1))); ii++) {
        RPulse[(int)wavelength_f2*(int(set.get("POLE").toString())+1) + ii +(int)RCyc*j] = 0;
      }
    } 
  }
  //Inverte the signals
  if (int(set.get("L_inver").toString()) == 1) {
    for(int k = 0; k < LPulse.length; k++) LPulse[k] = -LPulse[k];
  }
  if (int(set.get("R_inver").toString()) == 1) {
    for(int k = 0; k < RPulse.length; k++) RPulse[k] = -RPulse[k];
  }
  /* AudioSample createSample(float[] leftSampleData, float[] rightSampleData, AudioFormat format);
     のようにして、１つの音源に左右独立の音を作成可能 */
  pulse = minim.createSample(LPulse, RPulse, format);
}



void generateSawWaves(HashMap set, float[] LPulse, float[] RPulse, float LCyc, float RCyc) {
  float pulseWidth_f1 = sampleRate / float(set.get("f1").toString());
  float pulseWidth_f2 = sampleRate / float(set.get("f2").toString());
  float wavelength_f1 = pulseWidth_f1 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString());
  float wavelength_f2 = pulseWidth_f2 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString());
  if (int(set.get("POLE").toString()) == 1) {
    //LPulse
    for (int j = 0; j < (int)LPulse.length/LCyc; j++) {
      for (int i = 0; i < (int)wavelength_f1; i++) {
        LPulse[i+(int)LCyc*j] = 0.5 * i / (wavelength_f1 - 1);
      }
      for (int i = (int)wavelength_f1; i < (int)wavelength_f1 * 2 + 1; i++) {
        LPulse[i+(int)LCyc*j] = - 0.5 * (i - wavelength_f1) / wavelength_f1;
      }
      for (int ii = 0; ii < int(LCyc - (pulseWidth_f1 * (int(set.get("POLE").toString()) + 1))); ii++) {
        LPulse[(int)LCyc*(int(set.get("POLE").toString()) + ii + (int)LCyc * j)] = 0;
      }
    }
    //RPulse
    for (int j = 0; j < (int)RPulse.length/RCyc; j++) {
      for (int i = 0; i < (int)wavelength_f2; i++) {
        RPulse[i+(int)RCyc*j] = 0.5 * i / (wavelength_f2 - 1);
      }
      for (int i = (int)wavelength_f2; i < (int)wavelength_f2 * 2 + 1; i++) {
        RPulse[i+(int)RCyc*j] = - 0.5 * (i - wavelength_f2) / wavelength_f2;
      }
      for (int ii = 0; ii < int(RCyc - (pulseWidth_f2 * (int(set.get("POLE").toString()) + 1))); ii++) {
        RPulse[(int)RCyc*(int(set.get("POLE").toString()) + ii + (int)RCyc * j)] = 0;
      }
    }
  } else {
    //LPulse
    for (int j = 0; j < (int)LPulse.length/LCyc; j++) {
      for (int i = 0; i < (int)wavelength_f1; i++) {
        LPulse[i+(int)LCyc*j] = 0.5 * i / (wavelength_f1 - 1);
      }
      for (int ii = 0; ii < int(LCyc - (pulseWidth_f1 * (int(set.get("POLE").toString()) + 1))); ii++) {
        LPulse[(int)LCyc*(int(set.get("POLE").toString()) + ii + (int)LCyc * j)] = 0;
      }
    }
    //RPulse
    for (int j = 0; j < (int)RPulse.length/RCyc; j++) {
      for (int i = 0; i < (int)wavelength_f2; i++) {
        RPulse[i+(int)RCyc*j] = 0.5 * i / (wavelength_f2 - 1);
      }
      for (int ii = 0; ii < int(RCyc - (pulseWidth_f2 * (int(set.get("POLE").toString()) + 1))); ii++) {
        RPulse[(int)RCyc*(int(set.get("POLE").toString()) + ii + (int)RCyc * j)] = 0;
      }
    }
  }
  if (int(set.get("L_inver").toString()) == 1) {
    for(int k = 0; k < LPulse.length; k++) LPulse[k] = -LPulse[k];
  }
  if (int(set.get("R_inver").toString()) == 1) {
    for(int k = 0; k < RPulse.length; k++) RPulse[k] = -RPulse[k];
  }
  pulse = minim.createSample(LPulse, RPulse, format);
}



void generateSquareWaves(HashMap set, float[] LPulse, float[] RPulse, float LCyc, float RCyc) {
  float pulseWidth_f1 = sampleRate / float(set.get("f1").toString());
  float pulseWidth_f2 = sampleRate / float(set.get("f2").toString());
  float wavelength_f1 = pulseWidth_f1 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString());
  float wavelength_f2 = pulseWidth_f2 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString());
  if (int(set.get("POLE").toString()) == 1) {
    //LPulse
    for (int j = 0; j < (int)LPulse.length/LCyc; j++) {
      for (int i = 0; i < (int)wavelength_f1; i++) { 
        LPulse[i+(int)LCyc*j] = 1;
      }
      for (int i = (int)wavelength_f1; i < (int)wavelength_f1*2; i++) { 
        LPulse[i+(int)LCyc*j] = - 1;
      }
      for (int ii = 0; ii < int(LCyc - (wavelength_f1*(int(set.get("POLE").toString())+1)) ); ii++) {
        LPulse[int(wavelength_f1*(int(set.get("POLE").toString())+1) + ii + (int)LCyc*j)] = 0;
      }
    }
    //RPulse
    for (int j = 0; j < (int)RPulse.length/RCyc; j++) {
      for (int i = 0; i < (int)wavelength_f2; i++) { 
        RPulse[i+(int)RCyc*j] = 1;
      }
      for (int i = (int)wavelength_f2; i < (int)wavelength_f2*2; i++) { 
        RPulse[i+(int)RCyc*j] = -1;
      }
      for (int ii = 0; ii < int(RCyc - (wavelength_f2*(int(set.get("POLE").toString())+1)) ); ii++) {
        RPulse[int(wavelength_f2*(int(set.get("POLE").toString())+1) + ii + (int)RCyc*j)] = 0;
      }
    }
  } else {
    //LPulse
    for (int j = 0; j < (int)LPulse.length/LCyc; j++) {
      for (int i = 0; i < (int)wavelength_f1; i++) { 
        LPulse[i+(int)LCyc*j] = 1;
      }
      for (int ii = 0; ii < int(LCyc - (wavelength_f1*(int(set.get("POLE").toString())+1)) ); ii++) {
        LPulse[int(wavelength_f1*(int(set.get("POLE").toString())+1) + ii + (int)LCyc*j)] = 0;
      }
    }
    //RPulse
    for (int j = 0; j < (int)RPulse.length/RCyc; j++) {
      for (int i = 0; i < (int)wavelength_f2; i++) { 
        RPulse[i+(int)RCyc*j] = 1;
      }
      for (int ii = 0; ii < int(RCyc - (wavelength_f2*(int(set.get("POLE").toString())+1)) ); ii++) {
        RPulse[int(wavelength_f2*(int(set.get("POLE").toString())+1) + ii + (int)RCyc*j)] = 0;
      }
    }
  }
  if (int(set.get("L_inver").toString()) == 1) {
    for(int k = 0; k < LPulse.length; k++) LPulse[k] = -LPulse[k];
  }
  if (int(set.get("R_inver").toString()) == 1) {
    for(int k = 0; k < RPulse.length; k++) RPulse[k] = -RPulse[k];
  }
  pulse = minim.createSample(LPulse, RPulse, format);
}


class Survey {
int fpsf;
long nowTime;
long frameTime;
double f;
float fps;
int frame_survey;
long startTime = System.currentTimeMillis();
  void print_() {
    frame_survey++;
    if (frame_survey == 1)frameTime = System.currentTimeMillis();
    fpsf++;
    nowTime= System.currentTimeMillis();
    double time=Math.floor((nowTime-startTime)/1000);
    if ( time - f >= 1)
    {
      println(fpsf +" fps / "+((nowTime-frameTime)/fpsf)+" ms ");
      fpsf=0;
      f=time;
      frameTime = System.currentTimeMillis();
    }
  }
}
