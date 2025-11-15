int worldsize = 128;
int grid = 64;
int radius = 12;
int dia = radius*2;

int[] planey = new int[worldsize*worldsize];
int[] col = new int[worldsize*worldsize];
dot3d[] normals = new dot3d[2*(worldsize)*(worldsize)];
dot3d[] vnormals = new dot3d[worldsize*worldsize];
dot3d[] normals_rotated = new dot3d[2*(dia-1)*(dia-1)];
dot3d[] vnormals_rotated = new dot3d[dia*dia];
Tri[] triangles = new Tri[2*(dia-1)*(dia-1)];
int[] plx = new int[dia*dia];
int[] ply = new int[dia*dia];
int[] plz = new int[dia*dia];

int[] px = new int[dia*dia];
int[] py = new int[dia*dia];
boolean[] visibility = new boolean[2*(dia-1)*(dia-1)];
int[] luminity = new int[2*(dia-1)*(dia-1)];
int[] lv = new int[dia*dia];

int _color(int p, int py, int maxy)
{
  int col;
  /*
  py *= 3;
   if ( py > 255 ) py = 255;
   return (py << 8)|(100<<16);
   */
  /**/

  if ( py < -20 ) {
    col =(p*5)+150;
  } else if ( py < 15 ) {
    col = (50<<16)|(100+abs(py)/2)<<8;
  } else
  {
    py -= 15;
    float m = sqrt(maxy*maxy-py*py/3);

    col = (int(m*0.5))<<16;
    col |= (int(m*0.3))<<8;
    col |= (int(m*0.2));
  }
  return col;
  /**/
}
void create_planey()
{
  int h = 50;
  int n = 0;
  int y;
  int maxy=0;
  for (int z = 0; z < worldsize; ++z) {
    for (int x = 0; x < worldsize; ++x) {
      /**/
      int q = (x ^ z ) & 31;
      //q = int(sin((x^z)/2.2)*15+16);
      //y = q < 15 ? int(h/2*sin(x/5.1)) : q < 28 ? 10 : int(sin(x/1.1)*h+h);
      /**/
      y = int(sin(x/3.3)*cos(z/2.1)*h+cos(z/4.3)*h + sin((x + z)/1.5)*h/2);
      //y = z >= worldsize/2-4 ? 5 : 0;if ( (z > worldsize-10) ) y = 34;
      // y = int(sin(z/(worldsize/4.0))*10+5*((x+z)/(worldsize/65.0)));
      //y = y < -10 ? 0 : y;
      //y = min(y, 200);
      planey[n] = y;
      maxy = max(maxy, y);
      ++n;
    }
  }
  for (int i = 0; i < vnormals.length; ++i) {
    vnormals[i] = new dot3d(0, 0, 0);
  }

  n = 0;
  for (int z = 0; z < worldsize; ++z) {
    for (int x = 0; x < worldsize; ++x) {
      int x1;
      int z1;

      x1 = (x+1) & (worldsize-1);
      z1 = (z+1) & (worldsize-1);
      int _p0 = x+z*worldsize;
      int _p1 = x1+z*worldsize;
      int _p2 = x+z1*worldsize;
      int _p3 = x1+z1*worldsize;
      int y0 = planey[_p0];
      int y1 = planey[_p1];
      int y2 = planey[_p2];
      int y3 = planey[_p3];
      int c0, c1;

      c0 = _color(0, (y0+y1+y2+y3)/4, maxy);
      //c0 = _color(0, (y0+y1+y2)/3, maxy);
      //c1 = _color(0, (y1+y2+y3)/3, maxy);

      y0 = y0 < 10 ? 0 : y0;
      y1 = y1 < 10 ? 0 : y1;
      y2 = y2 < 10 ? 0 : y2;
      y3 = y3 < 10 ? 0 : y3;

      dot3d p0 = new dot3d(0, y0, 0);
      dot3d p1 = new dot3d(grid, y1, 0);
      dot3d p2 = new dot3d(0, y2, grid);
      dot3d p3 = new dot3d(grid, y3, grid);

      normals[n] = calculateNormal(p0, p1, p2);
      vnormals[_p0].add(normals[n]);
      vnormals[_p1].add(normals[n]);
      vnormals[_p2].add(normals[n]);
      col[n/2] = c0;
      ++n;

      normals[n] = calculateNormal(p1, p3, p2);
      vnormals[_p1].add(normals[n]);
      vnormals[_p3].add(normals[n]);
      vnormals[_p2].add(normals[n]);
      //col[n] = c1;
      ++n;
    }
  }
  for (int i = 0; i < vnormals.length; ++i) {
    vnormals[i].normalize();
  }
  for (int i = 0; i < planey.length; ++i) {
    if (planey[i] < 10 ) planey[i] = 0;
  }
  col[35+8*worldsize] = 255<<16;
  col[36+8*worldsize] = 255<<16;
  col[35+9*worldsize] = 255<<16;
  col[36+9*worldsize] = 255<<16;
  col[35+40*worldsize] = 255<<8;
  col[36+40*worldsize] = 255<<8;
  col[35+41*worldsize] = 255<<8;
  col[36+41*worldsize] = 255<<8;

  if ( exportPlane ) {
    exportPlaneAsArrays("/Users/bastian/tmp/planex.inc");
  }
}

int _sqrt(int n) 
{
  if (n < 0) {
    throw new IllegalArgumentException("Negative Zahlen haben keine reelle Quadratwurzel");
  }
  if (n == 0) return 0;

  int result = 0;
  int bit = 1 << 30;
  
  // find highest bit
  while (bit > n) {
    bit >>= 2;
  }

  while (bit != 0) {
    int temp = result + bit;
    result >>= 1;

    if (n - temp >= 0) {
      n -= temp;
      result += bit;
    }
    bit >>= 2;
  }

  return result;
}
int __sqrt(int n)
{
  int x0;
  x0 = n/2;
  while ( abs(x0*x0 - n) > n/4 ) {
    x0 = (x0+n/x0)/2;
  }
  return x0;
}
void create_plane(dot3d camera, int angle)
{
  int x_pos = (camera.x/256)/grid;
  int z_pos = (camera.z/256)/grid;

  int n;
  int x, z;
  int ox, oz;
  n = 0;
  z = z_pos-radius;
  for (int iz = 0; iz < dia; ++iz, ++z) {
    oz = (z & (worldsize-1))*worldsize;
    x = x_pos-radius;

    for (int ix = 0; ix < dia; ++ix, ++x) {
      ox = x & (worldsize-1);

      int norg = ox+oz;
      int wx = x*grid-camera.x/256;
      int wz = z*grid-camera.z/256;
      int rx = ((wx*co(angle)+wz*si(angle))+16383)/32768;
      int rz = ((-wx*si(angle)+wz*co(angle))+16383)/32768;
      int ry = planey[norg] - camera.y;
      plx[n] = rx;
      plz[n] = rz;
      ply[n] = ry;

      dot3d vn = vnormals_rotated[n] = rotY(vnormals[norg], angle);
      int lambient = ambient;
      lv[n] = max(0, 2*dot3d.dotProduct(vn, nlight));
      if ( darken ) {
        int d = rz*rz+rx*rx;
        int q = (far_z-3*grid)*(far_z-3*grid);
        if (d > q ) {
          //lambient -= (q*64*256)/d*256;
          lambient -= _sqrt(d-q)*256;
        }
      }
      lv[n] += lambient;

      /* Map */
      plot(rez_x-dia/2+rx/grid-10, 10+dia/2+rz/grid, col[norg*2], 255);

      /* project */
      if ( rz <= 0 ) {
        rz = 1;
      }
      rz = (1<<15)/rz;
      rx = (rx*rz)>>7;
      ry = (ry*rz)>>7;

      px[n] = rx + rez_x/2;
      py[n] = rez_y/2 - ry;
      /*******************/
      ++n;
    }
  }
  int p0, p1, p2, p3;
  n = 0;
  z = (z_pos-radius);
  x_pos -= radius;

  p0 = 0;
  p1 = 1;
  p2 = dia;
  p3 = dia+1;

  for (int i = 0; i < visibility.length; ++i) {
    visibility[i] = false;
  }
  for (int iz = 0; iz < dia-1; ++iz, ++z, ++p0, ++p1, ++p2, ++p3) {
    x = x_pos;
    oz = (z & (worldsize-1))*worldsize;

    for (int ix = 0; ix < dia-1; ++ix, ++x, ++p0, ++p1, ++p2, ++p3) {
      ox = (x & (worldsize-1))+oz;
      ox *= 2;

      //      if ( plz[p0] < -grid/2 || plz[p1] < -grid/2 || plz[p2] < -grid/2 || plz[p3] < -grid/2 )
      //        continue;

      dot3d _p0;
      dot3d normal = rotY(normals[ox], angle);
      int lambient = ambient;
      int p = p0;
      if ( plz[p] > plz[p1] ) p = p1;
      if ( plz[p] > plz[p2] ) p = p2;
      if ( plz[p] < 0 ) continue;
      if ( plz[p]*plz[p]+plx[p]*plx[p] > far_z*far_z ) continue;

      _p0 = new dot3d(plx[p], ply[p], plz[p]);
      if ( dot3d.dotProduct(normal, _p0) > 0 ) {
        visibility[n] = true;
        triangles[n] = new Tri(p0, p1, p2, col[ox/2]);
        luminity[n] = max(0, dot3d.dotProduct(normal, light));
        if ( darken ) {
          int d = _p0.z*_p0.z+_p0.x*_p0.x;
          int q = (far_z-3*grid)*(far_z-3*grid);
          if (d > q ) {
            //lambient -= (q*64*256)/d*256;
            lambient -= sqrt(d-q)*256;
          }
        }
        luminity[n] += lambient;

        ++n;
      }

      normal = rotY(normals[ox+1], angle);
      p = p1;
      if ( plz[p] > plz[p3] ) p = p3;
      if ( plz[p] > plz[p2] ) p = p2;
      //      if ( plz[p] < 0 ) continue;
      //      if ( plz[p]*plz[p]+plx[p]*plx[p] > far_z*far_z ) continue;

      _p0 = new dot3d(plx[p], ply[p], plz[p]);
      if ( dot3d.dotProduct(normal, _p0) > 0 ) {
        visibility[n] = true;
        triangles[n] = new Tri(p1, p3, p2, col[ox/2]);
        luminity[n] = max(0, dot3d.dotProduct(normal, light));
        luminity[n] += lambient;
        ++n;
      }
    }
  }
  //println(n," visible triangles");
  plot(rez_x-radius-10, 10+radius, 0xffffff, 255);
  plot(rez_x-radius-10, 10+radius-far_z/grid, 255<<16, 255);

  plane = new Object(normals_rotated, vnormals_rotated, px, py, plx, ply, plz,
    triangles, visibility, luminity, lv);
  // println("Tris:",n,"<",(dia-1)*(dia-1)*2);
  /**/
  /**/
}
