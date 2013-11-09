part of mb;

class ToolBar {

  static final int SELECT = 1;
  static final int BOX = 2;
  static final int LINE = 3;

  final Board board;

  int _onTool;
  int _fixedTool;

  ButtonElement selectButton;
  ButtonElement boxButton;
  ButtonElement lineButton;

  InputElement boxNameInput;
  InputElement itemNameInput;
  SelectElement itemOption;
  ButtonElement addItemButton;
  ButtonElement getItemButton;
  ButtonElement setItemButton;
  ButtonElement removeItemButton;

  Item currentItem;

  ToolBar(this.board) {
    selectButton = document.querySelector('#select');
    boxButton = document.querySelector('#box');
    lineButton = document.querySelector('#line');

    // Tool bar events.
    selectButton.onClick.listen((MouseEvent e) {
      onTool(SELECT);
    });
    selectButton.onDoubleClick.listen((MouseEvent e) {
      onTool(SELECT);
      _fixedTool = SELECT;
    });

    boxButton.onClick.listen((MouseEvent e) {
      onTool(BOX);
    });
    boxButton.onDoubleClick.listen((MouseEvent e) {
      onTool(BOX);
      _fixedTool = BOX;
    });

    lineButton.onClick.listen((MouseEvent e) {
      onTool(LINE);
    });
    lineButton.onDoubleClick.listen((MouseEvent e) {
      onTool(LINE);
      _fixedTool = LINE;
    });

    onTool(SELECT);
    _fixedTool = SELECT;

    boxNameInput = document.querySelector('#boxName');
    boxNameInput.onFocus.listen((Event e) {
      Box box = board.lastBoxSelected;
      if (box != null) {
        boxNameInput.value = box.title;
      }
    });
    boxNameInput.onInput.listen((Event e) {
      Box box = board.lastBoxSelected;
      if (box != null) {
        box.title = boxNameInput.value;
      }
    });

    itemNameInput = document.querySelector('#itemName');

    itemOption = document.querySelector('#itemCategory');

    addItemButton = document.querySelector('#addItem');
    addItemButton.onClick.listen((MouseEvent e) {
      Box box = board.lastBoxSelected;
      if (box != null) {
        currentItem = new Item(box, itemNameInput.value, itemOption.value);
        itemNameInput.select();
      }
    });

    getItemButton = document.querySelector('#getItem');
    getItemButton.onClick.listen((MouseEvent e) {
      Box box = board.lastBoxSelected;
      if (box != null) {
        Item item = box.findItem(itemNameInput.value);
        if (item != null) {
          currentItem = item;
          itemNameInput.value = item.name;
          itemNameInput.select();
        } else {
          currentItem = null;
        }
      }
    });

    setItemButton = document.querySelector('#setItem');
    setItemButton.onClick.listen((MouseEvent e) {
      Box box = board.lastBoxSelected;
      if (box != null) {
        if (currentItem != null) {
          currentItem.name = itemNameInput.value;
          itemNameInput.select();
        }
      }
    });

    removeItemButton = document.querySelector('#removeItem');
    removeItemButton.onClick.listen((MouseEvent e) {
      Box box = board.lastBoxSelected;
      if (box != null) {
        if (currentItem != null) {
          if (box.removeItem(currentItem)) {
            currentItem = null;
            itemNameInput.value = '';
          }
        }
      }
    });
  }

  onTool(int tool) {
    _onTool = tool;
    if (_onTool == SELECT) {
      selectButton.style.borderColor = "#000000"; // black
      boxButton.style.borderColor = "#808080"; // grey
      lineButton.style.borderColor = "#808080"; // grey
    } else if (_onTool == BOX) {
      selectButton.style.borderColor = "#808080"; // grey
      boxButton.style.borderColor = "#000000"; // black
      lineButton.style.borderColor = "#808080"; // grey
    } else if (_onTool == LINE) {
      selectButton.style.borderColor = "#808080"; // grey
      boxButton.style.borderColor = "#808080"; // grey
      lineButton.style.borderColor = "#000000"; // black
    }
  }

  bool isSelectToolOn() {
    if (_onTool == SELECT) {
      return true;
    }
    return false;
  }

  bool isBoxToolOn() {
    if (_onTool == BOX) {
      return true;
    }
    return false;
  }

  bool isLineToolOn() {
    if (_onTool == LINE) {
      return true;
    }
    return false;
  }

  void backToFixedTool()  {
      onTool(_fixedTool);
  }

  void backToSelectAsFixedTool()  {
    onTool(SELECT);
    _fixedTool = SELECT;
  }

}
