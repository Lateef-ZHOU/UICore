include_guard(GLOBAL)
include(FetchContent)
if(NOT TARGET Lidar::HandleCore)
    FetchContent_Declare(lidar_handlecore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/HandleCore.git
        GIT_TAG 113523f3a40ad2dc7c417d01326688b5bd79a51b)
    FetchContent_MakeAvailable(lidar_handlecore)
endif()
