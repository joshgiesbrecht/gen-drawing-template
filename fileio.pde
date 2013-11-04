import java.io.*;
import android.content.Context;

String SAVESTATE_FILENAME = "savestate";
String cacheImg = "cacheImg.png";
boolean weGotAFreakingCacheImg = false;

public void savePic() {
  if (uiReady) {
    print("savePic()");
    menuOff();
    File path = android.os.Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES);
    //print(path.getPath());
    String newFile = path.getPath() + "/drawing/" + year() +"-"+ month() 
                                    +"-"+ day() +"-" + hour() +"-" + minute() + ".png";
    save(newFile);

    // tell the media scanner that there's a new picture so it shows up in the Gallery and etc
    MediaScannerConnection.scanFile(this, new String[] { newFile }, null, null);

    // gonna cheat and assume this worked for now
    createPopup(1500);
    
  }
}

static class State implements Serializable {
  //public int img[];
  //public ArrayList undoImgs;

  public float hue;
  public float brightness;
  public float pensize;
  // If you add any other settings, add fields for that data here!

}


void saveState() {
  if (cp5.isVisible()) {
    menuOff();
  }
 
  State s = new State();
  s.hue = hue;
  s.brightness = bright;
  s.pensize = pensize;
  
  try {
    FileOutputStream fos = openFileOutput(SAVESTATE_FILENAME, Context.MODE_PRIVATE);

    // Write object with ObjectOutputStream
    ObjectOutputStream obj_out = new ObjectOutputStream (fos);

    // Write object out to disk
    obj_out.writeObject ( s );
    
    fos.close();
    
  } catch (FileNotFoundException fnfe) {
    // print("whoops, file not found when saving state? wtf?");
    fnfe.printStackTrace();
  } catch (IOException ioe) {
    // print("meh IOException on saving state?");
    ioe.printStackTrace();
  }
  
  // now save the image itself
  
  loadPixels();
  img = get();
  updatePixels();
  
  boolean itWorked = img.save(cacheImg);
  if (itWorked) {
    // print("saved an image maybe");
  } else {
    // print("totally didn't save an image");
  }
  
  
}


void restoreState() {
  try {
    FileInputStream fis = openFileInput(SAVESTATE_FILENAME);
    // print("file opened");
    // Read object using ObjectInputStream
    ObjectInputStream obj_in = new ObjectInputStream (fis);
    // print("obj_in created");
    // Read an object
    Object obj = obj_in.readObject();
    // print("obj_in read");
    if (obj instanceof State)
    {
      // print("found a State");
      // Cast object to a State
      State s = (State) obj;
      // print("cast it");
      // Do something with it....

      hue = s.hue;
      bright = s.brightness;
      pensize = s.pensize;
      
      // print("we seem to have restored state?");

    } else {
      // print("we loaded something from our savestate file that wasn't a State object?");
    }

    
  } catch (FileNotFoundException fnfe) {
    // print("No saved state found, no big deal");
  } catch (StreamCorruptedException sce) {
    // print("DON'T CROSS THE STREAMS!!! lolzorz");
    sce.printStackTrace();
  } catch (IOException ioe) {
    // print("I take exception to this IOException (we tried restoring state, whatever, move on)");
    ioe.printStackTrace();
  } catch (ClassNotFoundException cnfe) {
    // print("class not FOUND!?!?!");
    cnfe.printStackTrace();
  }
  
  // try loading image
  // print("using img to restore state");
  img = null;
  try {
    img = loadImage(cacheImg);
  } catch (RuntimeException re) {
    // print("wtf");
    re.printStackTrace();
  }
  if (img != null) {
    image(img, 0, 0);
    // print("loaded an image! " + img.width + " , " + img.height);
    weGotAFreakingCacheImg = true;
  } else {
    weGotAFreakingCacheImg = false;
  }
  
  // print("done onRestore");
    
}




