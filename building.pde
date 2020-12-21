class building {
  room rooms[] = {};
  int x;
  int y;
  int w;
  int h;
  int type;
  int rows;
  
  static final int TYPE_HOUSE = 0;
  static final int TYPE_HOUSE_WITH_SHOP = 1;
  static final int TYPE_SHOP = 2;
  static final int TYPE_OFFICE = 3;
  static final int TYPE_HOSPITAL = 4;
  
  zone zone;
  Simulation simulation;
  
  building(Simulation simulation, int type) {
    this.type = type;
    this.simulation = simulation;
    
    int rooms = int(pow(BUILDING_ROOMS_ROW, rand(0, BUILDING_MAX_POW)));
    rows = rooms == 1 ? 1 : ceil( rooms / BUILDING_ROOMS_ROW );
    h = rows * BUILDING_ROOM_SIZE + BUILDING_WALL_SIZE * 2;
    w = (rooms == 1 ? BUILDING_ROOM_SIZE : BUILDING_ROOM_SIZE * BUILDING_ROOMS_ROW) + BUILDING_WALL_SIZE * 2;
    
    int tx = 0;
    int ty = 0;
    for (int i = 0; i < rooms; i++) {
      boolean side = i % BUILDING_ROOMS_ROW > 0;
      this.addRoom(this.createRoom(tx, ty, side));
      tx += BUILDING_ROOM_SIZE;
      if (side) {
        tx = 0;
        ty += BUILDING_ROOM_SIZE;
      }
    }
  }
  
  int getSize() {
    return this.rooms.length;
  }
  
  void convertToHospital() {
    type = TYPE_HOSPITAL;
    room t = this.createRoom(0, 0, true);
    for (room r: this.rooms) {
      r.fillColor = t.fillColor;
      r.type = t.type;
    }
  }
  
  room createRoom(int x, int y, boolean side) {
    int BUILDING_TYPE1[] = {room.TYPE_HOME, room.TYPE_HOME, room.TYPE_SHOP};
    
    switch (this.type) {
      case TYPE_HOUSE:
        return new room(this, room.TYPE_HOME, x, y, side);
      case TYPE_HOUSE_WITH_SHOP: 
        return new room(this, (BUILDING_TYPE1)[rand(0, BUILDING_TYPE1.length-1)], x, y, side);
      case TYPE_SHOP: 
        return new room(this, room.TYPE_SHOP, x, y, side);
      case TYPE_HOSPITAL: 
        return new room(this, room.TYPE_HOSPITAL, x, y, side);
    }
    // 3
    return new room(this, room.TYPE_OFFICE, x, y, side);
  }
  
  void addRoom(room r) {
    this.rooms = (room[])append(this.rooms, r);
  }
  
  void registerRooms() {
    for (room r: this.rooms) {
      this.simulation.addRoom(r);
    }
  }
  
  int getAdjacency() {
    return int(getSize() * BUILDING_ADJACENCY);
  }
  
  void setPos(int x, int y) {
    this.x = x;
    this.y = y;
    int adj = getAdjacency();
    this.zone = new zone(this.x - adj,  this.y - adj, this.w + adj, this.h + adj);
  }
  
  int getTerrainSize() {
    return 2 + int(sqrt(getSize() * BUILDING_ADJACENCY) / 2);
  }
  
  void drawTerrain(PGraphics pg) {
    pg.noStroke();
    pg.fill(160, 185, 160);
    
    //pg.rect(this.x - getTerrainSize(), this.y - getTerrainSize(), this.w + BUILDING_WALL_SIZE * 2 + getTerrainSize() * 2, this.h + BUILDING_WALL_SIZE * 2 + getTerrainSize() * 2);
    for (int i = 0; i < this.rows + 1; i++) {
      //pg.rect(this.x - getTerrainSize(), this.y + i * BUILDING_ROOM_SIZE - (BUILDING_ROOM_SIZE - 2) / 2, this.w + BUILDING_WALL_SIZE + getTerrainSize() * 2, BUILDING_ROOM_SIZE - 1 + (i == this.rows ? BUILDING_WALL_SIZE : 0));
      pg.rect(this.x - getTerrainSize(), this.y + i * BUILDING_ROOM_SIZE + round((BUILDING_ROOM_SIZE - 1) / 2) - (BUILDING_ROOM_SIZE - 3), this.w + BUILDING_WALL_SIZE + getTerrainSize() * 2, BUILDING_ROOM_SIZE - 3 + (i == this.rows ? BUILDING_WALL_SIZE : 0));
    }
  }
  
  void draw(PGraphics pg) {
    if (pg != null) {
      pg.stroke(0);
      pg.strokeWeight(1);
      pg.strokeCap(SQUARE);
      pg.rect(this.x, this.y, this.w, this.h);
      for (int i = 0; i < rooms.length; i++) {
        rooms[i].draw(pg);
      }
      return;
    }
    stroke(0);
    strokeWeight(1);
    strokeCap(SQUARE);
    rect(this.x, this.y, this.w, this.h);
    for (int i = 0; i < rooms.length; i++) {
      rooms[i].draw(null);
    }
  }
}
