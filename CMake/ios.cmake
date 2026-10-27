include(FetchContent)

# Keep the desktop custom-audio formats available in the iOS build.
set(CMAKE_POLICY_VERSION_MINIMUM 3.5)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(INSTALL_DOCS OFF CACHE BOOL "" FORCE)
set(INSTALL_PKG_CONFIG_MODULE OFF CACHE BOOL "" FORCE)
set(INSTALL_CMAKE_PACKAGE_MODULE OFF CACHE BOOL "" FORCE)
FetchContent_Declare(
    Ogg
    GIT_REPOSITORY https://github.com/xiph/ogg.git
    GIT_TAG v1.3.6
    OVERRIDE_FIND_PACKAGE
)
FetchContent_MakeAvailable(Ogg)

FetchContent_Declare(
    Vorbis
    GIT_REPOSITORY https://github.com/xiph/vorbis.git
    GIT_TAG v1.3.7
)
FetchContent_MakeAvailable(Vorbis)
if(NOT TARGET Vorbis::vorbis)
    add_library(Vorbis::vorbis ALIAS vorbis)
    add_library(Vorbis::vorbisenc ALIAS vorbisenc)
    add_library(Vorbis::vorbisfile ALIAS vorbisfile)
endif()

set(OPUS_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(OPUS_BUILD_PROGRAMS OFF CACHE BOOL "" FORCE)
FetchContent_Declare(
    Opus
    GIT_REPOSITORY https://github.com/xiph/opus.git
    GIT_TAG v1.5.2
)
FetchContent_MakeAvailable(Opus)
if(NOT TARGET Opus::opus)
    add_library(Opus::opus ALIAS opus)
endif()

# Match the installed Opus header layout expected by Shipwright.
set(OPUS_COMPAT_INCLUDE_DIR "${CMAKE_BINARY_DIR}/harkinianpad-include")
file(COPY "${opus_SOURCE_DIR}/include/"
    DESTINATION "${OPUS_COMPAT_INCLUDE_DIR}/opus"
)
target_include_directories(opus INTERFACE
    "$<BUILD_INTERFACE:${OPUS_COMPAT_INCLUDE_DIR}>"
)

# opusfile 0.12 has no CMake project; build its local-file decoder directly.
FetchContent_Declare(
    OpusFile
    GIT_REPOSITORY https://github.com/xiph/opusfile.git
    GIT_TAG v0.12
    SOURCE_SUBDIR cmake-not-available
)
FetchContent_MakeAvailable(OpusFile)
add_library(opusfile STATIC
    ${opusfile_SOURCE_DIR}/src/info.c
    ${opusfile_SOURCE_DIR}/src/internal.c
    ${opusfile_SOURCE_DIR}/src/opusfile.c
    ${opusfile_SOURCE_DIR}/src/stream.c
)
target_compile_definitions(opusfile PRIVATE OP_DISABLE_HTTP)
target_include_directories(opusfile
    PUBLIC ${opusfile_SOURCE_DIR}/include
    PRIVATE ${opusfile_SOURCE_DIR}/src
)
target_link_libraries(opusfile PUBLIC Ogg::ogg Opus::opus)
add_library(OpusFile::opusfile ALIAS opusfile)
