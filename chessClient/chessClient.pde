//Client plays black

import processing.net.*;

Client myClient;

color lightbrown = #FFFFC3;
color darkbrown  = #D8864E;
PImage wrook, wbishop, wknight, wqueen, wking, wpawn;
PImage brook, bbishop, bknight, bqueen, bking, bpawn;
boolean firstClick;
boolean myTurn;
boolean pawnPremotion;
int row1, col1, row2, col2;
String lastMove;

char grid[][] = {
  {'R', 'B', 'N', 'Q', 'K', 'N', 'B', 'R'}, 
  {'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'}, 
  {'r', 'b', 'n', 'q', 'k', 'n', 'b', 'r'}
};

//message types
final int TURN = 0;
final int UNDO = 1;
final int PROMOTION = 2;
final int PAUSE = 3; 
final int ENPASSENT = 4;

void setup() {
  size(800, 800);
  
  myClient = new Client(this, "127.0.0.1", 1234);
  
  lastMove = " ";

  firstClick = true;
  myTurn = false;
  pawnPremotion = false;

  brook = loadImage("blackRook.png");
  bbishop = loadImage("blackBishop.png");
  bknight = loadImage("blackKnight.png");
  bqueen = loadImage("blackQueen.png");
  bking = loadImage("blackKing.png");
  bpawn = loadImage("blackPawn.png");

  wrook = loadImage("whiteRook.png");
  wbishop = loadImage("whiteBishop.png");
  wknight = loadImage("whiteKnight.png");
  wqueen = loadImage("whiteQueen.png");
  wking = loadImage("whiteKing.png");
  wpawn = loadImage("whitePawn.png");
}

void draw() {
  drawBoard();
  drawPieces();
  receiveMove();
  highlightSquare();
  checkPromotion();
}

void drawBoard() {
  strokeWeight(1);
  stroke(0);
  for (int r = 0; r < 8; r++) {
    for (int c = 0; c < 8; c++) { 
      if ( (r%2) == (c%2) ) { 
        fill(lightbrown);
      } else { 
        fill(darkbrown);
      }
      rect(c*100, r*100, 100, 100);
    }
  }
}

void drawPieces() {
  for (int r = 0; r < 8; r++) {
    for (int c = 0; c < 8; c++) {
      if (grid[r][c] == 'r') image (wrook, c*100, r*100, 100, 100);
      if (grid[r][c] == 'R') image (brook, c*100, r*100, 100, 100);
      if (grid[r][c] == 'b') image (wbishop, c*100, r*100, 100, 100);
      if (grid[r][c] == 'B') image (bbishop, c*100, r*100, 100, 100);
      if (grid[r][c] == 'n') image (wknight, c*100, r*100, 100, 100);
      if (grid[r][c] == 'N') image (bknight, c*100, r*100, 100, 100);
      if (grid[r][c] == 'q') image (wqueen, c*100, r*100, 100, 100);
      if (grid[r][c] == 'Q') image (bqueen, c*100, r*100, 100, 100);
      if (grid[r][c] == 'k') image (wking, c*100, r*100, 100, 100);
      if (grid[r][c] == 'K') image (bking, c*100, r*100, 100, 100);
      if (grid[r][c] == 'p') image (wpawn, c*100, r*100, 100, 100);
      if (grid[r][c] == 'P') image (bpawn, c*100, r*100, 100, 100);
    }
  }
}

void receiveMove() {
  
  if (myClient.available() > 0) {
    //println("?");
    String incoming = myClient.readString();
    println(incoming);
    //println(messageType(incoming));
    if (messageType(incoming) == TURN) {
      int r1 = int(incoming.substring(0,1));
      int c1 = int(incoming.substring(2,3));
      int r2 = int(incoming.substring(4,5));
      int c2 = int(incoming.substring(6,7));
      grid[r2][c2] = grid[r1][c1];
      grid[r1][c1] = ' ';
      if ((grid[row2][col2] == 'P') && (row2 == row1 + 2) && (grid[r2][c2] == 'p') && (r2 == row2 - 1)) enPassent();
      myTurn = true;
    } else if (messageType(incoming) == UNDO) {
      int r1 = int(incoming.substring(0,1));
      int c1 = int(incoming.substring(2,3));
      int r2= int(incoming.substring(4,5));
      int c2 = int(incoming.substring(6,7));
      char oldPiece = incoming.charAt(8);
      grid[r1][c1] = grid[r2][c2];
      grid[r2][c2] = oldPiece;
      myTurn = false;
    } else if (messageType(incoming) == PROMOTION) {
      int r2 = int(incoming.substring(0,1));
      int c2 = int(incoming.substring(2,3));
      char piece = incoming.charAt(4);
      //println(piece);
      grid[r2][c2] = piece;
      myTurn = true;
    } else if (messageType(incoming) == PAUSE) {
      int r1 = int(incoming.substring(0,1));
      int c1 = int(incoming.substring(2,3));
      int r2 = int(incoming.substring(4,5));
      int c2 = int(incoming.substring(6,7));
      grid[r2][c2] = grid[r1][c1];
      grid[r1][c1] = ' ';
      myTurn = false;
      //println("paused");
    } else if (messageType(incoming) == ENPASSENT) {
      int r2 = int(incoming.substring(0,1));
      int c2 = int(incoming.substring(2,3));
      grid[r2][c2] = ' ';
    }
  }
}

void highlightSquare() {
  if (!firstClick) {
    strokeWeight(3);
    stroke(255, 0, 0);
    noFill();
    rect(col1*100, row1*100, 100, 100);
  }
}

void checkPromotion() {
  if (pawnPremotion) {
    strokeWeight(3);
    stroke(0);
    fill(255);
    rect (100, 200, 600, 400);
    textAlign(CENTER);
    textSize(50);
    fill(0);
    text("Pawn Premotion", 400, 275);
    textSize(20);
    text("Press a key to choose a piece", 400, 325);
    image(bqueen, 170, 400, 100, 100);
    text("<Q>", 220, 550);
    image(brook, 290, 400, 100, 100);
    text("<R>", 340, 550);
    image(bknight, 410, 400, 100, 100);
    text("<K>", 460, 550);
    image(bbishop, 530, 400, 100, 100);
    text("<B>", 580, 550);
  }
}

void mouseReleased() {
  if (myTurn) {
    if (firstClick) {
      row1 = mouseY/100;
      col1 = mouseX/100;
      if (myPiece()) firstClick = false;
    } else {
      row2 = mouseY/100;
      col2 = mouseX/100;
      if (!(row2 == row1 && col2 == col1)) {
        lastMove = row1 + "," + col1 + "," + row2 + "," + col2 + "," + grid[row2][col2] + "," + UNDO;
        grid[row2][col2] = grid[row1][col1];
        grid[row1][col1] = ' ';
        if (grid[row2][col2] == 'P' && row2 == 7) {
          pawnPremotion = true;
          myClient.write(row1 + "," + col1 + "," + row2 + "," + col2 + "," + PAUSE);
        } else {
        myClient.write(row1 + "," + col1 + "," + row2 + "," + col2 + "," + TURN);
        }
        firstClick = true;
        myTurn = false;
      }
    }
  }
}

boolean myPiece() {
  char selected = (grid[row1][col1]);
  return (str(selected).equals(str(selected).toUpperCase()) && selected != ' ');
  }
  
int messageType(String string) {
  return int(string.substring(string.length() - 1, string.length()));
}

void keyReleased() {
  if ((key == 'z' || key == 'Z') && !(myTurn) && lastMove != " ") {
    grid[row1][col1] = grid[row2][col2];
    grid[row2][col2] = lastMove.charAt(8);
    myClient.write(lastMove);
    lastMove = " ";
    myTurn = true;
  }
  if (pawnPremotion) {
    if (key == 'q' || key == 'Q') {
      grid[row2][col2] = 'Q';
      myClient.write(row2 + "," + col2 + "," + "Q" + "," + PROMOTION);
      pawnPremotion = false;
    } else if (key == 'r' || key == 'R') {
      grid[row2][col2] = 'R';
      myClient.write(row2 + "," + col2 + "," + "R" + "," + PROMOTION);
      pawnPremotion = false;
    } else if (key == 'k' || key == 'K') {
      grid[row2][col2] = 'N';
      myClient.write(row2 + "," + col2 + "," + "N" + "," + PROMOTION);
      pawnPremotion = false;
    } else if (key == 'b' || key == 'B') {
      grid[row2][col2] = 'B';
      myClient.write(row2 + "," + col2 + "," + "B" + "," + PROMOTION);
      pawnPremotion = false;
    }
  }
}

void enPassent() {
  println("En Passent Move");
  grid[row2][col2] = ' ';
  myClient.write(row2 + "," + col2 + "," + ENPASSENT);
}
