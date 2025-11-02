class Object {
  int maxTriangles;
  Object(int[] ox, int[] oy, int[] oz, int _maxTriangles)
  {
    this.ox = ox;
    this.oy = oy;
    this.oz = oz;
    mx = new int[ox.length];
    my = new int[ox.length];
    mz = new int[ox.length];
    px = new int[ox.length];
    py = new int[ox.length];
    lv = new int[ox.length];
    maxTriangles = _maxTriangles;
    vnormals = new dot3d[ox.length];
    vnormals_rotated = new dot3d[ox.length];
    triangles = new Tri[maxTriangles];
    normals = new dot3d[maxTriangles];
    normals_rotated = new dot3d[maxTriangles];
    visibility = new boolean[maxTriangles];
    luminity = new int[maxTriangles];
    nTriangles = 0;
    pos = new dot3d(0, 0, 0);
    alwaysVisible = false;
  }
  Object(dot3d[] normals_rotated, dot3d[] vnormals_rotated,
    int[] mx, int[] my, int[] mz, Tri[] triangles)

  {
    this.mx = mx;
    this.my = my;
    this.mz = mz;
    this.normals_rotated = normals_rotated;
    this.triangles = triangles;
    for ( nTriangles = 0; triangles[nTriangles] != null; ++nTriangles) {
      /*emtpy*/
    }
    this.maxTriangles = nTriangles;
    px = new int[mx.length];
    py = new int[mx.length];
    lv = new int[mx.length];
    this.vnormals_rotated = vnormals_rotated;
    visibility = new boolean[maxTriangles];
    luminity = new int[maxTriangles];
    alwaysVisible = false;
  }

  Object(Object org)
  {
    ox = new int[org.ox.length];
    arrayCopy(org.ox, ox);
    oy = new int[ox.length];
    arrayCopy(org.oy, oy);
    oz = new int[ox.length];
    arrayCopy(org.oz, oz);
    mx = new int[ox.length];
    my = new int[ox.length];
    mz = new int[ox.length];
    px = new int[ox.length];
    py = new int[ox.length];
    lv = new int[ox.length];
    maxTriangles = org.maxTriangles;
    vnormals = new dot3d[ox.length];
    arrayCopy(org.vnormals, vnormals);
    vnormals_rotated = new dot3d[ox.length];
    triangles = new Tri[maxTriangles];
    arrayCopy(org.triangles, triangles);
    normals = new dot3d[maxTriangles];
    arrayCopy(org.normals, normals);
    normals_rotated = new dot3d[maxTriangles];
    visibility = new boolean[maxTriangles];
    luminity = new int[maxTriangles];

    pos = new dot3d(org.pos.x, org.pos.y, org.pos.z);
    alwaysVisible = org.alwaysVisible;
    nTriangles = org.nTriangles;
    ax= org.ax;
    ay = org.ay;
    az = org.az;
  }
  void addTriangle(Tri t)
  {
    triangles[nTriangles] = t;
    ++nTriangles;
  }
  void setPos(int x, int y, int z)
  {
    pos.x = x;
    pos.y = y;
    pos.z = z;
  }

  void setPos(dot3d pos)
  {
    this.pos = pos;
  }

  dot3d p13d(int index)
  {
    Tri t = triangles[index];
    return new dot3d(mx[t.p1], my[t.p1], mz[t.p1]);
  }
  dot3d p23d(int index)
  {
    Tri t = triangles[index];
    return new dot3d(mx[t.p2], my[t.p2], mz[t.p2]);
  }
  dot3d p33d(int index)
  {
    Tri t = triangles[index];
    return new dot3d(mx[t.p3], my[t.p3], mz[t.p3]);
  }

  dot2d p12d(int index) {
    Tri t = triangles[index];
    return new dot2d(px[t.p1], py[t.p1], t.col, 255);
  }
  dot2d p22d(int index) {
    Tri t = triangles[index];
    return new dot2d(px[t.p2], py[t.p2], t.col, 255);
  }
  dot2d p32d(int index) {
    Tri t = triangles[index];
    return new dot2d(px[t.p3], py[t.p3], t.col, 255);
  }

  void rotate(int ax, int ay, int az, dot3d cam)
  {
    this.ax = ax;
    this.ay = ay;
    this.az = az;

    int cam_cos = co(camera_angle);
    int cam_sin = si(camera_angle);

    if ( ax != 0 || ay != 0 || az != 0 ) {
      int a = si(ax);
      int b = co(ax);
      int c = si(ay);
      int d = co(ay);
      int e = si(az);
      int f = co(az);

      int bc = b*c/32768;
      int ac = a*c/32768;
      int acfbe = ac*f/32768+b*e/32768;
      int aebcf = a*e/32768-bc*f/32768;
      int bceaf = bc*e/32768+a*f/32768;
      int bface = b*f/32768 - ac*e/32768;

      a = -a*d/32768;
      b = b*d/32768;
      f = d*f/32768;
      d = -d*e/32768;

      for (int i = 0; i < ox.length; ++i) {
        int rx = (f*ox[i] + d*oy[i] + c*oz[i]) / 32768;
        int ry = (acfbe*ox[i] + bface*oy[i] + a*oz[i]) / 32768;
        int rz = (aebcf*ox[i] + bceaf*oy[i] + b*oz[i]) / 32768;

        // 2. Translation
        int tx = rx + pos.x - cam.x/256;
        int ty = ry + pos.y - cam.y;
        int tz = rz + pos.z - cam.z/256;

        // 3. Kamera-Rotation
        mx[i] = (cam_cos * tx + cam_sin * tz) / 32768;
        my[i] = ty;
        mz[i] = (-cam_sin * tx + cam_cos * tz) / 32768;

        if ( vnormals[i] != null ) {
          int x = vnormals[i].x;
          int y = vnormals[i].y;
          int z = vnormals[i].z;
          int x1, y1, z1;

          x1 = int(f*x     +d*y     +c*z)/32768;
          y1 = int(acfbe*x +bface*y +a*z)/32768;
          z1 = int(aebcf*x +bceaf*y +b*z)/32768;

          x = (cam_cos * x1 + cam_sin * z1) / 32768;
          y = y1;
          z = (-cam_sin * x1 + cam_cos * z1) / 32768;

          vnormals_rotated[i] = new dot3d(x, y, z);
        }
      }
      for (int i = 0; i < nTriangles; ++i) {
        int x = normals[i].x;
        int y = normals[i].y;
        int z = normals[i].z;
        int x1, y1, z1;

        x1 = int(f*x     +d*y     +c*z)/32768;
        y1 = int(acfbe*x +bface*y +a*z)/32768;
        z1 = int(aebcf*x +bceaf*y +b*z)/32768;

        x = (cam_cos * x1 + cam_sin * z1) / 32768;
        y = y1;
        z = (-cam_sin * x1 + cam_cos * z1) / 32768;

        normals_rotated[i] = new dot3d(x, y, z);
      }
    } else {
      for (int i = 0; i < ox.length; ++i) {
        int tx = ox[i] + pos.x - cam.x/256;
        int ty = oy[i] + pos.y - cam.y;
        int tz = oz[i] + pos.z - cam.z/256;

        mx[i] = (cam_cos * tx + cam_sin * tz) / 32768;
        my[i] = ty;
        mz[i] = (-cam_sin * tx + cam_cos * tz) / 32768;

        if ( vnormals[i] != null ) {
          int x = vnormals[i].x;
          int y = vnormals[i].y;
          int z = vnormals[i].z;

          vnormals_rotated[i] = new dot3d(
            (cam_cos * x + cam_sin * z) / 32768,
            y,
            (-cam_sin * x + cam_cos * z) / 32768);
        }
      }
      for (int i = 0; i < nTriangles; ++i) {
        int x = normals[i].x;
        int y = normals[i].y;
        int z = normals[i].z;
        normals_rotated[i] = new dot3d(
          (cam_cos * x + cam_sin * z) / 32768,
          y,
          (-cam_sin * x + cam_cos * z) / 32768);
      }
    }
  }
  boolean in_sight()
  {
    int min_z = far_z;
    int max_z = 0;

    for (int i = 0; i < oz.length; ++i) {
      int z = mz[i];
      //if ( z < 0 ) return false;
      min_z = z < min_z ? z : min_z;
      max_z = z > max_z ? z : max_z;
    }
    return obj_visible = (min_z >= 0) && (max_z <= far_z);
  }
  void visible()
  {
    for (int i = 0; i < nTriangles; ++i) {

      dot3d p1 = p13d(i);
      dot3d p2 = p23d(i);
      dot3d p3 = p33d(i);
      dot3d n = normals_rotated[i];

      dot3d c = p1;
      if ( p2.z < c.z ) {
        c = p2;
      }
      if ( p3.z < c.z ) {
        c = p3;
      }
      visibility[i] = true;
      visibility[i] &= abs(p1.x) < far_x && abs(p2.x) < far_x && abs(p3.x) < far_x;

      visibility[i] = faceIsVisible(c, n);
      if ( visibility[i] ) {
        dot3d _lv = nlight;
        if ( directed ) {
          int x = c.x - camera.x/256;
          x = x < 0 ? x+plsz_x*grid : x;
          x = x > plsz_x*grid ? x-plsz_x*grid : x;
          int z = c.z - camera.z/256;
          z = z < 0 ? z+plsz_z*grid : z;
          z = z > plsz_z*grid ? z-plsz_z*grid : z;
          //println(c.x,c.z);
          //dot3d c = p1;//getCenter(p1, p2, p3);
          _lv = new dot3d(light.x - x, light.y - c.y, light.z - z);
          _lv.normalize();
        }
        int lambient = ambient;
        luminity[i] = max(0, 2*dot3d.dotProduct(n, _lv));
        if ( darken ) {
          if (c.z > far_z-3*grid ) {
            lambient -= 2*(abs(far_z-3*grid-c.z))*255;
          }
        }
        luminity[i] += lambient;
      }
    }
  }
  void project_point(int index) {
    int x = mx[index];
    int y = my[index];
    int z = mz[index];

    if ( z <= 0 ) {
      z = 1;
    }
    z = (1<<15)/z;
    x = (x*z)>>7;
    y = (y*z)>>7;

    px[index] = x + rez_x/2;
    py[index] = rez_y/2 - y;

    if (vnormals_rotated[index] != null ) {
      dot3d _lv = nlight;
      if ( directed ) {
        _lv = new dot3d(nlight.x-x, nlight.y-y, nlight.z-z);
        _lv.normalize_quick();
      }
      int lambient = ambient;
      lv[index] = dot3d.dotProduct(vnormals_rotated[index], _lv);
      if ( darken ) {
        z = mz[index];
        if (z > far_z-3*grid ) {
          z = abs(far_z-3*grid-z);
          lambient -= 2*(z)*255;
        }
      }
      lv[index] += lambient;
    }
  }
  void project()
  {
    for (int i = 0; i < mx.length; ++i) {
      project_point(i);
    }
  }

  int cntVisible() {
    int cnt = 0;
    for (int i = 0; i < nTriangles; ++i) {
      if ( visibility[i] ) ++cnt;
    }
    return cnt;
  }
  void dumpPoints(int type) {
    switch( type ) {
    case 0:
      println("original");
      break;
    case 1:
      println("rotated");
      break;
    case 2:
      println("moved");
      break;
    case 3:
      println("projected");
      println("Z        X   Y");
      break;
    case 4:
      println("visible");
    }
    if ( type >= 0 && type <= 3 ) {
      for (int i = 0; i < mx.length; ++i) {
        switch( type ) {
        case 0:
          println(ox[i], oy[i], oz[i], i);
          break;
        case 1:
          //          println(rx[i], ry[i], rz[i], i);
          break;
        case 2:
          println(h(mx[i]), h(my[i]), h(mz[i]), i);
          break;
        case 3:
          print(h(mz[i]), hex(px[i], 4)+hex(py[i], 4), " ");
          if ( (i & 1) == 1 ) println();
        }
      }
    } else {
      for (int i = 0; i < nTriangles; ++i) {
        if ( type == 4 ) {
          print(visibility[i] ? 1 : 0, " ");
          if ( (i & 3) == 3 ) println();
        }
      }
    }

    println("+++++++++++");
  }

  int[] ox, oy, oz;
  int[] mx, my, mz;
  int[] px, py, lv;
  dot3d[] vnormals, vnormals_rotated;
  dot3d[] normals;
  dot3d[] normals_rotated;
  boolean[] visibility;
  int[] luminity;
  int ax, ay, az;
  dot3d pos;
  Tri[] triangles;
  int nTriangles;
  boolean alwaysVisible;
  boolean obj_visible;
}
