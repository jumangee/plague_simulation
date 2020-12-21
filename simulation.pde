import java.util.Map;

class Simulation {
  int dayTicks;
  int dayNum = 1;
  
  building buildings[] = {};
  room rooms[] = {};
  human people[] = {};

  IndexToObjects<building> indexBuildings;
  IndexToObjects<human> indexPeople;
  
  PGraphics frameBuffer;
  PGraphics frameBuffer2;

  IntList fps = new IntList();
  int frameCounterTime = 0;
  int frameCounter = 0;
  
  ArrayList<rooms> roomsCache = new ArrayList<rooms>(); 
  
  HashMap<String, PGraphics> backBuffer;
  
  // task "threads"
  HashMap<String, simulationtask> task;
  
  HistoryBook history;
  
  int initComplete = 0;
  
  Simulation() {
    dayTicks = daysToTicks(1);
    
    indexBuildings = new IndexToObjects<building>(width, height);
    indexPeople = new IndexToObjects<human>(width, height);
    
    backBuffer = new HashMap<String, PGraphics>();
    task = new HashMap<String, simulationtask>();
    
    history = new HistoryBook();
    
    task.put("POPULATION", new population(this));
    task.put("VIRUS", new virus(this)); 
    task.put("PRODUCTION", new production(this));
    
    frameBuffer = createGraphics(width, height);
    frameBuffer2 = createGraphics(width, height);  
  }
  
  // shortcuts to tasks
  
  production getProduction() {
    return (production)getTask("PRODUCTION");
  }
  
  virus getVirus() {
    return (virus)getTask("VIRUS");
  }
  
  population getPopulation() {
    return (population)getTask("POPULATION");
  }
  
  ////
  
  // buildings index
  void addBuilding(building b) {
    this.buildings = (building[])append(this.buildings, b);
  }
  
  void tickDays() {
    dayTicks--;
    if (dayTicks < 1) {

      HistoryBookEntry rec = history.entry("Day " + dayNum);
      dayNum++;
      dayTicks = daysToTicks(1);
      
      for (Map.Entry t : task.entrySet()) {
        ((simulationtask)t.getValue()).dayPassed(rec);
      }
      
      println ("=== " + rec.header +" ===");
      for (Map.Entry dayResult : rec.data.entrySet()) {
        println(dayResult.getKey() + ": " + dayResult.getValue());
      }
    }
  }
  
  // room index
  void addRoom(room r) {
    this.rooms = (room[])append(this.rooms, r);
  }
  
  // human index
  void addHuman(human h) {
    this.people = (human[])append(this.people, h);
  }
  
  rooms getRooms(int type) {
    ArrayList<room> result = new ArrayList<room>();
    for(room r: this.rooms) {
      if (type == r.type || type == -1) {
        result.add(r);
      }
    }
    return new rooms(result);
  }
  
  building getBuildingAt(int x, int y) {
    ArrayList<building> list = indexBuildings.get(x, y);
    return list.size() > 0 ? list.get(0) : null;
  }
  
  human[] getPeopleAt(int x, int y, int radius) {
    ArrayList<human> list = new ArrayList<human>();
    for(int dx = x - radius; dx < x + radius; dx++) {
      for(int dy = y - radius; dy < y + radius; dy++) {
        if (sqrt(pow(x - dx, 2) + pow(y - dy, 2)) <= (float)radius) {
          list.addAll( indexPeople.get(dx, dy) );
        }
      }
    }
    human[] result = new human[list.size()];
    return list.toArray(result);
  }
  
  boolean placeBuilding(building b) {
    int w = b.w + b.rooms.length * 2;
    int h = b.h + b.rooms.length * 2;

    for (int x = rand(10, 125) + b.getAdjacency(); x < width - 200 - (b.w + b.getAdjacency()); x+=w) {
      for (int y = rand(10, 125) + b.getAdjacency(); y < height - (b.h + b.getAdjacency()); y+=h) {
        b.setPos(x, y);
        boolean skip = false;
        for (building t: this.buildings) {
          if (t.zone.getIntersect(b.zone) != null) {
            skip = true;
            break;
          }
        }
        if (!skip) {
          this.addBuilding(b);
          b.registerRooms();
          for (int cx = b.x; cx < b.x + b.w; cx++) {
            for (int cy = b.y; cy < b.y + b.h; cy++) {
              indexBuildings.add(cx, cy, b);
            }
          }
          return true;
        }
      }
    }
    return false;
  }
  
  void fullScreenMessage(int bgcolor, String msg) {
    background(bgcolor);
    
    textSize(24);
    fill(255, 255, 255);
    textAlign(LEFT);
    text(msg, 50, 100);
  }
  
  ////
  
  void init() {
    initComplete = 1;
    
    // create buildings
    int BUILDINGS_MASK[] = {
      building.TYPE_HOUSE,
      building.TYPE_HOUSE,
      building.TYPE_HOUSE,
      building.TYPE_HOUSE_WITH_SHOP,
      building.TYPE_HOUSE_WITH_SHOP,
      building.TYPE_HOUSE_WITH_SHOP,
      building.TYPE_HOUSE_WITH_SHOP,
      building.TYPE_HOUSE_WITH_SHOP,
      building.TYPE_HOUSE_WITH_SHOP,
      building.TYPE_HOUSE_WITH_SHOP,
      building.TYPE_HOUSE_WITH_SHOP,
      building.TYPE_HOUSE_WITH_SHOP,
      building.TYPE_SHOP,
      building.TYPE_OFFICE,
      building.TYPE_OFFICE,
      building.TYPE_SHOP
    };
      do {
    } while (this.placeBuilding( new building(this, BUILDINGS_MASK[rand(0, BUILDINGS_MASK.length-1)]) ));
    
    /// create hospitals from offices
    
    for (int i = 0; i < rand(7, 15); i++) {
      building b;
      do {
        b = buildings[rand(0, buildings.length-1)];
      } while(b.getSize() < 4);
      b.convertToHospital();
    }
    
    ///
    
    roomsCache.add( getRooms(room.TYPE_HOME) );
    roomsCache.add( getRooms(room.TYPE_SHOP) );
    roomsCache.add( getRooms(room.TYPE_OFFICE) );
    roomsCache.add( getRooms(room.TYPE_HOSPITAL) );

    PGraphics cacheImage;

    ///
    // terrain pre-cache
    cacheImage = createGraphics(width - 200, height);
    cacheImage.beginDraw();
    cacheImage.background(128);
    for(building b: this.buildings) {
      b.drawTerrain(cacheImage);
    }
    cacheImage.endDraw();
    
    backBuffer.put("TERRAIN", cacheImage);

    ///

    // buildings pre-cache 
    cacheImage = createGraphics(width - 200, height);
    cacheImage.beginDraw();
    for(building b: this.buildings) {
      b.draw(cacheImage);
    }
    cacheImage.endDraw();
    
    backBuffer.put("BUILDINGS", cacheImage);
    
    ///
    
    // cursed human danger zone sprite
    cacheImage = createGraphics(60, 60);
    cacheImage.beginDraw();
    cacheImage.noStroke();
    for(int i = 0; i < 30; i++) {
      cacheImage.fill(255, 0, 0, sqrt(i + 1));
      cacheImage.circle(30, 30, 31 - i);
    }
    cacheImage.endDraw();
    
    backBuffer.put("SPRITE_CURSED", cacheImage);
    
    ///
    
    room[] workPlaces = roomsCache.get(2).items;
    
    // create people
    for (room r: this.rooms) {
      if (r.type == 0) {
        int num = rand(1, MAX_PEOPLE_IN_ROOM);
        for (int i = 0; i < num; i++) {
          human h = new human(this, workPlaces[rand(0, workPlaces.length-1)]);
          r.addHuman(h);
          h.home = r;
          h.x = r.getX() + rand(1, BUILDING_ROOM_SIZE-1);
          h.y = r.getY() + rand(1, BUILDING_ROOM_SIZE-1);
          this.addHuman(h);
          h.target = r;
          //break;
        }
      }
    }
    
    frameCounterTime = millis();
    
    getPopulation().dayPassed(null);  // hack: population counter
    
    println ("=== done setup ===");
    println ("buildings: " + this.buildings.length);
    println ("rooms: " + this.rooms.length);
    println ("people: " + this.people.length);
    
    initComplete = 2;
  }
  
  simulationtask getTask(String name) {
    return task.get(name);
  }
  
  void update() {
    for (Map.Entry t : task.entrySet()) {
      ((simulationtask)t.getValue()).update();
    }
    tickDays();
  }
  
  void draw() {

    /// map
    frameBuffer.beginDraw();
    
    frameBuffer.background(250);
    
    frameBuffer.image(backBuffer.get("TERRAIN"), 0, 0);

    
    frameBuffer2.smooth(4);
    frameBuffer2.beginDraw();
    
    frameBuffer2.clear();

    for(human h: this.people) {
      if (h.healthStatus == 3) {
        frameBuffer.image(backBuffer.get("SPRITE_CURSED"), h.x - 30, h.y - 30);
      }
      h.draw(frameBuffer2);
    }
    frameBuffer2.endDraw();
    
    frameBuffer.image(backBuffer.get("BUILDINGS"), 0, 0);
    
    frameBuffer.image(frameBuffer2, 0, 0);

    frameBuffer.endDraw();

    image(frameBuffer, 0, 0);
    
    /// info
    
    population populationTask = getPopulation();
    virus virusTask = getVirus();
    //production productionTask = getProduction();
    
    TextPrint print;
    int printPosY = height - 10;
    
    textAlign(RIGHT);
    
    print = new TextPrint(20, 5);
    print.add("День: " + dayNum);
    print.add("Жителей: " + populationTask.count);
    print.add("Заражённых: " + populationTask.infected);
    print.add("Умерло: " + populationTask.deaths);

    print.print(width - 10, printPosY, 0, -1);
    
    printPosY -= (print.getHeight() + 10);
    
    print = new TextPrint(20, 5);

    int totalCases = virusTask.getTotalCases();
    print.add("Всего случаев: " + totalCases);
    
    if (totalCases > 0) {
      print.add("Дома: " + int((float)virusTask.spreadAtHome / (float)totalCases * 100) + "%");
      print.add("На улице: " + int((float)virusTask.spreadAtStreet / (float)totalCases * 100) + "%");
      print.add("В магазине: " + int((float)virusTask.spreadAtShop / (float)totalCases * 100) + "%");
      print.add("На работе: " + int( (float)virusTask.spreadAtWork / (float)totalCases * 100) + "%");
    }
    print.add("Выздоровлений: " + virusTask.cureds);
    
    print.print(width - 10, printPosY, 0, -1);
    
    printPosY -= (print.getHeight() + 10);
    
    //////////////////////
    
    // info
    
    // w - 180 = > w - 20
    int barLen = 160;
    
    /// fps

    int y = printPosY-1;
    stroke(200, 200, 255);
    
    
    for (int i = fps.size() - 1; i > 0; i--) {
      float len = min(barLen, fps.get(i));
      line(width - 20 - len, y, width - 20, y);
      y--;
      if (y < 1) {
        break;
      }
    }

    int time = millis();
    if (time - frameCounterTime > 999) {
      frameCounterTime = time;
      fps.append(frameCounter);
      frameCounter = 0;
    } else {
      frameCounter++;
    }
    
    /// history logs (per day)
    
    stroke(200, 200, 200);
    line(width - 180, printPosY, width - 20, printPosY);
    y = printPosY-2;
    
    strokeCap(SQUARE);
    strokeWeight(2); 
    int totalHistory = history.log.size();
    for (int i = totalHistory - 1; i > 0; i--) {
      HistoryBookEntry rec = history.log.get(i);
      float value;
      
      // virus spreading
      stroke(255, 0, 0);
      value = (float)barLen * ((float)rec.getNum("INFECTED") / (float)rec.getNum("POPULATION"));
      //line(width - 180, printPosY-3-(totalHistory-i)*3, width - 180 + value, printPosY-3-(totalHistory-i)*3);
      line(width - 180, y, width - 180 + value, y);
      
      // virus detection
      stroke(255, 255, 100);
      value = (float)barLen * ((float)rec.getNum("DAILY_DETECTIONS") / (float)rec.getNum("POPULATION"));
      //line(width - 180, printPosY-1-(totalHistory-i)*3, width - 180 + value, printPosY-1-(totalHistory-i)*3);
      line(width - 180, y+2, width - 180 + value, y+2);
      
      /// production
      
      // zero
      stroke(220, 220, 220);
      point(width - 180 + 80, y);
      
      strokeCap(ROUND);
      strokeWeight(2);
      
      // eco change
      stroke(200, 50, 200);
      //value = (float)160 * ((float)rec.getNum("ECONOMICS") / production.ZERO_BALANCE_VALUE);
      point(width - 180 + 80 + rec.getNum("ECONOMICS"), y);

      // happiness change
      stroke(0, 0, 255);
      //value = (float)160 * ((float)rec.getNum("HAPPINESS") / production.ZERO_BALANCE_VALUE);
      point(width - 180 + 80 + rec.getNum("HAPPINESS"), y + 1);

      // sociality change
      stroke(0, 255, 0);
      //value = (float)160 * ((float)rec.getNum("SOCIALITY") / production.ZERO_BALANCE_VALUE);
      point(width - 180 + 80 + rec.getNum("SOCIALITY"), y + 2);

      y -= 4;
      if (y < 1) {
        break;
      }
    }
    strokeWeight(1);
  }
}
