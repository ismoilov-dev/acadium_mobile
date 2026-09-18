#!/usr/bin/env bash
# Acadium Student — platforma papkalarini (android/ios) generatsiya qilish skripti.
# lib/ va pubspec.yaml fayllariga TEGMAYDI — faqat yetishmayotgan native qismlarni qo'shadi.
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP_DIR="$(mktemp -d)"

echo "==> Vaqtinchalik skeleton yaratilmoqda: $TMP_DIR"
flutter create --org com.acadium --project-name acadium_student \
  --platforms=android,ios,web "$TMP_DIR/acadium_student"

echo "==> Native papkalar ko'chirilmoqda"
for item in android ios web .metadata; do
  if [ ! -e "$PROJECT_DIR/$item" ]; then
    cp -R "$TMP_DIR/acadium_student/$item" "$PROJECT_DIR/$item"
    echo "    + $item"
  else
    echo "    = $item (mavjud, o'tkazib yuborildi)"
  fi
done

rm -rf "$TMP_DIR"

echo "==> flutter pub get"
cd "$PROJECT_DIR" && flutter pub get

echo "==> Tayyor. Ishga tushirish: flutter run"
