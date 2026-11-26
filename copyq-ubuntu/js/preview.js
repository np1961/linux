// Правая N: показать запись N из истории 5 с, ничего не вставляя.
history();
var i = N - 1;
if (i < count()) {
  settings("preview_row", i);
  settings("preview_time", Date.now());
  var text = str(read("text/plain", i));
  if (text.length > 300) text = text.substr(0, 300) + "…";
  var isImage = str(read("?", i)).indexOf("image/") >= 0;
  tip("" + N, (text || (isImage ? "(картинка)" : "(пусто)")).split(NL).join(" "), 5000);
} else {
  tip("" + N, NO, 1500);
}
