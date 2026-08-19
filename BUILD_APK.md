# Збірка тестового Android APK

Цей проєкт містить автоматичну GitHub Actions збірку:

1. Вона використовує Flutter `3.29.3` і Java `17`.
2. Відтворює відсутній у checkpoint Android host-проєкт командою `flutter create --platforms=android`.
3. Виконує `flutter analyze` та `flutter test`.
4. Збирає `app-release.apk` тільки після успішних перевірок.

## Як отримати APK

1. Створіть приватний GitHub-репозиторій, наприклад `CarbCalcUA`.
2. Завантажте **вміст** цієї папки у корінь репозиторію (так, щоб `pubspec.yaml` був у корені).
3. Відкрийте вкладку **Actions** → **Android APK** → **Run workflow**.
4. Дочекайтеся зеленого статусу. У блоці **Artifacts** завантажте
   `CarbCalcUA-0.5.1-build-…`.
5. Розпакуйте завантажений artifact: усередині буде `app-release.apk`.

## Встановлення на телефон

Передайте `app-release.apk` на Android-пристрій, відкрийте файл і дозвольте
встановлення з цього джерела, якщо Android запитає. APK підписаний стандартним
debug signing key Flutter/Android для тестового встановлення, а не ключем Google Play.

Не завантажуйте цей APK у Google Play. Для публікації потрібні окремий release
keystore та Android App Bundle (AAB).
