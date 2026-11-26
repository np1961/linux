// Общее для всех действий. Запускается через ~/.local/bin/cq: copyq eval "var N = …; common.js + действие.js".
// Важно: copyq eval раскрывает обратные слэши — в этих файлах их нет, перевод строки = String.fromCharCode(10).
var NL = String.fromCharCode(10);
var PAD = new Array(120).join(String.fromCharCode(0xA0));   // хвост пробелов: подсказка всегда одной ширины
var NO = '<span style="color:#e53935; font-weight:bold">X</span>';   // красный X: пусто / ничего не выделено

// только нужные форматы: текст, HTML, RTF, ссылки на файлы, служебное VS Code и одна картинка в родном формате.
// Все форматы картинки подряд читаются секундами — система пересчитывает каждый.
function want(fs) {
  var k = fs.filter(function(m){ return ["text/plain", "text/html", "text/uri-list"].indexOf(m) >= 0 || m.indexOf("rtf") >= 0 || m.indexOf("vscode") >= 0 || m.indexOf("gnome-copied-files") >= 0; });
  var img = fs.filter(function(m){ return m.indexOf("image/") == 0; })[0];
  if (img) k.push(img);
  return k;
}
function snapClip() { var d = []; want(str(read("?")).split(NL)).forEach(function(m){ d.push(m); d.push(read(m)); }); return d; }
function itemData(row) { var d = []; want(str(read("?", row)).split(NL)).forEach(function(m){ d.push(m); d.push(read(m, row)); }); return d; }
function same(a, b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i += 2)
    if (a[i] != b[i] || a[i + 1].length != b[i + 1].length || (a[i].indexOf("text/") == 0 && str(a[i + 1]) != str(b[i + 1]))) return false;
  return true;
}
function tip(title, s, ms) { notification(".id", "cq", ".title", title, ".time", ms || 1500, ".message", s + PAD); }
function history() { tab(config("clipboard_tab")); }
function putTab(name, data) { tab(name); while (count() > 0) remove(0); if (data.length) write.apply(this, [0].concat(data)); }
