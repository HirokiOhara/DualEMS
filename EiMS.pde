/*
 GUI and Software for "EiMS"
 ver. 2.0
 
 This is made for Electrical Muscle Stimulation(EMS).
 The stimulation data is treated as audio data in this software.
 You can easilly set
   - Pulse number
   - Pulse type
   - Pulse pole
   - Pulse orientation
   - Pulse frequancy
   - Pulse width
   - Stimulation time
 for each stimulation.
 
 Also, you can get the force data and show graphic animation using Leptrino's sensor.
 The graphic animation is already set up to represent Y-axis rotation in the sensor's coordinate system.
 If you want chage the graphic animation, edit "rotateAnimation" file.
 
 Copyright (c) 2021 Hiroki Ohara
 Released under the MIT license */

/*
 Libraries */
import g4p_controls.*;
import controlP5.*;
import java.awt.Font;
import java.util.Map;
import ddf.minim.*;
import ddf.minim.ugens.*;
import javax.sound.sampled.*;
import processing.serial.*;
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
 For force sensor (Leptrino) ==================== ==================== */
PrintWriter file;
Serial my_port;
float time; // [msec]
boolean running = false;
int counter;  // output.csvのインデックス用
float[] rated_value_list = new float[6];  // センサーの定格値
boolean init;
float[] init_value_list = new float[6];
float[] calculated_list = new float[6];
/*
 利き手に合わせて"lefty"の値を変更する */
boolean lefty = true;
/*
 Check the connection between PC and sensor */
boolean connecting = false;
/*
 res_: Response from sensor */
byte res_bcc = 0x00;
int res_id = 0;
int res_state = 0;
byte[] res_data = new byte[0];
/*
 cc_: Control Character */
byte[] ccStart = new byte[]{0x10, 0x02};  // DEL STX
byte[] ccEnd = new byte[]{0x10, 0x03};    // DEL ETX
/*
 Command List */
byte[] checkProductInfo = {0x04, (byte)0xFF, 0x2A, 0x00};
byte[] checkRatedValue = {0x04, (byte)0xFF, 0x2B, 0x00};
byte[] checkDigitalFilter = {0x04, (byte)0xFF, (byte)0xB6, 0x00};
byte[] getHandShake = {0x04, (byte)0xFF, 0x30, 0x00};
byte[] getData = {0x04, (byte)0xFF, 0x32, 0x00};
byte[] stopData = {0x04, (byte)0xFF, 0x33, 0x00};
/* 
 OFF  : 0x00
 10Hz : 0x01
 30Hz : 0x02
 100Hz: 0x03 */
byte filter = 0x00;
byte[] setDigitalFilter = {0x08, (byte)0xFF, (byte)0xA6, filter, 0x00, 0x00, 0x00};
/* ==================== ==================== ==================== */
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
  /*
   For force sensor (Leptrino) ==================== ==================== */
  if (Serial.list().length >= 5)
    connecting = true;
  if (connecting) {
    my_port = portOpen();
    my_port.clear();
    sendMsg(my_port, checkRatedValue);
  }
  file = createWriter("output.csv");
  /* ==================== ==================== ==================== */
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
    running = false;
  }
  pushMatrix();
  rotateAnimation();
  popMatrix();
  //survey.print_();
}


void handleButtonEvents(GButton button, GEvent event) {
  if (event == GEvent.CLICKED) {
    if (button == b_pulse) {
      float[] pulse_f1 = new float[int(sampleRate * times.get(settings.get("TIME")))];
      float[] pulse_f2 = new float[int(sampleRate * times.get(settings.get("TIME")))];
      float cycle_f1 = sampleRate / (float)settings.get("f1");
      float cycle_f2 = sampleRate / (float)settings.get("f2");
      if (!running && connecting) {
        running = true;
        time = (times.get(settings.get("TIME")) + 1) * 1000;
        thread("subThread");
      }
      switch(settings.get("TYPE")) {
      case 0:
        generateSinWaves(settings, pulse_f1, pulse_f2, cycle_f1, cycle_f2);
        pulse.setGain(gainSin);
        pulse.trigger();
        break;
      case 1:
        generateSawWaves(settings, pulse_f1, pulse_f2, cycle_f1, cycle_f2);
        pulse.setGain(gainSaw);
        pulse.trigger();
        break;
      case 2:
        generateSquareWaves(settings, pulse_f1, pulse_f2, cycle_f1, cycle_f2);
        pulse.setGain(gainSquare);
        pulse.trigger();
        break;
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

/*
 For force sensor (Leptrino) ==================== ==================== */
void subThread() {
  while (running) {
    float cur = millis();
    init = true;
    counter = 0;
    sendMsg(my_port, getData);
    while (millis() - cur < time) {
      if (!running)
        break;
    }
    sendMsg(my_port, stopData);
    running = false;
  }
}

void keyPressed() {
  if (key == 'p') {
    file.flush();  // Writes the remaining data to the file
    file.close();  // Finishes the file
    exit();  // Stops the program
  }
}

void sendMsg(Serial p, byte[] cmd) {
  byte bcc = 0x00;
  int msg_id = 0;
  int msg_length = ccStart.length + cmd.length + ccEnd.length + 1;
  byte[] msg_lst = new byte[msg_length];
  for (int i = 0; i < ccStart.length; i++) {
    msg_lst[i] = ccStart[i];
    msg_id += 1;
  }
  for (int i = 0; i < cmd.length; i++) {
    msg_lst[msg_id] = cmd[i];
    bcc ^= cmd[i];
    msg_id += 1;
  }
  for (int i = 0; i < ccEnd.length; i++) {
    msg_lst[msg_id] = ccEnd[i];
    if (ccEnd[i] != 0x10)
      bcc ^= ccEnd[i];
    msg_id += 1;
  }
  msg_lst[msg_id] = bcc;
  p.write(msg_lst);
}

/*
 Called when data is available */
void serialEvent(Serial p) {
  byte inByte = (byte)p.read();
  switch(res_state) {
  case 0:
    if (inByte == ccStart[0]) {
      res_state += 1;
    }
    break;
  case 1:
    if (inByte == ccStart[1]) {
      res_state += 1;
    }
    break;
  case 2:
    res_data = new byte[inByte];
    res_data[res_id] = inByte;
    res_bcc ^= inByte;
    res_id += 1;
    res_state += 1;
    break;
  case 3:
    res_data[res_id] = inByte;
    res_bcc ^= inByte;
    res_id += 1;
    if (res_id == res_data.length)
      res_state += 1;
    break;
  case 4:
    if (inByte == ccEnd[0]) {
      res_state += 1;
    }
    break;
  case 5:
    if (inByte == ccEnd[1]) {
      res_bcc ^= inByte;
      res_state += 1;
    }
    break;
  case 6:
    if (res_bcc == inByte) {
      //println("> bcc of " + hex(res_data[2]) + " --- greate!");
      calForce(res_data);
    } else
      //println("> bcc of " + hex(res_data[2]) + " --- error");
      res_bcc = 0x00;
    res_id = 0;
    res_state = 0;
    break;
  }
}

void calForce(byte[] res) {
  byte cmd_type = res[2];
  switch(cmd_type) {
  case 0x2B:
    for (int i = 0; i < 6; i++) {
      String bi = binary(res[7 + 4*i]) + binary(res[6 + 4*i]) + binary(res[5 + 4*i]) + binary(res[4 + 4*i]);
      Integer sign = int(bi.substring(0, 1));
      String power = str(unbinary(bi.substring(1, 9)) - 127);
      String sig = bi.substring(9);
      float F = unbinary(str(int(float(1+ "." + sig) * pow(10, float(power)))));
      /* 
       sign=1は負の数 */
      if (sign == 1) {
        F -= F;
      }
      rated_value_list[i] = F;
    }
    break;
  case 0x30:
    String output_single = str(counter);
    for (int j = 0; j < 6; j++) {
      String bi = binary(res[5 + 2*j]) + binary(res[4 + 2*j]);
      float F = unbinary(bi);
      if (int(bi.substring(0, 1)) == 1) {  // Two's Complement
        float comp = unbinary("10000000000000000"); // 17 bits
        F = - (comp - F + 1);
      }
      if (abs(F) <= 10000) {
        if (init) {
          init_value_list[j] = rated_value_list[j] * F/10000;
        }
        //println(rated_value_list[j] * F/10000 - init_value_list[j]);
        calculated_list[j] = rated_value_list[j] * F/10000 - init_value_list[j];
        output_single +=  "," + calculated_list[j];
      } else
        println("error");
    }
    file.println(output_single);
    counter += 1;
    if (init) {
      init = false;
    }
    break;
  case 0x32:
    if (res_data[0] == 0x14) {
      String output_serial = str(counter);
      for (int j = 0; j < 6; j++) {
        String bi = binary(res[5 + 2*j]) + binary(res[4 + 2*j]);
        float F = unbinary(bi);
        if (int(bi.substring(0, 1)) == 1) {  // Two's Complement
          float comp = unbinary("10000000000000000"); // 17 bits
          F = - (comp - F + 1);
        }
        if (abs(F) <= 10000) {
          if (init) {
            init_value_list[j] = rated_value_list[j] * F/10000;
          }
          //println(rated_value_list[j] * F/10000 - init_value_list[j]);
          calculated_list[j] = rated_value_list[j] * F/10000 - init_value_list[j];
          output_serial +=  "," + calculated_list[j];
        } else
          println("error");
      }
      file.println(output_serial);
      counter += 1;
      if (init) {
        init = false;
      }
    }
    break;
  }
}
/* ==================== ==================== ==================== */
