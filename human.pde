class human {
  int x;
  int y;
  int lastmx, lastmy;
  int healthStatus;

  static final int HEALTH_DEAD = -1;
  static final int HEALTH_NORMAL = 0;
  static final int HEALTH_INCUBATION = 1;
  static final int HEALTH_IMMUNITY = 2;
  static final int HEALTH_INFECTED = 3;
  
  room home;
  int healthChangeTime;
  int workType; // 0 - home, 1 - std, 2 - rand
  String job;
  int nextJob;
  room target;
  room work;
  Simulation sim;
  int infectedsCount = 0;
  boolean detectedDecease = false;
  boolean triedDetection = false;
  
  human(Simulation s, room work) {
    int[] TYPES_MASK = {0, 0, 1, 1, 1, 1, 1, 1, 2, 2, 2};
    this.job = "HOME";
    this.workType = TYPES_MASK[rand(0, TYPES_MASK.length-1)];
    healthStatus = human.HEALTH_NORMAL;
    nextJob = hoursToTicks(rand(0, 10));
    sim = s;
    if (workType == 1) {
      this.work = work;
    }
  }
  
  room getHome() {
    return home;
  }
  
  boolean checkNextJob() {
    switch (job) {
      case "HOME": {
        if (nextJob < 1) {
          if (workType == 0) {
            return false;
          }
          if (healthStatus == human.HEALTH_INFECTED && detectedDecease) {
            this.nextJob = daysToTicks(1);
            return false;
          }
          String NEXT_MASK[] = {"GO_SHOP", "GO_SHOP", "GO_WORK", "GO_WORK", "GO_WORK"};
          this.job = NEXT_MASK[rand(0, NEXT_MASK.length-1)];
          int targetType = -1;
          target.removeHuman(this);
          switch (job) {
            case "GO_SHOP": {
              // shopping
              targetType = room.TYPE_SHOP;
              break;
            }
            case "GO_WORK": {
              // work
              if (workType == 1) {
                // fixed work
                target = this.work;
                return true;
              }
              targetType = room.TYPE_OFFICE;
              break;
            }
          }
          room[] rooms = sim.roomsCache.get(targetType).items;
          target = rooms[rand(0, rooms.length-1)];
          return true;
        }
        break;
      }
      case "WORK": {
        if (nextJob < 1) {
          String NEXT_MASK[] = {"GO_SHOP", "GO_HOME", "GO_HOME", "GO_HOME"};
          this.job = NEXT_MASK[rand(0, NEXT_MASK.length-1)];
          target.removeHuman(this);
          switch (job) {
            case "GO_HOME": {
              // home
              target = this.home;
              break;
            }
            case "GO_WORK": {
              // shopping
              room[] rooms = sim.roomsCache.get(1).items;
              target = rooms[rand(0, rooms.length-1)];
              break;
            }
          }
          return true;
        }
        break;
      }
      case "SHOP": {
        if (nextJob < 1) {
          String NEXT_MASK[] = {"GO_WORK", "GO_HOME", "GO_HOME", "GO_HOME", "GO_HOME", "GO_HOME"};
          this.job = NEXT_MASK[rand(0, NEXT_MASK.length-1)];
          target.removeHuman(this);
          switch (job) {
            case "GO_HOME": {
              // home
              target = this.home;
              break;
            }
            case "GO_WORK": {
              // shopping
              room[] rooms = sim.roomsCache.get(1).items;
              target = rooms[rand(0, rooms.length-1)];
              break;
            }
          }
          return true;
        }
        break;
      }
      case "CHECK": {
        if (nextJob < 1) {
          triedDetection = true;
          virus v = sim.getVirus();
          if (this.healthStatus == human.HEALTH_INFECTED && checkSuccess(v.VIRUS_DETECT_PROBABILITY)) {
            
            // detected virus
            this.detectedDecease = true;
            v.addKnowledge();
            v.dailyDetections++;
            
            if (this.target.people.size() < 10) {
              // start treatment
              this.job = "HOSPITAL";
              this.nextJob = daysToTicks(3);
              return true;
            }
          }
          this.job = "GO_HOME";
          target.removeHuman(this);
          target = this.home;
          return true;
        }
        break;
      }
      case "HOSPITAL": {
        if (nextJob < 1) {
          if (this.healthStatus == human.HEALTH_INFECTED) {
            if (checkSuccess(15)) {
              // continue treatment
              this.job = "HOSPITAL";
              this.nextJob = daysToTicks(3);
              return true;
            }
          }
          // un-detected virus or cured
          this.detectedDecease = false;
          this.job = "GO_HOME";
          target.removeHuman(this);
          target = this.home;
          return true;
        }
        break;
      }
      case "GO_SHOP":
      case "GO_WORK":
      case "GO_CHECK":
      case "GO_HOME": {
        if (target.getX() + target.enteringX == x && target.getY() + target.enteringY == y) {
          // in place
          target.addHuman(this);
          switch (job) {
            case "GO_HOME": {
              // home
              nextJob = hoursToTicks(HOURS_PER_DAY / 3);
              job = "HOME";
              break;
            }
            case "GO_SHOP": {
              // shopping
              job = "SHOP";
              nextJob = hoursToTicks(HOURS_PER_DAY / 6);
              break;
            }
            case "GO_WORK": {
              // work
              job = "WORK";
              nextJob = hoursToTicks(HOURS_PER_DAY / 2);
              break;
            }
            case "GO_CHECK": {
              // work
              job = "CHECK";
              nextJob = hoursToTicks(HOURS_PER_DAY / 6);
              break;
            }
          }
          return true;
        }
        break;
      }
    }
    return false;
  }
  
  void updateAtRoom() {
    zone space = this.target.getSpace();
    int newX = this.x - 1 + rand(0, 3);
    int newY = this.y - 1 + rand(0, 3);
    if (space.isIn(newX, newY)) {
      this.x = newX;
      this.y = newY;
    }
    sim.getProduction().job(this);
          
    nextJob--;
  }
  
  boolean goToRoom() {
    int tX = target.getX() + target.enteringX;
    int tY = target.getY() + target.enteringY;
    if (this.checkNextJob()) {  // changed
      return false;
    }
    int mx = tX > this.x ? 1 : (tX < this.x ? -1 : 0); 
    int my = tY > this.y ? 1 : (tY < this.y ? -1 : 0);

    lastmx = mx;
    lastmy = my;

    building b = sim.getBuildingAt(this.x + mx, this.y + my);
    if (b != null && b != target.building) {
      b = sim.getBuildingAt(this.x, this.y + my);
      if (b != null && b != target.building) {
        b = sim.getBuildingAt(this.x + mx, this.y);
        if (b != null && b != target.building) {
          mx = 0;
        } else {
          my = 0;
        }
      } else {
        mx = 0;
      }
    }
    
    if (mx == 0 && my == 0) {
      mx = lastmx;
      my = lastmy;
    }
    
    //println ("x=" + x + ", y=" + y +" // tx=" + tX + ", ty=" + tY + " // nx:" + ( tX > this.x ? 1 : (tX < this.x ? -1 : 0) ) + ", ny=" + (tY > this.y ? 1 : (tY < this.y ? -1 : 0)) + " // mx=" + mx + ", my=" + my);
    
    move(this.x + mx, this.y + my);
    
    return true;
  }
  
  void move(int newx, int newy) {
    sim.indexPeople.remove(this.x, this.y, this); 
    this.x = newx;
    this.y = newy;
    sim.indexPeople.add(newx, newy, this);
  }
  
  void setIllness() {
    healthStatus = human.HEALTH_INCUBATION;
    healthChangeTime = daysToTicks(rand(0, 3));
    detectedDecease = false;
    triedDetection = false;
  }
  
  float distanceBetween(human other) {
    return sqrt(pow(this.x - other.x, 2) + pow(this.y - other.y, 2));
  }
  
  boolean isInside() {
    return !(this.job.substring(0,3).equals("GO_"));
  }
  
  boolean isAtHospital() {
    return this.job.equals("HOSPITAL");
  }
  
  void death() {
    healthStatus = human.HEALTH_DEAD;
    if (target != null) {
      target.people.remove(this);
      target = null;
    }
    sim.indexPeople.remove(this.x, this.y, this);
  }
  
  boolean updateHealth() {
    healthChangeTime--;
    
    virus virus = sim.getVirus();
    
    if (healthChangeTime < 1) {
      if (healthStatus == human.HEALTH_IMMUNITY) {
        healthStatus = 0;
        return true;
      }
      if (healthStatus == 1) {
        healthStatus = human.HEALTH_INFECTED;
        healthChangeTime = daysToTicks(rand(virus.VIRUS_ACTIVE_DAYS * .75, virus.VIRUS_ACTIVE_DAYS * 1.25));
        return true;
      }
      // 3 => 2 && 3 => -1
      detectedDecease = false;
      int deathChance = sim.getVirus().VIRUS_DEATH_CHANCE;
      if (checkSuccess(deathChance, isAtHospital() ? -deathChance/2 : 0.0)) {
        // died
        death();
        return false;
      }
      healthStatus = human.HEALTH_IMMUNITY;
      virus.cureds++;
      healthChangeTime = daysToTicks(rand(virus.VIRUS_IMMUNITY_DAYS * .75, virus.VIRUS_IMMUNITY_DAYS * 1.25));
    } else if (healthStatus == human.HEALTH_INFECTED) {
      if (this.job.equals("HOME") && !detectedDecease && !triedDetection) {
        if (checkSuccess(10, infectedsCount)) {
          // decision to go hospital
          this.job = "GO_CHECK";
          room[] rooms = sim.roomsCache.get(room.TYPE_HOSPITAL).items;
          this.target = rooms[rand(0, rooms.length-1)];
        }
      }
      virus.spreadDecease(this);
    }
    return true;
  }
  
  void update() {
    if (healthStatus == human.HEALTH_DEAD) {
      // died
      return;
    }
    
    if (healthStatus != human.HEALTH_NORMAL) {
      if (!updateHealth()) {
        return;
      }
    }

    if (isInside()) {
      updateAtRoom();
    } else 
      if (!isInside()) {
        for (int s = 0; s < 5; s++) {
          if (!goToRoom()) {
            break;
          }
        }
        return;
      }
    
    this.checkNextJob();
  }
  
  void draw(PGraphics pg) {
    int pcolor = 0;
    switch (healthStatus) {
      case human.HEALTH_DEAD: return;
      case human.HEALTH_NORMAL: pcolor = color(0, 255, 0); break;
      case human.HEALTH_IMMUNITY: pcolor = color(220, 220, 10); break;
      case human.HEALTH_INCUBATION: pcolor = color(0, 0, 0); break;
      case human.HEALTH_INFECTED: pcolor = color(255, 0, 0); break;
    }
    
    pg.stroke(pcolor);
    //pg.noStroke();
    //pg.fill(pcolor);
    
    pg.strokeCap(ROUND);
    pg.strokeWeight(2); 
    pg.point(this.x, this.y);
    //pg.circle(this.x, this.y, 2);
    pg.strokeWeight(1);
  }
}
