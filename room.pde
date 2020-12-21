class room {
  int x;
  int y;
  int type; // 0 - home, 1 - shop, 2 - office, 3 - medicine
  int enteringX;
  int enteringY;
  
  static final int TYPE_HOME = 0;
  static final int TYPE_SHOP = 1;
  static final int TYPE_OFFICE = 2;
  static final int TYPE_HOSPITAL = 3;
  
  ArrayList<human> people = new ArrayList<human>();
  color fillColor;
  building building;
  
  room(building b, int type, int x, int y, boolean side) {
    this.type = type;
    this.x = x;
    this.y = y;
    this.building = b;
    
    enteringX = !side ? (-BUILDING_WALL_SIZE) : (BUILDING_ROOM_SIZE + BUILDING_WALL_SIZE);
    enteringY = round((BUILDING_ROOM_SIZE - 1) / 2);
    
    fillColor = color(229, 229, 31);
    switch (type) {
      case room.TYPE_HOSPITAL: fillColor = color(255, 255, 255); break;
      case room.TYPE_OFFICE: fillColor = color(170, 50, 170); break;
      case room.TYPE_SHOP : fillColor = color(0, 0, 255); break;
    }
  }
  
  void setPos(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  void addHuman(human h) {
    this.people.add(h);
  }
  
  void removeHuman(human h) {
    for (int i = this.people.size() - 1; i >= 0; i--) {
      if (this.people.get(i) == h) {
        this.people.remove(i);
        return;
      }
    }
  }
  
  int getX() {
    return building.x + BUILDING_WALL_SIZE + x;
  }
  
  int getY() {
    return building.y + BUILDING_WALL_SIZE + y;
  }
  
  zone getSpace() {
    return new zone(getX()+1, getY()+1,BUILDING_ROOM_SIZE-1,BUILDING_ROOM_SIZE-1);
  }
  
  void draw(PGraphics pg) {
    if (pg != null) {
      pg.stroke(200);
      pg.fill(fillColor);
      pg.rect(getX(), getY(), BUILDING_ROOM_SIZE, BUILDING_ROOM_SIZE);
      
      pg.stroke(128);
      pg.fill(128);
      pg.rect(getX() + enteringX, getY() + enteringY, 1, 1);
      return;
    }
    stroke(200);
    fill(fillColor);
    rect(getX(), getY(), BUILDING_ROOM_SIZE, BUILDING_ROOM_SIZE);
  }
}
