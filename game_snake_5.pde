float grid_width = 15;
//Grid game_grid;
Game game_loop;
void setup(){
  size(700, 500);
  frameRate(60);
  //game_grid = new Grid(grid_width);
  game_loop = new Game();
}

void draw(){
  background(0);
  //game_grid.drawGrid();
  game_loop.updateGameState();
}

// keyboard control for game
void keyPressed(){
  if (key == CODED) {
    if (keyCode == UP) {
      game_loop.game_snake.segments.get(0).vel_x = 0;
      game_loop.game_snake.segments.get(0).vel_y = -1;
    }
    else if (keyCode == DOWN) {
      game_loop.game_snake.segments.get(0).vel_x = 0;
      game_loop.game_snake.segments.get(0).vel_y = 1;
    }
    else if (keyCode == RIGHT) {
      game_loop.game_snake.segments.get(0).vel_x = 1;
      game_loop.game_snake.segments.get(0).vel_y = 0;
    }
    else if (keyCode == LEFT) {
      game_loop.game_snake.segments.get(0).vel_x = -1;
      game_loop.game_snake.segments.get(0).vel_y = 0;
    }
    else {
      println("Key: " + key + " is not recognized!");
    }
  }
  else {
    if (key == 'w' || key == 'W') {
      game_loop.game_snake.segments.get(0).vel_x = 0;
      game_loop.game_snake.segments.get(0).vel_y = -1;
    }
    else if (key == 's' || key == 'S') {
      game_loop.game_snake.segments.get(0).vel_x = 0;
      game_loop.game_snake.segments.get(0).vel_y = 1;
    }
    else if (key == 'a' || key == 'A') {
      game_loop.game_snake.segments.get(0).vel_x = 1;
      game_loop.game_snake.segments.get(0).vel_y = 0;
    }
    else if (key == 'd' || key == 'D') {
      game_loop.game_snake.segments.get(0).vel_x = -1;
      game_loop.game_snake.segments.get(0).vel_y = 0;
    }
    else {
      println("Key: " + key + " is not recognized!");
    }
  }
}

class Grid{
  int column;
  int row;
  int grid_width;
  int score;
  
  Grid(float grid_width){
    this.grid_width = int(grid_width);
    column = int(width/this.grid_width - 1);
    row = int(height/this.grid_width - 2);
  }
  // draw the lines in the grid
  void drawGrid(){
    stroke(100);
    strokeWeight(2);
    for(int i = 1; i <= column; i++) {
      line(i*grid_width, grid_width, i*grid_width, row*grid_width);
    }
    for(int j = 1; j <= row; j++) {
      line(grid_width, j*grid_width, column*grid_width, j*grid_width);
    }
    fill(0, 255, 0);
    text("Framerate: " + frameRate, grid_width,  (row + 1)*grid_width);
    text("Score: " + score, (column - 7)*grid_width, (row + 1)*grid_width);
  }
  // get the x-coordinate of a box given the position in the grid
  int getXPos(int pos_x){
    return pos_x*grid_width;
  }
  // get the y-coordinate of a box given the position in the grid
  int getYPos(int pos_y){
    return pos_y*grid_width;
  }
}

class Box{
  int pos_x, pos_y;
  int vel_x, vel_y;
  Grid game_grid;
  Box parent;
  
  // frame rate related fields
  float second_per_block = 0.1;
  int passed_frames = 0;
  
  // for the head segment of the snake
  Box(Grid game_grid) {
    this.game_grid = game_grid;
    pos_x = game_grid.column/2;
    pos_y = game_grid.row/2;
    vel_x = 1;
    vel_y = 0;
  }
  // for the body segments of the snake
  Box(Box parent, Grid game_grid) {
    this.parent = parent;
    this.game_grid = game_grid;
    pos_x = parent.pos_x;
    pos_y = parent.pos_y;
    vel_x = 0;
    vel_y = 0;
  }
  void drawBox(){
    stroke(#057E18);
    strokeWeight(3);
    fill(0, 255, 0);
    rect(game_grid.getXPos(pos_x), game_grid.getYPos(pos_y), game_grid.grid_width, game_grid.grid_width);
  }
  void updateBox(){
    passed_frames += 1;
    if (passed_frames >= int(frameRate*second_per_block)) {
      pos_x += vel_x;
      pos_y += vel_y;
      copyParent();
      passed_frames = 0;
    }
  }
  void copyParent(){
    // if the box has a parent then copy its velocity
    if (parent != null) {
      vel_x = parent.vel_x;
      vel_y = parent.vel_y;
    }
  }
}

class Snake{
  int num_segments = 1;
  Grid game_grid;
  ArrayList<Box> segments = new ArrayList<Box>();
  int foodx, foody;
  Snake(Grid game_grid) {
    this.game_grid = game_grid;
    segments.add(new Box(game_grid));
    for(int i = 1; i < num_segments; i++) {
      segments.add(new Box(segments.get(i - 1), game_grid));
    }
  }
  // call the draw and update methods for each box in the snake
  // must be done from the tail to the head
  void updateSnake(){
    for(int i = segments.size() - 1; i >= 0; i--) {
      segments.get(i).drawBox();
      segments.get(i).updateBox();
    }
    checkSelfCollision();
  }
  // check if the snake eat its own tail, remove the blocks that it eat
  void checkSelfCollision(){
    boolean bitten = false;
    for(int i = 2; i < segments.size(); i++){
      if (segments.get(0).pos_x == segments.get(i).pos_x && segments.get(0).pos_y == segments.get(i).pos_y) {
        bitten = true;
      }
      if (bitten) {
        segments.remove(segments.size() - 1);
      }
    }
  }
}

class Game{
  Grid game_grid;
  Snake game_snake;
  int foodx, foody;
  float grid_width = 20;
  boolean game_started;
  Game() {
    game_grid = new Grid(grid_width);
    game_snake = new Snake(game_grid);
    game_started = false;
    createFood();
  }
  // show the start screen at the start of the game
  void showStartScreen(){
    fill(255);
    textSize(20);
    text("Press any key to start game", game_grid.getXPos(game_grid.column)/2, game_grid.getYPos(game_grid.row)/2);
  }
  // update the game loop
  void updateGameState(){
    if (game_started) {
      game_snake.updateSnake();
      game_grid.drawGrid();
      drawFood();
      updateFood();
      checkWallCollision();
    }
    else {
      if (keyPressed) {
        game_started = true;
      } 
      else {
        showStartScreen();
      }
    }
  }
  // draw the food
  void drawFood(){
    stroke(#B70909);
    strokeWeight(2);
    fill(255, 0, 0);
    rect(game_grid.getXPos(foodx), game_grid.getYPos(foody), grid_width, grid_width);
  }
  // generate the food for the snake
  void createFood(){
    foodx = int(random(1, game_grid.column));
    foody = int(random(1, game_grid.row));
  }
  // update the position of the food if it has been eaten by the food
  void updateFood(){
    if (game_snake.segments.get(0).pos_x == foodx && game_snake.segments.get(0).pos_y == foody) {
      createFood();
      game_snake.segments.add(new Box(game_snake.segments.get(game_snake.segments.size() - 1), game_grid));
      game_grid.score += 1;
    }
  }
  // end the game if the snake hits the wall
  void checkWallCollision(){
    if (game_snake.segments.get(0).pos_x >= game_grid.column || game_snake.segments.get(0).pos_y >= game_grid.row || game_snake.segments.get(0).pos_x <= 0 || game_snake.segments.get(0).pos_y <= 0){
      game_started = false;
      resetGame();
    }
  }
  // reset the game state when the player loses
  void resetGame(){
    game_grid = new Grid(grid_width);
    game_snake = new Snake(game_grid);
    createFood();
  }
}
