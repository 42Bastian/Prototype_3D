void setupCube()
{

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
}

int[] cx = new int[]{-50/2, 50/2, 50/2, -50/2, -50/2, 50/2, 50/2, -50/2};
int[] cy = new int[]{-50/2, -50/2, -50/2, -50/2, 50/2, 50/2, 50/2, 50/2};
int[] cz = new int[]{-50/2, -50/2, 50/2, 50/2, -50/2, -50/2, 50/2, 50/2};

int[] cube_faces = new int[]{
  0, 1, 5, 5, 4, 0,
  2, 3, 7, 7, 6, 2,
  1, 2, 6, 6, 5, 1,
  0, 4, 7, 7, 3, 0,
  3, 2, 1, 1, 0, 3,
  7, 4, 5, 5, 6, 7
};

int[] cube_normals = new int[]{
  0, 0, 256,
  0, 0, 256,
  0, 0, -256,
  0, 0, -256,
  -256, 0, 0,
  -256, 0, 0,
  256, 0, 0,
  256, 0, 0,
  0, 256, 0,
  0, 256, 0,
  0, -256, 0,
  0, -256, 0
};

int[] cube_vnormals = new int[]{
  147, 147, 147,
  -147, 147, 147,
  -147, 147, -147,
  147, 147, -147,
  147, -147, 147,
  -147, -147, 147,
  -147, -147, -147,
  147, -147, -147
};
