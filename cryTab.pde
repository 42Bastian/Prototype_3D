int cry[];

int rgb2cry(int rgb)
{
  int  intensity;
  int  color_offset;
  int  q;
  int red,green,blue;
  
  red = (rgb >> 16) & 0xff;
  green = (rgb >> 8 ) & 0xff;
  blue = rgb & 0xff;
  intensity = red;        /* start with red */
  if (green > intensity)
    intensity = green;
  if (blue > intensity)
    intensity = blue;      /* get highest RGB value */
  if (intensity != 0)
  {
    red = int(red * 255. / intensity);
    green = int(green * 255. / intensity);
    blue = int(blue * 255. / intensity);
  } else
    red = green = blue = 0;    /* R, G, B, were all 0 (black) */

  color_offset = (red & 0xF8) << 7;
  color_offset += (green & 0xF8) << 2;
  color_offset += (blue & 0xF8) >> 3;
  
  q = (cry[color_offset] << 8) | intensity;
  return q;
}
