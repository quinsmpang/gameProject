/****************************************************************************
file:lua_my_auto_manual.h
author:hujinheng
time:2015-5-20
use:lua-binding
 ****************************************************************************/
#ifndef MY_CLASS_AUTO
#define MY_CLASS_AUTO

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

int register_all_my_auto_manual(lua_State* tolua_S);

#endif