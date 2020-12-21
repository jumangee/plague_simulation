
class production implements simulationtask {
  
  Simulation sim;
  
  //static final int ZERO_BALANCE_VALUE = 100000;

  int economics = 100;
  int sociality = 100;
  int happiness = 100;
  
  int economicsTotal = 0;
  int socialityTotal = 0;
  int happinessTotal = 0;

  production(Simulation s) {
    this.sim = s;
  }
  
  void dayPassed(HistoryBookEntry rec) {
    int population = sim.getPopulation().count;
    
    float ratio = (float)this.economics / population;
    economicsTotal += ratio > 1 ? 1 : (ratio < 0.1 ? -1 : 0);
    rec.set("ECONOMICS", economicsTotal);
    
    ratio = (float)this.happiness / population;
    happinessTotal += ratio > 1 ? 1 : (ratio < 0.1 ? -1 : 0);
    rec.set("HAPPINESS", happinessTotal);
    
    ratio = (float)this.sociality / population;
    socialityTotal += ratio > 1 ? 1 : (ratio < 0.1 ? -1 : 0);
    rec.set("SOCIALITY", socialityTotal);
    
    economics = 0;
    sociality = 0;
    happiness = 0;
  }
  
  void update() {
    int population = sim.getPopulation().count;
    
    this.economics -= population * .61;
    this.economics -= sim.buildings.length * .61;
    
    this.happiness -= population * .39;
    
    this.sociality -= population * .43;
  }
  
  void job(human src) {
    switch (src.job) {
      case "HOME": {
        if (src.healthStatus != 3) {
          this.sociality += 1;
          this.happiness += 1;
        }
        break;
      }
      case "WORK": {
        this.economics += 4;
        break;
      }
      case "SHOP": {
        // work
        this.economics += 1;
        this.happiness += 2;
        this.sociality += 1;
        break;
      }
      case "HOSPITAL": {
        this.economics--;
        this.happiness--;
        break;
      }
    }
  }
  
}
