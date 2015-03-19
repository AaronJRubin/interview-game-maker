import 'dart:html';

Element categories = document.querySelector(".categories");

main() {
  initialize();
  ButtonElement addCategoryButton = document.querySelector(".add-category");
  addCategoryButton.onClick.listen((e) => addCategory());
  ButtonElement resetButton = document.querySelector(".reset");
  resetButton.onClick.listen((e) => initialize());
}

void addCategory() {
   categories.appendHtml('''<li>
      <div class="category">
        <button class="delete-button">削除</button>
        <input type="text" class="fragment">
        <input type="text" class="question">
        <input type="checkbox" class="possessive">
        <ol class="items">
          <li><input type="text" class="item"></li>
          <li><input type="text" class="item"></li>
          <li><input type="text" class="item"></li>
          <li><input type="text" class="item"></li>
        </ol>
      </div>
    </li>''');
}

void initialize() {
  categories.children.clear();
  addCategory();
  addCategory();
  addCategory();
}