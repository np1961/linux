// Правый 0: положить показанную запись в буфер — Ctrl+V через 0,25 с нажмёт keyd.
// Если ничего не показано (или прошло больше 5 с) — на время вставки кладём пустоту, чтобы Ctrl+V ничего не вставил.
history();
var i = settings("preview_row");
var t = settings("preview_time");
if (t && Date.now() - t < 5000 && i < count()) {
  settings("preview_time", 0);
  notification(".id", "cq", ".time", 1, ".message", "");
  select(i);
} else {
  var old = snapClip();
  disable();
  try { copy(""); sleep(700); } finally { if (old.length) copy.apply(this, old); sleep(150); enable(); }
}
