import android.util.DisplayMetrics;
import controlP5.*;


//boolean actuallyFinishedInitializingUIThanksForAsking = false;
// okay, I'll give it a normal name
boolean uiReady = false;


// Want more controls? Add them here
// Check out the controlp5 library's docs for info on how
Slider hueSlider;
Slider brightSlider;
Slider sizeSlider;
Button clearButton;
Button saveButton;
Button undoButton;
PImage title;
int titleDelay;
boolean titleDone;
boolean popupDone;
int popupDelay;

float UIscale;
PVector UIanchor;
float canvasHeight = 162; 
float menuWidth = 480;
float menuHeight = 638;

ControlP5 cp5;

void initUI() {
  popupDone = true;  // for now
  
  setUIscale();
  // FYI, only do this after UIscale is set, since that might change menuHeight too
  UIanchor = new PVector(0, height - menuHeight); // current height of UI panel
  
  cp5 = new ControlP5(this);
  PFont pfont = createFont("Roboto",20,true);
  ControlFont font = new ControlFont(pfont,241);

  // seems like the slider initialization tends to mess up the color settings.
  // no idea why it's only this and not others, but adding something to force
  // color settings back to our restored values after
  float tmpH = hue;
  float tmpB = bright;

  hueSlider = cp5.addSlider("hue")
    .setPosition(transToAnchor(27, 81))
    .setSize(scaleUI(63), scaleUI(243))
    .setRange(0,255)
    .setSliderMode(Slider.FLEXIBLE)
    .setNumberOfTickMarks(256)
    .setValue(tmpH);
  //hueSlider.getCaptionLabel().setText("Hue");

  hue = tmpH;

  brightSlider = cp5.addSlider("bright")
    .setPosition(transToAnchor(99, 81))
    .setSize(scaleUI(63), scaleUI(243))
    .setRange(0, 255)
    .setSliderMode(Slider.FLEXIBLE)
    .setNumberOfTickMarks(256)
    .setValue(tmpB);
  
  bright = tmpB;

  clearButton = cp5.addButton("clear")
    .setPosition(transToAnchor(138, 540))
    .setSize(scaleUI(90),scaleUI(54));
    
  saveButton = cp5.addButton("savePic")
    .setPosition(transToAnchor(360, 540))
    .setSize(scaleUI(90), scaleUI(54))
    .setCaptionLabel("save");

  undoButton = cp5.addButton("undo")
    .setPosition(transToAnchor(27, 540))
    .setSize(scaleUI(90), scaleUI(54));
    
  sizeSlider = cp5.addSlider("pensize")
    .setPosition(transToAnchor(189, 27))
    .setSize(scaleUI(72), scaleUI(297))
    .setRange(0.5,10)
    .setNumberOfTickMarks(20);

  // if you're adding more controls, initialize them here


  // This section grabs all the controls and sets the font to what we want
  List list = cp5.getAll();
  for (int i=0; i < list.size(); i++) {
     Controller k = (Controller)list.get(i);
     k.captionLabel()
      .setFont(font)
      .setSize(scaleUI(16))
      .toUpperCase(false);
     if (k.getValueLabel() != null) {
       k.getValueLabel()
        .setFont(font)
        .setSize(scaleUI(12))
        .toUpperCase(false);
     }
     if (k instanceof Slider) {
       k.getValueLabel().hide();
     }
  }

  
  // print("buttons added");

  cp5.hide(); // enable when menu is turned on
  uiReady = true;  
  
}

void setUIscale() {
  DisplayMetrics dm = new DisplayMetrics();
  getWindowManager().getDefaultDisplay().getMetrics(dm);
  float density = dm.density; 
  int densityDpi = dm.densityDpi;
  println("density is " + density); 
  println("densityDpi is " + densityDpi);

  // scale is based on a density of 1.5, since that's what my phone had
  // when I made this. 
  // 
  // Also, stock UI menu panel size is 480 across, 638 high. My phone, mostly.
  //
  // SCIENCE.
  
  // if we're a super high def screen, make stuff bigger.
  if (density > 1.5) {
    UIscale = density / 1.5;
    menuWidth = menuWidth * UIscale;
    menuHeight = menuHeight * UIscale;
  } else {  // or keep it the same for now.
    UIscale = 1;
  }

  // if the screen is frickin' huge, make stuff a bit bigger.
  if (width > menuWidth*1.5 && height > menuHeight*1.5) {
    UIscale = UIscale * 1.5;
    menuWidth = menuWidth * UIscale;
    menuHeight = menuHeight * UIscale;
  }

  // if we don't fit on the device, make stuff smaller.
  if (menuWidth > width) {
    UIscale = UIscale * width / menuWidth;
    menuWidth = menuWidth * UIscale;
    menuHeight = menuHeight * UIscale;
  }
  if (menuHeight > height) {
    UIscale = UIscale * height / menuHeight;
    menuWidth = menuWidth * UIscale;
    menuHeight = menuHeight * UIscale;
  }
  
  // print("UIscale set to " + UIscale);
}

void drawMenuPanel() {
  // FYI, controlp5 also has objects to group and minimize controls, if you want to use that
  // instead of my grey rectangle then go for it
  //
  // Also I really should've made this rectangle semi-transparent
  fill(128);
  noStroke();
  rect(0, UIanchor.y, menuWidth, height, 0, scaleUI(10), 0, 0);

  // this draws the color-selector preview box
  fill(hue, 256, bright);
  noStroke();
  PVector r = transToAnchor(new PVector(27, 27));
  rect(r.x, r.y, scaleUI(135), scaleUI(45), 5);
}

PVector transToAnchor(PVector v) {
  v.mult(UIscale);
  v.add(UIanchor);
  return v;
}

// scales the position of UI elements to match the current screen size
// this also takes the scale into account
PVector transToAnchor(float x, float y) {
  PVector v = new PVector(x, y);
  return transToAnchor(v);
}

int scaleUI(int n) {
  return round(n * UIscale);
}

// CreatePopup - makes a short, timed popup message
//     duration in millis
// (in this case it's the 'image saved' popup
void createPopup(int duration) { 
  popupDone = false;
  loadPixels();
  // print("making a popup; menuOn()");
  img = get();
  updatePixels();

  // the popup is stored in the data folder as this image file
  PImage popup = loadImage("imagesaveddialog.png");
  image( popup, (width-popup.width)/2, (height-popup.height)/2 );
  
  popupDelay = millis() + duration;
}

void clearPopup() {
  image(img, 0, 0);
  popupDone = true;
}
