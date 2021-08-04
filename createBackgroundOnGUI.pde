void createBackgroundOnGUI() {
  background(255, 255, 255);
  fill(255, 255, 255);
  noStroke();
  /*
   AREA-1 */
  rect(x_calib, y_calib, 779, 198);
  /*
   AREA-2 */
  rect(x_calib, y_calib + 202, 1200, 585);
  /*
   AREA-3 */
  fill(64, 64, 64);
  rect(x_calib + 783, y_calib, 417, 198);
}
