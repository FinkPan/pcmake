build_lib 用法:

build_lib(lib_name lib_files...)
对与HEADONLY项目加关键字HEADONLY
build_lib(lib_name HEADONLY lib_files...)


install_lib 用法:

install_lib(lib_name)


build_exe 用法:

build_exe(exe_name exe_files...)


lib_dep 用法:

lib_dep(target dep_lib_name DEP lib1 lib2...)
lib_dep(target dep_lib_name)
对与HEADONLY项目加关键字HEADONLY
lib_dep(target dep_lib_name HEADONLY) 
每条lib_dep只能用一个依赖库.

如果设置有系统变量3RDPARTY_INSTALL_DIR
则当HSLIB_INSTALL_DIR_OPTION为OFF时,cmake自动获取该变量地址.