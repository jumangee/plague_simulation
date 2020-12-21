
class virus implements simulationtask {
  Simulation sim;
  
  int VIRUS_SPREAD_RADIUS = 1;
  int VIRUS_SPREAD_PROBABILITY = 2;
  int VIRUS_DETECT_PROBABILITY = 25;
  int VIRUS_DEATH_CHANCE = 5;
  int VIRUS_ACTIVE_DAYS = 14;
  int VIRUS_IMMUNITY_DAYS = 21;
  
  int spreadStart = rand(300, 700);
  
  int spreadAtWork = 0;
  int spreadAtHome = 0;
  int spreadAtStreet = 0;
  int spreadAtShop = 0;
  int spreadAtHosp = 0;
  
  //IntList casesHistory = new IntList();
  //IntList detectionHistory = new IntList();
  
  int cureds = 0;
  int dailyDetections = 0;
  
  int knowledge = 0;
  
  
  virus(Simulation s) {
    this.sim = s;
  }
  
  void dayPassed(HistoryBookEntry rec) {
    rec.set("TOTAL_CASES", getTotalCases());
    rec.set("DAILY_DETECTIONS", dailyDetections);
    rec.set("TOTAL_CUREDS", cureds);
    //casesHistory.append();
    //detectionHistory.append(dailyDetections);
    dailyDetections = 0;
  }
  
  int getTotalCases() {
    return spreadAtWork + spreadAtHome + spreadAtStreet + spreadAtShop + spreadAtHosp;
  }
  
  void update() {
    if (spreadStart > 0) {
      spreadStart--;
      if (spreadStart == 0) {
        println("spread started!");
        sim.people[rand(0, sim.people.length-1)].setIllness();
      }
    }
  }
  
  void addKnowledge() {
    knowledge++;
  }

  void spreadDecease(human source) {
    if (source.isInside()) {
      // inside
      for (human h: source.target.people) {
        if (h.healthStatus == 0 && (source.distanceBetween(h) < this.VIRUS_SPREAD_RADIUS*2) && checkSuccess(VIRUS_SPREAD_PROBABILITY, h.isAtHospital() ? -VIRUS_SPREAD_PROBABILITY/2 : 0)) {
          switch (h.job) {
            case "WORK": this.spreadAtWork++; break;
            case "HOME": this.spreadAtHome++; break;
            case "SHOP": this.spreadAtShop++; break;
            case "HOSPITAL": this.spreadAtHosp++; break;
          }
          h.setIllness();
          h.infectedsCount++;
        }
      }
    }
    else {
      // outside
      human[] nearby = sim.getPeopleAt(source.x, source.y, VIRUS_SPREAD_RADIUS);
      for (human h: nearby) {
        if (h.healthStatus == 0 && !h.isInside() && checkSuccess(VIRUS_SPREAD_PROBABILITY/2)) {  // lower probability
          // spreading
          this.spreadAtStreet++;
          h.setIllness();
          h.infectedsCount++;
        }
      }
    }  
  }
}
