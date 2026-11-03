include_guard(GLOBAL)
include(FetchContent)
if(NOT TARGET Lidar::HandleCore)
    FetchContent_Declare(lidar_handlecore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/HandleCore.git
        GIT_TAG 753f884cd2644ac423e1feb4004bdcb14b233ad9)
    FetchContent_MakeAvailable(lidar_handlecore)
endif()
