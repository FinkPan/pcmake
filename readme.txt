build_lib �÷�:

build_lib(lib_name lib_files...)
����HEADONLY��Ŀ�ӹؼ���HEADONLY
build_lib(lib_name HEADONLY lib_files...)
����3RDPARTY��Ŀ�ӹؼ���3RDPARTY
build_lib(lib_name 3RDPARTY lib_files...)

install_lib �÷�:

install_lib(lib_name)


build_exe �÷�:

build_exe(exe_name exe_files...)


lib_dep �÷�:

lib_dep(target dep_lib_name DEP lib1 lib2...)
lib_dep(target dep_lib_name)
����HEADONLY��Ŀ�ӹؼ���HEADONLY
lib_dep(target dep_lib_name HEADONLY) 
ÿ��lib_depֻ����һ��������.

���������ϵͳ����3RDPARTY_INSTALL_DIR
��HSLIB_INSTALL_DIR_OPTIONΪOFFʱ,cmake�Զ���ȡ�ñ�����ַ.