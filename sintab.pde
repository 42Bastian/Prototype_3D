int[] sintab = new int[512];
int si(int angle)
{
  int s;
  angle &= 511;
  
  //return int(sin(angle*PI/256)*32768);
  /**/
  return sintab[angle];
  /**/
  //return int(sin(angle*PI/256)*(1<<15));
  //return sintab[angle & 255];
}
int co(int angle)
{
  return si(angle+128);
}
