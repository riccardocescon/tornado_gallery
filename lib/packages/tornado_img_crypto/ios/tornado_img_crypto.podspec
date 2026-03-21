Pod::Spec.new do |spec|
  spec.name          = 'tornado_img_crypto'
  spec.version       = '1.0.0'
  spec.license       = { :file => '../LICENSE' }
  spec.homepage      = 'https://github.com/riccardocescon/tornado_gallery'
  spec.authors       = { 'Riccardo Cescon' => 'riccardo.cescon@example.com' }
  spec.summary       = 'A powerful encryption package for images with AES-CTR cipher'
  
  spec.source              = { :path => '.' }
  spec.source_files        = 'src/**/*.{c,cpp,h}'
  spec.public_header_files = 'src/**/*.h'
  
  spec.ios.deployment_target = '11.0'
  spec.osx.deployment_target = '10.14'
  
  # C++ configuration
  spec.compiler_flags = '-x objective-c++'
  spec.xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++'
  }
  
  # System frameworks and libraries
  spec.frameworks = ['Security', 'Foundation']
  spec.libraries = ['c++']
  
  # For now, we'll implement crypto without OpenSSL dependency on iOS
  # iOS has built-in CommonCrypto which we can use instead
  spec.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
    'VALID_ARCHS[sdk=iphoneos*]' => 'arm64'
  }
  
  spec.dependency 'Flutter'
end