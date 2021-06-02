// Width of the border and of the lines that compose the rectangles
int borderWidth = 8;
// Canvas dimensions
int maxWidth = 600;
int maxHeight = 600;

// Probability that the rect becomes unsplittable
float stopProbability = 30;
// Amount of which the probability to stop splitting rectangles icnreases after each iteration
float stopProbabilityIncrease = 10;

// Useless probably
IntRange lineOffset = new IntRange(round((float)(maxWidth) * 0.1), round((float)(maxWidth) * 0.5));

// Range of horizontal lines to be drawn per rectangle
IntRange nHorizontalLines = new IntRange(0, 3);
// Range of vertical lines to be drawn per rectangle
IntRange nVerticalLines = new IntRange(0, 3);
// Number of iterations of the splitting algorithm
IntRange nIterations = new IntRange(0, 6);

// Probability that if a rectangle is horizontal, it will be split vertically
int perpProbability = 70;

// Colors
color yellow = color(247, 231, 32);
color red = color(247, 0, 2);
color blue = color(0, 74, 158);
color white = color(255, 255, 255);

color colors[] = {yellow, red, blue, white};

// The rectangles you have at the moment
ArrayList<Rect> currentRects = new ArrayList();
// The rectangles that have been drawn during the current iteration
ArrayList<Rect> addedRects = new ArrayList();

// Next time a rectangle will be drawn (this is just to show the drawing sequence)
int nextDrawTime = millis() + 1000;

// Range class, utility to generate random integers between min and max
class IntRange {
    private int min;
    private int max;

    public IntRange(int min, int max) {
        this.min = min;
        this.max = max;
    }

    public void setMin(int min) {
        this.min = min;
    }

    public void setMax(int max) {
        this.max = max;
    }

    public int get() {
        return round(random(min, max));
    }
}

// Rectangle class, contains useful info and tells whether or not it's possible to split it
class Rect {
    private int startX;
    private int startY;
    private int rectWidth;
    private int rectHeight;
    private boolean stopDrawing;

    public Rect() {
        startX = -1;
        startY = -1;
        rectWidth = -1;
        rectHeight = -1;

        stopDrawing = false;
    }

    public Rect(int startX, int startY, int rectWidth, int rectHeight) {
        this.startX = startX;
        this.startY = startY;
        this.rectWidth = rectWidth;
        this.rectHeight = rectHeight;
        this.stopDrawing = false;
    }

    public Rect(Rect clone) {
        startX = clone.getStartX();
        startY = clone.getStartY();
        rectWidth = clone.getWidth();
        rectHeight = clone.getHeight();
    }

    public boolean canDraw() {
        return !stopDrawing;
    }

    public void disable() {
        stopDrawing = true;
    }

    public float getRatio() {
        return (float)rectWidth / (float)rectHeight;
    }

    public void setStartX(int value) {
        this.startX = value;
    }
    public void setStartY(int value) {
        this.startY = value;
    }
    public void setWidth(int value) {
        this.rectWidth = value;
    }
    public void setHeight(int value) {
        this.rectHeight = value;
    }

    public int getStartX() {
        return startX;
    }
    public int getStartY() {
        return startY;
    }
    public int getWidth() {
        return rectWidth;
    }
    public int getHeight() {
        return rectHeight;
    }

    public String toString() {
        return "Start: " + startX + "; " + startY + "\nSize: " + rectWidth + "; " + rectHeight + "\n";
    }
}

void setup() {
    // Initializing the seed
    randomSeed(millis());
    // Creating the canvas
    size(600, 600);

    // Painting the canvas pink for debug
    fill(248, 0, 248);
    rect(0, 0, maxWidth, maxHeight);

    noStroke();

    print("-------------------------------------GENERATING-------------------------------\n\n");
    drawBorder();

    // Adding the first rect
    currentRects.add(new Rect(borderWidth, borderWidth, maxWidth - 2*borderWidth, maxHeight - 2*borderWidth));
    // Generating the rest
    mondrian();
}

float clamp(float min, float max, float v) {
    return min(max(min, v), max);
}

void drawBorder() {
    fill(0);

    // Drawing borders
    rect(0, 0, borderWidth, maxHeight);
    rect(0, 0, maxWidth, borderWidth);
    rect(maxWidth - borderWidth, 0, borderWidth, maxHeight);
    rect(0, maxHeight - borderWidth, maxWidth, borderWidth);
}

void mondrian() {
    int actualIter = nIterations.get();

    // Iterating on the rectangles
    for (int i=0; i<3; i++) {
        // Clearing the added rects list
        addedRects = new ArrayList<Rect>();

        // Randomly creating smaller rectangles from the bigger ones
        for (int j=0; j<currentRects.size(); j++) {
            // Getting the current rect
            Rect currRect = currentRects.get(j);

            // If I can split the rectangle
            if (currRect.canDraw()) {
                // I split the rectangle. The chances that it'll be splitted horizontally are higher
                // if it's a vertical rectangle and viceversa.
                float rectRatio = clamp(0.33, 3, currRect.getRatio());
                print("Ratio: " + rectRatio + "\n");

                // Rect is horizontal
                if (rectRatio > 1) {
                    float hProb = perpProbability + lerp(0, (100 - perpProbability), (rectRatio - 1) / 2);

                    print("H prob: " + hProb + "\n");
                    
                    if (random(0, 100) < hProb) {
                        // Split horizontally
                        addedRects.addAll(splitVertically(currRect, nHorizontalLines.get()));
                    }
                    else {
                        // Split vertically
                        addedRects.addAll(splitHorizontally(currRect, nVerticalLines.get()));
                    }
                }
                // Rect is vertical
                else if (rectRatio < 1) {
                    float vProb = perpProbability + lerp(0, (100 - perpProbability), (rectRatio - 0.33) / 0.77);
                    print("V prob: " + vProb  + "\n");

                    if (random(0, 100) < vProb) {
                        // Split vertically
                        addedRects.addAll(splitHorizontally(currRect, nVerticalLines.get()));
                    }
                    else {
                        // Split horizontally
                        addedRects.addAll(splitVertically(currRect, nHorizontalLines.get()));
                    }
                }
                else {
                    float hProb = random(0, 100);

                    if (hProb < 50) {
                        // Split horizontally
                        addedRects.addAll(splitHorizontally(currRect, nHorizontalLines.get()));
                    }
                    else {
                        // Split vertically
                        addedRects.addAll(splitVertically(currRect, nVerticalLines.get()));
                    }
                }

                for (int k=0; k<addedRects.size(); k++) {
                    // There's a chance the generated rects won't be splittable anymore
                    if (random(0, 100) < stopProbability) {
                        addedRects.get(k).disable();
                    }
                }

                // Debug timer so rectangles will be drawn in a visible sequence
                //while (nextDrawTime >= millis());
                //nextDrawTime = millis() + 500;
            }
        }

        currentRects = new ArrayList<Rect>();
        currentRects.addAll(addedRects);
    }
    
    print("-----------------------------------FINISHED--------------------------------");
}

ArrayList<Rect> splitHorizontally(Rect toSplit, int nLines) {
    ArrayList<Rect> ret = new ArrayList<Rect>();

    int lineDistance = round(toSplit.getHeight() / (nLines + 1)) - borderWidth;
    int currentY = toSplit.getStartY();

    for (int i=0; i<nLines; i++) {
        // Drawing a rect
        fillRect(toSplit.getStartX(), currentY, toSplit.getWidth(), lineDistance, -1);
        // Adding a new rect
        ret.add(new Rect(toSplit.getStartX(), currentY, toSplit.getWidth(), lineDistance));

        // Drawing a line
        currentY += lineDistance;
        fillRect(toSplit.getStartX(), currentY, toSplit.getWidth(), borderWidth, color(0,0,0));
        currentY += borderWidth;
    }

    // Filling the last rect
    fillRect(toSplit.getStartX(), currentY, toSplit.getWidth(), toSplit.getHeight() - currentY + borderWidth, -1);

    return ret;
}

ArrayList<Rect> splitVertically(Rect toSplit, int nLines) {
    ArrayList<Rect> ret = new ArrayList<Rect>();

    int lineDistance =  round(toSplit.getWidth() / (nLines + 1)) - borderWidth;
    int currentX = toSplit.getStartX();

    for (int i=0; i<nLines; i++) {  
        // Drawing a rect
        fillRect(currentX, toSplit.getStartY(), lineDistance, toSplit.getHeight(), -1);
        ret.add(new Rect(currentX, toSplit.getStartY(), lineDistance, toSplit.getHeight()));
        
        // Drawing a line
        currentX += lineDistance;
        fillRect(currentX, toSplit.getStartY(), borderWidth, toSplit.getHeight(), color(0,0,0));
        currentX += borderWidth;
    }

    // Filling the last rect
    fillRect(currentX, toSplit.getStartY(), toSplit.getWidth() - currentX + borderWidth, toSplit.getHeight(), -1);

    return ret;
}

void fillRect(int startX, int startY, int width, int height, color c) {
    if (c != color(0,0,0))
        c = colors[round(random(0, 3))];
    print("color: " + c);
    fill(c);
    rect(startX, startY, width, height);
}
