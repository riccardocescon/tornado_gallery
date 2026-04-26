# Tornado Image Crypto - FFI Integration

## 🔗 Collegamento C++ ↔ Dart

Il file `encryptor_interface.dart` ora si collega al tuo codice C++ di crittografia tramite **Dart FFI**.

## 📋 Setup Completo:

### 1. **Compila la libreria condivisa C++**
```bash
# Da lib/cpp/
scripts/build_shared.ps1    # Windows PowerShell
# oppure
scripts/build_shared.bat    # Windows Batch
```

### 2. **Distribuisci la DLL**
```bash
# Da lib/cpp/
scripts/distribute_dll.bat
```

### 3. **Installa le dipendenze Dart**
```bash
# Da lib/packages/tornado_img_crypto/
dart pub get
```

### 4. **Testa l'integrazione**
```bash
# Da lib/packages/tornado_img_crypto/
dart run test_ffi.dart
```

## 🔧 Come Funziona:

### **Caricamento Multi-Piattaforma:**
Il codice ora rileva automaticamente la piattaforma e carica il file appropriato:
- **Windows**: `tornado_crypto.dll`
- **Linux**: `libtornado_crypto.so`  
- **macOS**: `libtornado_crypto.dylib`

### **Percorsi di Ricerca:**
1. Directory di sviluppo: `lib/cpp/build/`
2. Directory corrente
3. PATH di sistema

### **API Dart:**
```dart
// Cripta/decripta dati
final result = await processImage(
  input: imageBytes,           // Uint8List - dati immagine
  phrase: 'my_secret_key',     // String - chiave
  palette: paletteColors,      // Uint8List - palette colori
  useRgb: true,               // bool - modalità RGB vs byte
  onProgress: (progress) {    // Callback progresso
    print('Progress: ${progress * 100}%');
  },
);
```

## 🎯 Vantaggi:

✅ **Zero-Copy**: Elaborazione diretta in memoria nativa  
✅ **Multi-threading**: Supporto per isolate Dart  
✅ **Progress tracking**: Monitoraggio in tempo reale  
✅ **Cross-platform**: Windows/Linux/macOS  
✅ **Type-safe**: Binding FFI tipizzati  

## 🚀 Prossimi Passi:

1. **Testa l'integrazione** con `dart run test_ffi.dart`
2. **Integra nel tuo app Flutter** importando il package
3. **Compila per altre piattaforme** (Linux/macOS) se necessario

## 🛠️ Troubleshooting:

Se hai errori di caricamento libreria:
- Verifica che `tornado_crypto.dll` esista ed sia accessibile
- Controlla che le dipendenze OpenSSL siano disponibili
- Su Windows, potrebbe servire Visual Studio Redistributable

## 📁 Struttura File:

```
lib/packages/tornado_img_crypto/
├── lib/src/
│   └── encryptor_interface.dart  # 🔗 FFI Interface (AGGIORNATO)
├── test_ffi.dart               # 🧪 Test di integrazione
├── pubspec.yaml                # 📦 Dipendenze (ffi, path)
└── tornado_crypto.dll          # 🔧 Libreria nativa
```

La tua libreria è ora **completamente integrata** e pronta per l'uso in Flutter! 🎉