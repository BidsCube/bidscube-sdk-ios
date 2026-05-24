# Реліз iOS SDK (`bidscubeSdk`) — чеклист і пуш

Поточна версія в репозиторії зазначена в:

- `bidscubeSdk/Core/Constants.swift` → `Constants.sdkVersion`
- `bidscubeSdk.podspec` → `spec.version`
- `README.md` (приклади SPM/CocoaPods)
- анонс у секції **Changelog** в `README.md`

Тег у Git має збігатися з підом: **`v{VERSION}`**, наприклад **`v1.2.3`** (поле `:tag => "v#{spec.version}"` у podspec).

---

## Перед релізом

1. Збірка в Xcode: схема **`bidscubeSdk`** (+ за потреби **`testApp-ios`**) під **Simulator** і/або пристрій.
2. Переконатися, що **`pod install`** у репозиторії проходить (якщо використовується workspace з Pods).
3. Лінт подспеки (локально):
   ```bash
   cd bidscube-sdk-ios
   pod spec lint bidscubeSdk.podspec --allow-warnings --verbose
   ```
   При помилках мережі/залежностей іноді допомагає `--skip-import-validation` лише як тимчасовий workaround; для релізу краще усунути причину.

---

## Git: коміт і тег

1. Перевірити диф лише файлів версії й документації (+ потрібні зміни коду релізу).
2. Закомітити (повідомлення на кшталт: `release: bidscubeSdk 1.2.3`).
3. Створити анотований тег:
   ```bash
   git tag -a v1.2.3 -m "bidscubeSdk 1.2.3"
   ```
4. Пушнути гілку і теги:
   ```bash
   git push origin main
   git push origin v1.2.3
   ```
   (замість `main` — ваша основна гілка релізів)

---

## Swift Package Manager (SPM)

Після того як тег **`v1.2.3`** з’явився на **`https://github.com/bidscube/bidscube-sdk-ios`**, SPM-клієнти знайдуть версію за semver тегами. Нові інтеграції роблять `from: "1.2.3"` або вибирають версію в Xcode **Add Package**.

Нічого додатково пушити для trunk SPM не потрібно — достатньо тегу на репозиторії.

---

## CocoaPods (`pod trunk push`)

Машина, з якої пушиться Trunk, повинна бути авторизована:

```bash
pod trunk register YOU@DOMAIN.com 'Your Name'
# підтвердити посилання з листа, потім:
pod trunk me
```

Публікація:

```bash
cd bidscube-sdk-ios
pod trunk push bidscubeSdk.podspec
```

Примітка:

- Перший успішний `pod trunk push` публікує pod **`bidscubeSdk`** із версією з podspec (`1.2.3`).
- Якщо podspec вказує `spec.source.tag => v1.2.3`, цей тег **має існувати** у remote на момент `pod trunk push` або валідація/користувачі з git source можуть упасти.

---

## GitHub Release (рекомендовано)

У вебінтерфейсі репозиторію: **Releases → Draft a new release** → Tag **`v1.2.3`**, опис з пунктів з Changelog для **1.2.3**, прикріпити за потреби збіркові артефакти (не обов’язково для SPM/Pods).

---

## Після релізу

- Оновити **AppLovin adapter** доку або podspec там, якщо потрібна явна нижня межа вашого релізу (наприклад `bidscubeSdk ~> 1.2`).
- Перевірити кеш CocoaPods CDN через кілька хвилин: `pod search bidscubeSdk`.
