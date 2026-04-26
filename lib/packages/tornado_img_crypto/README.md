# Tornado Image Crypto Package

A high-performance, cross-platform image encryption library for Flutter applications using AES-256-CTR encryption.

## Features

- 🔐 **AES-256-CTR Encryption**: Military-grade encryption with deterministic key derivation
- 🚀 **High Performance**: Optimized C++ implementation with >90,000 bytes/second throughput
- 🎨 **Image-Aware Modes**: Specialized RGB mode for visual scrambling
- 📱 **Cross-Platform**: Windows, Linux, macOS, iOS, and Android support
- 🔄 **Reversible**: Perfect encryption/decryption cycles
- 🧪 **Well-Tested**: Comprehensive test suite with 7 test scenarios

## Platform Support

| Platform | Status | Implementation | Notes |
|----------|--------|----------------|-------|
| ✅ Windows | Ready | OpenSSL 3.x | Via vcpkg |
| ✅ Linux | Ready | OpenSSL 3.x | System packages |
| ✅ macOS | Ready | OpenSSL 3.x | Homebrew/system |
| ✅ iOS | Ready | CommonCrypto | Native iOS framework |
| ⚠️ Android | Configured | OpenSSL 3.x | Requires NDK setup |

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  tornado_img_crypto:
    path: path/to/tornado_img_crypto
```

## Usage

```dart
import 'package:tornado_img_crypto/tornado_img_crypto.dart';

// Encrypt image bytes
final encryptedBytes = await processImage(
  input: imageBytes,
  phrase: 'your-encryption-key',
  palette: customPalette,
  useRgb: true, // Use RGB mode for better visual scrambling
  onProgress: (progress) => print('Progress: ${(progress * 100).toInt()}%'),
);

// Decrypt (same operation with same parameters)
final decryptedBytes = await processImage(
  input: encryptedBytes,
  phrase: 'your-encryption-key',
  palette: customPalette,
  useRgb: true,
);
```

## Directory Structure

```
tornado_img_crypto/
├── README.md                   # This file
├── pubspec.yaml               # Package configuration
├── CMakeLists.txt             # Main build configuration
├── lib/
│   ├── tornado_img_crypto.dart    # Main library export
│   └── src/
│       └── encryptor_interface.dart   # Dart FFI interface
├── src/                       # Native C++ source
│   ├── encryptor.h            # Header with cross-platform exports
│   └── encryptor.cpp          # Main implementation
├── test/
│   └── image_crypto_test.dart # Comprehensive test suite
├── docs/                      # Documentation
│   ├── README_FFI.md          # FFI setup guide
│   └── README_MOBILE.md       # Mobile platform guide
├── scripts/                   # Build scripts
│   ├── build_windows.bat     # Windows build script
│   └── build_ios.sh          # iOS/macOS build script
├── ios/
│   └── tornado_img_crypto.podspec # iOS CocoaPods configuration
├── android/
│   └── CMakeLists.txt         # Android build configuration
└── build_windows/             # Windows build artifacts
```

## Building

### Windows
```bash
scripts/build_windows.bat
```

### iOS/macOS
```bash
chmod +x scripts/build_ios.sh
scripts/build_ios.sh
```

### Android
Requires Android NDK and OpenSSL setup. See `docs/README_MOBILE.md` for details.

## Testing

Run the comprehensive test suite:

```bash
flutter test
```

Tests include:
- Encryption/decryption reversibility (byte and RGB modes)
- Large data performance validation
- Image unrecognizability verification
- Different key isolation
- Edge case handling
- Progress callback functionality

## Performance Metrics

- **Throughput**: >90,000 bytes/second
- **Reversibility**: 100% for both byte and RGB modes  
- **Image Scrambling**: <10% pixel similarity in RGB mode
- **Memory**: Efficient batch processing for large images

## Technical Details

### Encryption Algorithm
- **Cipher**: AES-256-CTR (Counter mode)
- **Key Derivation**: SHA-256 based deterministic generation
- **IV Generation**: SHA-256 of key for deterministic IVs
- **Modes**: BYTE_MODE (raw XOR) and RGB_MODE (pixel-aware)

### Implementation
- **Core**: Modern C++ with OpenSSL 3.x EVP APIs
- **iOS**: Apple CommonCrypto for native performance
- **Interface**: Dart FFI with isolate-based async processing
- **Build**: CMake with cross-platform configuration

## License

See the main project license.