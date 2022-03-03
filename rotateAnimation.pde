void rotateAnimation() {
  rectMode(CENTER);
  stroke(0);
  fill(30);
  translate(displayWidth*0.7, y_calib + 100);
  if (lefty)
    rotate(calculated_list[4]/6*TWO_PI);  // トルクの定格容量：6[N*m]で rad=2pi 回転するようにした
  else
    rotate(-calculated_list[4]/6*TWO_PI);
  rect(0, 0, 40, 100);
  rectMode(CORNER);
}
