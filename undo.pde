public void undo() {
  if (uiReady) {
    print("undo()");
    menuOff();
    if (undoImgs.size() >= 0) {
      // print("using img in undo()");
      img = undoImgs.pop();
      if (img != null) {
        image(img, 0, 0);
        // print("writing img to screen");
      }
    }
    menuOn();
  }
}
 

void addUndoState() {
  loadPixels();
  undoImgs.push(get());
  updatePixels();
}

class UndoImages {

  int saveIndex;
  int undoIndex;
  int size;
  
  int maxUndo = 20;

  String filebase = "undoimg";
  String ext = ".png";
  
  UndoImages() {
    saveIndex = 0;
    undoIndex = -1;
    size = -1;
  }
  
  int size() {
    return size;
  }
  
  void push(PImage img) {
    size++;
    if (size > maxUndo-1) {   // subtract 1 because we're always precaching an extra
      size = maxUndo-1;
    }
    saveIndex++;
    if (saveIndex > maxUndo) {
      saveIndex = 1;
    }
    undoIndex++;
    if (undoIndex > maxUndo) {
      undoIndex = 1;
    }
    // save image
    // print("save undo " + saveIndex);
    
    save(filebase + saveIndex + ext);
    
  }

  PImage pop() {

    if (size > 0) {
      // print("load undo " + undoIndex);
      PImage loadimg = null;
      // try loading image
      try {
        loadimg = loadImage(filebase + undoIndex + ext);
      } catch (RuntimeException re) {
        re.printStackTrace();
      }
      if (loadimg != null) {
        size--;
        saveIndex--;
        if (saveIndex < 1) {
          saveIndex = maxUndo;
        }
        undoIndex--;
        if (undoIndex < 1) {
          undoIndex = maxUndo;
        }
        
        return loadimg;
      } else {  // we didn't get an image
        return null;  // this is redundant but it makes me feel less crazy right now
      }
    } else { // we have no undo states to pop!
      return null;
    }
  }
  
  
}


