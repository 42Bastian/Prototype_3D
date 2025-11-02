
static class dot3d {
  dot3d(int _x, int _y, int _z) {
    x = (_x);
    y = (_y);
    z = (_z);
  };
  int x, y, z;
  // Subtrahiert zwei Vektoren
  static dot3d subtract(dot3d a, dot3d b) {
    return new dot3d(a.x - b.x, a.y - b.y, a.z - b.z);
  }
  int length() {
    return int(sqrt(x*x+y*y+z*z));
  }
  void add(dot3d a) {
    this.x += a.x;
    this.y += a.y;
    this.z += a.z;
  }
  void normalize_quick() {
    int sum = abs(x)+abs(y)+abs(z);
    if ( sum == 0 ) sum = 1;
    sum = (1<<15)/sum;
    x = (x*sum)>>(15-8);
    y = (y*sum)>>(15-8);
    z = (z*sum)>>(15-8);
  }
  void normalize() {
    x /= 4;
    y /= 4;
    z /= 4;
    float l = sqrt((x*x+y*y+z*z));
    if ( l == 0 ) {
      x = y = z = 0;
    } else {
      x = int((x<<8)/l);
      y = int((y<<8)/l);
      z = int((z<<8)/l);
    }
  }

  int dotProduct(dot3d a)
  {
    return (a.x * x + a.y * y + a.z * z);
  }
  static int dotProduct(dot3d a, dot3d b) {
    return (a.x * b.x + a.y * b.y + a.z * b.z);
  }

  static dot3d crossProduct(dot3d v1, dot3d v2) {
    return new dot3d(
      (v1.y * v2.z - v1.z * v2.y),
      (v1.z * v2.x - v1.x * v2.z),
      (v1.x * v2.y - v1.y * v2.x)
      );
  }

  static dot3d midpoint(dot3d a, dot3d b) {
    return new dot3d(
      (a.x + b.x) / 2,
      (a.y + b.y) / 2,
      (a.z + b.z) / 2
      );
  }
}

dot3d calculateNormal(dot3d p0, dot3d p1, dot3d p2)
{
  dot3d v1 = dot3d.subtract(p0, p1);
  dot3d v2 = dot3d.subtract(p0, p2);
  dot3d n = dot3d.crossProduct(v1, v2);
  n.normalize();
  return n;
}

dot3d calculateNormal_quick(dot3d p0, dot3d p1, dot3d p2)
{
  dot3d v1 = dot3d.subtract(p0, p1);
  dot3d v2 = dot3d.subtract(p0, p2);
  dot3d n = dot3d.crossProduct(v1, v2);
  n.normalize_quick();
  return n;
}

dot3d getCenter(dot3d p1, dot3d p2, dot3d p3)
{
  return new dot3d(
    (p1.x + p2.x + p3.x)/3,
    (p1.y + p2.y + p3.y)/3,
    (p1.z + p2.z + p3.z)/3);
}
dot3d rotY(dot3d p, int angle)
{
  if ( p.x > 32767 || p.z > 32767 ) println(p.x,p.y);
  return new dot3d(
    (p.x*co(angle)+p.z*si(angle))/32768,
    p.y,
    (-p.x*si(angle)+p.z*co(angle))/32768);
}
