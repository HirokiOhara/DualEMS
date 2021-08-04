void createStatusOnGUI() {
  /*
   Pulse幅の表示 */
  //text("Pulse Width", x_calib + 520, y_calib + 53);
  //x_calib + 228, y_calib + 316.5
  text("lamda", x_calib + 150, y_calib + 360);
  text("lamda", x_calib + 150, y_calib + 520);
  text("usec", x_calib + 332, y_calib + 360);
  text("usec", x_calib + 332, y_calib + 520);
  for (int i=0; i < pulseWidths.length; i++) {
    if (pulseWidths[i] > 0) {
      text((int)pulseWidths[i], x_calib + 228, y_calib + 360 + i*160);
    }
  }
  if ( settings.get("PERIOD") > 0 && settings.get("PULSE") > 0 && settings.get("PERIOD") > settings.get("PULSE")) {
    if ( (settings.get("f1") >= 20 && settings.get("f2") == 0)
      || (settings.get("f1") == 0 && settings.get("f2") >= 20)
      || (settings.get("f1") >= 20 && settings.get("f2") >= 20)) {
      fill(149, 214, 208);
      rect(x_calib, y_calib + 791, displayWidth*0.8, 100);
      //text("Ready", x_calib + 100, y_calib + 909);
      b_pulse.setEnabled(true);
      b_stop.setEnabled(true);
      b_pulse.setLocalColorScheme( 12 );
      b_stop.setLocalColorScheme( 11 );
    } else {
      fill(0, 0, 0);
      //text("Unprepared", x_calib + 100, y_calib + 909);
      b_pulse.setEnabled(false);
      b_stop.setEnabled(false);
      b_pulse.setLocalColorScheme( 10 );
      b_stop.setLocalColorScheme( 10 );
    }
  } else {
    fill(0, 0, 0);
    //text("Unprepared", x_calib + 100, y_calib + 909);
    b_pulse.setEnabled(false);
    b_stop.setEnabled(false);
    b_pulse.setLocalColorScheme( 10 );
    b_stop.setLocalColorScheme( 10 );
  }
}
