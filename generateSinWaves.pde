void generateSinWaves(HashMap set, float[] LPulse, float[] RPulse, float LCyc, float RCyc) {
  float pulseWidth_f1 = sampleRate / float(set.get("f1").toString());
  float pulseWidth_f2 = sampleRate / float(set.get("f2").toString());
  float wavelength_f1 = pulseWidth_f1 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString());
  float wavelength_f2 = pulseWidth_f2 * float(set.get("PULSE").toString()) / float(set.get("PERIOD").toString());
  int pole = int(set.get("POLE").toString());
  /*
   Check the pole; 1:bi, 0:uni */
  if (pole == 1) {
    /*
     LPulse */
    for (int j = 0; j < int(LPulse.length/LCyc); j++) {
      /*
       Create sin wave (whose cycle is "2*wavelength_f1") */
      for (int i = 0; i <= int(wavelength_f1)*2; i++) {
        LPulse[i+int(LCyc)*j] = 0.5 * (float)Math.sin(i / wavelength_f1 * 1 * Math.PI);
      }
      /*
       In the wave length, set the amplitude as Zero except the sin wave section */
      for (int ii = 0; ii < int(LCyc - (wavelength_f1 * (pole + 1))); ii++) {
        LPulse[int(wavelength_f1)*(pole + 1) + ii +int(LCyc)*j] = 0;
      }
    }
    /*
     RPulse */
    for (int j = 0; j < int(RPulse.length/RCyc); j++) {
      for (int i = 0; i <= int(wavelength_f2)*2; i++) { 
        RPulse[i+int(RCyc)*j] = 0.5 * (float)Math.sin(i/wavelength_f2 * 1 * Math.PI);
      }
      for (int ii = 0; ii < int(RCyc - (wavelength_f2 * (pole + 1))); ii++) {
        RPulse[int(wavelength_f2)*(pole + 1) + ii + int(RCyc)*j] = 0;
      }
    }
  } else {
    /*
     LPulse */
    for (int j = 0; j < int(LPulse.length/LCyc); j++) {
      /*
       Create half sin wave (whose cycle is "wavelength_f1") */
      for (int i = 0; i <= int(wavelength_f1); i++) { 
        LPulse[i+int(LCyc)*j] = 0.5 * (float)Math.sin(i/wavelength_f1 * 1 * Math.PI);
      }
      for (int ii = 0; ii < int(LCyc - (wavelength_f1 * (pole + 1))); ii++) {
        LPulse[int(wavelength_f1)*(pole + 1) + ii +int(LCyc)*j] = 0;
      }
    }
    /*
     RPulse */
    for (int j = 0; j < int(RPulse.length/RCyc); j++) {
      for (int i = 0; i <= int(wavelength_f2); i++) { 
        RPulse[i+int(RCyc)*j] = 0.5 * (float)Math.sin(i/wavelength_f2 * 1 * Math.PI);
      }
      for (int ii = 0; ii < int(RCyc - (wavelength_f2 * (pole + 1))); ii++) {
        RPulse[int(wavelength_f2)*(pole + 1) + ii + int(RCyc)*j] = 0;
      }
    }
  }
  /*
   Inverte the signals */
  if (int(set.get("L_inver").toString()) == 1) {
    for (int k = 0; k < LPulse.length; k++) LPulse[k] = -LPulse[k];
  }
  if (int(set.get("R_inver").toString()) == 1) {
    for (int k = 0; k < RPulse.length; k++) RPulse[k] = -RPulse[k];
  }
  /*
   AudioSample createSample(float[] leftSampleData, float[] rightSampleData, AudioFormat format);
   のようにして、１つの音源に左右独立の音を作成可能 */
  pulse = minim.createSample(LPulse, RPulse, format);
}
