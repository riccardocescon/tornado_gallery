Pod::Spec.new do |spec|
  spec.name          = 'tornado_img_crypto'
  spec.version       = '1.0.0'
  spec.license       = { :file => '../LICENSE' }
  spec.homepage      = 'https://github.com/riccardocescon/tornado_gallery'
  spec.authors       = { 'Riccardo Cescon' => 'riccardo.cescon@example.com' }
  spec.summary       = 'A powerful encryption package for images with AES-CTR cipher'

  spec.source = { :path => '.' }
  spec.source_files = 'Classes/**/*.{h,m,mm,c,cc,cpp}'

  # Pre-built xcframework produced by build_test_deploy.ps1 (phase 2 on macOS).
  # The xcframework contains two slices:
  #   - arm64-iphoneos          (physical device)
  #   - arm64 + x86_64 -iphonesimulator  (fat simulator library)
  spec.vendored_frameworks = 'Frameworks/tornado_crypto.xcframework'

  spec.ios.deployment_target = '11.0'
  spec.osx.deployment_target = '10.14'

  # CommonCrypto (AES-CTR, HMAC-SHA256, SHA256) and Foundation are system
  # frameworks already available on every Apple platform — no extra install.
  spec.frameworks = ['Security', 'Foundation']
  spec.libraries  = ['c++']

  spec.xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY'           => 'libc++'
  }

  spec.pod_target_xcconfig = {
    'DEFINES_MODULE'                       => 'YES',
    'VALID_ARCHS[sdk=iphonesimulator*]'    => 'arm64 x86_64',
    'VALID_ARCHS[sdk=iphoneos*]'           => 'arm64'
  }

  spec.dependency 'Flutter'
end