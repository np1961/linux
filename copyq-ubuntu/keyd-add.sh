#!/bin/bash
# Дописывает правила CopyQ из keyd-copyq.conf в /etc/keyd/default.conf и перечитывает keyd.
#   bash keyd-add.sh          — добавить (повторный запуск заменяет старое, не дублирует)
#   bash keyd-add.sh remove   — убрать всё, что добавлено
# Наши строки стоят между комментариями «# copyq begin» и «# copyq end» — по ним и убираются.
set -e
cd "$(dirname "$0")"
CONF=/etc/keyd/default.conf
# keyd работает от root — cq запускаем от вас (setpriv без PAM, окружение как у вас при входе)
CQ="setpriv --reuid=$(id -u) --regid=$(id -g) --init-groups --reset-env $HOME/.local/bin/cq"

sudo python3 - "$CONF" keyd-copyq.conf "${1:-add}" "$CQ" <<'EOF'
import sys, os, re
conf, ours, mode, cq = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
BEGIN, END = "# copyq begin", "# copyq end"

text = open(conf).read() if os.path.exists(conf) else "[ids]\n*\n\n[main]\n"
# убрать прошлое добавление (всё между пометками, включая их)
lines, skip = [], False
for l in text.splitlines():
    if l.strip() == BEGIN: skip = True; continue
    if l.strip() == END: skip = False; continue
    if not skip: lines.append(l)

if mode != "remove":
    # разобрать наш файл по разделам
    sections, cur = {}, None
    for l in open(ours).read().splitlines():
        s = l.strip()
        if not s or s.startswith("#"):
            continue
        m = re.match(r"\[(.+)\]$", s)
        if m:
            cur = m.group(1); sections.setdefault(cur, []); continue
        sections[cur].append(s.replace("@CQ@", cq))

    main_at = next((i for i, l in enumerate(lines) if l.strip() == "[main]"), None)
    if main_at is None:
        lines += ["", "[main]"]; main_at = len(lines) - 1
    end = next((i for i in range(main_at + 1, len(lines)) if lines[i].strip().startswith("[")), len(lines))
    # клавиши, уже настроенные пользователем в [main], не перетираем — сообщаем и выходим
    taken = {l.split("=")[0].strip() for l in lines[main_at + 1:end] if "=" in l and not l.strip().startswith("#")}
    clash = [s.split("=")[0].strip() for s in sections["main"] if s.split("=")[0].strip() in taken]
    if clash:
        print("These keys are already mapped in your keyd config, nothing changed:", ", ".join(clash))
        sys.exit(1)

    lines[main_at + 1:main_at + 1] = [BEGIN] + sections["main"] + [END]
    lines += ["", BEGIN]
    for name in ("cq_put", "cq_get"):
        lines += [f"[{name}]"] + sections[name] + [""]
    lines += [END]

open(conf, "w").write("\n".join(lines).rstrip() + "\n")
print(("removed from " if mode == "remove" else "added to ") + conf + "  OK")
EOF

# проверка конфига самим keyd: при ошибке показываем её и не перечитываем
CHECK=$(sudo keyd check "$CONF" 2>&1 || true)
if echo "$CHECK" | grep -q "No errors found"; then echo "keyd config check              OK"
else echo "$CHECK"; echo "keyd config check              FAIL"; exit 1; fi
sudo keyd reload
echo "keyd reloaded                  OK"
