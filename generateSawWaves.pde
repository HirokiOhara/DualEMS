/*
 This functions "generateSawWaves" is mainly based on wavEMS(Kono 2019).*/   

void generateSawWaves(HashMap set, float[] LPulse, float[] RPulse, float LCyc, float RCyc) {
  float pulseWidth_f1 = sampleRate / float(set.get("f1").toString());
  float pulseWidth_f2 = sampleRate / float(set.get("f2").toString());
  int wavelength_f1 = int(pulseWidth_f1 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString()));
  int wavelength_f2 = int(pulseWidth_f2 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString()));
  int pole = int(set.get("POLE").toString());
  /*
   Check the pole; 1:bi, 0:uni */
  if (pole == 1) {
    /*
     LPulse */
    for (int j = 0; j < int(LPulse.length/LCyc); j++) {
      for (int i = 0; i < wavelength_f1; i++) {
        LPulse[i+int(LCyc)*j] = 0.5 * i / (wavelength_f1 - 1);
      }
      for (int i = int(wavelength_f1); i < wavelength_f1 * 2; i++) {
        LPulse[i+int(LCyc)*j] = - 0.5 * (i - wavelength_f1) / (wavelength_f1 - 1);
      }
      for (int ii = 0; ii < int(LCyc - (pulseWidth_f1 * (pole + 1))); ii++) {
        LPulse[int(LCyc)*(pole + ii + int(LCyc) * j)] = 0;
      }
    }
    /*
     RPulse */
    for (int j = 0; j < int(RPulse.length/RCyc); j++) {
      for (int i = 0; i < wavelength_f2; i++) {
        RPulse[i+int(RCyc)*j] = 0.5 * i / (wavelength_f2 - 1);
      }
      for (int i = int(wavelength_f2); i < wavelength_f2 * 2 + 1; i++) {
        RPulse[i+int(RCyc)*j] = - 0.5 * (i - wavelength_f2) / (wavelength_f2 - 1);
      }
      for (int ii = 0; ii < int(RCyc - (pulseWidth_f2 * (pole + 1))); ii++) {
        RPulse[int(RCyc)*(pole + ii + int(RCyc) * j)] = 0;
      }
    }
  } else {
    /*
     LPulse */
    for (int j = 0; j < int(LPulse.length/LCyc); j++) {
      for (int i = 0; i < wavelength_f1; i++) {
        LPulse[i+int(LCyc)*j] = 0.5 * i / (wavelength_f1 - 1);
      }
      for (int ii = 0; ii < int(LCyc - (pulseWidth_f1 * (pole + 1))); ii++) {
        LPulse[int(LCyc)*(pole + ii + int(LCyc) * j)] = 0;
      }
    }
    /*
     RPulse */
    for (int j = 0; j < int(RPulse.length/RCyc); j++) {
      for (int i = 0; i < wavelength_f2; i++) {
        RPulse[i+int(RCyc)*j] = 0.5 * i / (wavelength_f2 - 1);
      }
      for (int ii = 0; ii < int(RCyc - (pulseWidth_f2 * (pole + 1))); ii++) {
        RPulse[int(RCyc)*(pole + ii + int(RCyc) * j)] = 0;
      }
    }
  }
  if (int(set.get("L_inver").toString()) == 1) {
    for (int k = 0; k < LPulse.length; k++) LPulse[k] = -LPulse[k];
  }
  if (int(set.get("R_inver").toString()) == 1) {
    for (int k = 0; k < RPulse.length; k++) RPulse[k] = -RPulse[k];
  }
  pulse = minim.createSample(LPulse, RPulse, format);
}
