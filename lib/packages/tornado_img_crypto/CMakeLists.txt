cmake_minimum_required(VERSION 3.10)

# Project setup
project(tornado_crypto)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Platform detection
if(ANDROID)
    message(STATUS "Building for Android")
elseif(IOS)
    message(STATUS "Building for iOS")
elseif(WIN32)
    message(STATUS "Building for Windows")
elseif(APPLE)
    message(STATUS "Building for macOS")
elseif(UNIX)
    message(STATUS "Building for Linux")
endif()

# Find OpenSSL
if(ANDROID)
    # For Android, we'll use a bundled crypto library or link statically
    # Android typically requires static linking or bundled crypto
    set(OPENSSL_USE_STATIC_LIBS TRUE)
    # You may need to set OPENSSL_ROOT_DIR for Android builds
elseif(IOS)
    # For iOS, similar approach - static linking preferred
    set(OPENSSL_USE_STATIC_LIBS TRUE)
    # You may need to set OPENSSL_ROOT_DIR for iOS builds
else()
    # Desktop platforms
    find_package(OpenSSL REQUIRED)
endif()

# Source files
set(SOURCES
    src/encryptor.cpp
)

# Headers
set(HEADERS
    src/encryptor.h
)

# Create shared library
add_library(tornado_crypto SHARED ${SOURCES} ${HEADERS})

# Compiler definitions for export
if(WIN32)
    target_compile_definitions(tornado_crypto PRIVATE BUILDING_DLL)
    if(MSVC)
        set_target_properties(tornado_crypto PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
    endif()
endif()

# Platform-specific configurations
if(ANDROID)
    # Android-specific settings
    message(STATUS "Configuring for Android - using OpenSSL")
    target_link_libraries(tornado_crypto log)
    
    # For Android, we'll need to include OpenSSL
    # This requires setting up vcpkg or using prebuilt OpenSSL for Android
    # For now, this will require manual OpenSSL setup for Android NDK
    
elseif(IOS)
    # iOS-specific settings
    message(STATUS "Configuring for iOS - using CommonCrypto")
    
    set_target_properties(tornado_crypto PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION A
        MACOSX_FRAMEWORK_IDENTIFIER com.tornado.crypto
        PUBLIC_HEADER "${HEADERS}"
    )
    
    # iOS uses CommonCrypto instead of OpenSSL
    target_link_libraries(tornado_crypto 
        "-framework Foundation"
        "-framework Security"
    )
    
    # Set iOS deployment target
    set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0")
    
    # Define TARGET_OS_IPHONE for conditional compilation
    target_compile_definitions(tornado_crypto PRIVATE TARGET_OS_IPHONE=1)
    
elseif(WIN32)
    # Windows-specific settings
    if(OpenSSL_FOUND)
        target_link_libraries(tornado_crypto OpenSSL::SSL OpenSSL::Crypto)
    endif()
    target_link_libraries(tornado_crypto ws2_32 crypt32)
    
else()
    # Linux/macOS desktop
    if(OpenSSL_FOUND)
        target_link_libraries(tornado_crypto OpenSSL::SSL OpenSSL::Crypto)
    endif()
endif()

# Set output name
set_target_properties(tornado_crypto PROPERTIES
    OUTPUT_NAME tornado_crypto
)

# Include directories
target_include_directories(tornado_crypto PRIVATE src)

# Install targets (for desktop builds)
if(NOT ANDROID AND NOT IOS)
    install(TARGETS tornado_crypto
        LIBRARY DESTINATION lib
        FRAMEWORK DESTINATION lib
        RUNTIME DESTINATION bin
    )
endif()

# Print build information
message(STATUS "Building tornado_crypto library")
message(STATUS "Platform: ${CMAKE_SYSTEM_NAME}")
message(STATUS "Architecture: ${CMAKE_SYSTEM_PROCESSOR}")
if(OpenSSL_FOUND)
    message(STATUS "OpenSSL version: ${OPENSSL_VERSION}")
    message(STATUS "OpenSSL include: ${OPENSSL_INCLUDE_DIR}")
endif()