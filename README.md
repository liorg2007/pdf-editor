# 📄 Hebrew Invoice & Price Quote Generator

A professional, offline-first Flutter application designed for creating Hebrew invoices (חשבון עסקה) and price quotes (הצעת מחיר). Built with a focus on speed, precision, and RTL (Right-to-Left) accuracy.

## ✨ Key Features

- **🇮🇱 Professional Hebrew Layout**: Full RTL support with standard Hebrew business formatting.
- **🛡️ 100% Offline**: Generates PDFs locally on your device. No internet connection required for document creation.
- **🔢 Auto-Incrementing Counter**: Documents are automatically numbered. The counter persists even after closing the app.
- **💾 Persistent Company Info**: Save your business details once; the app auto-loads them every time you open it.
- **📊 Grid-Based PDF Table**: Modern, high-readability items table with borders and automated tax (VAT) calculations.
- **📱 One-Tap Sharing**: Quickly share generated PDFs via WhatsApp, Email, or any other messaging app.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Android Studio or VS Code with Flutter extension
- An Android device or emulator

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/liorg2007/pdf-editor.git
   cd pdf-editor
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## 🛠️ Built With

- **[Flutter](https://flutter.dev/)** - UI Framework
- **[pdf](https://pub.dev/packages/pdf)** - PDF creation library
- **[shared_preferences](https://pub.dev/packages/shared_preferences)** - Local data persistence
- **[intl](https://pub.dev/packages/intl)** - Date and currency formatting
- **[share_plus](https://pub.dev/packages/share_plus)** - Cross-platform sharing

## 📦 Building the APK

To generate a standalone APK for your Android phone:

```powershell
flutter build apk --release
```

The resulting file will be located at:  
`build/app/outputs/flutter-apk/app-release.apk`

## 📝 Usage

1. **Setup**: Fill in your company details once and click **"Save Company Details"**.
2. **Draft**: Enter the customer info and itemize your services/products.
3. **Generate**: Click the PDF icon. The app will automatically capture the date/time, assign the next serial number, and generate the document.
4. **Share**: Use the native share sheet to send the document to your client.

---
*Created for efficient business management.*
