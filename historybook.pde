
class HistoryBookEntry {
  String header;
  HashMap<String, String> data;
  
  HistoryBookEntry(String header) {
    this.header = header;
    data = new HashMap<String, String>();
  }
  
  private String getItem(String item) {
    String result = data.get(item);
    if (result == null) {
      result = "";
    }
    return result;
  }
  
  void set(String title, String value) {
    data.put(title, value);
  }
  
  void set(String title, int value) {
    data.put(title, value + "");
  }
  
  String getStr(String title) {
    return getItem(title);
  }
  
  int getNum(String title) {
    String result = getItem(title);
    if (result.equals("")) {
      return 0;
    }
    return int(result);
  }
}

class HistoryBook {
  ArrayList<HistoryBookEntry> log;
  
  HistoryBook() {
    log = new ArrayList<HistoryBookEntry>(); 
  }
  
  HistoryBookEntry entry(String name) {
    HistoryBookEntry e = new HistoryBookEntry(name);
    log.add(e);
    return e;
  }
}
