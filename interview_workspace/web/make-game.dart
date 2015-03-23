import 'dart:html';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:interview_workspace/cryptoutils.dart';

UListElement categories = document.querySelector(".categories");
DivElement downloads = document.querySelector(".downloads");
SpanElement minClass = document.querySelector(".class-size-minimum");
SpanElement maxClass = document.querySelector(".class-size-maximum");
int currentItemCount = 5;
int categoryIDCounter = 0;

main() {
  initialize(fetchCachedCategories());
  updateClassSizeDisplay();
  ButtonElement addCategoryButton = document.querySelector(".add-category");
  addCategoryButton.onClick.listen((e) {
    addCategory();
    updateClassSizeDisplay();
  });
  ButtonElement resetButton = document.querySelector(".reset");
  resetButton.onClick.listen((e) {
    if (window.confirm("本当にリセットしますか？保存されていたのも削除されますよ。")) {
    window.localStorage.remove("categories");
    initialize();
    }
  });
  ButtonElement increaseItemsButton = document.querySelector(".increase-items");
  increaseItemsButton.onClick.listen((e) => increaseItems());
  ButtonElement decreaseItemsButton = document.querySelector(".decrease-items");
  decreaseItemsButton.onClick.listen((e) {
    if (window.confirm("本当に減少しますか？各カテゴリーの一番最後のアイテムが削除されますよ。")) {
    decreaseItems();
    }
  });
  ButtonElement createButton = document.querySelector(".create");
  createButton.onClick.listen((e) {
    List<Map> categories = getCategories();
    if (!validateCategories(categories)) {
       window.alert("空っぽのアイテムがあります。なので、作れません");
       return;
    }
    createButton.disabled = true;
    resetButton.disabled = true;
    createButton.text = "作成中";
    Map params = {"categories" : categories};
    HttpRequest.request("/", method: "post", sendData: JSON.encode(params)).then
    ((HttpRequest resp) {
      createButton.disabled = false;
      resetButton.disabled = false;
      createButton.text = "作成する";
      Map mapResponse = JSON.decode(resp.responseText);
      String descriptions = mapResponse["descriptions"];
      String tasks = mapResponse["tasks"];
      downloads.children.clear();
      downloads.append(pdfDownloadLink("個人情報.pdf", descriptions));
      downloads.append(pdfDownloadLink("目的.pdf", tasks));
    });
  });
  ButtonElement saveButton = document.querySelector(".save");
  saveButton.onClick.listen((e) {
    cacheCategories(getCategories());
    saveButton.disabled = true;
    saveButton.text = "保存しました";
    new Timer(new Duration(seconds: 2), () {
      saveButton.disabled = false;
      saveButton.text = "保存する";
    });
  });
}

AnchorElement pdfDownloadLink(String filename, String base64) {
  AnchorElement res = new AnchorElement();
  List<int> bytes = CryptoUtils.base64StringToBytes(base64);
  res.setAttribute("download", filename);
  res.setAttribute("href", Url.createObjectUrlFromBlob(new Blob([bytes], "application/pdf")));
  res.setInnerHtml(filename + "をダウンロード");
  res.onClick.listen((t) => res.classes.add("clicked"));
  return res;
}

Element childWithClass(Element element, String targetClass) {
  return element.children.where
        ((element) => element.classes.contains(targetClass)).first;
}

Map readCategory(DivElement categoryElement) {
  DivElement categoryDescription = categoryElement.children.first;
  TextInputElement fragmentElement = childWithClass(categoryDescription, "fragment").children.first;
  String fragment = fragmentElement.value;
  bool possessive = fragment.startsWith("Your");
  if (possessive) {
    fragment = fragment.replaceFirst("Your ", "");
  } else {
    fragment = fragment.replaceFirst("You ", "");
  }
  TextInputElement questionElement = childWithClass(categoryDescription, "question").children.first;
  String question = questionElement.value;
  UListElement itemsElement = childWithClass(categoryElement, "items");
  List<String> items = itemsElement.children.map((listItem) => listItem.children.first.value.trim()).
      where((string) => string.length > 0).toList(growable: false);
  return {"fragment": fragment, "question": question, "possessive": possessive, "items": items};
}

List<Map> getCategories() {
  return categories.children.map((listItem) => readCategory(listItem.children.first)).toList(growable: false);
}

bool validateCategories(List<Map> categoryMaps) {
  return categoryMaps.every((categoryMap) => categoryMap["items"].length == currentItemCount);
}

void cacheCategories(List<Map> categoryMaps) {
  window.localStorage["categories"] = JSON.encode(categoryMaps);
}

List<Map> fetchCachedCategories() {
   String cachedCategories = window.localStorage["categories"];
   if (cachedCategories == null) {
    return null;
   }
   return JSON.decode(cachedCategories);
}

const Map theEmptyCategory = const {"items" : const [], "fragment" : "", "question" : "", "possessive" : false };

void addCategory([Map categoryMap = theEmptyCategory]) {
   List<String> items = categoryMap["items"];
   String pronoun = categoryMap["possessive"] ? "Your " : "You ";
   String fragment;
   if (categoryMap["fragment"].length > 0) {
    fragment =  pronoun + categoryMap["fragment"];
   } else {
     fragment = "";
   }
   StringBuffer html = new StringBuffer('''<li id="category-$categoryIDCounter">
      <div class="category" >
      <div class="category-description">
        <label class="fragment">You/Yourで始まる文型（アイテムは{}に入る）
        <input type="text" value="$fragment"></label>
        <label class="question">質問の仕方
        <input type="text" value="${categoryMap["question"]}"></label>
      </div>
        <div>アイテム（{}に入る英語）</div>
        <ul class="items">''');
  for (int i = 0; i < currentItemCount; i++) {
    String initialValue = i < items.length ? items[i] : "";
    html.write('<li><input type="text" class="item" value="$initialValue"></li>');
   }
  html.write('''</ul>
       <button class="delete-button" id="delete-$categoryIDCounter">削除</button>
      </div>
    </li>''');
  categories.appendHtml(html.toString());
  createDeleteAction(categoryIDCounter);
  categoryIDCounter++;
}


void createDeleteAction(int categoryID) {
  ButtonElement deleteButton = document.querySelector("#delete-$categoryID");
  deleteButton.onClick.listen((e) {
    if (window.confirm("本当にこのカテゴリーを削除しますか？")) {
    categories.children.removeWhere((element) {
      String toDelete = deleteButton.id.split("-")[1];
      return element.id == "category-$toDelete";
    });
    updateClassSizeDisplay();
    };
  });
}

Element itemInput() {
  return new Element.li()..
      append(new InputElement(type: "text")..classes.add("item"));
}

List<UListElement> itemLists() => document.querySelectorAll(".items");

void increaseItems() {
  currentItemCount++;
  itemLists().forEach((list) => list.append(itemInput()));
  updateClassSizeDisplay();
}

void decreaseItems() {
  if (currentItemCount > 0) {
  currentItemCount--;
  itemLists().forEach((list) => list.children.removeLast());
  }
  updateClassSizeDisplay();
}

String makeFullWidth(String numberString) {
  return new String.fromCharCodes(numberString.codeUnits.map((codeUnit) => codeUnit + 65248));
}

void updateClassSizeDisplay() {
  int minimum = currentItemCount * categories.children.length;
  int maximum = minimum + 5;
  minClass.innerHtml = makeFullWidth(minimum.toString());
  maxClass.innerHtml = makeFullWidth(maximum.toString());
}


void initialize([List<Map> cachedCategories]) {
  categories.children.clear();
  if (cachedCategories != null) {
    currentItemCount = cachedCategories.map((category) => category["items"].length).reduce(max);
    if (currentItemCount == 0) {
      currentItemCount = 5;
    }
    cachedCategories.forEach((cachedCategory) => addCategory(cachedCategory));
  } else {
    currentItemCount = 5;
    addCategory();
    addCategory();
    addCategory();
    addCategory();
    addCategory();
  }
  updateClassSizeDisplay();
}
