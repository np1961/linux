#!/bin/bash
# Откат всего, что сделали install.sh и keyd-add.sh. Саму CopyQ не удаляет (см. последнюю строку).
cd "$(dirname "$0")"
bash keyd-add.sh remove
copyq exit >/dev/null 2>&1 || true
rm -f ~/.config/autostart/copyq-numpad.desktop ~/.local/bin/cq
rm -rf ~/.local/share/copyq-numpad
echo "Uninstall done. To also remove CopyQ and its history: sudo apt remove copyq && rm -rf ~/.config/copyq ~/.local/share/copyq"
