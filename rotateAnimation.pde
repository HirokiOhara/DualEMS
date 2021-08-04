void rotateAnimation() {
  rectMode(CENTER);
  stroke(0);
  fill(30);
  translate(displayWidth*0.7 , y_calib + 100);
  if (lefty)
    rotate(calculated_list[4]*PI);  // 適当
  else
    rotate(-calculated_list[4]*PI);
  rect(0, 0, 40, 100);
  rectMode(CORNER);
}
