// Держишь правый + и жмёшь N: keyd уже нажал Ctrl+C — забираем скопированное в слот N,
// убираем эту копию из истории и возвращаем прежний буфер.
var cur = snapClip();
tab("cq-old");
var old = count() > 0 ? itemData(0) : [];
if (!cur.length || same(cur, old)) {
  tip("Слот " + N, NO);                       // ничего не выделено — буфер не поменялся
} else {
  putTab("slot " + N, cur);
  history();
  if (count() > 0 && same(itemData(0), cur)) remove(0);
  disable();
  try { if (old.length) copy.apply(this, old); sleep(150); } finally { enable(); }
  tip("Слот " + N, "сохранено");
}
