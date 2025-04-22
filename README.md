CZ - Version

# Schoolkit

**Maturitní projekt – multiplatformní školní informační systém postavený pomocí Flutteru a Firebase**

## O aplikaci

Schoolkit je školní mobilní aplikace, která slouží jako jednoduchý a přehledný informační systém pro studenty, učitele i administrátory. Nabízí funkce jako:

- Správa uživatelů a jejich rolí
- Zobrazení známek a testů
- Zadávání domácích úkolů
- Vypracování úkolů studenty (text)
- Přehled plánovaných testů

Projekt byl vytvořen jako součást maturitní práce a ukazuje práci s moderními technologiemi jako jsou Flutter, Dart a Firebase (Firestore, Auth).

## Instalace

Aplikace není dostupná na Google Play. Pokud si ji chcete vyzkoušet:

### Spuštění ze zdrojového kódu

1. Stáhněte si zdrojový kód z GitHubu
2. Otevřete projekt v IDE s podporou Flutteru (např. VS Code nebo Android Studio).
3. Ujistěte se, že máte nainstalovaný Flutter SDK.
4. Spusťte aplikaci příkazem: flutter run

## Struktura projektu

- `lib/` – zdrojový kód aplikace (obrazovky, modely, logika)
- `assets/` – obrázky, ikony, pozadí aplikace
- `pubspec.yaml` – definice závislostí, fontů a assetů
- `android/app/google-services.json` – konfigurace Firebase

## Bezpečnostní upozornění

Pro zvýšení bezpečnosti byly z projektu odstraněny všechny API klíče a citlivé soubory:

- `/lib/firebase_options.dart` – automaticky generovaný konfigurační soubor Firebase byl odstraněn
- `android/app/google-services.json` – klíč odstraněn z řádku 18

Při vlastním nasazení je třeba tyto soubory vygenerovat pomocí Firebase konzole.

## Použité technologie

- Flutter
- Dart
- Firebase (Authentication, Firestore, Storage)
- flutter_launcher_icons
- intl, http, fluttertoast, flutter_spinkit

## Závěr

Projekt Schoolkit reprezentuje kompletní vývojovou práci od návrhu až po hotovou aplikaci. Byl vytvořen s důrazem na přehlednost a rozšiřitelnost. V budoucnu je možné projekt dále rozvíjet.

## Autor

Štěpán Zobal  
Maturitní práce – 2025  
Střední průmyslová škola Brno, Purkyňova, příspěvková organizace




EN - Version

Schoolkit
Graduation Project – A Cross-Platform School Information System built with Flutter and Firebase

##About the App
Schoolkit is a mobile school app designed as a simple and clear information system for students, teachers, and administrators. It provides features such as:

- User and role management
- Display of grades and tests
- Assigning homework
- Submitting homework by students (text)
- Overview of planned tests

The project was created as part of a graduation thesis and demonstrates working with modern technologies like Flutter, Dart, and Firebase (Firestore, Auth).

Installation
The app is not available on Google Play. If you’d like to try it:

Run from Source Code
1. Download the source code from GitHub
2. Open the project in an IDE with Flutter support (e.g., VS Code or Android Studio)
3. Make sure Flutter SDK is installed
4. Run the app using the command: flutter run

Project Structure
`lib/` – app source code (screens, models, logic)
`assets/` – images, icons, app backgrounds
`pubspec.yaml` – dependency, fonts, and assets definitions
`android/app/google-services.json` – Firebase configuration

Security Notice
To enhance security, all API keys and sensitive files have been removed from the project:

- `/lib/firebase_options.dart` – auto-generated Firebase config file removed
- `android/app/google-services.json` – key removed from line 18

To deploy the app yourself, generate these files using Firebase Console.

Technologies Used
- Flutter
- Dart
- Firebase (Authentication, Firestore, Storage)
- flutter_launcher_icons
- intl, http, fluttertoast, flutter_spinkit

Conclusion
The Schoolkit project represents a complete development process from concept to a working application. It was created with a focus on clarity and future scalability. The project can be further expanded with new features.

Author
Štěpán Zobal
Graduation Project – 2025
Secondary Industrial School Brno, Purkyňova, Public Institution