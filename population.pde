
class population implements simulationtask {
  Simulation sim;
  
  int infected = 0;
  int deaths = 0;
  int count = 0;
  
  population(Simulation s) {
    sim = s;
  }
  
  void update() {
    infected = 0;
    deaths = 0;
    count = 0;

    for (human h: sim.people) {
      h.update();
      
      switch (h.healthStatus) {
        case human.HEALTH_IMMUNITY: 
        case human.HEALTH_NORMAL:
          count++; break;
        case human.HEALTH_INCUBATION: 
        case human.HEALTH_INFECTED:
          count++;
          infected++; break;
        case human.HEALTH_DEAD:
          deaths++; break;
      }
    }
  }
  
  void dayPassed(HistoryBookEntry rec) {
    if (rec != null) {
      rec.set("INFECTED", infected);
      rec.set("POPULATION", count);
    }
  }
  
}
