# Acadium — Student va Parent ilovasi (Flutter)

Bitta ilovada **ikkita mustaqil oqim**: o'quvchi (Student) va ota-ona (Parent).
Kirishdagi rol qaysi oqim ochilishini belgilaydi. Hozircha **barcha ma'lumotlar
fake (mock)**, lekin arxitektura shunday qurilganki, real backend tayyor
bo'lganda **faqat `service_locator.dart`** o'zgartiriladi.

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
flutter test      → 32/32 test passed
flutter build web → ✓ Built build/web
```

Testlar:

* `test/mock_data_test.dart` — mock JSON → model, fake datasource'lar,
  arena XP mantiqi, ota-ona ma'lumotlari va to'lovlar;
* `test/app_smoke_test.dart` — Student oqimi (splash → telefon → noto'g'ri PIN
  → 1234 → Home → Arena → Profil) va arena testini yechib +120 XP olish;
* `test/parent_flow_test.dart` — Parent oqimi (telefon `33...` → PIN → Parent
  Home → Farzandlar → farzand tanlash → Child Detail → Baholar tabi →
  To'lovlar).

> Agar loyihani boshqa kompyuterga ko'chirsangiz va native papkalar yo'q bo'lsa,
> `./setup.sh` ularni qayta yaratadi (lib/ va pubspec.yaml ga tegmaydi).

### Demo (fake) rejim qoidalari

| Qadam | Qoida |
|---|---|
| Telefon | `+998` + 9 ta raqam (istalgan raqam qabul qilinadi) |
| Operator kodi **33** | **Ota-ona** oqimi ochiladi |
| Boshqa kodlar (90, 91, 99...) | **O'quvchi** oqimi ochiladi |
| Raqam **juft** bilan tugasa | Birinchi marta kirish → PIN o'rnatish ekrani |
| Raqam **toq** bilan tugasa | Mavjud foydalanuvchi → PIN kiritish ekrani |
| To'g'ri PIN | `1234` |

Masalan:

* `90 123 45 67` → o'quvchi, toq (7) → PIN kiritish → `1234`
* `33 123 45 67` → **ota-ona**, toq (7) → PIN kiritish → `1234`
* `90 123 45 68` → juft (8) → PIN o'rnatish (istalgan 4 raqam)

Rol `AuthSession.role` orqali keladi va `shellRouteFor()` tegishli oqimni
ochadi. Real API'da rol `/auth/login/` javobidan olinadi — fake qoida
(operator kodi) faqat demo uchun, `FakeAuthDatasource._roleOf()` ichida.

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
│   │   ├── parent_datasource.dart        # ABSTRACT
│   │   ├── fake_auth_datasource.dart     # hozirgi implementatsiya
│   │   ├── fake_student_datasource.dart  # hozirgi implementatsiya
│   │   ├── fake_parent_datasource.dart   # hozirgi implementatsiya
│   │   └── mock/mock_data.dart           # backend formatidagi mock JSON
│   └── repositories/                     # UI ↔ datasource orasidagi qatlam
│
└── presentation/
    ├── providers/                        # Riverpod (state management)
    ├── screens/                          # student/ va parent/ ekranlari
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
| **Arena** | XP, reyting jadvali (o'z qatori gradient bilan ajratilgan), o'qituvchi yuklagan topshiriqlarni **bajarish**, XP tarixi |
| **Notifications** | Turlari bo'yicha ikonka/rang, o'qilgan/o'qilmagan, "hammasini o'qildi" |
| **Profile** | Ism, telefon, guruh, filial, device_id, chiqish (token tozalanadi) |

Har bir ekranda **loading (shimmer)**, **error (qayta urinish tugmasi bilan)**
va **empty state** bor. Ro'yxatlarda pull-to-refresh ishlaydi.

---

## 5.1. Arena — topshiriqlarni bajarish

O'qituvchi topshiriq yuklaydi → o'quvchi ro'yxatda ko'radi → bajaradi → **XP
avtomatik yig'iladi**. Uch xil topshiriq turi bor:

| Tur | Qanday bajariladi | XP qanday hisoblanadi |
|---|---|---|
| **Test** (`quiz`) | Savollarga birma-bir javob beriladi (A/B/C/D) | To'g'ri javoblar ulushi × mukofot. Masalan 5 tadan 3 tasi → 120 × 3/5 = 72 XP |
| **Topshiriq** (`submission`) | Matn yoziladi va/yoki fayl biriktiriladi | To'liq mukofot |
| **Chellenj** (`challenge`) | Avtomatik to'planadi (davomat, vazifalar). To'lgach "Mukofotni olish" tugmasi paydo bo'ladi | To'liq mukofot |

**To'g'ri javoblar mijozga yuborilmaydi.** `ArenaQuestion` modelida javob kaliti
yo'q — javoblar `POST /arena-tasks/{id}/submit/` orqali yuboriladi va "server"
tomonida tekshiriladi (fake rejimda `MockData.quizAnswerKey` datasource ichida).
Real API'ga o'tganda bu mantiq o'zgarmaydi.

Topshiriq yakunlangach bir vaqtning o'zida:

1. jami XP oshadi (Home, Profil, Arena — hammasida);
2. XP tarixiga yozuv qo'shiladi;
3. reyting qayta hisoblanadi va o'rin o'zgarsa natija ekranida
   "2-o'rindan 1-o'ringa ko'tarildingiz 🎉" deb ko'rsatiladi;
4. "+XP" bildirishnomasi yaratiladi.

Demo ma'lumotda 420 XP lik topshiriq bor — hammasini bajarsangiz 1240 → 1660 XP
bo'lib, reytingda Madinani (1480) ortda qoldirasiz.

O'zgaruvchan holat `data/datasources/mock/mock_state.dart` ichida — bu "fake
server bazasi". Real API'ga o'tilganda bu fayl kerak bo'lmaydi.

---

## 5.2. Parent (ota-ona) oqimi

Ota-ona raqami bilan kirilganda 4 tabli mustaqil ilova ochiladi:
**Bosh sahifa, Farzandlar, To'lovlar, Profil**.

| Ekran | Nima bor |
|---|---|
| **Bosh sahifa** | Gradient sarlavhada farzand switcher; "bir qarashda" kartalar: bugungi dars holati (rangli: keldi/kechikdi/kelmadi/kutilmoqda), kutilayotgan vazifalar soni, o'rtacha baho, keyingi dars vaqti, to'lov holati. Har bir karta tegishli ekranga olib boradi |
| **Farzandlar** | Bog'langan farzandlar kartalari (XP, daraja, filial). Bosilganda farzand tanlanadi va tafsilotlar ochiladi |
| **Farzand tafsiloti** | Ichki `TabBar`: Davomat, Vazifalar, Baholar, Jadval. Vazifalar faqat ko'rish uchun (`HomeworkTile(readOnly: true)`) — ota-ona topshira olmaydi |
| **To'lovlar** | Umumiy qarzdorlik kartasi + farzandlar bo'yicha guruhlangan to'lovlar: umumiy/to'langan/qolgan summa, progress bar, status badge (yashil/sariq/qizil) |
| **Bildirishnomalar** | Student ekraniga o'xshash, lekin har bir xabarda "qaysi farzand haqida" degan yorliq (bir nechta farzand bo'lsa) |
| **Profil** | Ism, telefon, farzandlar ro'yxati, chiqish (mavjud logout logikasi qayta ishlatiladi) |

### Farzand almashtirish

`widgets/child_switcher.dart` — Home va To'lovlar ekranlarida ko'rinadi.
Bosilganda pastdan ro'yxat ochiladi; tanlov `selectedChildIdProvider` ga
yoziladi va unga bog'liq **barcha** provider'lar (davomat, vazifa, baho,
jadval, summary, to'lov) Riverpod reaktivligi tufayli avtomatik qayta
so'raladi — hech qanday qo'lda "refresh" kerak emas.

### Parent qatlamlari

```
data/models/          parent_model.dart, child_model.dart, payment_model.dart
data/datasources/     parent_datasource.dart (ABSTRACT)
                      fake_parent_datasource.dart
data/repositories/    parent_repository.dart
presentation/providers/
                      parent_provider.dart, children_provider.dart,
                      selected_child_provider.dart, child_attendance_provider.dart,
                      child_homework_provider.dart, child_grades_provider.dart,
                      child_payments_provider.dart, parent_notification_provider.dart
presentation/screens/parent/
                      shell/, home/, children/, payments/, notifications/, profile/
```

### Real API'ga o'tish (Parent uchun)

`core/service_locator.dart` da **ALMASHTIRISH NUQTASI 3** bor:

```dart
final parentDatasourceProvider = Provider<ParentDatasource>((ref) {
  final api = ref.watch(apiClientProvider);
  if (kUseFakeData) return FakeParentDatasource(api);
  // return RealParentDatasource(api);   // ← shu yerga qo'shiladi
});
```

Ya'ni `data/datasources/real_parent_datasource.dart` yozilib, shu ikki qator
almashtiriladi. Model'lar, repository, provider'lar va ekranlar o'zgarmaydi.

### Demo ma'lumot

Ota-ona **Sanjar Tursunov** (`+998 33 123 45 67`), ikkita farzand:

* **Amir Tursunov** — IELTS Intensive B2 (Student ilovasidagi o'sha o'quvchi,
  bir xil ID), to'lovi to'liq to'langan;
* **Zilola Tursunova** — Matematika 5-sinf, joriy oyda 500 000 so'm qolgan,
  o'tgan oyda 400 000 so'm **kechikkan**.

Dizayn butunlay mavjud `app_theme.dart` dan: yangi rang yoki shrift
qo'shilmagan.

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
