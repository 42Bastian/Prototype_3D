void setup()
{
  surface.setLocation(2620-rez_x*scale, 48);
  rectMode(CORNER);
  fill(0, 0, 0);
  stroke(0, 0, 0);
  rect(0, 0, rez_x*scale, rez_y*scale);
  frameRate(60);
  f = createFont("Monaco", 20);
  textFont(f);
  textAlign(LEFT, CENTER);
  translate(0, 0);
  fill(255, 0, 0);
  text("Hello", 40, 10);

  light = new dot3d(-lix, -liy, -liz);
  light.normalize();
  println("Light:", light.x, light.y, light.z);

  setupBall();
  cube = new Object(cx, cy, cz, cube_faces.length/3);
  int[] cc = new int[]{
    255<<16, 255<<8, 255,
    255<<16|255<<8, 255<<16|255,
    255<<8|255, 255<<16|255, 255<<16|255<<8|255
  };
  for (int i = 0, in = 0, t = 0; i < cube_faces.length; ++t ) {
    int p2 = cube_faces[i++];
    int p1 = cube_faces[i++];
    int p3 = cube_faces[i++];

    dot3d n = new dot3d(cube_normals[in++], cube_normals[in++], cube_normals[in++]);
    cube.normals[t] = n;

    int col = cc[t/2];//(100<<8)|((t/2)*40);
    cube.addTriangle(new Tri(p1, p3, p2, col));
  }
  for (int vi = 0, i = 0; i < cx.length; ++i) {
    dot3d vn;
    vn = new dot3d(cube_vnormals[vi++], cube_vnormals[vi++], cube_vnormals[vi++]);
    cube.vnormals[i] = vn;
  }
cube.setPos(100, 50, 500);

  torus = new Object(lx, ly, lz, torus_faces.length/3);
  torus2 = new Object(lx, ly, lz, torus_faces.length/3);

  for (int i = 0, in = 0, t = 0; i < torus_faces.length; ++t ) {
    int p2 = torus_faces[i++];
    int p1 = torus_faces[i++];
    int p3 = torus_faces[i++];
    dot3d n;

    n = new dot3d(torus_normals[in++], torus_normals[in++], torus_normals[in++]);

    int col = 200<<16;//(120+(i&1)*20)<<16;//int(200/36.*n)+55;
    torus.normals[t] = n;
    if ( t < 24 ) col = (255<<16)+255;

    if ( t >= 272 & t <= 275 ) col = 128<<8;
    torus.addTriangle(new Tri(p1, p2, p3, col));

    col = (255)|(255<<8);
    torus2.normals[t] = n;
    if ( t == 0 ) col = 255<<16|120;

    torus2.addTriangle(new Tri(p1, p2, p3, col));
  }
  for (int vi = 0, i = 0; i < lx.length; ++i) {
    dot3d vn = new dot3d(torus_vnormals[vi++],
      torus_vnormals[vi++],
      torus_vnormals[vi++]);
    vn.normalize();
    torus.vnormals[i] = vn;
    torus2.vnormals[i] = vn;
  }

  torus.setPos(new dot3d(0, 50, 0));
  torus2.setPos(new dot3d(0, 00, 800));
  create_planey();

  liz = 0;
  lix = 1000;
  liy = 200;
  far_z = radius*grid;
  camera.x = 0*256;
  camera.y = 100;
  camera.z = 0*256;
}
String h(int n)
{
  return hex(n, 8);
}
