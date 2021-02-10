/*

xxTITLExx
ver. 1.1

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
//settings = {TYPE=0, POLE=0, PERIOD=0, PULSE=0, f1=0, f2=0, TIME=0}
HashMap<Integer, Float> times;
Boolean emg_flg;
float sampleRate = 48000f;
float gainSin = 2;
float gainSaw = 6;
float gainSquare = -2;

Minim minim;
AudioSample pulse;
AudioFormat format = new AudioFormat( sampleRate, // sample rate
  16, // sample size in bits
  2, // channels for STEREO sound
  true, // signed
  true   // littleEndian which depends on CPU
  );

// "b_" means button
Font b_font;
GButton b_sin;
GButton b_saw;
GButton b_square;
GButton b_mono;
GButton b_bi;
GButton b_01s;
GButton b_1s;
GButton b_5s;
GButton b_pellere;
GButton b_emg;

// "i_" means input field
ControlP5 i_period;
ControlP5 i_pulse;
ControlP5 i_f1;  // f1: Left Speaker
ControlP5 i_f2;  // f2: Right Speaker



// Variables for TEST
//int t_setup_s;
//int t_setup_e;
//int t_draw_s;
//int t_draw_e;



void setup() {
  //t_setup_s = millis();

  size(1300, 837);
  font = createFont( "SansSerif", 18 );
  textFont( font );
  textAlign( LEFT, TOP );
  createButtonAndInputFieldOnGUI();

  minim = new Minim(this);

  settings = new HashMap<String, Integer>();
  // initialize
  // TYPE --- 0:Sin, 1:Saw, 2:Square
  // POLE --- 0:Mono, 1:Bi
  // TIME --- 0:0.1s, 1:1s, 2:5s
  settings.put("TYPE", 0);
  settings.put("POLE", 0);
  settings.put("PERIOD", 0);
  settings.put("PULSE", 0);
  settings.put("f1", 0);
  settings.put("f2", 0);
  settings.put("TIME", 0);

  times = new HashMap<Integer, Float>();
  times.put(0, 0.1);
  times.put(1, 1f);
  times.put(2, 5f);

  emg_flg = false;

  //pulseが0である音を出力するように設定する
  float[] zeroPulse = new float[int(sampleRate)];
  for (int i = 0; i < int(sampleRate); i++){
    zeroPulse[i] = 0;
  }
  pulse = minim.createSample(zeroPulse, zeroPulse, format);
  //t_setup_e = millis();
  //println("Time for setting up is " + (t_setup_e - t_setup_s) + "msec");
}



void draw() {
  //t_draw_s = millis() - t_setup_e;

  createBackgroundOnGUI();
  createDisplaysOnGUI();
  createTextOnGUI();
  createStatusOnGUI();

  updateSettingsFromInputFields();

  if (emg_flg == true) {
    pulse.stop();
    emg_flg = false;
  }
  
  //println(settings);

  //t_draw_e = millis() - t_setup_e;
  //println("Time for drawing is " + (t_draw_e - t_draw_s) + "msec");
}



void createButtonAndInputFieldOnGUI() {
  b_font = new Font( Font.SANS_SERIF, Font.PLAIN, 18 );
  GButton.useRoundCorners( false );

  //button for TYPE
  b_sin = new GButton( this, 278, 75, 71, 30, "Sin" );
  b_saw = new GButton( this, 351, 75, 71, 30, "Saw" );
  b_square = new GButton( this, 424, 75, 71, 30, "Square" );
  b_sin.setLocalColorScheme( 9 );
  b_saw.setLocalColorScheme( 8 );
  b_square.setLocalColorScheme( 8 );
  b_sin.setFont(b_font);
  b_saw.setFont(b_font);
  b_square.setFont(b_font);

  //button for POLE
  b_mono = new GButton( this, 278, 109, 107.5, 30, "Mono" );
  b_bi = new GButton( this, 387.5, 109, 107.5, 30, "Bi" );
  b_mono.setLocalColorScheme( 9 );
  b_bi.setLocalColorScheme( 8 );
  b_mono.setFont(b_font);
  b_bi.setFont(b_font);

  //button for 0.1s, 1s, 5s
  b_01s = new GButton( this, 933, 109, 71, 30, "0.1s" );
  b_1s = new GButton( this, 1006, 109, 71, 30, "1s" );
  b_5s = new GButton( this, 1079, 109, 71, 30, "5s" );
  b_01s.setLocalColorScheme( 9 );
  b_1s.setLocalColorScheme( 8 );
  b_5s.setLocalColorScheme( 8 );
  b_01s.setFont(b_font);
  b_1s.setFont(b_font);
  b_5s.setFont(b_font);

  //button for Pellere
  b_pellere = new GButton( this, 933, 143, 144, 30, "Pellere" );
  b_pellere.setLocalColorScheme( 10 );
  b_pellere.setFont(b_font);
  //button for EMG
  b_emg = new GButton( this, 1079, 143, 71, 30, "EMG" );
  b_emg.setLocalColorScheme( 11 );
  b_emg.setFont(b_font);

  //input field for PERIOD:PULSE
  i_period = new ControlP5(this);
  i_pulse = new ControlP5(this);
  i_f1 = new ControlP5(this);
  i_f2 = new ControlP5(this);
  i_period.addTextfield("PERIOD")
    .setPosition(278, 143)
    .setSize(100, 30)
    .setAutoClear(false)
    .setFont(font)
    .setColor(color(64, 64, 64))
    .setColorCursor(color(64, 64, 64))
    .setColorActive(color(254, 107, 53))
    .setColorForeground(color(254, 107, 53))
    .setColorBackground(color(255, 255, 255))
    .setColorCaptionLabel(color(243, 244, 247));
  i_pulse.addTextfield("PULSE")
    .setPosition(395, 143)
    .setSize(100, 30)
    .setAutoClear(false)
    .setFont(font)
    .setColor(color(64, 64, 64))
    .setColorCursor(color(64, 64, 64))
    .setColorActive(color(254, 107, 53))
    .setColorForeground(color(254, 107, 53))
    .setColorBackground(color(255, 255, 255))
    .setColorCaptionLabel(color(243, 244, 247));

  //input field for FREQ
  i_f1.addTextfield("f1")
    .setPosition(278, 341.5)
    .setSize(100, 30)
    .setAutoClear(false)
    .setFont(font)
    .setColor(color(64, 64, 64))
    .setColorCursor(color(64, 64, 64))
    .setColorActive(color(254, 107, 53))
    .setColorForeground(color(254, 107, 53))
    .setColorBackground(color(255, 255, 255))
    .setColorCaptionLabel(color(243, 244, 247));
  i_f2.addTextfield("f2")
    .setPosition(278, 504.5)
    .setSize(100, 30)
    .setAutoClear(false)
    .setFont(font)
    .setColor(color(64, 64, 64))
    .setColorCursor(color(64, 64, 64))
    .setColorActive(color(254, 107, 53))
    .setColorForeground(color(254, 107, 53))
    .setColorBackground(color(255, 255, 255))
    .setColorCaptionLabel(color(243, 244, 247));
}



void createBackgroundOnGUI() {
  background(255, 255, 255);
  fill(243, 244, 247);
  noStroke();
  //AREA-1
  rect(50, 25, 779, 198);
  //AREA-2
  rect(50, 227, 1200, 585);
  //AREA-3
  rect(833, 25, 417, 198);
}



void createTextOnGUI() {
  //AREA-1
  fill(64, 64, 64);
  text("TYPE", 150, 78);
  text("POLE", 150, 112);
  text("PERIOD:PULSE", 150, 146);
  text(":", 383.5, 146);
  //AREA-2
  text("FREQ", 150, 277);
  text("BEAT", 150, 603);
  text("f1", 200, 344.5);
  text("f2", 200, 507.5);
  text("|f1-f2|", 200, 670.5);
  text("Hz", 382, 344.5);
  text("Hz", 382, 507.5);
  text("Hz", 382, 670.5);
}



void createDisplaysOnGUI() {
  fill(255, 255, 255);
  //"Preview"
  rect(570, 75, 159, 98);
  //"FREQ"
  rect(460, 277, 686, 159);
  rect(460, 440, 686, 159);
  //"BEAT"
  rect(278, 667.5, 100, 30);
  rect(460, 603, 686, 159);
  if (settings.get("f1") != 0 && settings.get("f2") != 0) {
    fill(64, 64, 64);
    text(Math.abs( settings.get("f1") - settings.get("f2") ), 278, 670.5);
  }
  if (pulse != null) {
    for (int i = 0; i < 686; i++) {
      stroke( 68, 11, 212);
      line(460 + i, 356.5 - pulse.left.get(i) * pulseH, 460 + i+1, 356.5 - pulse.left.get(i+1) * pulseH);
      stroke(255, 32, 121);
      line(460 + i, 519.5 - pulse.right.get(i) * pulseH, 460 + i+1, 519.5 - pulse.right.get(i+1) * pulseH);
      stroke( (68 + 255) / 2, (11 + 32) / 2, (212 + 121) / 2);
      line(460 + i, 682.5 - ( pulse.right.get(i) + pulse.left.get(i) ) * pulseH, 460 + i+1, 682.5 - ( pulse.right.get(i+1) + pulse.left.get(i+1) ) * pulseH);
    }
    stroke(255, 255, 255);
  }
}



void createStatusOnGUI() {
  if ( settings.get("PERIOD") > 0 && settings.get("PULSE") > 0 && settings.get("PERIOD") > settings.get("PULSE")) {
    if ( (settings.get("f1") >= 20 && settings.get("f2") == 0)
      || (settings.get("f1") == 0 && settings.get("f2") >= 20)
      || (settings.get("f1") >= 20 && settings.get("f2") >= 20)) {
      fill(68, 11, 212);
      text("Ready", 933, 75);
      b_pellere.setEnabled(true);
      b_emg.setEnabled(true);
      b_pellere.setLocalColorScheme( 12 );
      b_emg.setLocalColorScheme( 11 );
    } else {
      fill(64, 64, 64);
      text("Unprepared", 933, 75);
      b_pellere.setEnabled(false);
      b_emg.setEnabled(false);
      b_pellere.setLocalColorScheme( 10 );
      b_emg.setLocalColorScheme( 10 );
    }
  } else {
    fill(64, 64, 64);
    text("Unprepared", 933, 75);
    b_pellere.setEnabled(false);
    b_emg.setEnabled(false);
    b_pellere.setLocalColorScheme( 10 );
    b_emg.setLocalColorScheme( 10 );
  }
}



void handleButtonEvents(GButton button, GEvent event) {
  if (event == GEvent.CLICKED) {
    if (button == b_pellere) {
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
    } else if (button == b_emg) {
      emg_flg = true;
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
    } else if (button == b_01s) {
      b_01s.setLocalColorScheme( 9 );
      b_1s.setLocalColorScheme( 8 );
      b_5s.setLocalColorScheme( 8 );
      settings.put("TIME", 0);
    } else if (button == b_1s) {
      b_01s.setLocalColorScheme( 8 );
      b_1s.setLocalColorScheme( 9 );
      b_5s.setLocalColorScheme( 8 );
      settings.put("TIME", 1);
    } else if (button == b_5s) {
      b_01s.setLocalColorScheme( 8 );
      b_1s.setLocalColorScheme( 8 );
      b_5s.setLocalColorScheme( 9 );
      settings.put("TIME", 2);
    }
  }
}



void updateSettingsFromInputFields() {
  settings.put("PERIOD", int(i_period.get(Textfield.class, "PERIOD").getText()));
  settings.put("PULSE", int(i_pulse.get(Textfield.class, "PULSE").getText()));
  settings.put("f1", int(i_f1.get(Textfield.class, "f1").getText()));
  settings.put("f2", int(i_f2.get(Textfield.class, "f2").getText()));
}



void generateSinWaves(HashMap set, float[] LPulse, float[] RPulse, float LCyc, float RCyc) {
  float pulseWidth_f1 = sampleRate / float(set.get("f1").toString());
  float pulseWidth_f2 = sampleRate / float(set.get("f2").toString());
  float wavelength_f1 = pulseWidth_f1 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString());
  float wavelength_f2 = pulseWidth_f2 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString());

  for (int j = 0; j < (int)LPulse.length/LCyc; j++) {
    for (int i = 0; i < (int)wavelength_f1; i++) { 
      LPulse[i+(int)LCyc*j] = 0.5 * (float)Math.sin(i/wavelength_f1 * 1 * Math.PI);
      //sin波の半周期分の山を作成
    }
    if (int(set.get("POLE").toString()) == 1) {
      //BiPoleの場合、もう半分の山を作成
      for (int i = (int)wavelength_f1; i < (int)wavelength_f1*2; i++) { 
        LPulse[i+(int)LCyc*j] = 0.5 * (float)Math.sin(i/wavelength_f1 * 1 * Math.PI);
      }
    }
    for (int ii = 0; ii < int(LCyc - ( wavelength_f1 * (int(set.get("POLE").toString())+1)) ); ii++) {
      LPulse[(int)wavelength_f1*(int(set.get("POLE").toString())+1) + ii +(int)LCyc*j] = 0;
      //山以外の部分が振幅=0になるように設定
    }
  }

  for (int j = 0; j < (int)RPulse.length/RCyc; j++) {
    for (int i = 0; i < (int)wavelength_f2; i++) { 
      RPulse[i+(int)RCyc*j] = (float)Math.sin(i/wavelength_f2 * 1 * Math.PI);
    }
    if (int(set.get("POLE").toString()) == 1) {
      for (int i = (int)wavelength_f2; i < (int)wavelength_f2*2; i++) { 
        RPulse[i+(int)RCyc*j] = (float)Math.sin(i/wavelength_f2 * 1 * Math.PI);
      }
    }
    for (int ii = 0; ii < int(RCyc - (wavelength_f2 * (int(set.get("POLE").toString())+1))); ii++) {
      RPulse[(int)wavelength_f2*(int(set.get("POLE").toString())+1) + ii +(int)RCyc*j] = 0;
    }
  }
  println(max(RPulse));
  println(max(LPulse));
  println(min(RPulse));
  println(min(LPulse));
  pulse = minim.createSample(LPulse, RPulse, format);
  //AudioSample createSample(float[] leftSampleData, float[] rightSampleData, AudioFormat format);
  //のようにして、１つの音源に左右独立の音を作成可能
  //さらに、流れ出てくる音はプラスの山->マイナスの山->...の順番で発生することがわかった
}



void generateSawWaves(HashMap set, float[] LPulse, float[] RPulse, float LCyc, float RCyc) {
  float pulseWidth_f1 = sampleRate / float(set.get("f1").toString());
  float pulseWidth_f2 = sampleRate / float(set.get("f2").toString());
  float wavelength_f1 = pulseWidth_f1 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString());
  float wavelength_f2 = pulseWidth_f2 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString());

  for (int j = 0; j < (int)LPulse.length/LCyc; j++) {
    for (int i = 0; i < (int)wavelength_f1; i++) {
      LPulse[i+(int)LCyc*j] = 0.5 * i / (wavelength_f1 - 1);
    }
    if (int(set.get("POLE").toString()) == 1) {
      for (int i = (int)wavelength_f1; i < (int)wavelength_f1 * 2 + 1; i++) {
        LPulse[i+(int)LCyc*j] = - 0.5 * (i - wavelength_f1) / wavelength_f1;
      }
    }
    for (int ii = 0; ii < int(LCyc - (pulseWidth_f1 * (int(set.get("POLE").toString()) + 1))); ii++) {
      LPulse[(int)LCyc*(int(set.get("POLE").toString()) + ii + (int)LCyc * j)] = 0;
    }
  }

  for (int j = 0; j < (int)RPulse.length/RCyc; j++) {
    for (int i = 0; i < (int)wavelength_f2; i++) {
      RPulse[i+(int)RCyc*j] = i / (wavelength_f2 - 1);
    }
    if (int(set.get("POLE").toString()) == 1) {
      for (int i = (int)wavelength_f2; i < (int)wavelength_f2 * 2 + 1; i++) {
        RPulse[i+(int)RCyc*j] = - (i - wavelength_f2) / wavelength_f2;
      }
    }
    for (int ii = 0; ii < int(RCyc - (pulseWidth_f2 * (int(set.get("POLE").toString()) + 1))); ii++) {
      RPulse[(int)RCyc*(int(set.get("POLE").toString()) + ii + (int)RCyc * j)] = 0;
    }
  }

  pulse = minim.createSample(LPulse, RPulse, format);
}



void generateSquareWaves(HashMap set, float[] LPulse, float[] RPulse, float LCyc, float RCyc) {
  float pulseWidth_f1 = sampleRate / float(set.get("f1").toString());
  float pulseWidth_f2 = sampleRate / float(set.get("f2").toString());
  float wavelength_f1 = pulseWidth_f1 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString());
  float wavelength_f2 = pulseWidth_f2 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString());

  for (int j = 0; j < (int)LPulse.length/LCyc; j++) {
    for (int i = 0; i < (int)wavelength_f1; i++) { 
      LPulse[i+(int)LCyc*j] = 1;
    }
    if (int(set.get("POLE").toString()) == 1) {
      for (int i = (int)wavelength_f1; i < (int)wavelength_f1*2; i++) { 
        LPulse[i+(int)LCyc*j] = - 1;
      }
    }
    for (int ii = 0; ii < int(LCyc - (wavelength_f1*(int(set.get("POLE").toString())+1)) ); ii++) {
      LPulse[int(wavelength_f1*(int(set.get("POLE").toString())+1) + ii + LCyc*j)] = 0;
    }
  }

  for (int j = 0; j < (int)RPulse.length/RCyc; j++) {
    for (int i = 0; i < (int)wavelength_f2; i++) { 
      RPulse[i+(int)RCyc*j] = 1;
    }
    if (int(set.get("POLE").toString()) == 1) {
      for (int i = (int)wavelength_f2; i < (int)wavelength_f2*2; i++) { 
        RPulse[i+(int)RCyc*j] = -1;
      }
    }
    for (int ii = 0; ii < int(RCyc - (wavelength_f2*(int(set.get("POLE").toString())+1)) ); ii++) {
      RPulse[int(wavelength_f2*(int(set.get("POLE").toString())+1) + ii + RCyc*j)] = 0;
    }
  }

  pulse = minim.createSample(LPulse, RPulse, format);
}
