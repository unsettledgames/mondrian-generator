int borderWidth = 10;
int maxWidth = 600;
int maxHeight = 600;
float stopProbability = 0;
float stopProbabilityIncrease = 5;

int minLineOffset = round((float)(maxWidth) * 0.1);
int maxLineOffset = round((float)(maxWidth) * 0.5);

int maxHorizontalLines = 3;
int maxVerticalLines = 3;
int maxDepth = 6;

color yellow = color(247, 231, 32);
color red = color(247, 0, 2);
color blue = color(0, 74, 158);
color white = color(255, 255, 255);

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
}

void setup()
{
  randomSeed(3);
  size(600, 600);
  
  fill(248, 0, 248);
  rect(0, 0, maxWidth, maxHeight);
  
  noStroke();
  
  mondrian(borderWidth, borderWidth, maxWidth - borderWidth, maxHeight - borderWidth, maxDepth, stopProbability);
  drawBorder();
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
  
  int hDivisions = (int)random(0, maxHorizontalLines + 1);
  int vDivisions;
  
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
  
  ArrayList<Rect> toFill = new ArrayList<Rect>();
  Rect currRect;
  
  if (canDraw > stopProbability)
  {
    currRect = new Rect();
    currRect.setStartY(startY);
    currRect.setHeight(rectPos - startY);
    
    // Picking a random colour
     switch(rectColor)
     {
       case 0:
         fill(white);
         break;
       case 1:
         fill(blue);
         break;
       case 2:
         fill(red);
         break;
       case 3:
         fill(yellow);
         break;
     }
     
     if (endX <= maxWidth - borderWidth && endY <= maxHeight - borderWidth) {
        rect(startX, startY, endX - startX, endY - startY); //<>//
     } 
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
         rect(startX, rectPos, endX - startX, borderWidth);
         
         // Updating startY and rectpos
         rectPos += borderWidth;
         startY = rectPos;
         
         rectPos += (int)random(minLineOffset, maxLineOffset);
         
         // Adding the tmp rect to the list
         toFill.add(currRect);
         // Resetting the rectangle
         currRect = new Rect();
         currRect.setStartY(startY);
         currRect.setHeight(rectPos - startY);
         nHorizontalRects++;
      }
    }
    
    // Resetting the startX and Y
    startX = savedStartX;
    startY = savedStartY;
    // Generating a new rectPos
    rectPos = startX + (int)random(minLineOffset, maxLineOffset);
    // Index of the current rectangle
    int rectIndex = 0;
    
    // I have to take all the rectangles I created with horizontal lines and set the remaining parameters
     for (int j=rectIndex; j<toFill.size(); j++)
     {
        toFill.get(j).setStartX(startX);
        if (vDivisions > 0)
        {
          toFill.get(j).setWidth(rectPos - startX);
        }
        else
        {
          toFill.get(j).setWidth(endX - startX);
        }
     }
     
    // VERTICAL LINES
    for (int i=0; i<vDivisions; i++)
    {
      if (rectPos < (endX - 4*borderWidth))
      {
         // Drawing a line
         fill(0);
         rect(rectPos, startY, borderWidth, endY - startY);
         
         rectPos += borderWidth;
         startX = rectPos;
         rectPos += (int)random(minLineOffset, maxLineOffset);

         // Adding new rectangles, because with a vertical line I've created twice the number of rects I created with horizontal lines
         for (int j=0; j<nHorizontalRects; j++)
         {
           Rect toAdd = new Rect(toFill.get(i));
           toAdd.setStartX(startX);
           toAdd.setWidth(rectPos - startX);
           toFill.add(toAdd);
           // Updating the rectindex so that the next rects to be set are the ones I've just cloned
           rectIndex++;
         }
      }
    }
    
    // Finally I call the same function on the smaller rects I've created
    for (int i=0; i<toFill.size(); i++)
    {
      Rect curr = toFill.get(i);
      mondrian(curr.getStartX(), curr.getStartY(), curr.getStartX() + curr.getWidth(), curr.getStartY() + curr.getHeight(), depth - 1, stopProbability + stopProbabilityIncrease);
    }
  }
}
