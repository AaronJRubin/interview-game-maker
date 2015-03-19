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
        <label>文型（{}で下線部を指定して）
        <input type="text" class="fragment"></label>
        <label>質問の仕方
        <input type="text" class="question"></label>
        <label>Iの代わりにMyで始まるか
        <input type="checkbox" class="possessive"></label>
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