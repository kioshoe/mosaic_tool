//Adapted from Daniel Schiffman's Obamathon Mosaic Code

//Imports video exporting library
//https://github.com/hamoid/video_export_processing
import com.hamoid.*;

VideoExport videoExport;
boolean recording = false;

//Define image variables
PImage mosaic;
PImage scaled;
PImage[] gallery;
PImage[] bgallery;
float[] bright;
int w, h, col, row;
int res = 14;


void setup() {
  //Defines canvas size
  size(800, 800, P3D);
  frameRate(30);
  imageMode(CENTER);
  
  //Sets up video export for the mosaic explosion
  videoExport = new VideoExport(this, "video.mp4");
  videoExport.startMovie();
  
  //Loads primary image
  //Change "img.jpg" to select a different image.
  mosaic = loadImage("img.jpg");
  
  //Loads photo gallery for mosaic tiles
  String path = ("/Users/Belle/Documents/Processing/Mosaic_Tool/mosaic_images");
  File[] files = listFiles(path);
  
  gallery = new PImage[files.length-1];
  bright = new float [gallery.length];
  bgallery = new PImage[256];
  
  //Resizes all images in photo gallery and calculates its average brightness
  for (int i = 0; i < gallery.length; i++) {
    String filename = files[i+1].toString();

    PImage img = loadImage(filename);

    gallery[i] = createImage(res, res, RGB);
    gallery[i].copy(img, 0, 0, img.width, img.height, 0, 0, res, res);
    gallery[i].loadPixels();

    float avg = 0;
    for (int j = 0; j < gallery[i].pixels.length; j++) {
      float b = brightness(gallery[i].pixels[j]);
      avg += b;
    }
    avg /= gallery[i].pixels.length;  

    bright[i] = avg;
  }
  
  //Finds most similar image for the individual brighness values
  for (int i = 0; i < bgallery.length; i++) {
    float rec = 256;
    for (int j = 0; j < bright.length; j++) {
      float diff = abs(i - bright[j]);
      if (diff < rec) {
        rec = diff;
        bgallery[i] = gallery[j];
        bgallery[i].resize(200,0);
      }
    }
  }
  
  
  w = mosaic.width;
  h = mosaic.height;
  
  col = w/res;
  row = h/res; 
  
  //Resizes primary image
  scaled = createImage(w, h, RGB);
  scaled.copy(mosaic, 0, 0, w, h, 0, 0, col, row);
}

//Replaces each pixel with an image of similar brightness from the photo gallery
//Tiles scatter in 3D when mouse is moved from left to right in the window
void draw() {
  background(0);
  
  scaled.loadPixels();
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      int index = x + y * w;
      color c = scaled.pixels[index];
      int imgIndex = int(brightness(c));
      float z = (2*mouseX/float(width)) * brightness(scaled.pixels[index]) - 50.0;
      pushMatrix();
      translate(x, y, z);
      image(bgallery[imgIndex], x*res, y*res, res, res);
      popMatrix();
    }
  }
  if (recording) {
    videoExport.saveFrame();
  }
}

//Screenshots current frame when S key is pressed
void keyPressed() {
  if (key == 's') {
    saveFrame("screenshot-######.jpg");
  }
  if (key == 'r') {
    recording = !recording;
  }
  if (key == 'q') {
    videoExport.endMovie();
    exit();
  }
}
      
//Directory list code
File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } else {
    return null;
  }
}