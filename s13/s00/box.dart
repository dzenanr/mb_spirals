part of mb;

class Box {

  static const int DEFAULT_WIDTH = 120;
  static const int DEFAULT_HEIGHT = 120;
  static const int DEFAULT_INCREMENT = 20;

  static const int SSS = 6; // selection square size
  static const int TBH = 20; // title box height
  static const int TOS = 4; // text offset size
  static const int IOS = TBH - TOS; // item offset size

  final Board board;

  String _name = '';
  bool entry = false;
  num x;
  num y;
  num width;
  num height;

  List<Item> items;

  bool _selected = false;
  bool _hidden = false;
  bool _mouseDown = false;

  Box(this.board, this.x, this.y, this.width, this.height) {
    items = new List<Item>();

    draw();
    // Box events (actually, canvas events).
    document.querySelector('#canvas').onMouseDown.listen(onMouseDown);
    document.querySelector('#canvas').onMouseUp.listen(onMouseUp);
    document.querySelector('#canvas').onMouseMove.listen(onMouseMove);
  }

  void draw() {
    if (!isHidden()) {
      board.context.beginPath();
      board.context.clearRect(x, y, width, height);
      board.context.rect(x, y, width, height);
      board.context.moveTo(x, y + TBH);
      board.context.lineTo(x + width, y + TBH);
      board.context.font = 'bold ${Board.DEFAULT_FONT_SIZE}px sans-serif';
      board.context.textAlign = 'start';
      board.context.textBaseline = 'top';
      if (entry) {
        board.context.fillText('|| ${title}', x + TOS, y + TOS, width - TOS);
      } else {
        board.context.fillText(title, x + TOS, y + TOS, width - TOS);
      }
      sortItemsBySequence();
      num i = 0;
      for (Item item in items) {
        if (item.category == 'attribute') {
          board.context.font = '${Board.DEFAULT_FONT_SIZE}px sans-serif';
          board.context.fillText(item.name, x + TOS, y + TOS + TBH + i * IOS,
            width - TOS);
        } else if (item.category == 'guid') {
          board.context.font = 'italic ${Board.DEFAULT_FONT_SIZE}px sans-serif';
          board.context.fillText(item.name, x + TOS, y + TOS + TBH + i * IOS,
            width - TOS);
        } else if (item.category == 'identifier') {
          board.context.font = 'bold italic ${Board.DEFAULT_FONT_SIZE}px sans-serif';
          board.context.fillText(item.name, x + TOS, y + TOS + TBH + i * IOS,
            width - TOS);
        } else if (item.category == 'required') {
          board.context.font = 'bold ${Board.DEFAULT_FONT_SIZE}px sans-serif';
          board.context.fillText(item.name, x + TOS, y + TOS + TBH + i * IOS,
            width - TOS);
        }
        i++;
      }
      if (isSelected()) {
        board.context.rect(x, y, SSS, SSS);
        board.context.rect(x + width - SSS, y, SSS, SSS);
        board.context.rect(x + width - SSS, y + height - SSS, SSS, SSS);
        board.context.rect(x, y + height - SSS, SSS, SSS);
      }
      board.context.lineWidth = Board.DEFAULT_LINE_WIDTH;
      board.context.strokeStyle = Board.DEFAULT_LINE_COLOR;

      board.context.stroke();
      board.context.closePath();
    }
  }

  void select() {
    _selected = true;
    board.lastBoxSelected = this;
    board.toolBar.bringSelectedBox();
  }

  void deselect() {
    _selected = false;
    board.lastBoxSelected = null;
  }

  void toggleSelection() {
    if (isSelected()) {
      deselect();
    } else {
      select();
    }
  }

  bool isSelected() => _selected;

  hide() => _hidden = true;
  show() => _hidden = false;
  bool isHidden() => _hidden;

  void set title(String name) {
    _name = name;
  }

  String get title {
    return _name;
  }

  Map<String, Object> toJson() {
    Map<String, Object> boxMap = new Map<String, Object>();
    boxMap["name"] = title;
    boxMap["entry"] = entry;
    boxMap["x"] = x;
    boxMap["y"] = y;
    boxMap["width"] = width;
    boxMap["height"] = height;
    boxMap["items"] = itemsToJson();
    return boxMap;
  }

  List<Map<String, Object>> itemsToJson() {
    List<Map<String, Object>> itemsList = new List<Map<String, Object>>();
    for (Item item in items) {
      itemsList.add(item.toJson());
    }
    return itemsList;
  }

  num findLastItemSequence() {
    if (items.isEmpty) {
      return 0;
    } else {
      Item item = items.last;
      return item.sequence;
    }
  }

  Item findItem(String name) {
    for (Item item in items) {
      if (item.name == name) {
        return item;
      }
    }
    return null;
  }

  Item findFirstItem() {
    if (items.isEmpty) {
      return null;
    } else {
      return items[0];
    }
  }

  Item findLastItem() {
    if (items.isEmpty) {
      return null;
    } else {
      return items.last;
    }
  }

  Item findPreviousItem(Item currentItem) {
    sortItemsBySequence();
    for (Item item in items) {
      if (item == currentItem) {
        num ix = items.indexOf(item, 0);
        if (ix > 0) {
          return items[ix - 1];
        }
      }
    }
    return null;
  }

  Item findNextItem(Item currentItem) {
    sortItemsBySequence();
    for (Item item in items) {
      if (item == currentItem) {
        num ix = items.indexOf(item, 0);
        if (ix < items.length - 1) {
          return items[ix + 1];
        }
      }
    }
    return null;
  }

  bool removeItem(Item item) {
    if (item != null) {
      num index = items.indexOf(item, 0);
      if (index >= 0) {
        items.removeRange(index, index + 1);
        return true;
      }
    }
    return false;
  }

  void sortItemsBySequence() {
    items.sort((Item i1, Item i2) {
      if (i1.sequence == i2.sequence) {
        return 0;
      } else if (i1.sequence > i2.sequence) {
        return 1;
      } else {
        return -1;
      }
    });
  }

  String toString() => '$title ($x, $y)';

  Point center() {
    num centerX = x + width / 2;
    num centerY = y + height / 2;
    return new Point(centerX, centerY);
  }

  Point twin1() {
    num twinX = x + width / 4;
    num twinY = y + height / 4;
    return new Point(twinX, twinY);
  }

  Point twin2() {
    num twinX = x + (width / 4) * 3;
    num twinY = y + (height / 4) * 3;
    return new Point(twinX, twinY);
  }

  Point reflexive1() {
    num reflexiveX = x;
    num reflexiveY = y - height / 2;
    return new Point(reflexiveX, reflexiveY);
  }

  Point reflexive2() {
    num reflexiveX = x + width;
    num reflexiveY = y - height / 2;
    return new Point(reflexiveX, reflexiveY);
  }

  bool contains(num pointX, num pointY) {
    if ((pointX > x && pointX < x + width)
        && (pointY > y && pointY < y + height)) {
      return true;
    }
    else {
      return false;
    }
  }

  /**
   * Return the intersection point of the line between the begin <x1,y1>
   * and end <x2,y2> points with this box;
   * <x1,y1> is inside the box, <x2,y2> may be inside or outside.
   * Fast algorithm.
   */

  /**
  Point getIntersectionPoint(Point lineBeginPoint, Point lineEndPoint) {
    num x1 = lineBeginPoint.x;
    num y1 = lineBeginPoint.y;
    num x2 = lineEndPoint.x;
    num y2 = lineEndPoint.y;
    if (x2 == x1) {
      /* vertical line */
      return new Point(x2, (y2 < y1 ? y : y + height));
    }
    if (y2 == y1) {
      /* horizontal line */
      return new Point((x2 < x1 ? x : x + width), y2);
    }

    double m = (y2 - y1) / (x2 - x1);
    num intersectionX = (x2 < x1 ? x : x + width);
    double fy = m * (intersectionX - x2) + y2;
    num intersectionY;
    /* float comparison, because fy may be bigger than the biggest integer */
    if (fy >= y && fy <= y + height) {
      intersectionY = fy.toInt();
    } else {
      y = (y2 < y1 ? y : y + height);
      x = ((fy - y2) / m).toInt() + x2;
    }
    return new Point(intersectionX, intersectionY);
  }
  */

  Point getIntersectionPoint(Point lineBeginPoint, Point lineEndPoint) {
    num x1 = lineBeginPoint.x;
    num y1 = lineBeginPoint.y;
    num x2 = lineEndPoint.x;
    num y2 = lineEndPoint.y;
    if (x2 == x1) { /* vertical line */
      return new Point(x2, (y2 < y1 ? this.y : this.y + this.height));
    }
    if (y2 == y1) { /* horizontal line */
      return new Point((x2 < x1 ? this.x : this.x + this.width), y2);
    }

    double m = (y2 - y1) / (x2 - x1);
    num x = (x2 < x1 ? this.x : this.x + this.width);
    double fy = m * (x - x2) + y2;
    num y;
    /* float comparison, because fy may be bigger than the biggest integer */
    if (fy >= this.y && fy <= this.y + this.height) {
      y = fy.toInt();
    } else {
      y = (y2 < y1 ? this.y : this.y + this.height);
      x = ((fy - y2) ~/ m) + x2;
    }
    return new Point(x, y);
  }

  void onMouseDown(MouseEvent e) {
    _mouseDown = true;
    if (board.toolBar.isSelectToolOn() && contains(e.offset.x, e.offset.y)) {
      toggleSelection();
    }
    if (contains(e.offset.x, e.offset.y)) {
      if (board.lastBoxClicked != null && board.lastBoxClicked != this) {
        board.beforeLastBoxClicked = board.lastBoxClicked;
      }
      board.lastBoxClicked = this;
    }
  }

  void onMouseUp(MouseEvent e) {
    _mouseDown = false;
  }

  /** Change a position of the box with mouse mouvements. */
  void onMouseMove(MouseEvent e) {
    if (contains(e.offset.x, e.offset.y) && _mouseDown &&
        board.countBoxesContain(e.offset.x, e.offset.y) < 2) {
      x =  e.offset.x - width / 2;
      if (x < 0) {
        x = 1;
      }
      if (x > board.width - width) {
        x = board.width - width - 1;
      }
      y = e.offset.y - height / 2;
      if (y < 0) {
        y = 1;
      }
      if (y > board.height - height) {
        y = board.height - height - 1;
      }
    }
  }

}
