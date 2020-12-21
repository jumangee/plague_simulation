// const

int BUILDING_ROOM_SIZE = 7;
int BUILDING_ROOMS_ROW = 2;
int BUILDING_WALL_SIZE = 1;
int BUILDING_MAX_POW = 3;
int BUILDING_ADJACENCY = 3;

int MAX_PEOPLE_IN_ROOM = 4;

int TICKS_PER_HOUR = 40;
int HOURS_PER_DAY = 12;


//////

Simulation simulation;

//////

void settings() {
  fullScreen(P2D);
}

void setup() {
  simulation = new Simulation();
}

void draw() {
  if (simulation.initComplete != 2) {
    if (simulation.initComplete == 0) {
      thread("initSimulation");
    }
    simulation.fullScreenMessage(0, "Создание города...");
    return;
  }
  
  simulation.update();
  simulation.draw();
}

void initSimulation() {
  println ("init...");
  simulation.init();
  println ("ok");
}
