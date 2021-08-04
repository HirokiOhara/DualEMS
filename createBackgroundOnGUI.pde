void createBackgroundOnGUI() {
  background(255, 255, 255);
  fill(255, 255, 255);
  //fill(155, 155, 155);
  noStroke();
  /*
   AREA-1 */
  //rect(x_calib, y_calib, 779, 198);
  rect(x_calib, y_calib, displayWidth*0.8, 198);
  /*
   AREA-2 */
  rect(x_calib, y_calib + 202, displayWidth*0.8, 585);
  /*
   AREA-3 */
  fill(64, 64, 64);
  rect(x_calib, y_calib + 791, displayWidth*0.8, 198);
}
