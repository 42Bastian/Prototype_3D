// -*-c++-*-

int maxFaces = 20000;
int scale = 3;
PFont f;
boolean fill = !false;

int COL_FP = 8;

int ax = 0;
int ay = 0;
int az = 0;
int visibleFaces = 0;
int di_x = 512;
int di_y = 512;
int far_z;
int far_x = 1000;
int rez_x = 384;
int rez_y = 200;
int max_z;
int MAX_Z_LVL = 256;
int lix;
int liy;
int liz;
int ambient = int(255*0.2);
boolean directed = !true;
boolean darken = !false;
boolean gouraud = true;

dot3d light;
dot3d nlight;
int camera_angle = 490;
dot3d camera = new dot3d(0, 0, 0);

tri2d[] visTris = new tri2d[maxFaces];
int[] zlevels = new int[MAX_Z_LVL];

Object torus;
Object torus2;
Object plane;
Object plane2;
Object cube;
Object ball;

void settings()
{
  size(rez_x*scale, rez_y*scale);

  noSmooth();
}

void mouseClicked()
{
  if ( mouseButton == LEFT ) {
  }
}

class Tri {
  Tri(int a, int b, int c, int _col) {
    p1 = a;
    p2 = b;
    p3 = c;
    col2 = col3 = col = _col;
  }
  Tri(int a, int b, int c, int _col, int _col2, int _col3) {
    p1 = a;
    p2 = b;
    p3 = c;
    col = _col;
    col2 = _col2;
    col3 = _col3;
  }

  int p1, p2, p3, col, col2, col3;
}
class dot2d {
  public dot2d(int _x, int _y, int _col, int _l ) {
    x = _x;
    y = _y;
    l = _l;
    col = _col;
  };
  public dot2d(int _x, int _y) {
    x = _x;
    y = _y;
    col = 1;
    l = 255;
  };
  public int x, y, l, col;
};

class tri2d {
  tri2d(Object obj, int index)
  {
    boolean _gouraud = gouraud;
    int l = obj.luminity[index];
    int col = obj.triangles[index].col;
    int col2 = obj.triangles[index].col2;
    int col3 = obj.triangles[index].col3;
    if (obj.vnormals_rotated[0] == null ) {
      _gouraud = false;
    }

    int _p1 = obj.triangles[index].p1;
    if ( _gouraud ) {
      l = obj.lv[obj.triangles[index].p1];
    }
    p1 = new dot2d(obj.px[_p1], obj.py[_p1], col, l);

    int _p2 = obj.triangles[index].p2;
    if ( _gouraud ) {
      l = obj.lv[obj.triangles[index].p2];
    }
    p2 = new dot2d(obj.px[_p2], obj.py[_p2], col2, l);

    int _p3 = obj.triangles[index].p3;
    if ( _gouraud ) {
      l = obj.lv[obj.triangles[index].p3];
    }
    p3 = new dot2d(obj.px[_p3], obj.py[_p3], col3, l);

    z = max(obj.mz[_p1], obj.mz[_p2], obj.mz[_p3]);
    z = zscale(z);

    next = -1;
  }
  dot2d p1, p2, p3;
  int z;
  int next;
};


boolean faceIsVisible(dot3d v, dot3d normal)
{
  if ( v.z < -grid) return false;
  if ( v.z > far_z ) return false;
  return dot3d.dotProduct(normal, v) > 0;
}

int zscale(int z)
{
  int help = (MAX_Z_LVL<<8)/far_z;
  help =  (z * help)>>8;
  if ( help >= MAX_Z_LVL ) help = MAX_Z_LVL-1;
  if ( help < 0 ) help = 0;
  return help;
}

void addObject(Object obj)
{
  for (int fc = 0; fc < obj.nTriangles; ++fc) {
    if ( obj.alwaysVisible || obj.visibility[fc] ) {
      tri2d t = new tri2d(obj, fc);
      visTris[visibleFaces] = t;

      t.next = zlevels[t.z];
      zlevels[t.z] = visibleFaces;
      ++visibleFaces;
    }
  }
  //println("visible:",visibleFaces);
}
void render()
{
  int used_levels = 0;
  int rendered = 0;

  for (int zlevel = MAX_Z_LVL-1; zlevel >= 0; --zlevel) {
    int fc;
    /*
    if ( zlevel < 255 ){
     ambient = org_ambient;
     } else {
     ambient = 255-zlevel;
     }
     */
    fc = zlevels[zlevel];
    if ( fc >= 0 ) ++used_levels;
    while ( fc >= 0 ) {

      rendered += tri(visTris[fc]);
      fc = visTris[fc].next;
    }
  }
  //println("Used Z levels:", used_levels);
  // println("rendered:", rendered);
}

int last_framerate = 0;
int lastKey;

void draw()
{
  int horizon;

  horizon = (rez_y/2)+(di_x*camera.y)/far_z;
  fill(10, 10, 10);
  stroke(0, 0, 0);
  rect(0, 0, rez_x*scale, horizon*scale);
  fill(40, 80, 40);
  rect(0, horizon*scale, rez_x*scale, (rez_y-horizon)*scale);

  //ax = 88;

  light = new dot3d(-lix, -liy, -liz);

  nlight = light = rotY(light, camera_angle);
  nlight.normalize();
  light.normalize();
  //println(light.x,light.y, light.z);
  //println("---");
  visibleFaces = 0;
  max_z = -1000;
  for (int i = 0; i < MAX_Z_LVL; ++i) {
    zlevels[i] = -1;
  }
  /**/
  if ( torus.pos.z-camera.z < far_z ) {
    torus.pos.z += 10;
  } else {
    torus.pos.z = camera.z;
  }
  torus.pos.y = 0;
  torus.setPos(-100, 40, 500);
  torus.rotate(0, ax, 0, camera);
  //torus.move(camera);

  torus.visible();
  torus.project();
  // torus.dumpPoints(3);
  addObject(torus);
  //  }
  /**/
  /**
   torus2.setPos(new dot3d( 0*si(ax*4)*80/(1<<14),0, 300));
   torus2.rotate(0, 128,0);
   torus2.move(camera);
   torus2.visible(camera);
   torus2.project(camera);
   //  addObject(torus2);
   **/
  /**/
  cube.pos.x += 2;
  if ( cube.pos.x > plsz_x/2*grid) cube.pos.x -= plsz_x*grid;
  int cx = cube.pos.x/grid;
  int cz = cube.pos.z/grid;

  int cx1 = (cx+1) & (plsz_x-1);
  int cz1 = (cx+1) & (plsz_x-1);
  int cy = planey[cx+cz*plsz_x]+planey[cx1+cz*plsz_x];//+planey[cx1+cz*plsz_x]+planey[cx1+cz1*plsz_x];
  cube.pos.y = cy / 2 + 50;

  //cube.setPos(100, 50, 500);
  cube.rotate(0, 0, 0, camera);
  cube.visible();
  cube.project();
  addObject(cube);
  /**/
  create_plane(camera, camera_angle);
  plane.visible();
  plane.project();
  addObject(plane);
  /**/
  ball.rotate(0, ax, 0, camera);
  ball.visible();
  ball.project();
  addObject(ball);
  
  render();
  
  fill(200, 200, 0);
  text("ax:"+lix, 5, 10);
  text("ay:"+liy, 5, 40);
  text("az:"+liz, 5, 70);
  text("cx:"+camera.x/256, 100, 10);
  text("cy:"+camera.y, 100, 40);
  text("cz:"+camera.z/256, 100, 70);
  text("a:"+camera_angle, 100, 90);
  text("fz:"+far_z, 195, 10);
  text("directed:"+directed, 290, 10);
  text("gouraud: "+gouraud, 290, 40);

  int dx = -(4*si(camera_angle)+127)>>(15-8);
  int dz = (4*co(camera_angle)+127)>>(15-8);

  cx = (camera.x/grid/256) & (plsz_x-1);
  cz = (camera.z/grid/256) & (plsz_x-1);

  if ( keyPressed ) {
    //println(dx,dz);
    switch ( key ) {
    case '1':
      camera.y += 10;
      break;
    case '2':
      if ( camera.y - 5 > planey[cx+cz*plsz_x] && camera.y > 15 ) {
        camera.y -= 5;
      }
      break;
    case CODED:
      switch ( keyCode ) {
      case LEFT:
        camera_angle += 1;
        break;
      case RIGHT:
        camera_angle -= 1;
        break;
      case UP:
        cx = ((camera.x + 16*dx)/grid/256) & (plsz_x-1);
        cz = ((camera.z + 16*dz)/grid/256) & (plsz_x-1);
        cy = camera.y;
        if ( planey[cx+cz*plsz_x] < cy ) {
          camera.x += dx;
          camera.z += dz;
        }
        break;
      case DOWN:
        cx = ((camera.x - 16*dx)/grid/256) & (plsz_x-1);
        cz = ((camera.z - 16*dz)/grid/256) & (plsz_x-1);
        cy = camera.y;
        if ( planey[cx+cz*plsz_x] < cy ) {
          camera.x -= dx;
          camera.z -= dz;
        }
        break;
      }
      break;
    case '5':
    case '6':
       dx = -(4*si(camera_angle+128)+127)>>(15-8);
       dz = (4*co(camera_angle+128)+127)>>(15-8);
       if ( key == '5' ){
         camera.x += dx;
         camera.z += dz;
       } else {
         camera.x -= dx;
         camera.z -= dz;
       }         
      break;
    case 'q':
      liy += 10;
      break;
    case 'y':
      liy -= 10;
      break;
    case 'w':
      liz += 10;
      break;
    case 'x':
      liz -= 10;
      break;
    case 'a':
      lix -= 10;
      break;
    case 'd':
      lix += 10;
      break;
    case 'p':
      if ( lastKey != key ) {
        gouraud = !gouraud;
      }
      break;
    case 'o':
      if ( lastKey != key ) {
        directed = !directed;
      }
      break;
    default:
      /* empty */
    }
    lastKey = key;
  } else {
    lastKey = 0;
  }
  if ( camera.z/256 < -plsz_z/2*grid) camera.z = plsz_z/2*grid*256;
  if ( camera.z/256 >  plsz_z/2*grid) camera.z = -plsz_z/2*grid*256;
  if ( camera.x/256 < -plsz_x/2*grid) camera.x = plsz_x/2*grid*256;
  if ( camera.x/256 >  plsz_x/2*grid) camera.x = -plsz_x/2*grid*256;

  camera_angle &= 511;

  if ( !mousePressed ) {
    ++ax;
    ax &= 511;

    // ++ay;
    if ( ay >= 512 ) ay = 0;
    az &= 512;
    //++az;
    if ( az >= 512 ) az = 0;
    //->     camera.z += 5;
    //camera.y += 1;
  }
  /*
  if ( mousePressed ) {
   liz = far_z-int(float(far_z)/float(rez_y*scale)*float(mouseY));
   } else {
   liy = rez_y*scale-mouseY;
   }
   lix = rez_x*scale/2-mouseX;
   */
   
  /**
   if ( round(frameRate) != last_framerate ){
   println(round(frameRate));
   last_framerate = round(frameRate);
   }
   **/
}
