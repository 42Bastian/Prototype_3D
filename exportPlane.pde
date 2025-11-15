void exportPlaneAsArrays(String filename)
{
  StringBuilder sb = new StringBuilder();
  int n;
  sb.append(" align 4\nplane_y:\n dc.w ");
  n = 0;
  for (int i = 0; i < (worldsize); ++i) {
    for (int j = 0; j < (worldsize); ++j, ++n) {
      sb.append(min(planey[n], 255));
      if ( (n & 15) == 15 ) sb.append("\n dc.w ");
      else sb.append(",");
    }
  }
  sb.append("0\n");

  sb.append(" align 4\nplane_col:\n dc.w ");
  n = 0;
  for (int i = 0; i < (worldsize); ++i) {
    for (int j = 0; j < (worldsize); ++j,++n) {
      sb.append("$"+hex(rgb2cry(col[n]), 4));
      if ( (n & 15) == 15 ) sb.append("\n dc.w ");
      else sb.append(",");
    }
  }
  sb.append("0\n");
  sb.append(" align 4\n;"+(worldsize-1)*(worldsize-1)*2+"\nplane_normals:\n dc.l ");
  n = 0;
  for (int i = 0; i < (worldsize-1); ++i) {
    for (int j = 0; j < (worldsize-1); ++j,++n) {
      sb.append(normals[n].x+","+normals[n].y+","+normals[n].z+",0,");      
      ++n;
      sb.append(normals[n].x+","+normals[n].y+","+normals[n].z+",0");
      if ( (n & 3) == 3 ) sb.append("\n dc.l ");
      else sb.append(",");
    }
  }
  sb.append(" 0\nalign 4\nplane_vnormals:\n");
  for (int i = 0; i < vnormals.length; ++i) {
    sb.append(" VNT "+vnormals[i].x+","+vnormals[i].y+","+vnormals[i].z+"\n");
  }
  saveStrings(filename, split(sb.toString(), "\n"));
}
