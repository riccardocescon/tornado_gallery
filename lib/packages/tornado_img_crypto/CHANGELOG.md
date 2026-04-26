# Changelog

All notable changes to the Tornado Image Crypto package will be documented in this file.

## [1.0.0] - 2026-03-20

### Added
- Initial release of the Tornado Image Crypto package
- Cross-platform AES-256-CTR encryption implementation
- Support for Windows, Linux, macOS, iOS, and Android platforms
- Dart FFI interface for seamless Flutter integration
- Two encryption modes: BYTE_MODE and RGB_MODE
- Comprehensive test suite with 7 test scenarios
- High-performance C++ implementation (>90,000 bytes/second)
- Platform-specific optimizations:
  - Windows/Linux/macOS: OpenSSL 3.x EVP APIs
  - iOS: Apple CommonCrypto framework
  - Android: OpenSSL 3.x with NDK support (configured)

### Features
- Deterministic key and IV generation using SHA-256
- Reversible encryption/decryption cycles
- Image unrecognizability validation (<10% pixel similarity)
- Progress callback support for long operations
- Memory-efficient batch processing for large images
- Cross-platform build system using CMake
- Flutter plugin architecture with FFI support

### Performance Metrics
- Encryption throughput: >90,000 bytes/second
- Perfect reversibility: 100% for both modes
- Image scrambling effectiveness: <10% similarity in RGB mode
- Reasonable performance requirements: <1 second for 10KB data

### Documentation
- Comprehensive README with usage examples
- Platform-specific setup guides
- FFI integration documentation
- Build instructions for all platforms
- Performance benchmarking results

### Testing
- Basic encryption/decryption reversibility tests
- RGB mode specialized testing
- Large data performance validation
- Image unrecognizability verification
- Different key isolation tests
- Edge case and error handling tests
- Progress callback functionality tests