import 'dart:html';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:cryptoutils/cryptoutils.dart';

UListElement categories = document.querySelector(".categories");
NumberInputElement peopleToFind = document.querySelector(".people-to-find");
DivElement downloads = document.querySelector(".downloads");
int currentItemCount = 5;
int categoryIDCounter = 0;

main() {
  initialize(fetchCachedCategories());
  ButtonElement addCategoryButton = document.querySelector(".add-category");
  addCategoryButton.onClick.listen((e) => addCategory());
  ButtonElement resetButton = document.querySelector(".reset");
  resetButton.onClick.listen((e) {
    if (window.confirm("本当にリセットしますか？保存されていたのも削除されますよ")) {
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
       window.alert("空っぽのアイテムがありますから作れません");
       return;
    }
    createButton.disabled = true;
    createButton.text = "作成中";
    Map params = {"categories" : categories, "people_to_find" : peopleToFind.valueAsNumber};
    HttpRequest.request("/", method: "post", sendData: JSON.encode(params)).then
    ((HttpRequest resp) {
      createButton.disabled = false;
      createButton.text = "作成する";
      Map mapResponse = JSON.decode(resp.responseText);
      String descriptions = mapResponse["descriptions"];
      String tasks = mapResponse["tasks"];
      List<int> descriptionBytes = CryptoUtils.base64StringToBytes(descriptions);
      List<int> tasksBytes = CryptoUtils.base64StringToBytes(tasks);
      downloads.append(pdfDownloadLink("description.pdf", descriptionBytes));
      downloads.append(pdfDownloadLink("tasks.pdf", tasksBytes));
    });
  });
  ButtonElement saveButton = document.querySelector(".save");
  saveButton.onClick.listen((e) {
    cacheCategories(getCategories());
    saveButton.disabled = true;
    saveButton.text = "保存しました";
    new Timer(new Duration(seconds: 5), () {
      saveButton.disabled = false;
      saveButton.text = "保存する";
    });
  });
}

AnchorElement pdfDownloadLink(String filename, List<int> bytes) {
  AnchorElement res = new AnchorElement();
  res.setAttribute("download", filename);
  res.setAttribute("href", Url.createObjectUrlFromBlob(new Blob([bytes], "application/pdf")));
  res.setInnerHtml(filename);
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
  TextInputElement questionElement = childWithClass(categoryDescription, "question").children.first;
  String question = questionElement.value;
  CheckboxInputElement possessiveElement = childWithClass(categoryDescription, "possessive").children.first;
  bool possessive = possessiveElement.checked;
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

void create() {
  List<Map> categoryMaps = getCategories();
  if (!validateCategories(categoryMaps)) {
    window.alert("空っぽのアイテムがありますから作れません");
  } else {
    print(categoryMaps.toString());
  }
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

void addCategory() {
  StringBuffer html = new StringBuffer('''<li id="category-$categoryIDCounter">
      <div class="category">
      <div class="category-description">
        <label class="fragment">文型（{アイテムは{}に入る）
        <input type="text"></label>
        <label class="question">質問の仕方
        <input type="text"></label>
        <label class="possessive">Iの代わりにMyで始まるか
        <input type="checkbox"></label>
      </div>
        <div>アイテム（{}に入る英語）</div>
        <ul class="items">''');
  for (int i = 0; i < currentItemCount; i++) {
    html.write('<li><input type="text" class="item"></li>');
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
    categories.children.removeWhere((element) {
      String toDelete = deleteButton.id.split("-")[1];
      return element.id == "category-$toDelete";
    });
  });
}

void addCategoryFromMap(Map categoryMap) {
  List<String> items = categoryMap["items"];
  StringBuffer html = new StringBuffer('''<li id="category-$categoryIDCounter">
      <div class="category" >
      <div class="category-description">
        <label class="fragment">文型（{アイテムは{}に入る）
        <input type="text" value="${categoryMap["fragment"]}"></label>
        <label class="question">質問の仕方
        <input type="text" value="${categoryMap["question"]}"></label>
        <label class="possessive">Iの代わりにMyで始まるか
        <input type="checkbox" checked=${categoryMap["possessive"]}></label>
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

UListElement itemInput() {
  return new UListElement()..
      append(new InputElement(type: "text")..classes.add("item"));
}

List<UListElement> itemLists() => document.querySelectorAll(".items");

void increaseItems() {
  currentItemCount++;
  itemLists().forEach((list) => list.append(itemInput()));
}

void decreaseItems() {
  if (currentItemCount > 0) {
  currentItemCount--;
  itemLists().forEach((list) => list.children.removeLast());
  }
}

void initialize([List<Map> cachedCategories]) {
  categories.children.clear();
  if (cachedCategories != null) {
    print("Cached categories were found!");
    print(cachedCategories.toString());
    int currentItemCount = cachedCategories.map((category) => category["items"].length).reduce(max);
    cachedCategories.forEach((cachedCategory) => addCategoryFromMap(cachedCategory));
  } else {
    currentItemCount = 5;
    addCategory();
    addCategory();
    addCategory();
    addCategory();
    addCategory();
  }
}
