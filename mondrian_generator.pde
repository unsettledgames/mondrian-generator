int borderWidth = 10;
int maxWidth = 600;
int maxHeight = 600;
float stopProbability = 0;
float stopProbabilityIncrease = 1;

int minLineOffset = round((float)(maxWidth) * 0.1);
int maxLineOffset = round((float)(maxWidth) * 0.5);

int maxHorizontalLines = 3;
int maxVerticalLines = 3;
int maxDepth = 6;

color yellow = color(247, 231, 32);
color red = color(247, 0, 2);
color blue = color(0, 74, 158);
color white = color(255, 255, 255);

ArrayList<DrawnRect> everything = new ArrayList();
int everythingIndex = 0;
int nextDrawTime = millis() + 1000;

class DrawnRect
{
 public int startX;
 public int startY;
 public int rectWidth;
 public int rectHeight;
 public color col;
 
 public DrawnRect(int x, int y, int w, int h, color c)
 {
   startX = x;
   startY = y;
   rectWidth = w;
   rectHeight = h;
   col = c;
 }
}

class Rect
{
  private int startX;
  private int startY;
  private int rectWidth;
  private int rectHeight;
  
  public Rect()
  {
    startX = -1;
    startY = -1;
    rectWidth = -1;
    rectHeight = -1;
  }
  
  public Rect(int startX, int startY, int rectWidth, int rectHeight) 
  {
    this.startX = startX;
    this.startY = startY;
    this.rectWidth = rectWidth;
    this.rectHeight = rectHeight;
  }
  
  public Rect(Rect clone)
  {
    startX = clone.getStartX();
    startY = clone.getStartY();
    rectWidth = clone.getWidth();
    rectHeight = clone.getHeight();
  }
  
  public void setStartX(int value)
  {
    this.startX = value;
  }
  public void setStartY(int value)
  {
    this.startY = value;
  }
  public void setWidth(int value)
  {
    this.rectWidth = value;
  }
  public void setHeight(int value)
  {
    this.rectHeight = value;
  }
  
  public int getStartX()
  {
    return startX;
  }
  public int getStartY()
  {
    return startY;
  }
  public int getWidth()
  {
    return rectWidth;
  }
  public int getHeight()
  {
    return rectHeight;
  }
  
  public String toString()
  {
    return "Start: " + startX + "; " + startY + "\nSize: " + rectWidth + "; " + rectHeight + "\n";
  }
}

void setup()
{
  randomSeed(4);
  size(600, 600);
  
  fill(248, 0, 248);
  rect(0, 0, maxWidth, maxHeight);
  
  noStroke();
  
  mondrian(borderWidth, borderWidth, maxWidth - borderWidth, maxHeight - borderWidth, maxDepth, stopProbability);
  drawBorder();
}

void draw()
{
   if (millis() >= nextDrawTime && everythingIndex < everything.size())
   {
     fill(everything.get(everythingIndex).col);
     rect(everything.get(everythingIndex).startX, everything.get(everythingIndex).startY, everything.get(everythingIndex).rectWidth, everything.get(everythingIndex).rectHeight); 
     
     everythingIndex++;
     nextDrawTime = millis() + 1000;
   }
}

void drawBorder()
{
  fill(0);
  
  // Drawing borders
  rect(0, 0, borderWidth, maxHeight);
  rect(0, 0, maxWidth, borderWidth);
  rect(maxWidth - borderWidth, 0, borderWidth, maxHeight);
  rect(0, maxHeight - borderWidth, maxWidth, borderWidth);
}

// Problema: devo salvare i punti in cui taglio, altrimenti quando disegno un rettangolo vado sopra quelli già esistenti.

void mondrian(int startX, int startY, int endX, int endY, int depth, float stopProbability)
{
  float canDraw = random(0, 100);
  color currentCol = 0;
  int hDivisions = (int)random(0, maxHorizontalLines + 1);
  int vDivisions;
  
  // If I don't make horizontal divisions, I have to make at least a vertical one
  if (hDivisions == 0)
  {
     vDivisions = (int)random(1, maxVerticalLines + 1);
  }
  else
  {
    vDivisions = (int)random(0, maxVerticalLines + 1);
  }
  
  int rectPos = startY + (int)random(minLineOffset, maxLineOffset);
  int rectColor = (int)random(0, 4);
  
  int savedStartX = startX;
  int savedStartY = startY;
  int nHorizontalRects = 0;
  int allRectsStart = 0;
  int nVerticalRects = 0;
  
  ArrayList<Rect> toFill = new ArrayList<Rect>();
  Rect currRect;
  
  /*print("H divisions: " + hDivisions + ", V divisions: " + vDivisions + "\n");
  print("Bounding rect: x " + startX + ", y " + startY + ", endX " + endX + ", endY " + endY);*/ 
  
  // Questo serve per garantire la possibilità di generare divisioni verticali
  if (hDivisions == 0) 
  {
    toFill.add(new Rect(borderWidth, borderWidth, maxWidth - borderWidth*2, maxHeight - borderWidth*2));
  }
  
  // Picking a random colour
     switch(rectColor)
     {
       case 0:
         currentCol = white;
         break;
       case 1:
         currentCol = blue;
         break;
       case 2:
         currentCol = red;
         break;
       case 3:
         currentCol = yellow;
         break;
     }
     
     // Riempio il rettangolo corrente
     if (endX <= maxWidth - borderWidth && endY <= maxHeight - borderWidth) {
        everything.add(new DrawnRect(startX, startY, endX - startX, endY - startY, currentCol));
     } 
  
  if (canDraw > stopProbability)
  {
    currRect = new Rect();
    currRect.setStartY(startY);
    currRect.setHeight(rectPos - startY);
     /*
     else if (startX < maxWidth && startY < maxHeight) {
       rect(startX, startY, maxWidth - borderWidth - startX, maxHeight - borderWidth - startY);
     }*/
     
    // HORIZONTAL LINES
    for (int i=0; i<hDivisions; i++)
    {
      if (rectPos < (endY - 4*borderWidth))
      {
         // Drawing a line
         fill(0);
         everything.add(new DrawnRect(startX, rectPos, endX - startX, borderWidth, 0));
         
         currRect.setWidth(endX - startX);
         currRect.setStartX(startX);
         
         // Updating startY and rectpos
         rectPos += borderWidth;
         startY = rectPos;
         
         rectPos += (int)random(minLineOffset, maxLineOffset);
         
         // Adding the tmp rect to the list
         toFill.add(currRect);
         // Resetting the rectangle
         currRect = new Rect();
         currRect.setStartY(startY);
         currRect.setHeight(rectPos - startY - borderWidth);
         nHorizontalRects++;
      }
    }
    
    // Resetting the startX and Y
    startX = savedStartX;
    startY = savedStartY;
    // Generating a new rectPos
    rectPos = startX + (int)random(minLineOffset, maxLineOffset);
     
    // VERTICAL LINES
    for (int i=0; i<vDivisions; i++)
    {
      if (rectPos < (endX - 4*borderWidth))
      {
         // Drawing a line
         fill(0);
         everything.add(new DrawnRect(rectPos, startY, borderWidth, endY - startY, 0));
         
         rectPos += borderWidth;
         startX = rectPos;
         rectPos += (int)random(minLineOffset, maxLineOffset);

         // Adding new rectangles, because with a vertical line I've created twice the number of rects I created with horizontal lines
         if (nHorizontalRects > 0) 
         {
           for (int j=0; j<nHorizontalRects; j++)
           {
             Rect toAdd = new Rect(toFill.get(i));
             toAdd.setWidth(startX - 2*borderWidth);
             toAdd.setStartY(toFill.get(i).getStartY());
             toAdd.setHeight(toFill.get(i).getHeight());
             toFill.add(toAdd);
           }
         }
         else 
         {
           toFill.add(new Rect(savedStartX, startY, startX - savedStartX - borderWidth, endY));
         }
         
         nVerticalRects++;
      }
    }
    
    if (nVerticalRects != 0) 
    {
      allRectsStart = nHorizontalRects; 
    }
    
    print("\nInizio da " + allRectsStart + ", ne ho " + toFill.size() + "\n");
    
    // Finally I call the same function on the smaller rects I've created
    for (int i=allRectsStart; i<toFill.size(); i++)
    {
      Rect curr = toFill.get(i);
      if (curr.getStartX() == borderWidth && curr.getStartY() == borderWidth && (curr.getWidth() == (maxWidth - borderWidth*2)) && (curr.getHeight() == (maxHeight - borderWidth*2))) {
        continue;
      }
      print("\n" + curr.toString());
      mondrian(curr.getStartX(), curr.getStartY(), curr.getStartX() + curr.getWidth(), curr.getStartY() + curr.getHeight(), depth - 1, stopProbability + stopProbabilityIncrease);
    }
  }
}
