macro(prjenv)
  option(HSLIB_INSTALL_DIR_OPTION "OFF: use System Path Value: 3RDPARTY_INSTALL_DIR." OFF)
  option(HSLIB_BUILD_SHARED_OPTION "Check if link shared hs library" OFF)
  #if build the shared lib or not?
  if(HSLIB_BUILD_SHARED_OPTION)
    set(BUILD_SHARED_LIBS ON)
    set(LINK_TYPE "shared")
  else()
    set(LINK_TYPE "static")
  endif()
	
	#if set the lib install dir
	if(NOT HSLIB_INSTALL_DIR_OPTION)
		#$ENV{3RDPARTY_INSTALL_DIR} NAME: 3RDPARTY_INSTALL_DIR
		set(HSLIB_DIR $ENV{3RDPARTY_INSTALL_DIR})
			if(NOT HSLIB_DIR)
				message("can't find the 3RDPARTY_INSTALL_DIR path.\nplease set the \"HSLIB_DIR\"")
				set(HSLIB_DIR "" CACHE PATH "3rdparty libs install directory")
			endif()
		else()
		  set(HSLIB_DIR "" CACHE PATH "3rdparty libs install directory")
	endif()

	string(REPLACE  " " "_" GENERATOR_TYPE ${CMAKE_GENERATOR})
	string(REPLACE  "\\" "/" HSLIB_DIR ${HSLIB_DIR})
	if(HSLIB_DIR)
		set(CMAKE_INSTALL_PREFIX ${HSLIB_DIR})
	endif()

endmacro()


#usage: build_lib(lib_name lib_files1 lib_files2...)
macro(build_lib lib_name)
	prjenv()
	
	#config header.
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/config/hs_config.hpp.in"
                   "${CMAKE_CURRENT_BINARY_DIR}/inc/config/hs_config.hpp")
	
	include_directories(inc)
	include_directories("${CMAKE_CURRENT_BINARY_DIR}/inc")
	add_library(${lib_name} ${ARGN})
	
	install_lib(${lib_name})
  
endmacro()


macro(lib_dep target dep_lib_name)
prjenv()

#set(DEP_LIB_INC "${HSLIB_DIR}/${LINK_TYPE}/${GENERATOR_TYPE}/${dep_lib_name}/inc")
#set(DEP_LIB_DIR "F:/programs/lib/3rdparty/static/Visual_Studio_10/lib1/lib/Debug")
include_directories(${DEP_LIB_INC})
target_link_libraries(${target} ${dep_lib_name})

message(${target})					  
#foreach(conf ${CMAKE_CONFIGURATION_TYPES})
#target_link_libraries(${lib_name}

#endforeach()					  


endmacro()

macro(build_exe exe_name)
  set(var_list "${ARGN}")
  set(LIBS "")
  set(SOURCE_FILES "")
  foreach(var ${var_list})
    if(var STREQUAL "DEP")
      set(NEED_DEP ON)
    endif()
    if(NEED_DEP)
      list(APPEND LIBS ${var})
    else()
      list(APPEND SOURCE_FILES ${var})
    endif()
  endforeach()
  list(REMOVE_AT LIBS 0)

  if(NEED_DEP)
    prjenv()
    
    set(DEP_LIB_INC "")
    set(DEP_LIB_DIR "")
    set(DEP_LIB_DLL "")
    foreach(LIB_NAME ${LIBS})
      list(APPEND DEP_LIB_INC "${HSLIB_DIR}/${LINK_TYPE}/${GENERATOR_TYPE}/${LIB_NAME}/inc")
      list(APPEND DEP_LIB_DIR "${HSLIB_DIR}/${LINK_TYPE}/${GENERATOR_TYPE}/${LIB_NAME}/lib")
      list(APPEND DEP_LIB_DLL "${HSLIB_DIR}/${LINK_TYPE}/${GENERATOR_TYPE}/${LIB_NAME}/bin")
      if(HSLIB_BUILD_SHARED_OPTION)
       install(FILE "${DEP_LIB_DLL}/${BUILD_TYPE}/${LIB_NAME}.dll"
              DESTINATION "
      endif()
    endforeach()

    
    include_directories(${DEP_LIB_INC})
    link_directories(${DEP_LIB_DIR})
    include_directories(inc)
    add_executable(${exe_name} ${SOURCE_FILES})
    target_link_libraries(${exe_name} ${LIBS})
  else()  
    include_directories(inc)
    add_executable(${exe_name} ${ARGN})
  endif()

endmacro()

macro(install_lib lib_name)

	#install header files
	install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/inc/config"
			DESTINATION "${CMAKE_INSTALL_PREFIX}/${LINK_TYPE}/${GENERATOR_TYPE}/${lib_name}/inc")
	install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/inc/"
			DESTINATION "${CMAKE_INSTALL_PREFIX}/${LINK_TYPE}/${GENERATOR_TYPE}/${lib_name}/inc")
		
	#install lib dll
	foreach(conf ${CMAKE_CONFIGURATION_TYPES})
	install(TARGETS ${lib_name}
			ARCHIVE DESTINATION "${CMAKE_INSTALL_PREFIX}/${LINK_TYPE}/${GENERATOR_TYPE}/${lib_name}/lib/${conf}"  #libs
			CONFIGURATIONS ${conf} OPTIONAL
			RUNTIME DESTINATION  "${CMAKE_INSTALL_PREFIX}/${LINK_TYPE}/${GENERATOR_TYPE}/${lib_name}/bin/${conf}"  #dlls
			CONFIGURATIONS ${conf} OPTIONAL) 
					
	endforeach()

endmacro()