extern "C"{
#include "lua.h"
#include "lauxlib.h"
}
#include "../../runtime-src/Classes/lua_my_auto_manual.h"


int lua_register_my_class(lua_State *L)
{

	lua_getglobal(L, "_G");
	if (lua_istable(L,-1))//stack:...,_G,
	{
		register_all_my_auto_manual(L);
	}
	lua_pop(L, 1);

	return 1;
}
