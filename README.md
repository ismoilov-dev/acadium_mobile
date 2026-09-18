# Acadium — Student ilovasi (Flutter)

O'quvchilar uchun mobil ilova. Hozircha **barcha ma'lumotlar fake (mock)**,
lekin arxitektura shunday qurilganki, real backend tayyor bo'lganda
**faqat bitta fayl** o'zgartiriladi.

---

## 1. Ishga tushirish

Loyiha **tayyor holatda**: `android/`, `ios/`, `web/` papkalari generatsiya
qilingan, `flutter pub get` bajarilgan.

Flutter SDK shu kompyuterga `~/development/flutter` ga o'rnatilgan
(3.47.4 stable). PATH'ga doimiy qo'shish uchun:

```bash
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

So'ng:

```bash
cd ~/Desktop/acadium
flutter run                 # ulangan qurilma / emulyatorda
flutter run -d chrome       # tez ko'rish uchun brauzerda
```

**Android Studio'da:** `File → Open → acadium`. Android emulyatorda ishlashi
uchun Android SDK kerak (`flutter doctor` hozir uni topmayapti — Android
Studio o'rnatilganda avtomatik keladi). iOS uchun Xcode + CocoaPods kerak.

Minimal talab: **Flutter 3.27+** (`Color.withValues` ishlatilgan).

### Tekshirilgan holat

```
flutter analyze   → No issues found!
flutter test      → 13/13 test passed
flutter build web → ✓ Built build/web
```

Testlar: `test/mock_data_test.dart` (mock JSON → model, fake datasource,
repository progress) va `test/app_smoke_test.dart` (splash → telefon →
noto'g'ri PIN → 1234 → Home → Arena → Profil oqimi to'liq).

> Agar loyihani boshqa kompyuterga ko'chirsangiz va native papkalar yo'q bo'lsa,
> `./setup.sh` ularni qayta yaratadi (lib/ va pubspec.yaml ga tegmaydi).

### Demo (fake) rejim qoidalari

| Qadam | Qoida |
|---|---|
| Telefon | `+998` + 9 ta raqam (istalgan raqam qabul qilinadi) |
| Raqam **juft** bilan tugasa | Birinchi marta kirish → PIN o'rnatish ekrani |
| Raqam **toq** bilan tugasa | Mavjud foydalanuvchi → PIN kiritish ekrani |
| To'g'ri PIN | `1234` |

Masalan: `+998 90 123 45 67` → toq (7) → PIN kiritish → `1234`.
`+998 90 123 45 68` → juft (8) → PIN o'rnatish (istalgan 4 raqam).

---

## 2. Arxitektura

```
lib/
├── core/
│   ├── constants/app_constants.dart      # konstantalar, route nomlari
│   ├── error/app_exception.dart          # AppException va turlari
│   ├── network/api_client.dart           # ApiClient interfeysi + FakeApiClient
│   ├── storage/secure_storage_service.dart
│   ├── theme/app_theme.dart              # BARCHA ranglar/shriftlar shu yerda
│   ├── utils/                            # formatters, phone mask
│   └── service_locator.dart              # <<< YAGONA ALMASHTIRISH NUQTASI
│
├── data/
│   ├── models/                           # JSON ⇄ model (UUID, ISO 8601)
│   ├── datasources/
│   │   ├── auth_datasource.dart          # ABSTRACT
│   │   ├── student_datasource.dart       # ABSTRACT
│   │   ├── fake_auth_datasource.dart     # hozirgi implementatsiya
│   │   ├── fake_student_datasource.dart  # hozirgi implementatsiya
│   │   └── mock/mock_data.dart           # backend formatidagi mock JSON
│   └── repositories/                     # UI ↔ datasource orasidagi qatlam
│
└── presentation/
    ├── providers/                        # Riverpod (state management)
    ├── screens/                          # ekranlar
    └── widgets/                          # qayta ishlatiladigan komponentlar
```

**Qatlamlar qoidasi:** ekran → provider → repository → datasource → API.
Ekranlar datasource'ni umuman ko'rmaydi.

---

## 3. Real API'ga o'tish (faqat shu qadamlar)

1. `core/network/real_api_client.dart` — `ApiClient` interfeysini `http`/`dio`
   bilan implement qiling (`buildHeaders()` allaqachon token va `X-Device-Id`
   header'larini to'g'ri yig'adi).
2. `data/datasources/real_auth_datasource.dart` va
   `real_student_datasource.dart` — mavjud abstract interfeyslarni implement
   qiling. Model'lar `fromJson` bilan tayyor, mock JSON allaqachon backend
   formatida.
3. `core/service_locator.dart` ichida `kUseFakeData` ni `false` qiling va
   izohlangan qatorlarni oching:

```dart
// return FakeStudentDatasource(api);
return RealStudentDatasource(api);
```

Yoki umuman kodga tegmasdan:

```bash
flutter run --dart-define=USE_FAKE=false
```

**Boshqa hech qanday fayl o'zgarmaydi** — model, repository, provider va
ekranlar o'z holida qoladi.

---

## 4. Auth oqimi

```
Splash  → secure_storage'da token bormi?
   ├── ha  → Home (MainShell)
   └── yo'q → Phone Login
                 ├── yangi user → PIN Setup (kiritish + tasdiqlash)
                 └── mavjud user → PIN Login
                             ↓
                    device_id (UUID, ilova ichida generatsiya, qurilma ID'siga
                    bog'liq emas) + token → secure_storage → Home
```

Har bir so'rovda (fake rejimda ham) header'lar yig'iladi va log qilinadi:

```
[FAKE API] GET https://api.acadium.uz/api/v1/students/<id>/homeworks/
headers={Content-Type: application/json, X-Device-Id: <uuid>,
         Authorization: Bearer fake.xxx.yyy}
```

---

## 5. Ekranlar

| Ekran | Nima bor |
|---|---|
| **Home** | Salomlashish, XP kartasi, keyingi dars (jonli countdown), kutilayotgan vazifalar soni, davomat %, oxirgi 3 baho |
| **Schedule** | Haftalik jadval, kunlar bo'yicha gorizontal tanlash, dars kartalari |
| **Homework** | Status filtrlari (Berilgan/Topshirilgan/Kechikkan/Tekshirilgan) + sonlari, detal sahifa, topshirish oynasi (matn + fayl tanlash simulyatsiyasi) |
| **Grades** | Umumiy progress (davomat %, uy vazifasi %, testlar %), fanlar bo'yicha o'rtacha, barcha baholar |
| **Arena** | XP, reyting jadvali (o'z qatori gradient bilan ajratilgan), topshiriqlar, XP tarixi |
| **Notifications** | Turlari bo'yicha ikonka/rang, o'qilgan/o'qilmagan, "hammasini o'qildi" |
| **Profile** | Ism, telefon, guruh, filial, device_id, chiqish (token tozalanadi) |

Har bir ekranda **loading (shimmer)**, **error (qayta urinish tugmasi bilan)**
va **empty state** bor. Ro'yxatlarda pull-to-refresh ishlaydi.

---

## 6. Dizayn tizimi

Barcha ranglar, shriftlar, radius, soya va matn stillari faqat
`core/theme/app_theme.dart` ichida: `AppColors`, `AppSpacing`, `AppRadius`,
`AppShadows`, `AppTextStyles`, `AppTheme`. Ekranlarda hardcoded hex rang yo'q.

- Asosiy gradient: `#4F6CF7 → #9061F9` (ko'k → binafsha)
- Shrift: Poppins (google_fonts)
- Karta: 20px radius + yumshoq soya, tugmalar gradient fon bilan

---

## 7. Paketlar

`flutter_riverpod`, `flutter_secure_storage`, `google_fonts`, `uuid`, `intl`,
`shimmer`.

---

## 8. Eslatmalar

- `google_fonts` shriftni birinchi ishga tushishda internetdan yuklaydi.
  Release build uchun `android/app/src/main/AndroidManifest.xml` ichiga
  `<uses-permission android:name="android.permission.INTERNET"/>` qatorini
  qo'shing (debug rejimda bu avtomatik qo'shilgan). Internet bo'lmasa ilova
  tizim shriftiga qaytadi — xato bermaydi.
- Fake datasource o'zgarishlarni faqat **xotirada** saqlaydi: uy vazifasini
  topshirsangiz status yangilanadi, lekin ilova qayta ishga tushganda mock
  ma'lumot boshlang'ich holatga qaytadi.
- `device_id` faqat `logout` emas, `SecureStorageService.wipe()` chaqirilganda
  o'chadi — chiqishda u ataylab saqlanadi.
# acadium_mobile
