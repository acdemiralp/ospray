## ======================================================================== ##
## Copyright 2009-2016 Intel Corporation                                    ##
##                                                                          ##
## Licensed under the Apache License, Version 2.0 (the "License");          ##
## you may not use this file except in compliance with the License.         ##
## You may obtain a copy of the License at                                  ##
##                                                                          ##
##     http://www.apache.org/licenses/LICENSE-2.0                           ##
##                                                                          ##
## Unless required by applicable law or agreed to in writing, software      ##
## distributed under the License is distributed on an "AS IS" BASIS,        ##
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. ##
## See the License for the specific language governing permissions and      ##
## limitations under the License.                                           ##
## ======================================================================== ##

IF (OSPRAY_MPI)
  SET(OSPRAY_MPI_DISTRIBUTED ON) # sets this define in OSPConfig.h

  MACRO(CONFIGURE_MPI)

    IF (WIN32) # FindMPI does not find Intel MPI on Windows, we need to help here
      FIND_PACKAGE(MPI)

      # need to strip quotes, otherwise CMake treats it as relative path
      STRING(REGEX REPLACE "^\"|\"$" "" MPI_CXX_INCLUDE_PATH ${MPI_CXX_INCLUDE_PATH})

      IF (NOT MPI_CXX_FOUND)
        # try again, hinting the compiler wrappers
        SET(MPI_CXX_COMPILER mpicxx.bat)
        SET(MPI_C_COMPILER mpicc.bat)
        FIND_PACKAGE(MPI)

        IF (NOT MPI_CXX_LIBRARIES)
          SET(MPI_LIB_PATH ${MPI_CXX_INCLUDE_PATH}\\..\\lib)

          SET(MPI_LIB "MPI_LIB-NOTFOUND" CACHE FILEPATH "Cleared" FORCE)
          FIND_LIBRARY(MPI_LIB NAMES impi HINTS ${MPI_LIB_PATH})
          SET(MPI_C_LIB ${MPI_LIB})
          SET(MPI_C_LIBRARIES ${MPI_LIB} CACHE STRING "MPI C libraries to link against" FORCE)

          SET(MPI_LIB "MPI_LIB-NOTFOUND" CACHE FILEPATH "Cleared" FORCE)
          FIND_LIBRARY(MPI_LIB NAMES impicxx HINTS ${MPI_LIB_PATH})
          SET(MPI_CXX_LIBRARIES ${MPI_C_LIB} ${MPI_LIB} CACHE STRING "MPI CXX libraries to link against" FORCE)
          SET(MPI_LIB "MPI_LIB-NOTFOUND" CACHE INTERNAL "Scratch variable for MPI lib detection" FORCE)
        ENDIF()
      ENDIF()
    ELSE()
      FIND_PACKAGE(MPI REQUIRED)
      IF(MPI_CXX_FOUND)
        GET_FILENAME_COMPONENT(DIR ${MPI_LIBRARY} PATH)
        SET(MPI_LIBRARY_MIC ${DIR}/../../mic/lib/libmpi.so CACHE FILEPATH "")
      ENDIF()
    ENDIF()

    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${MPI_CXX_COMPILE_FLAGS}")
    SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${MPI_CXX_LINK_FLAGS}")

    IF (${CMAKE_CXX_COMPILER_ID} STREQUAL "Intel")
      SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mt_mpi")
      SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -mt_mpi")
    ENDIF()

    INCLUDE_DIRECTORIES(SYSTEM ${MPI_CXX_INCLUDE_PATH})

    IF (THIS_IS_MIC)
      SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -mmic")
    ENDIF()

  ENDMACRO()

  IF (THIS_IS_MIC)
    INCLUDE(${PROJECT_SOURCE_DIR}/cmake/icc_xeonphi.cmake)
  ENDIF()

ELSE()
  MACRO(CONFIGURE_MPI)
    # nothing to do w/o mpi mode
  ENDMACRO()
ENDIF()
