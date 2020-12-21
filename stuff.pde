float rand(float min, float max) {
  return int(random(min, max + .1));
}

int rand(int min, int max) {
  return int(rand((float)min, (float)max));
}


boolean checkSuccess(float probability, float penalty) {
  return rand(0.0, 100.0) < (probability + penalty);
}

boolean checkSuccess(float probability) {
  return checkSuccess(probability, 0.0);
}

int hoursToTicks(float hours) {
  return int(TICKS_PER_HOUR * hours);
}

int daysToTicks(float days) {
  return HOURS_PER_DAY * hoursToTicks(days);
}

class rooms {
  room[] items;
  
  rooms(ArrayList<room> items) {
    this.items = new room[items.size()];
    this.items = (room[])items.toArray(this.items);
  }
}

class IndexToObjects<T> {
  Object map[][];
  
  IndexToObjects(int w, int h) {
    map = new Object[w][h];
  }
  
  void init(int x, int y) {
    if (map[x][y] == null) {
      map[x][y] = new ArrayList<T>();
    }
  }
  
  void add(int x, int y, T item) {
    init(x, y);
    ((ArrayList<T>)map[x][y]).add(item);
  }
  
  ArrayList<T> get(int x, int y) {
    init(x, y);
    return (ArrayList<T>)map[x][y];
  }
  
  void remove(int x, int y, T item) {
    init(x, y);
    ArrayList<T> list = get(x, y);
    for (int i = list.size() - 1; i >= 0; i--) {
      if (list.get(i) == item) {
        list.remove(i);
        return;
      }
    }
  }
}

class zone {
  int x;
  int y;
  int w;
  int h;
  
  zone(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  zone getIntersect(zone z) {
    int xL = Math.max(this.x, z.x);
    int xR = Math.min(this.x + this.w, z.x + z.w);
    if (xR <= xL) {
        return null;
    }
    int yT = Math.max(this.y, z.y);
    int yB = Math.min(this.y + this.h, z.y + z.h);
    if (yB <= yT) {
        return null;
    }
    return new zone(xL, yB, xR-xL, yB-yT);
  }
  
  boolean isIn(int x, int y) {
    return (x >= this.x && x <= this.x + this.w) && (y >= this.y && y <= this.y + this.h);
  }
  
  String getString() {
    return (String)(x + "/" + y + "/" + (x + w) + "/" + (y + h));
  }
  
  void setPost(int x, int y) {
    this.x = x;
    this.y = y;
  }
}
