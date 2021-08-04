void createButtonAndInputFieldOnGUI() { 
  b_font = new Font( Font.SANS_SERIF, Font.PLAIN, 18 );
  GButton.useRoundCorners( false );
  /*
   button for TYPE */
  b_sin = new GButton( this, x_calib + 228, y_calib + 40, 71, 30, "Sin" );
  b_saw = new GButton( this, x_calib + 301, y_calib + 40, 71, 30, "Saw" );
  b_square = new GButton( this, x_calib + 374, y_calib + 40, 71, 30, "Square" );
  b_sin.setLocalColorScheme( 9 );
  b_saw.setLocalColorScheme( 8 );
  b_square.setLocalColorScheme( 8 );
  b_sin.setFont(b_font);
  b_saw.setFont(b_font);
  b_square.setFont(b_font);
  /*
   button for POLE */
  b_mono = new GButton( this, x_calib + 228, y_calib + 74, 107.5, 30, "Mono" );
  b_bi = new GButton( this, x_calib + 337.5, y_calib + 74, 107.5, 30, "Bi" );
  b_mono.setLocalColorScheme( 9 );
  b_bi.setLocalColorScheme( 8 );
  b_mono.setFont(b_font);
  b_bi.setFont(b_font);
  /*
   button for Pulse Inversion */
  b_inver_l = new GButton( this, x_calib + 228, y_calib + 142, 107.5, 30, "L" );
  b_inver_r = new GButton( this, x_calib + 337.5, y_calib + 142, 107.5, 30, "R" );
  b_inver_l.setLocalColorScheme( 8 );
  b_inver_r.setLocalColorScheme( 8 );
  b_inver_l.setFont(b_font);
  b_inver_r.setFont(b_font);
  /*
   button for 1[s], 2[s], 5[s] */
  //b_1s = new GButton( this, x_calib + 883, y_calib + 84, 71, 30, "1 sec" );
  b_1s = new GButton( this, x_calib + 228, y_calib + 865, 71, 30, "1 sec" );
  b_2s = new GButton( this, x_calib + 301, y_calib + 865, 71, 30, "2 sec" );
  b_5s = new GButton( this, x_calib + 374, y_calib + 865, 71, 30, "5 sec" );
  b_1s.setLocalColorScheme( 9 );
  b_2s.setLocalColorScheme( 8 );
  b_5s.setLocalColorScheme( 8 );
  b_1s.setFont(b_font);
  b_2s.setFont(b_font);
  b_5s.setFont(b_font);
  /*
   button for Pulse */
  //b_pulse = new GButton( this, x_calib + 883, y_calib + 118, 144, 30, "Pulse" );
  b_pulse = new GButton( this, x_calib + 228, y_calib + 909, 144, 30, "Pulse" );
  b_pulse.setLocalColorScheme( 10 );
  b_pulse.setFont(b_font);
  /*
   button for Stop */
  //b_stop = new GButton( this, x_calib + 1029, y_calib + 118, 71, 30, "Stop" );
  b_stop = new GButton( this, x_calib + 374, y_calib + 909, 71, 30, "Stop" );
  b_stop.setLocalColorScheme( 11 );
  b_stop.setFont(b_font);
  /*
   input field for PERIOD:PULSE */
  i_period = new ControlP5(this);
  i_pulse = new ControlP5(this);
  i_f1 = new ControlP5(this);
  i_f2 = new ControlP5(this);
  i_period.addTextfield("PERIOD")
    .setPosition(x_calib + 228, y_calib + 108)
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
    .setPosition(x_calib + 345, y_calib + 108)
    .setSize(100, 30)
    .setAutoClear(false)
    .setFont(font)
    .setColor(color(64, 64, 64))
    .setColorCursor(color(64, 64, 64))
    .setColorActive(color(254, 107, 53))
    .setColorForeground(color(254, 107, 53))
    .setColorBackground(color(255, 255, 255))
    .setCaptionLabel("");
  /*
   input field for FREQ */
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
