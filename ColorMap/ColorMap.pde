// SOURCE SKETCH FOR PROJECT 1 (COLOR) OF  FOR 2017 

import processing.pdf.*;    // to save screen shots as PDFs
PImage myFace; // picture of author's face, should be: data/pic.jpg in sketch folder
int n = 24; // Number of colors
color[] Map = new color[3*n]; // array containing proposed colors for the map
float r=10;  // darius of disk around mouse
float L=60;  // current L value in Lch space
boolean showLch=false, showTerrain=true;  // what to show
float x, y;  // rectangle sizes
int p = 256;   // resolution of terrain map
final int PERF_FIFTH = 210;
final int MAJOR_THIRD = 120;
final int MAX_HUE = 360;
final int MAX_LIGHTNESS = 100;
final int MAX_CHROMATICITY = 140;
final int CHROMATICITY_OFFSET = 20;
 

void setup() 
  {
  size(800, 800, P2D);  // opens canvas and selects rendering library
  myFace = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data (replace that file with your pic of your own face!!!)
  rectMode(CENTER);
  x = (float)width/(n+2); // dimensions of color rectangles for drawing
  y = (float)height/(n+2);
  computeJareksMap();           // compute proposed map
  }

// ************************************************************************ DRAW
void draw() 
  {  
  background(L*2.55);
  
  if(snapPic) beginRecord(PDF,PicturesOutputPath+"/P"+nf(pictureCounter++,3)+".pdf");  // *********** START PDF CAPTURE
  
  if(showTerrain) showRampOnTerrain(0,100,20,70);
  else if(showLch)  showLch(L);   // show Lch matrix
  else           // show ramps
    {
    image(myFace, width-myFace.width/2,35,myFace.width/2,myFace.height/2); 
    showMapRGB();  // linear ramp in LGB (above)
    showMapLch();  // proposed map (below)
    }
    
  // **** computes mouse coordinates in map space to compute the proper color  
  float h =  ((float)mouseX - x*1.5)/( width-2*x)*n;
  float c =  ((float)mouseY - y*1.5)/( height-2*y)*n;
  fill(LCHtoColor(L,100./n*c,360./n*h)); myDrawDisk(mouseX,mouseY,r);
  
  fill(0,0,200); // blue color for text ** YOUR NAME AS AUTHOR!!!
  text("Rossignac's 2017 CAe Course@GaTech, Project 1: Color map, Authors: Jarek Rossignac, Yury Park, Dibyendu Mondal",10,20); //
  text("ACTIONS: ` to snapPicture, ,/. to edit n="+n+", c/j to recomputeMyMap/JareksMap, ' ' to toggleShowPlot, </> to editPlotTesolution p="+p+", l to toggleShowLch mouse drag to edit L="+(int)L,10,height-8); // bottom text

  if(snapPic) {endRecord(); snapPic=false;} // ************************************************************************** END PDF CAPTURE
  } // end draw()

// ************************************************************************ MOUSE ACTIONS
void mouseDragged()
  {
  L-=(float)(mouseY-pmouseY)*100/height; // vertical mouse drag (press+move) changes L
  L=max(0,L); L=min(100,L);
  }

// ************************************************************************ KEY ACTIONS
void keyPressed()
  {
  if(key=='`') snapPic=true; // to snap an image of the canvas and save as zoomable a PDF
  if(key=='l') {showTerrain=false; showLch=!showLch;} // Show Lch matrix for current L
  if(key==' ') showTerrain=!showTerrain; // Show Lch matrix for current L
  if(key=='c') computeMyMap();
  if(key=='j') computeJareksMap();
  if(key=='p') printMap();
  if(key==',') {n=max(1,n-1); x = (float)width/(n+2);  y = (float)height/(n+2); computeMyMap(); } // decrement n (number of colors)
  if(key=='.') {n++; x = (float)width/(n+2);  y = (float)height/(n+2); computeMyMap(); }  // increment n
  if(key=='<') {p=max(1,p-1);  } // decrement n (number of colors)
  if(key=='>') {p++; }  // increment n
  }
  
// ************************************************************************ DISPLAY DISK (Ues to show mouse and color)
void myDrawDisk(float px, float py, float pr) 
  {
  ellipse(px,py,pr*2,pr*2);
  }


// ************************************************************************ COMPUTE, PRINT, SHOW MAPS

void computeMyMap() 
  {
  for(int i=0; i<n; i++) Map[i]=myMap(i,n); // press 'c'
  }
 
void computeJareksMap() 
  {
  for(int i=0; i<n; i++) Map[i]=JareksMap(i,n); // set at initialization
  }
 
void printMap()  // press 'p', make sure that it has been computed
  {
  for(int i=0; i<n; i++) 
    {
    float r = red(Map[i]), g = green(Map[i]), b = blue(Map[i]);
    println(nf(i,2,0)+": ("+nf(r,2,0)+","+nf(g,2,0)+","+nf(b,2,0)+")");
    }
  }
 
void showMapRGB() 
  {
  stroke(2.55*L);
  for(int i=0; i<n; i++) 
    {
    fill(color(255./n*i,255-255./n*i,2.55*L));
    rect((1.5+i)*x,height/2-y,x,y);
    }
  }
  
void showMapLch()  
  {
  stroke(2.55*L);
  for(int i=0; i<n; i++) 
    {
    fill(Map[i]);               //fill(myMap(i,n));
    rect((1.5+i)*x,height/2+y,x,y);
    }
  }

void showRampOnTerrain(float a, float b, float c, float d)
  {
  float s = float(width-60)/(p+1);
  noStroke();
  for(int i=0; i<p; i++) 
    for(int j=0; j<p; j++)
      {
      float v = L(0,L(0,a,p,b,j),p,L(0,d,p,c,j),i); 
      int r = floor(v/100*n);
      if(0<=r && r<n) fill(Map[r]); // fill(myMap(r,n));
      rect(30+(0.5+i)*s,30+(0.5+j)*s,s,s);
      }
  }
  
// ********** LERP of values
float L(float x1, float v1, float x2, float v2, float x) { return v1 + (v2-v1)*(x-x1)/(x2-x1);}



// ************************************************************************ SHOW LCH MATRIX FOR CURRENT L
void showLch(double l) 
  {
  stroke(2.55*(100-L));
  for(int i=0; i<n; i++) 
    for(int j=0; j<n; j++)
      {
      fill(LCHtoColor(l,100./n*j,360/n*i));
      rect((1.5+i)*x,(1.5+j)*y,x,y);
      }
  }
  
  
// ************************************************************************ CONVERSION BETWEEN COLOR SPACES
public double[] D65 = {95.0429, 100.0, 108.8900};
public double[] whitePoint = D65;
public double[][] Mi  = {{ 3.2406, -1.5372, -0.4986},
                         {-0.9689,  1.8758,  0.0415},
                         { 0.0557, -0.2040,  1.0570}};
public double[][] M   = {{0.4124, 0.3576,  0.1805},
                         {0.2126, 0.7152,  0.0722},
                         {0.0193, 0.1192,  0.9505}};


// LCH to color
color LCHtoColor(double L, double c, double h) {int [] C= LCHtoRGB(L,c,h); return color(C[0],C[1],C[2]);}

// LCH > RGB = (LCH > LAB) + (LAB > XYZ) + (XYZ > RGB)
public int[] LCHtoRGB(double L, double c, double h) {return XYZtoRGB(LABtoXYZ(LCHtoLAB(L, c, h)));}

// LCH > LAB (from http://www.brucelindbloom.com/index.html?Equations.html)
public double[] LCHtoLAB(double L, double c, double h) {
      double[] result = new double[3];
      h = Math.toRadians(h);
      result[0] = L;
      result[1] = c * Math.cos(h);
      result[2] = c * Math.sin(h);
      return result;
      }

// LAB > XYZ
public double[] LABtoXYZ(double[] LAB) {return LABtoXYZ(LAB[0], LAB[1], LAB[2]);}
public double[] LABtoXYZ(double L, double a, double b) {
      double[] result = new double[3];
      double y = (L + 16.0) / 116.0;
      double y3 = Math.pow(y, 3.0);
      double x = (a / 500.0) + y;
      double x3 = Math.pow(x, 3.0);
      double z = y - (b / 200.0);
      double z3 = Math.pow(z, 3.0);
      if (y3 > 0.008856) y = y3; else y = (y - (16.0 / 116.0)) / 7.787;
      if (x3 > 0.008856) x = x3; else x = (x - (16.0 / 116.0)) / 7.787;
      if (z3 > 0.008856) z = z3; else z = (z - (16.0 / 116.0)) / 7.787;
      result[0] = x * whitePoint[0];
      result[1] = y * whitePoint[1];
      result[2] = z * whitePoint[2];
      return result;
      }

// XYZ > RGB    
public int[] XYZtoRGB(double[] XYZ) {return XYZtoRGB(XYZ[0], XYZ[1], XYZ[2]);}
public int[] XYZtoRGB(double X, double Y, double Z) {
      int[] result = new int[3];
      double x = X / 100.0;
      double y = Y / 100.0;
      double z = Z / 100.0;
      // [r g b] = [X Y Z][Mi]
      double r = (x * Mi[0][0]) + (y * Mi[0][1]) + (z * Mi[0][2]);
      double g = (x * Mi[1][0]) + (y * Mi[1][1]) + (z * Mi[1][2]);
      double b = (x * Mi[2][0]) + (y * Mi[2][1]) + (z * Mi[2][2]);
      // assume sRGB
      if (r > 0.0031308) r = ((1.055 * Math.pow(r, 1.0 / 2.4)) - 0.055); else r = (r * 12.92);
      if (g > 0.0031308) g = ((1.055 * Math.pow(g, 1.0 / 2.4)) - 0.055); else g = (g * 12.92);
      if (b > 0.0031308) b = ((1.055 * Math.pow(b, 1.0 / 2.4)) - 0.055); else b = (b * 12.92);
      r = (r < 0) ? 0 : r;
      r = (r > 1) ? 1 : r;
      g = (g < 0) ? 0 : g;
      g = (g > 1) ? 1 : g;
      b = (b < 0) ? 0 : b;
      b = (b > 1) ? 1 : b;
      // convert 0..1 into 0..255
      result[0] = (int) Math.round(r * 255);
      result[1] = (int) Math.round(g * 255);
      result[2] = (int) Math.round(b * 255);
      return result;
      }
// ************************************************************************ TOOLS FOR SAVING INDIVIDUAL IMAGES OF CANVAS WITH INCREMENTED FILE NAMES
boolean snapPic=false;
String PicturesOutputPath="data/PDFimages";
int pictureCounter=0;
void snapPicture() {saveFrame("PICTURES/P"+nf(pictureCounter++,3)+".jpg"); }

// ********** STUDENT's SOLUTION (Modify myMap)
color JareksMap(int i, int n)
  {
  int j=i; if(j%4==2) j--; else if(j%4==1) j++;
  float c = 40+60.*((float)((j+4)%4))/3 ; 
  float l = 30+20./n*4*round(i/4)+50.*((float)((j+4)%4))/3; 
  float h = 360.*((int)(i/4))*4/n; 
  return LCHtoColor(l*0.8,c,h);
  }


// ********** STUDENT's SOLUTION (Modify myMap)
color myMap(int k, int n)
  {
  float l = MAX_LIGHTNESS * k / n;
  float c = MAX_CHROMATICITY + CHROMATICITY_OFFSET - (MAX_CHROMATICITY * k / n);
  float h;
  
  if (k % 2 == 1) {
    h = (((k-1) / 2) * PERF_FIFTH) % MAX_HUE;
  } else {
    h = MAJOR_THIRD + (((k-2)/2) * PERF_FIFTH) % MAX_HUE;
  }
  return LCHtoColor(l,c,h);
  }
  