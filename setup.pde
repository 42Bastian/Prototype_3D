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

  if ( exportPlane ) {
    String[] lines = loadStrings("cry.tab");
    cry = new int[lines.length];
    println(lines.length);

    for (int i = 0; i < lines.length; i++) {
      cry[i] = int(lines[i]);
    }
  }
  light = new dot3d(-lix, -liy, -liz);
  light.normalize();
  println("Light:", light.x, light.y, light.z);
  for (int i = 0; i < 512; ++i) {
    sintab[i] = int(sin(i*PI/256)*32768);
  }
  setupBall();
  setupTorus();
  setupCube();
  create_planey();
  liz = 0;
  lix = 1000;
  liy = 300;
  far_z = radius*grid;
  far_x = 8*grid; //radius*grid;
  camera.x = 782*256;
  camera.y = 60;
  camera.z = 1024*256;
  camera_angle = 256;

}
String h(int n)
{
  return hex(n, 8);
}
