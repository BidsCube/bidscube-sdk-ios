# Реліз iOS SDK (`bidscubeSdk`) — чеклист і пуш

**Внутрішня документація для команди:** [`doc/README.md`](doc/README.md)

Поточна версія в репозиторії зазначена в:

- `bidscubeSdk/Core/Constants.swift` → `Constants.sdkVersion`
- `bidscubeSdk.podspec` → `spec.version`
- `README.md` (приклади SPM/CocoaPods)
- анонс у секції **Changelog** в `README.md`

Тег у Git має збігатися з підом: **`v{VERSION}`**, наприклад **`v1.2.5`** (поле `:tag => "v#{spec.version}"` у podspec).

---

## Перед релізом

1. Збірка в Xcode: схема **`bidscubeSdk`** (+ за потреби **`testApp-ios`**) під **Simulator** і/або пристрій.
2. Переконатися, що **`pod install`** у репозиторії проходить (якщо використовується workspace з Pods).
3. Лінт podspec (локально):
   ```bash
   cd bidscube-sdk-ios
   pod spec lint bidscubeSdk.podspec --allow-warnings --verbose
   ```
   При помилках мережі/залежностей іноді допомагає `--skip-import-validation` лише як тимчасовий workaround; для релізу краще усунути причину.

---

## Git: коміт і тег

1. Перевірити диф — **не комітити** `build/`, `.build/`, `.swiftpm/`, `Pods/` (якщо не оновлювали навмисно), `DerivedData/`, `.derivedData*`, `__MACOSX/`, `.DS_Store`, `xcuserdata/`, `*.xcuserstate`, `.git/`.

### Чистий source archive (без build/Pods)

Для релізного ZIP або перевірки вмісту репозиторію:

```bash
cd bidscube-sdk-ios
git archive --format=zip --prefix=bidscube-sdk-ios/ HEAD \
  -o bidscube-sdk-ios-source.zip
```

Або експорт каталогу з виключеннями:

```bash
tar -czf bidscube-sdk-ios-source.tar.gz \
  --exclude='.git' \
  --exclude='.build' \
  --exclude='build' \
  --exclude='Pods' \
  --exclude='DerivedData' \
  --exclude='.derivedData*' \
  --exclude='__MACOSX' \
  --exclude='.DS_Store' \
  --exclude='xcuserdata' \
  --exclude='.swiftpm' \
  .
```

2. Закомітити (повідомлення на кшталт: `release: bidscubeSdk 1.2.5`).
3. Створити анотований тег:
   ```bash
   git tag -a v1.2.5 -m "bidscubeSdk 1.2.5"
   ```
4. Пушнути гілку і теги:
   ```bash
   git push origin main
   git push origin v1.2.5
   ```
   (замість `main` — ваша основна гілка релізів)

Після push тегу **`v1.2.5`** GitHub Actions (`.github/workflows/publish.yml`) автоматично опублікує CocoaPods + створить GitHub Release.

---

## Swift Package Manager (SPM)

Після того як тег **`v1.2.5`** з’явився на **`https://github.com/bidscube/bidscube-sdk-ios`**, SPM-клієнти знайдуть версію за semver тегами. Нові інтеграції роблять `from: "1.2.5"` або вибирають версію в Xcode **Add Package**.

Нічого додатково пушити для trunk SPM не потрібно — достатньо тегу на репозиторії.

---

## CocoaPods (`pod trunk push`)

Машина, з якої пушиться Trunk, повинна бути авторизована:

```bash
pod trunk register YOU@DOMAIN.com 'Your Name'
# підтвердити посилання з листа, потім:
pod trunk me
```

Публікація (якщо CI не спрацював):

```bash
cd bidscube-sdk-ios
pod trunk push bidscubeSdk.podspec
```

Примітка:

- Podspec вказує `spec.source.tag => v1.2.5` — цей тег **має існувати** у remote на момент `pod trunk push`.

---

## GitHub Release (рекомендовано)

У вебінтерфейсі репозиторію: **Releases → Draft a new release** → Tag **`v1.2.5`**, опис з пунктів Changelog для **1.2.5** (або дочекатися auto-release від Actions).

---

## Після релізу

- Оновити **AppLovin adapter** podspec/доку, якщо потрібна явна нижня межа (`bidscubeSdk ~> 1.2`).
- Перевірити кеш CocoaPods CDN через кілька хвилин: `pod search bidscubeSdk`.
