class Survey {
  int fpsf;
  long nowTime;
  long frameTime;
  double f;
  float fps;
  int frame_survey;
  long startTime = System.currentTimeMillis();
  void print_() {
    frame_survey++;
    if (frame_survey == 1)frameTime = System.currentTimeMillis();
    fpsf++;
    nowTime= System.currentTimeMillis();
    double time=Math.floor((nowTime-startTime)/1000);
    if ( time - f >= 1)
    {
      println(fpsf +" fps / "+((nowTime-frameTime)/fpsf)+" ms ");
      fpsf=0;
      f=time;
      frameTime = System.currentTimeMillis();
    }
  }
}
