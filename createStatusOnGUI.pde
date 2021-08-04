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
