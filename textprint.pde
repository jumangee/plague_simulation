
class TextPrint {
  StringList lines = new StringList();
  int size;
  int padding;
  int mode;
  
  TextPrint(int size, int padding) {
    setSize(size);
    setPadding(padding);
  }
  
  void add(String text) {
    lines.append(text);
  }
  
  void clear() {
    lines.clear();
  }
  
  void setSize(int size) {
    this.size = size;
  }
  
  void setPadding(int padding) {
    this.padding = padding;
  }
  
  int getHeight() {
    return lines.size() * size + (lines.size() - 1) * padding;  
  }
  
  private void drawLine(int x, int y, int n) {
    text(lines.get(n), x, y);
  }
  
  void print(int x, int y, int pcolor, int mode) {
    textSize(size);
    fill(pcolor);
    
    int dy = y;
    if (mode / abs(mode) > 0) {
      for (int i = 0 ; i < lines.size(); i++) {
        drawLine(x, dy, i);
        dy += (size + padding);
      }
    } else 
      for (int i = lines.size()-1; i >= 0; i--) {
        drawLine(x, dy, i);
        dy -= (size + padding);
      }
  }
}
