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
		#默认:HSLIB_INSTALL_DIR_OPTION为 OFF : 搜索系统环境变量:3RDPARTY_INSTALL_DIR
    #如果不存在3RDPARTY_INSTALL_DIR, 则提示用户设定3RDPARTY_INSTALL_DIR
		set(HSLIB_DIR $ENV{3RDPARTY_INSTALL_DIR})
			if(NOT HSLIB_DIR)
				message("can't find the 3RDPARTY_INSTALL_DIR path.\nplease set the \"HSLIB_DIR\"")
				set(HSLIB_DIR CACHE PATH "3rdparty libs install directory")
			endif()
		else()
      message("The 3RDPARTY_INSTALL_DIR is null, please set a DIR, or use default DIR.")
		  set(HSLIB_DIR CACHE PATH "3rdparty libs install directory")
	endif()
  
	string(REPLACE  " " "_" GENERATOR_TYPE ${CMAKE_GENERATOR})

	if(HSLIB_DIR)
    string(REPLACE  "\\" "/" HSLIB_DIR ${HSLIB_DIR})
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
	
endmacro()

#usage  lib_dep(target_name dep_lib_name)
#       lib_dep(target_name dep_lib_name DEP lib1 lib2)
#说明:一次只能添加一个项目的lib
macro(lib_dep target dep_lib_name)

prjenv()
set(DEP_LIB_INC "${HSLIB_DIR}/${LINK_TYPE}/${GENERATOR_TYPE}/${dep_lib_name}/inc")
set(DEP_LIB_DIR "${HSLIB_DIR}/${LINK_TYPE}/${GENERATOR_TYPE}/${dep_lib_name}/lib/$<CONFIGURATION>")
set(DEP_DLL_DIR "${HSLIB_DIR}/${LINK_TYPE}/${GENERATOR_TYPE}/${dep_lib_name}/bin/$<CONFIGURATION>")

#判断是否有多个libs
foreach(var_lib ${ARGN})
  if(var_lib STREQUAL "DEP")
    set(MULTI_LIB ON)
  endif()
endforeach()

#多个libs
if(MULTI_LIB)
  set(DEP_KEYWORD "${ARGN}")
  list(REMOVE_ITEM DEP_KEYWORD "DEP")
  set(LIBS "")
  set(DLLS "")
  foreach(var_lib1 ${DEP_KEYWORD})
    list(APPEND LIBS ${DEP_LIB_DIR}/${var_lib1}.lib)
    list(APPEND DLLS ${DEP_DLL_DIR}/${var_lib1}.dll)
  endforeach()
else() #单个lib
  set(LIBS ${DEP_LIB_DIR}/${dep_lib_name}.lib)
  set(DLLS ${DEP_DLL_DIR}/${dep_lib_name}.dll)
endif()

include_directories(${DEP_LIB_INC})
target_link_libraries(${target} ${LIBS})

#如果是动态链接,则将dll拷贝到build对应CONFIGURATION目录
if(BUILD_SHARED_LIBS)
  foreach(dll_name ${DLLS})
	add_custom_command(
          TARGET ${target}
          POST_BUILD
          COMMAND ${CMAKE_COMMAND}
          -E copy ${dll_name} "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIGURATION>/")
	endforeach()
endif()

endmacro()

#usage build_exe(exe_name source1 source2...)
macro(build_exe exe_name)
  include_directories(inc)
  add_executable(${exe_name} ${ARGN})
endmacro()

#usage install_lib(lib_name)
macro(install_lib lib_name)
  prjenv()
	#install header files
	install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/inc/config"
			DESTINATION "${CMAKE_INSTALL_PREFIX}/${LINK_TYPE}/${GENERATOR_TYPE}/${PROJECT_NAME}/inc")
	install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/inc/"
			DESTINATION "${CMAKE_INSTALL_PREFIX}/${LINK_TYPE}/${GENERATOR_TYPE}/${PROJECT_NAME}/inc")
		
	#install lib dll
	foreach(conf ${CMAKE_CONFIGURATION_TYPES})
	install(TARGETS ${lib_name}
			ARCHIVE DESTINATION "${CMAKE_INSTALL_PREFIX}/${LINK_TYPE}/${GENERATOR_TYPE}/${PROJECT_NAME}/lib/${conf}"  #libs
			CONFIGURATIONS ${conf} OPTIONAL
			RUNTIME DESTINATION  "${CMAKE_INSTALL_PREFIX}/${LINK_TYPE}/${GENERATOR_TYPE}/${PROJECT_NAME}/bin/${conf}"  #dlls
			CONFIGURATIONS ${conf} OPTIONAL) 
	endforeach()

endmacro()