void createDisplaysOnGUI() {
  fill(255, 255, 255);
  /*
   "FREQ" */
  rect(x_calib + 520, y_calib + 252, 512, 159);
  rect(x_calib + 520, y_calib + 415, 512, 159);
  /*
   "BEAT" */
  rect(x_calib + 228, y_calib + 642.5, 100, 30);
  rect(x_calib + 520, y_calib + 578, 512, 159);
  if (settings.get("f1") != 0 && settings.get("f2") != 0) {
    fill(64, 64, 64);
    text(Math.abs( settings.get("f1") - settings.get("f2") ), x_calib + 228, y_calib + 645.5);
  }
  if (pulse != null) {
    stroke( 68, 11, 212);
    for (int i = 0; i < 512; i++) {
      line(x_calib + 520 + i, y_calib + 331.5 - pulse.left.get(i) * pulseH, x_calib + 520 + i+1, y_calib + 331.5 - pulse.left.get(i+1) * pulseH);
    }
    stroke(255, 32, 121);
    for (int i = 0; i < 512; i++) {
      line(x_calib  + 520 + i, y_calib + 494.5 - pulse.right.get(i) * pulseH, x_calib  + 520 + i+1, y_calib + 494.5 - pulse.right.get(i+1) * pulseH);
    }
    stroke( (68 + 255) / 2, (11 + 32) / 2, (212 + 121) / 2);
    for (int i = 0; i < 512; i++) {
      line(x_calib  + 520 + i, y_calib + 657.5 - ( pulse.right.get(i) + pulse.left.get(i) ) * pulseH, x_calib  + 520 + i+1, y_calib + 657.5 - ( pulse.right.get(i+1) + pulse.left.get(i+1) ) * pulseH);
    }
    stroke(255, 255, 255);
  }
}
