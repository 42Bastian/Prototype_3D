int plsz_z = 256;
int plsz_x = 256;
int grid = 64;
int radius = 16;
int dia = radius*2;
int min_z = -10;
int[] planey = new int[plsz_x*plsz_z];
int[] col = new int[2*plsz_x*plsz_z];
dot3d[] normals = new dot3d[2*(plsz_x)*(plsz_z)];
dot3d[] vnormals = new dot3d[plsz_x*plsz_z];
dot3d[] normals_rotated = new dot3d[2*(dia-1)*(dia-1)];
dot3d[] vnormals_rotated = new dot3d[dia*dia];
Tri[] triangles = new Tri[2*(dia-1)*(dia-1)];
int[] plx = new int[dia*dia];
int[] ply = new int[dia*dia];
int[] plz = new int[dia*dia];

int _color(int p, int py, int maxy)
{
  int col;
  /*
  py *= 3;
   if ( py > 255 ) py = 255;
   return (py << 8)|(100<<16);
   */
  /**/

  if ( py < -10 ) {
    col = (p*5)+150;
  } else if ( py < 4 ) {
    col = (50<<16)|(100<<8);
  } else
  {
    float m = float(py)/float(maxy);
    col = (int(90.+45*m))<<16;
    col |= (int(60.+15*m))<<8;
    col |= (int(60.+15*m));
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
  for (int z = 0; z < plsz_z; ++z) {
    for (int x = 0; x < plsz_x; ++x) {
      /**/
      int q = (x ^ z ) & 31;
      //q = int(sin((x^z)/2.2)*15+16);
      //y = q < 15 ? int(h/2*sin(x/5.1)) : q < 28 ? 10 : int(sin(x/1.1)*h+h);
      /**/
      y = int(sin(x/3.3)*cos(z/2.1)*h+cos(z/4.3)*h + sin((x + z)/1.5)*h/2);
      //y = z >= plsz_z/2-4 ? 5 : 0;if ( (z > plsz_z-10) ) y = 34;
      // y = int(sin(z/(plsz_x/4.0))*10+5*((x+z)/(plsz_z/65.0)));
      //y = y < -10 ? 0 : y;
      planey[n] = y;
      maxy = max(maxy, y);
      ++n;
    }
  }
  for (int i = 0; i < vnormals.length; ++i) {
    vnormals[i] = new dot3d(0, 0, 0);
  }

  n = 0;
  for (int z = 0; z < plsz_z; ++z) {
    for (int x = 0; x < plsz_x; ++x) {
      int x1;
      int z1;

      x1 = (x+1) & (plsz_x-1);
      z1 = (z+1) & (plsz_z-1);
      int _p0 = x+z*plsz_x;
      int _p1 = x1+z*plsz_x;
      int _p2 = x+z1*plsz_x;
      int _p3 = x1+z1*plsz_x;
      int y0 = planey[_p0];
      int y1 = planey[_p1];
      int y2 = planey[_p2];
      int y3 = planey[_p3];
      int c;

      c = _color(0, (y0+y1+y2+y3)/4, maxy);

      y0 = y0 < 0 ? 1 : y0;
      y1 = y1 < 0 ? 1 : y1;
      y2 = y2 < 0 ? 1 : y2;
      y3 = y3 < 0 ? 1 : y3;

      planey[_p0] = y0;
      planey[_p1] = y1;
      planey[_p2] = y2;
      planey[_p3] = y3;

      dot3d p0 = new dot3d(0, y0, 0);
      dot3d p1 = new dot3d(grid, y1, 0);
      dot3d p2 = new dot3d(0, y2, grid);
      dot3d p3 = new dot3d(grid, y3, grid);

      normals[n] = calculateNormal(p0, p1, p2);
      col[n] = c;
      vnormals[_p0].add(normals[n]);
      vnormals[_p1].add(normals[n]);
      vnormals[_p2].add(normals[n]);

      ++n;

      normals[n] = calculateNormal(p1, p3, p2);
      col[n] = c;
      vnormals[_p1].add(normals[n]);
      vnormals[_p3].add(normals[n]);
      vnormals[_p2].add(normals[n]);

      ++n;
    }
  }
  for (int i = 0; i < vnormals.length; ++i) {
    vnormals[i].normalize();
  }

  col[35+8*plsz_x] = 255<<16;
  col[36+8*plsz_x] = 255<<16;
  col[35+9*plsz_x] = 255<<16;
  col[36+9*plsz_x] = 255<<16;
  col[35+40*plsz_x] = 255<<8;
  col[36+40*plsz_x] = 255<<8;
  col[35+41*plsz_x] = 255<<8;
  col[36+41*plsz_x] = 255<<8;
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
    x = x_pos-radius;
    for (int ix = 0; ix < dia; ++ix, ++x) {
      ox = x & (plsz_x-1);
      oz = z & (plsz_z-1);
      
      int norg = ox+oz*plsz_x;
      int wx = x*grid-camera.x/256;
      int wz = z*grid-camera.z/256;
      int rx = ((wx*co(angle)+wz*si(angle))+16383)/32768;
      int rz = ((-wx*si(angle)+wz*co(angle))+16383)/32768;
      plx[n] = rx;
      plz[n] = rz;
      ply[n] = planey[norg] - camera.y;

      vnormals_rotated[n] = rotY(vnormals[norg], angle);
      ++n;
      /* Map */
      plot(rez_x-dia/2+rx/grid-10, 10+dia/2+rz/grid, col[norg], 255);
    }
  }

  n = 0;
  z = z_pos-radius;
  for (int iz = 0; iz < dia-1; ++iz, ++z) {
    x = x_pos-radius;
    for (int ix = 0; ix < dia-1; ++ix, ++x) {
      ox = x & (plsz_x-1);
      oz = z & (plsz_z-1);
      int idx = 2*(ox+oz*plsz_x);

      int x1 = (ix+1) & (dia-1);
      int z1 = (iz+1) & (dia-1);
      int p0 = ix+iz*dia;
      int p1 = x1+iz*dia;
      int p2 = ix+z1*dia;
      int p3 = x1+z1*dia;

      if ( plz[p0] < min_z && plz[p1] < min_z && plz[p2] < min_z && plz[p3] < min_z ) {
        continue;
      }

      triangles[n] = new Tri(p0, p1, p2, col[idx]);
      normals_rotated[n] = rotY(normals[idx], angle);

      ++n;

      triangles[n] = new Tri(p1, p3, p2, col[idx+1]);
      normals_rotated[n] = rotY(normals[idx+1], angle);
      ++n;
    }
  }
  plot(rez_x-radius-10, 10+radius, 0xffffff, 255);
  plot(rez_x-radius-10, 10+radius-far_z/grid, 255<<16, 255);

  plane = new Object(normals_rotated, vnormals_rotated, plx, ply, plz, triangles);

  // println("Tris:",n,"<",(dia-1)*(dia-1)*2);
  /**/
  /**/
  //exportPlaneAsArrays("/Users/bastian/tmp/planex.inc", px, py, pz);
}
