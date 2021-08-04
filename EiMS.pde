/*
 GUI and Software for "EiMS"
 ver. 1.3
 
 This is audio output ver. software for EMS & IFC.
 Most of this software based on wavEMS.
 
 Copyright (c) 2021 Hiroki Ohara Released under the MIT license */

/*
 Libraries */
import g4p_controls.*;
import controlP5.*;
import java.awt.Font;
import java.util.Map;
import ddf.minim.*;
import ddf.minim.ugens.*;
import javax.sound.sampled.*;
/*
 Variables */
PFont font;
float pulseH = 50;
HashMap<String, Integer> settings;  // settings = {TYPE=0, POLE=0, PERIOD=0, PULSE=0, f1=0, f2=0, TIME=0, L_inver=0, R_inver=0}
HashMap<Integer, Float> times;
Boolean stop_flg;
float sampleRate = 44100f;
float gainSin = 5;  // 適当
float gainSaw = 4;  // 適当
float gainSquare = -2;  // 適当
float[] pulseWidths;
Minim minim;
AudioSample pulse;
AudioFormat format = new AudioFormat(
  sampleRate, // sample rate
  16, // sample size in bits
  2, // channels for STEREO sound
  true, // signed
  true  // littleEndian which depends on CPU
  );

float x_calib;
float y_calib;
/*
 "b_" means button */
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
/*
 "i_" means input field */
ControlP5 i_period;
ControlP5 i_pulse;
ControlP5 i_f1;  // f1: Left Speaker
ControlP5 i_f2;  // f2: Right Speaker
/*
 For test */
//Survey survey = new Survey();


void setup() {
  fullScreen();
  //x_calib = (displayWidth-1200)/2;
  //y_calib = (displayHeight-787)/2;
  x_calib = displayWidth*0.1;
  y_calib = (displayHeight-891)/2;
  frameRate(60);
  /*
   Initialize of "settings"
   TYPE --- 0:Sin, 1:Saw, 2:Square
   POLE --- 0:Mono, 1:Bi
   TIME --- 0:1[s], 1:2[s], 2:5[s] */
  settings = new HashMap<String, Integer>();
  settings.put("TYPE", 0);
  settings.put("POLE", 0);
  settings.put("PERIOD", 0);
  settings.put("PULSE", 0);
  settings.put("f1", 0);
  settings.put("f2", 0);
  settings.put("TIME", 0);
  settings.put("L_inver", 0);
  settings.put("R_inver", 0);
  minim = new Minim(this);
  times = new HashMap<Integer, Float>();
  times.put(0, 1f);
  times.put(1, 2f);
  times.put(2, 5f);
  stop_flg = false;
  /*
   pulseが0である音を出力するように設定する */
  float[] zeroPulse = new float[int(sampleRate)];
  for (int i = 0; i < int(sampleRate); i++) {
    zeroPulse[i] = 0;
  }
  pulse = minim.createSample(zeroPulse, zeroPulse, format);
  /*
   f1とf2のパルス幅[usec]がどれくらいの大きさなのかを格納する */
  pulseWidths = new float[2];
  for (int i = 0; i < pulseWidths.length; i++) {
    pulseWidths[i] = 0;
  }
  font = createFont( "SansSerif", 18 );
  textFont( font );
  textAlign( LEFT, TOP );
  createButtonAndInputFieldOnGUI();
  thread("updateParametersFromInputFields");
  //survey = new Survey();
}



void draw() {
  createBackgroundOnGUI();
  createDisplaysOnGUI();
  createTextOnGUI();
  createStatusOnGUI();
  if (stop_flg == true) {
    pulse.stop();
    stop_flg = false;
  }
  //survey.print_();
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
        pulse.setGain(gainSquare);
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
  while (true) {
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
        pulseWidths[0] = (1/float(f1))*(float(pw)/float(pi)) * (float)pow(10, 6);
      }
      if (f2 != "0") {
        pulseWidths[1] = floor((1/float(f2))*(float(pw)/float(pi)) * (float)pow(10, 6));
      }
    }
  }
}
