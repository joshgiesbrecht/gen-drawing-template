// Drawing Template App
// Copyright (c) 2013 Josh Giesbrecht (see license.txt)
//
// This is code for Android mode in Processing, and creates a standalone
// drawing app with basic save, undo, clear, and pen control functionality.
// 
// It's based on a simple technique of drawing to image buffers; undo is based on taking
// image snapshots, not by tracking pen movement.  Drawing is done by moving 'Agent' objects
// which aim towards the current 'mouse' (ie. touch) position.  Customize the Agent class
// to make the agents move (and draw) in more interesting ways.


import java.io.*;
import android.content.Context;
import android.os.Environment;
import processing.event.*;
import android.view.KeyEvent;
import java.lang.Throwable;
import android.media.MediaScannerConnection;
//import android.app.Activity;
import java.util.List;

PImage img;
UndoImages undoImgs;

float hue;
float sat;
float bright;
float pensize;
boolean wasPressed;
boolean ignorePress;


void onResume() {
  super.onResume();
  print("Resuming...");

  restoreState();
  
}

void setup() {
  orientation(PORTRAIT);
  colorMode(HSB);
  smooth();

  titleDelay = millis() + 4000;

  title = loadImage("titlescreen.jpg");
  titleDone = false;

  // does this even help right now?
  if (img == null) {
    background(255);
    img = createImage(width, height, RGB);
  } else {
    image(img,0,0);
  }

  wasPressed = false;
  ignorePress = false;
  undoImgs = new UndoImages();

  initUI();

  addUndoState();
    
}

void draw() {
  if (!titleDone) {
    background(0);
    image(title, 0, 0, width, height);
    
    if (millis() > titleDelay) {
      titleDone = true;
      if (weGotAFreakingCacheImg) {
        image(img, 0, 0);
      } else {
        background(255);
      }
    }
  } else if (!popupDone) {
    if (millis() > popupDelay) {
      clearPopup();
    }
  } else {
  
    if (mousePressed) {
      if (!ignorePress) { 
        if (cp5.isVisible()) {
          ignorePress = true;
          if (mouseY < UIanchor.y || mouseX > menuWidth) {
            menuOff();
          } else { 
            // if you press a control, cp5 will take care of it; don't think this
            // needs anything
          }
        } else { // menu is already off, just draw already
          addAgent(mouseX, mouseY);
          updateAll();
          drawAll();
          wasPressed = true;
        }
      }
    } else {
      ignorePress = false;
      if (wasPressed) {
        clearAgents();
        wasPressed = false;
        addUndoState();
      }
    }
    if (cp5.isVisible()) {
      drawMenuPanel();
    }
  }
}


void onPause() {
  print("Pausing...");
  
  saveState();
  
  super.onPause();
}

void onStop() {
  print("Stopping...");
  super.onStop();
}

void onDestroy() {
  print("Destroying...");
  super.onDestroy();
}



public void clear(int theValue) {
  if (uiReady) {
    // print("clear()");
    menuOff();
    background(255);
    loadPixels();
    // print("clearing img - clear()");  
    img = get();
    updatePixels();
    addUndoState();
    
    menuOn();
  }
}
  

void menuOn() {
  loadPixels();
  // print("using img; menuOn()");
  img = get();
  updatePixels();
  cp5.show();
}

void menuOff() {
  cp5.hide();
  image(img, 0, 0);
  // print("writing img to screen - menuOff()");
}


void onBackPressed() {
  if (cp5.isVisible()) {
    menuOff();
  } else {
    saveState();
    exit();
  }
}

void keyPressed() {
  if (key == CODED) {
    // not checking for BACK here because it's caught by onBackPressed()
    if (keyCode == MENU) { // toggle UI
      if (cp5.isVisible()) {
        menuOff();
      } else {
        menuOn();
      }
    }
  }
}



