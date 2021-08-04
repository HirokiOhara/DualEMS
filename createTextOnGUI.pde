void createTextOnGUI() {
  /*
   AREA-1 */
  fill(64, 64, 64);
  text("Type", x_calib + 100, y_calib + 40);
  text("Pole", x_calib + 100, y_calib + 74);
  text("PI:PW", x_calib + 100, y_calib + 108);  //Pulse Width per Pulse Interval
  text(":", x_calib + 333.5, y_calib + 108);
  text("INV", x_calib + 100, y_calib + 142);
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
