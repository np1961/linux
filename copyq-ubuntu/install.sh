#!/bin/bash
# CopyQ на Ubuntu 24 (Wayland): история на правых цифрах + 9 слотов, как на Mac.
# Запуск из этой папки: bash install.sh, потом bash keyd-add.sh. Откат: bash uninstall.sh
set -e
cd "$(dirname "$0")"

command -v copyq >/dev/null || sudo apt install -y copyq

# 1. CopyQ через XWayland (так она видит буфер на Wayland) + свой автозапуск с этим же
copyq exit >/dev/null 2>&1 || true
sleep 1
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/copyq-numpad.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=CopyQ
Exec=env QT_QPA_PLATFORM=xcb copyq --start-server hide
X-GNOME-Autostart-enabled=true
EOF
echo "autostart (XWayland)            OK"
(QT_QPA_PLATFORM=xcb nohup copyq --start-server hide >/dev/null 2>&1 &)
for i in $(seq 1 20); do copyq eval 1 >/dev/null 2>&1 && break; sleep 0.5; done
copyq eval 1 >/dev/null 2>&1 || { echo "CopyQ did not start            FAIL"; exit 1; }
echo "CopyQ started (XWayland)       OK"

# настройка CopyQ: ставим, читаем обратно, печатаем OK / FAIL
cfg() {
  copyq config "$1" "$2" >/dev/null
  if [ "$(copyq config "$1")" = "$2" ]; then printf "%-30s OK\n" "$1 = $2"
  else printf "%-30s FAIL\n" "$1 = $2"; exit 1; fi
}
cfg autostart false            # свой автозапуск выше, иначе CopyQ пропишет свой без XWayland
cfg maxitems 9
cfg native_notifications false
cfg clipboard_notification_lines 0
cfg item_popup_interval 0
cfg autocompletion false
cfg check_selection false      # выделение мышью в историю не пишем
cfg copy_selection false
cfg disable_tray true          # без значка в верхней панели
cfg hide_main_window true      # без трея «свернуть» не работает — прятать окно совсем

# 2. скрипты действий
mkdir -p ~/.local/share/copyq-numpad ~/.local/bin
cp js/*.js ~/.local/share/copyq-numpad/
cp js/cq ~/.local/bin/cq && chmod +x ~/.local/bin/cq
echo "scripts → ~/.local/share/copyq-numpad, ~/.local/bin/cq  OK"

# cq запускает сам keyd (command в keyd-copyq.conf) — сочетания GNOME не нужны

echo
echo "CopyQ network connections (empty = none):"
ss -tpn 2>/dev/null | grep -i copyq || true
echo
echo "Done. Next: bash keyd-add.sh"
