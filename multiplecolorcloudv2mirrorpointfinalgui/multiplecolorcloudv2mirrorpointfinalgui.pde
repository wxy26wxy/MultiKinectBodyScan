import java.nio.*;
import org.openkinect.processing.Kinect2;
import de.bezier.guido.*;

Slider bufferdepth11;
Slider bufferdepth21;
Slider scaleValue1;
Slider Xposition11;
Slider Yposition11;
Slider Depthposition11;
Slider Xposition21;
Slider Yposition21;
Slider Depthposition21;

Kinect2 kinect2a;
Kinect2 kinect2b;
int mode=0;
float angle = PI;
float scaleValue = -1500;
int minDepth =  0;
int maxDepth =  2000; //4.5m
int drawState = 1;
PImage depthImg;
//openGL
PGL pgl;
PShader sh;
int  vertLoc;
int  colorLoc;
float bufferdepth1=1000;
float bufferdepth2=1000;
float Xposition1=70;
float Yposition1=-100;
float Depthposition1=2050;
float scalez=0;
float Xposition2=0;
float Yposition2=0;
float Depthposition2=0;
int x=0;
void setup() {
  size(1440, 900, P3D);
  kinect2a = new Kinect2(this);
  kinect2b = new Kinect2(this);
  kinect2a.initDepth();
  kinect2a.initIR();
  kinect2a.initVideo();
  kinect2a.initRegistered();
  kinect2a.initDevice(0);
  kinect2b.initDepth();
  kinect2b.initIR();
  kinect2b.initVideo();
  kinect2b.initRegistered();
  kinect2b.initDevice(1);
  sh = loadShader("frag.glsl", "vert.glsl");
  smooth(16);

  Interactive.make(this); 
  bufferdepth11= new Slider ( 10, 100, 200, 10 );
  bufferdepth21= new Slider ( 10, 150, 200, 10 );
  scaleValue1= new Slider ( 10, 200, 200, 10 );
  Xposition11= new Slider ( 10, 250, 200, 10 );
  Yposition11= new Slider ( 10, 300, 200, 10 );
  Depthposition11= new Slider ( 10, 350, 200, 10 );
  Xposition21= new Slider ( 10, 400, 200, 10 );
  Yposition21= new Slider ( 10, 450, 200, 10 );
  Depthposition21= new Slider ( 10, 500, 200, 10 );
  stroke(255);

  Interactive.on( bufferdepth11, "valueChanged", this, "bufferdepth1Changed" );
  Interactive.on( bufferdepth21, "valueChanged", this, "bufferdepth2Changed" );
  Interactive.on( scaleValue1, "valueChanged", this, "scaleValueChanged" );
  Interactive.on( Xposition11, "valueChanged", this, "Xposition1Changed" );
  Interactive.on( Yposition11, "valueChanged", this, "Yposition1Changed" );
  Interactive.on( Depthposition11, "valueChanged", this, "Depthposition1Changed" );
  Interactive.on( Xposition21, "valueChanged", this, "Xposition2Changed" );
  Interactive.on( Yposition21, "valueChanged", this, "Yposition2Changed" );
  Interactive.on( Depthposition21, "valueChanged", this, "Depthposition2Changed" );
}
int i=0;
void draw() {
  background(0);
  pushMatrix();
  pushStyle();
  text("bufferdepth1 " + bufferdepth1, 10, 90); 
  text("bufferdepth2 " + bufferdepth2, 10, 140);
  text("scaleValue " + scaleValue, 10, 190);
  text("Xposition1 " + Xposition1, 10, 240);
  text("Yposition1 " + Yposition1, 10, 290);
  text("Depthposition1 " + Depthposition1, 10, 340);
  text("Xposition2 " + Xposition2, 10, 390);
  text("Yposition2 " + Yposition2, 10, 440); 
  text("Depthposition2 " + Depthposition2, 10, 490);
  popStyle();
  scale(0.05);
  image(kinect2a.getDepthImage(), 0, 0, 320, 240);
  image(kinect2a.getIrImage(), 320, 0, 320, 240);
  image(kinect2a.getVideoImage(), 320*2, 0, 320, 240);
  image(kinect2a.getRegisteredImage(), 320*3, 0, 320, 240);
  image(kinect2b.getDepthImage(), 0, 240, 320, 240);
  image(kinect2b.getIrImage(), 320, 240, 320, 240);
  image(kinect2b.getVideoImage(), 320*2, 240, 320, 240);
  image(kinect2b.getRegisteredImage(), 320*3, 240, 320, 240);
  popMatrix();   

  pushMatrix();
  fill(255);
  translate(width/2, height/2, scaleValue);
  //scale(map(mouseY, 0, height, 0, 2));
  rotateY(map(x, 0, 10, 0, PI*2));
  
  x+=0.01;
  
  
  
  stroke(255);
  int vertDataa = kinect2a.depthWidth * kinect2a.depthHeight;
  FloatBuffer depthPositions=kinect2a.getDepthBufferPositions(); 

  for (int i=2; i<depthPositions.capacity (); i+=3) {
    if (depthPositions.get(i)>bufferdepth1) {
      depthPositions.put(i, 0);
      depthPositions.put(i-1, 0);
      depthPositions.put(i-2, 0);
    }
    if (mode==0) {
      if (depthPositions.get(i)!=0) {
        float zposition=depthPositions.get(i);
        depthPositions.put(i, Depthposition1-zposition);
        float yposition=depthPositions.get(i-1);
        depthPositions.put(i-1, Yposition1+yposition);
        float xposition=depthPositions.get(i-2);
        depthPositions.put(i-2, Xposition1-xposition);
      }
    } else if (mode==1) {
      depthPositions.put(i, random(depthPositions.get(i)));
    }
  }
  println(mouseX);
  IntBuffer irData = kinect2a.getIrColorBuffer();
  IntBuffer registeredData= kinect2a.getRegisteredColorBuffer();
  IntBuffer depthData= kinect2a.getDepthColorBuffer();
  pgl = beginPGL();
  sh.bind();
  vertLoc  = pgl.getAttribLocation(sh.glProgram, "vertex");
  colorLoc = pgl.getAttribLocation(sh.glProgram, "color");
  pgl.enableVertexAttribArray(vertLoc);
  pgl.enableVertexAttribArray(colorLoc);
  pgl.vertexAttribPointer(vertLoc, 3, PGL.FLOAT, false, 0, depthPositions);
  switch(drawState) {
  case 0:
    pgl.vertexAttribPointer(colorLoc, 4, PGL.UNSIGNED_BYTE, true, 0, depthData);
    break;
  case 1:
    pgl.vertexAttribPointer(colorLoc, 4, PGL.UNSIGNED_BYTE, true, 0, irData);
    break;
  case 2:
    pgl.vertexAttribPointer(colorLoc, 4, PGL.UNSIGNED_BYTE, true, 0, registeredData);
    break;
  }
  pgl.drawArrays(PGL.POINTS, 0, vertDataa);
  pgl.disableVertexAttribArray(vertLoc);
  pgl.disableVertexAttribArray(colorLoc);
  sh.unbind();
  endPGL();
  popMatrix();

  pushMatrix();
  fill(255);
  translate(width/2, height/2, scaleValue);
  // scale(map(mouseY, 0, height, 0, 2));
  //rotateY(map(mouseX, 0, width, 0, PI*2));
  rotateY(map(x, 0, 10, 0, PI*2));
  
  stroke(255);
  int vertDatab = kinect2b.depthWidth * kinect2b.depthHeight;
  FloatBuffer depthPositionsb = kinect2b.getDepthBufferPositions();

  for (int i=2; i<depthPositionsb.capacity (); i+=3) {
    if (depthPositionsb.get(i)>bufferdepth2) {
      depthPositionsb.put(i, 0);
      depthPositionsb.put(i-1, 0);
      depthPositionsb.put(i-2, 0);
    }
    if (mode==0) {
      if (depthPositionsb.get(i)!=0) {
        float zposition=depthPositionsb.get(i);
        depthPositionsb.put(i, Depthposition2+zposition);
        float yposition=depthPositionsb.get(i-1);
        depthPositionsb.put(i-1, Yposition2+yposition);
        float xposition=depthPositionsb.get(i-2);
        depthPositionsb.put(i-2, Xposition2+xposition);
      }
    } else if (mode==1) {
      depthPositionsb.put(i, random(depthPositionsb.get(i)));
    }
  }

  IntBuffer irDatab = kinect2b.getIrColorBuffer();
  IntBuffer registeredDatab = kinect2b.getRegisteredColorBuffer();
  IntBuffer depthDatab      = kinect2b.getDepthColorBuffer();
  pgl = beginPGL();
  sh.bind();
  vertLoc  = pgl.getAttribLocation(sh.glProgram, "vertex");
  colorLoc = pgl.getAttribLocation(sh.glProgram, "color");
  pgl.enableVertexAttribArray(vertLoc);
  pgl.enableVertexAttribArray(colorLoc);
  pgl.vertexAttribPointer(vertLoc, 3, PGL.FLOAT, false, 0, depthPositionsb);
  switch(drawState) {
  case 0:
    pgl.vertexAttribPointer(colorLoc, 4, PGL.UNSIGNED_BYTE, true, 0, depthDatab);
    break;
  case 1:
    pgl.vertexAttribPointer(colorLoc, 4, PGL.UNSIGNED_BYTE, true, 0, irDatab);
    break;
  case 2:
    pgl.vertexAttribPointer(colorLoc, 4, PGL.UNSIGNED_BYTE, true, 0, registeredDatab);
    break;
  }
  pgl.drawArrays(PGL.POINTS, 0, vertDatab);
  pgl.disableVertexAttribArray(vertLoc);
  pgl.disableVertexAttribArray(colorLoc);
  sh.unbind();
  endPGL();
  popMatrix();
}

void keyPressed() {
  if (key == '1') {
    drawState = 0;
  }

  if (key == '2') {
    drawState = 1;
  }
  if (key == '3') {
    drawState = 2;
  }

  if (key == '4') {
    mode=0;
  }

  if (key == '5') {
    mode =1;
  }
}
void bufferdepth1Changed( float v )
{
  bufferdepth1 = map( v, 0, 1, 600, 3000 );
}

void bufferdepth2Changed( float v )
{
  bufferdepth2 = map( v, 0, 1, 600, 3000 );
}


void scaleValueChanged( float v )
{
  scaleValue = map( v, 0, 1, -3000, 3000);
}

void Xposition1Changed( float v )
{
  Xposition1 = map( v, 0, 1, -200, 200 );
}

void Yposition1Changed( float v )
{
  Yposition1 = map( v, 0, 1, -200, 200 );
}


void Depthposition1Changed( float v )
{
  Depthposition1 = map( v, 0, 1, -3000, 3000);
}

void Xposition2Changed( float v )
{
  Xposition2 = map( v, 0, 1, -200, 200  );
}

void Yposition2Changed( float v )
{
  Yposition2 = map( v, 0, 1, -200, 200  );
}


void Depthposition2Changed( float v )
{
  Depthposition2 = map( v, 0, 1, -3000, 3000);
}

