void plot(int x, int y, int col, int l)
{
  int r = (col >> 16) & 255;
  int g = (col >> 8) & 255;
  int b = col & 255;
  
  if ( l > 255 ) l = 255;
  if ( l < -255 ) l = -255;


  r += (r * l)>>COL_FP;
  g += (g * l)>>COL_FP;
  b += (b * l)>>COL_FP;

  if ( x < 0 || x > rez_x ) return;

  fill(r, g, b);
  stroke(r, g, b);
  rect(x*scale, y*scale, scale, scale);
}

void dline(int x0, int y0, int h0, int x1, int y1, int col1)
{
  int h = (h0+col1);
  fill(h, h0, col1);
  stroke(h, h0, col1);
  line(x0*scale, y0*scale, x1*scale, y1*scale);
}

int tri(tri2d t)
{
  return tri(t.p1, t.p2, t.p3);
}

void hline(int x0, int x1, int y, int l0, int l1, int col1)
{
  int dh;
  int dx;
  int mh;

  dx = x1-x0;
  if ( dx == 0 ) return;
  dh = l1-l0;
  mh = dh/dx;
  /**/
  if ( x0 > x1 ) {
    x0 += dx;
    x1 -= dx;
    //mh = -mh;
    dx = -dx;
    int t = l0;
    l0 = l1;
    l1 = t;
  }
  /**/
  // Interpolation an abgeschnittenen Rändern
  if (x0 < 0) {
    dx += x0;
    l0 -= mh * x0;
    x0 = 0;
  }

  if (x1 > rez_x-1) {
    dx -= (x1-rez_x);
  }

  for (; dx >= 0; --dx, ++x0) {
    plot(x0, y, col1, l0>>8);
    l0 += mh;
  }
}


int tri(dot2d p0, dot2d p1, dot2d p2)
{
  /**
   int dot1, dot2;
   dot1 = (p1.x-p0.x)*(p2.y-p1.y);
   dot2 = (p1.x-p2.x)*(p1.y-p0.y);
   dot1 += dot2;
   if ( dot1 > 0 ) return 0;
   **/

  if ( fill == false ) {
    dline(p0.x, p0.y, p0.col, p1.x, p1.y, p1.col);
    dline(p1.x, p1.y, p1.col, p2.x, p2.y, p2.col);
    dline(p2.x, p2.y, p2.col, p0.x, p0.y, p0.col);
    return 1;
  }
  // Sortiere Punkte nach y
  if (p0.y > p1.y) {
    dot2d t = p0;
    p0 = p1;
    p1 = t;
  }
  if (p1.y > p2.y) {
    dot2d t = p1;
    p1 = p2;
    p2 = t;
  }
  if (p0.y > p1.y) {
    dot2d t = p0;
    p0 = p1;
    p1 = t;
  }
  int x0 = p0.x*256;
  int x1 = p1.x*256;
  int x2 = p2.x*256;
  int y0 = p0.y;
  int y1 = p1.y;
  int y2 = p2.y;
  int l0 = p0.l;
  int l1 = p1.l;
  int l2 = p2.l;
  int col0 = p0.col;

  if ( x0 >= rez_x*256 && x1 >= rez_x*256 && x2 >= rez_x*256 ) {
    return 0;
  }
  if ( x0 < 0 && x1 < 0 && x2 < 0 ) {
    return 0;
  }
  if ( y0 < 0 && y1 < 0 && y2 < 0 ) {
    return 0;
  }
  if ( y0 >= rez_y && y1 >= rez_y && y2 >= rez_y ) {
    return 0;
  }

  //l0 = l1 = l2 = 255<<8;
  int dy01 = y1 - y0;
  int dy12 = y2 - y1;
  int dy02 = y2 - y0;

  if (dy02 == 0) return 0; // horizontales Dreieck

  int reci0 = dy01 != 0 ? (1<<14)/dy01 : 0;
  int reci1 = dy12 != 0 ? (1<<14)/dy12 : 0;
  int reci2 = (1<<14)/dy02;

  int dx02 = ((x2 - x0)*reci2)>>14;
  int dl02 = ((l2 - l0)*reci2)>>14;

  int dx01 = ((x1 - x0)*reci0)>>14;
  int dl01 = ((l1 - l0)*reci0)>>14;

  int dx12 = ((x2 - x1)*reci1)>>14;
  int dl12 = ((l2 - l1)*reci1)>>14;

  //col0 = (col0+p1.col+p2.col)/3;

  x2 = x0;
  l2 = l0;

  // Clip y
  if (y0 < 0) {
    x0 -= dx01*y0;
    l0 -= dl01*y0;
    x2 -= dx02*y0;
    l2 -= dl02*y0;
    y0 = 0;
  }
  if ( y1 < 0 ) {
    x1 -= dx12*y1;
    l1 -= dl12*y1;
    y1 = 0;
  }
  if ( y1 >= rez_y ) {
    y1 = rez_y-1;
  }
  if (y2 >= rez_y) {
    y2 = rez_y-1;
  }
  if ( y0 < y1 ) {
    for (; y0 < y1; ++y0) {
      hline((x0+128)/256, (x2+128)/256, y0, l0, l2, col0);

      x0 += dx01;
      l0 += dl01;
      x2 += dx02;
      l2 += dl02;
    }
  }

  x0 = x1;
  l0 = l1;
  for (; y0 < y2; ++y0) {
    hline((x0+128)/256, (x2+128)/256, y0, l0, l2, col0);
    x0 += dx12;
    l0 += dl12;
    x2 += dx02;
    l2 += dl02;
  }
  return 1;
}
