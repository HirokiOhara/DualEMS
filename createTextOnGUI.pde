void createTextOnGUI() {
  /*
   AREA-1 */
  fill(64, 64, 64);
  text("Type", x_calib + 100, y_calib + 53);
  text("Pole", x_calib + 100, y_calib + 87);
  text("PI:PW", x_calib + 100, y_calib + 121);  //Pulse Width per Pulse Interval
  text(":", x_calib + 333.5, y_calib + 121);
  text("INV", x_calib + 100, y_calib + 155);
  /*
   Pulse幅の表示 */
  //text("Pulse Width", x_calib + 520, y_calib + 53);
  //for (int i=0; i < pulseWidths.length; i++) {
  //  text("f"+(i+1)+":", x_calib + 520, y_calib + 87 + i*34);
  //  text("usec", x_calib + 620, y_calib + 87 + i*34);
  //}
  for (int i=0; i < pulseWidths.length; i++) {
    if (pulseWidths[i] > 0) {
      text((int)pulseWidths[i], x_calib + 550, y_calib + 87 + i*34);
    }
  }
  /*
   AREA-2 */
  text("FREQ", x_calib + 100, y_calib + 252);
  text("Beat", x_calib + 100, y_calib + 578);
  text("f1", x_calib + 150, y_calib + 319.5);
  text("f2", x_calib + 150, y_calib + 482.5);
  text("|f1-f2|", x_calib + 150, y_calib + 645.5);
  text("Hz", x_calib + 332, y_calib + 319.5);
  text("Hz", x_calib + 332, y_calib + 482.5);
  text("Hz", x_calib + 332, y_calib + 645.5);
}
