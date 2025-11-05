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
  setupTorus();
  setupCube();
  create_planey();
  liz = 0;
  lix = 1000;
  liy = 300;
  far_z = radius*grid;
  camera.x = 0*256;
  camera.y = 100;
  camera.z = 0*256;
}
String h(int n)
{
  return hex(n, 8);
}
