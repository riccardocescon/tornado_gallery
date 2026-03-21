# Android-specific CMakeLists.txt for tornado_img_crypto
cmake_minimum_required(VERSION 3.22.1)

project(tornado_crypto_android CXX)

# Configure C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Ensure proper architecture handling
if(ANDROID)
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
    
    # Add 16KB page size compatibility flags for Android
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wl,-z,max-page-size=16384")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wl,-z,max-page-size=16384")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,max-page-size=16384")
    
    # Ensure correct architecture compilation
    message(STATUS "Building for Android ABI: ${ANDROID_ABI}")
    message(STATUS "Building for Android Architecture: ${CMAKE_ANDROID_ARCH_ABI}")
endif()

# Add the main source files
add_library(tornado_crypto SHARED
    ../src/encryptor.cpp
)

# Find required libraries for Android
find_library(log-lib log)

# Try to find OpenSSL if available
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
    pkg_check_modules(OPENSSL QUIET openssl)
endif()

# If OpenSSL is not found, use simplified crypto
if(NOT OPENSSL_FOUND)
    message(STATUS "OpenSSL not found, building with simplified crypto for Android")
    target_compile_definitions(tornado_crypto PRIVATE
        ANDROID_BUILD=1
        NO_OPENSSL=1
    )
else()
    # Link OpenSSL if available
    target_link_libraries(tornado_crypto
        ${OPENSSL_LIBRARIES}
    )
    target_include_directories(tornado_crypto PRIVATE
        ${OPENSSL_INCLUDE_DIRS}
    )
endif()

# Link Android native libraries
target_link_libraries(tornado_crypto
    ${log-lib}
)

# Include directories
target_include_directories(tornado_crypto PRIVATE
    ../src
)