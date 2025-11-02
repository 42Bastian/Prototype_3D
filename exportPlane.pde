void exportPlaneAsArrays(String filename, int[] px, int[] py, int[] pz)
{
  StringBuilder sb = new StringBuilder();
  int n;
  sb.append(" align 4\nplane_points:\n dc.l "+(plsz_x)*(plsz_z)+"\n");
  n = 0;
  for (int i = 0; i < (plsz_x); ++i) {
    for (int j = 0; j < (plsz_z); ++j, ++n) {
      sb.append(" _PT "+ px[n]+ ","+ py[n]+ ","+pz[n]+"\n");
    }
  }
  sb.append(" align 4\nplane_faces:\n dc.l "+ (plsz_x-1)*(plsz_z-1)*2+"\n");
  for (int z = 0; z < (plsz_z-1); ++z) {
    for (int x = 0; x < (plsz_x-1); ++x) {
      int p0 = x+z*plsz_x;
      int p1 = (x+1)+z*plsz_x;
      int p2 = x+(z+1)*plsz_x;
      int p3 = (x+1)+(z+1)*plsz_x;
      if ( py[p0] <= 0 && py[p1] <= 0 && py[p2] <= 0 ) {
        sb.append(" tri "+p0+","+p1+","+p2+",$0030\n");
      } else {
        sb.append(" tri "+p0+","+p1+","+p2+",$3030\n");
      }
      if ( py[p1] <= 0 && py[p3] <= 0 && py[p2] <= 0 ) {
        sb.append(" tri "+p1+","+p3+","+p2+",$0030\n");
      } else {
        sb.append(" tri "+p1+","+p3+","+p2+",$3030\n");
      }
    }
  }
  sb.append(" align 4\nplane_normals:\n dc.l "+(plsz_x-1)*(plsz_z-1)*2+"\n");
  n = 0;
  for (int i = 0; i < (plsz_x-1); ++i) {
    for (int j = 0; j < (plsz_z-1); ++j) {
      sb.append(" _PT "+plane.normals[n].x+","+plane.normals[n].y+","+plane.normals[n].z+"\n");
      ++n;
      sb.append(" _PT "+plane.normals[n].x+","+plane.normals[n].y+","+plane.normals[n].z+"\n");
      ++n;
    }
  }
  sb.append(" align 4\nplane_vnormals:\n dc.l "+plane.vnormals.length+"\n");
  for (int i = 0; i < plane.vnormals.length; ++i) {
    sb.append(" VNT "+plane.vnormals[i].x+","+plane.vnormals[i].y+","+plane.vnormals[i].z+"\n");
  }

  saveStrings(filename, split(sb.toString(), "\n"));
}
