// Держишь правый − и жмёшь N: кладём слот N в буфер, Ctrl+V через 0,4 с нажмёт keyd,
// потом возвращаем прежний буфер. Пустой слот — на время вставки кладём пустоту.
tab("slot " + N);
var data = count() > 0 ? itemData(0) : [];
var old = snapClip();
disable();
try {
  if (data.length) copy.apply(this, data); else copy("");
  tip("Слот " + N, data.length ? "вставлено" : NO);
  sleep(900);
} finally {
  if (old.length) copy.apply(this, old);
  sleep(150);
  enable();
}
