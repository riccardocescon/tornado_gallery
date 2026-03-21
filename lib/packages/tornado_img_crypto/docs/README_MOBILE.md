# Tornado Image Crypto - Mobile Platform Support

This package now supports mobile platforms (Android and iOS) in addition to desktop platforms.

## Platform Support Matrix

| Platform | Status | Crypto Implementation | Notes |
|----------|--------|----------------------|-------|
| Windows  | ✅ Ready | OpenSSL 3.x | Using vcpkg OpenSSL |
| Linux    | ✅ Ready | OpenSSL 3.x | System OpenSSL |
| macOS    | ✅ Ready | OpenSSL 3.x | HomeBrew/System OpenSSL |
| iOS      | ✅ Ready | CommonCrypto | Uses iOS native crypto APIs |
| Android  | ⚠️ Setup Required | OpenSSL 3.x | Requires NDK OpenSSL setup |

## Architecture

The package uses conditional compilation to support different crypto backends:

- **Desktop platforms**: OpenSSL EVP APIs for AES-256-CTR encryption
- **iOS**: Apple's CommonCrypto framework for native performance
- **Android**: OpenSSL (requires NDK setup)

## File Structure

```
lib/packages/tornado_img_crypto/
├── pubspec.yaml           # Flutter plugin configuration
├── CMakeLists.txt         # Cross-platform build configuration
├── ios/
│   └── tornado_img_crypto.podspec  # iOS CocoaPods configuration
├── src/
│   ├── encryptor.h        # Common header with platform exports
│   └── encryptor.cpp      # Main implementation with platform conditionals
├── build_windows.bat      # Windows build script
├── build_linux.sh        # Linux build script
└── build_ios.sh          # iOS/macOS build script
```

## Building for Specific Platforms

### Windows
```bash
./build_windows.bat
```
Requirements: Visual Studio 2022, vcpkg with OpenSSL

### Linux/macOS
```bash
chmod +x build_ios.sh
./build_ios.sh
```
Requirements: OpenSSL development packages

### iOS
The iOS build uses CommonCrypto and is configured through the `.podspec` file.
No additional dependencies required.

### Android
Android support requires OpenSSL to be built for Android NDK.
This is more complex and requires additional setup.

## Encryption Details

- **Algorithm**: AES-256-CTR
- **Key Derivation**: SHA-256 based deterministic key/IV generation
- **Modes**: 
  - BYTE_MODE: XOR-based reversible encryption
  - RGB_MODE: RGB-aware encryption for better visual scrambling

## Performance

All platforms maintain the same encryption performance characteristics:
- Reversible encryption/decryption
- Deterministic key generation
- Fast batch processing
- Image unrecognizability in RGB mode

## Integration

The Dart interface (`encryptor_interface.dart`) automatically detects the platform and loads the appropriate native library:

```dart
import 'package:tornado_img_crypto/tornado_img_crypto.dart';

// Works on all supported platforms
final result = await ImageCrypto.processImage(
  imageBytes,
  encryptionKey: 'your-key',
  mode: EncryptionMode.rgb,
);
```

## Testing

Each platform maintains compatibility with the comprehensive test suite:
- Byte mode reversibility tests
- RGB mode reversibility tests
- Image unrecognizability validation
- Performance benchmarks
- Large data handling tests