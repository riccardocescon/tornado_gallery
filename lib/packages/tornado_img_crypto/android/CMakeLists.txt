# Android-specific CMakeLists.txt for tornado_img_crypto
cmake_minimum_required(VERSION 3.22.1)

project(tornado_crypto_android CXX)

# Configure C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Ensure proper architecture handling
if(ANDROID)
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
    
    # Add 16KB page size compatibility flags (linker only)
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,max-page-size=16384")
    
    # Ensure correct architecture compilation
    message(STATUS "Building for Android ABI: ${ANDROID_ABI}")
    message(STATUS "Building for Android Architecture: ${CMAKE_ANDROID_ARCH_ABI}")
endif()

# Add the main source files
add_library(tornado_crypto SHARED
    ../../../cpp/src/encryptor.cpp
)

# Find required libraries for Android
find_library(log-lib log)

# Resolve the path to the prebuilt OpenSSL for the current ABI.
# The third_party folder lives at  <repo>/lib/cpp/third_party/openssl-android/.
# From this file's location (android/) we go up three levels to reach lib/cpp/.
set(OPENSSL_PREBUILT_DIR
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../cpp/third_party/openssl-android/${ANDROID_ABI}"
)

if(EXISTS "${OPENSSL_PREBUILT_DIR}/lib/libcrypto.a")
    message(STATUS "Using prebuilt OpenSSL for ${ANDROID_ABI}: ${OPENSSL_PREBUILT_DIR}")

    add_library(ssl_crypto STATIC IMPORTED)
    set_target_properties(ssl_crypto PROPERTIES
        IMPORTED_LOCATION "${OPENSSL_PREBUILT_DIR}/lib/libcrypto.a"
    )

    target_include_directories(tornado_crypto PRIVATE
        "${OPENSSL_PREBUILT_DIR}/include"
    )

    target_link_libraries(tornado_crypto ssl_crypto)
else()
    message(WARNING
        "Prebuilt OpenSSL not found for ABI ${ANDROID_ABI} at ${OPENSSL_PREBUILT_DIR}. "
        "The build will likely fail."
    )
endif()

# Link Android native libraries
target_link_libraries(tornado_crypto
    ${log-lib}
)

# Include directories
target_include_directories(tornado_crypto PRIVATE
    ../../../cpp/src
)