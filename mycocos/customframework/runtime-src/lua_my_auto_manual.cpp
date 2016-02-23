/****************************************************************************
file:lua_my_auto_manual.cpp
author:hujinheng
time:2015-5-20
use:lua-binding
 ****************************************************************************/
#include "lua_my_auto_manual.h"
#include "tolua_fix.h"
#include "break/ensBreakNode.h"
#include "LuaBasicConversions.h"
#include "classA.h"

//init
int lua_myclass_CbreakSprite_init(lua_State* tolua_S)
{
	int argc = 0;
	ens::CbreakSprite* cobj = nullptr;
	bool ok  = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

	cobj = (ens::CbreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) 
	{
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_myclass_CbreakSprite_init'", nullptr);
		return 0;
	}
#endif


	argc = lua_gettop(tolua_S)-1;
	if (argc == 1) 
	{

		std::string arg0;
		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "CbreakSprite:init"); 

		
		if(!ok)
		{
			tolua_error(tolua_S,"invalid arguments in function 'lua_myclass_CbreakSprite_init'", nullptr);
			return 0;
		}

		cobj->init(arg0);
		return 0;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CbreakSprite:init",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_myclass_CbreakSprite_init'.",&tolua_err);
#endif

	return 0;
}

//new
int lua_myclass_CbreakSprite_constructor(lua_State* tolua_S)
{
	int argc = 0;
	ens::CbreakSprite* cobj = nullptr;
	bool ok  = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{
		if(!ok)
		{
			tolua_error(tolua_S,"invalid arguments in function 'lua_myclass_CbreakSprite_constructor'", nullptr);
			return 0;
		}
		cobj = new ens::CbreakSprite();
		/*cobj->autorelease();
		int ID =  (int)cobj->_ID ;
		int* luaID =  &cobj->_luaID ;
		toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"ens::CbreakSprite");
		*/
		tolua_pushusertype(tolua_S,(void*)cobj,"CbreakSprite");
		tolua_register_gc(tolua_S,lua_gettop(tolua_S));
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CbreakSprite",argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_error(tolua_S,"#ferror in function 'lua_myclass_CbreakSprite_constructor'.",&tolua_err);
#endif

	return 0;
}

int lua_myclass_CbreakSprite_create(lua_State* tolua_S)
{
	int argc = 0;
	ens::CbreakSprite* cobj = nullptr;
	bool ok  = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0)
	{
		/*std::string arg0;
		ok &= luaval_to_std_string(tolua_S, 2,&arg0, "ens::CbreakSprite:create");
		if(!ok)
		{
			tolua_error(tolua_S,"invalid arguments in function 'lua_myclass_CbreakSprite_create'", nullptr);
			return 0;
		}*/

		cobj = new ens::CbreakSprite();
		//if (cobj && cobj->init(arg0))
		//{
			cobj->autorelease();
			object_to_luaval<ens::CbreakSprite>(tolua_S, "CbreakSprite",(ens::CbreakSprite*)cobj);
			return 1;
		//}
#if COCOS2D_DEBUG >= 1
		tolua_error(tolua_S,"#CbreakSprite is nullptr",&tolua_err);
#endif
	}
#if COCOS2D_DEBUG >= 1
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "lua_myclass_CbreakSprite_create",argc, 1);
#endif

	CC_SAFE_DELETE(cobj);

	return 0;
}


int lua_myclass_CbreakSprite_doCrack(lua_State* tolua_S)
{
	int argc = 0;
	ens::CbreakSprite* cobj = nullptr;
	bool ok  = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

	cobj = (ens::CbreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) 
	{
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_myclass_CbreakSprite_doCrack'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	
	if (argc == 1) 
	{
		cocos2d::Vec2 arg0;
		ok &= luaval_to_vec2(tolua_S, 2, &arg0, "CbreakSprite:doCrack");
		
		if (!ok) 
		{ 
			tolua_error(tolua_S,"invalid arguments in function 'lua_myclass_CbreakSprite_doCrack'", nullptr);
			return 0;
		}
		//CCPoint loc_GLSpace = arg0;//CCDirector::sharedDirector()->convertToGL(arg0);
		//luaL_error(tolua_S, "loc_GLSpace ================== %d ==== %d",loc_GLSpace.x,loc_GLSpace.y);
		cobj->doCrack(arg0);
		return 0;
	}

	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CbreakSprite:doCrack",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_myclass_CbreakSprite_doCrack'.",&tolua_err);
#endif

	return 0;
}

int lua_myclass_CbreakSprite_generateDelayTimes(lua_State* tolua_S)
{
	int argc = 0;
	ens::CbreakSprite* cobj = nullptr;
	bool ok  = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

	cobj = (ens::CbreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) 
	{
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_myclass_CbreakSprite_generateDelayTimes'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 1) 
	{

		double arg0;

		ok &= luaval_to_number(tolua_S, 2,&arg0, "CbreakSprite:generateDelayTimes");

		if(!ok)
		{
			tolua_error(tolua_S,"invalid arguments in function 'lua_myclass_CbreakSprite_generateDelayTimes'", nullptr);
			return 0;
		}

		cobj->generateDelayTimes(arg0);
		return 0;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CbreakSprite:generateDelayTimes",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_myclass_CbreakSprite_generateDelayTimes'.",&tolua_err);
#endif

	return 0;
}

int lua_myclass_CbreakSprite_getGridSideLenMax(lua_State* tolua_S)
{
	int argc = 0;
	ens::CbreakSprite* cobj = nullptr;
	bool ok  = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

	cobj = (ens::CbreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) 
	{
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_myclass_CbreakSprite_getGridSideLenMax'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{

		if(!ok)
		{
			tolua_error(tolua_S,"invalid arguments in function 'lua_myclass_CbreakSprite_getGridSideLenMax'", nullptr);
			return 0;
		}

		double ret = cobj->getGridSideLenMax();
		tolua_pushnumber(tolua_S,(lua_Number)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CbreakSprite:getGridSideLenMax",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_myclass_CbreakSprite_getGridSideLenMax'.",&tolua_err);
#endif

	return 0;
}

int lua_myclass_CbreakSprite_setGridSideLenMax(lua_State* tolua_S)
{
	int argc = 0;
	ens::CbreakSprite* cobj = nullptr;
	bool ok  = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

	cobj = (ens::CbreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) 
	{
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_myclass_CbreakSprite_setGridSideLenMax'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 1) 
	{
		double arg0;

		ok &= luaval_to_number(tolua_S, 2,&arg0, "CbreakSprite:setGridSideLenMax");
		if(!ok)
		{
			tolua_error(tolua_S,"invalid arguments in function 'lua_myclass_CbreakSprite_setGridSideLenMax'", nullptr);
			return 0;
		}
		cobj->setGridSideLenMax(arg0);
		return 0;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CbreakSprite:setGridSideLenMax",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_myclass_CbreakSprite_setGridSideLenMax'.",&tolua_err);
#endif

	return 0;
}


int lua_myclass_CbreakSprite_getGridSideLenMin(lua_State* tolua_S)
{
	int argc = 0;
	ens::CbreakSprite* cobj = nullptr;
	bool ok  = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

	cobj = (ens::CbreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) 
	{
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_myclass_CbreakSprite_getGridSideLenMin'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{

		if(!ok)
		{
			tolua_error(tolua_S,"invalid arguments in function 'lua_myclass_CbreakSprite_getGridSideLenMin'", nullptr);
			return 0;
		}

		double ret = cobj->getGridSideLenMin();
		tolua_pushnumber(tolua_S,(lua_Number)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CbreakSprite:getGridSideLenMin",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_myclass_CbreakSprite_getGridSideLenMin'.",&tolua_err);
#endif

	return 0;
}

int lua_myclass_CbreakSprite_setGridSideLenMin(lua_State* tolua_S)
{
	int argc = 0;
	ens::CbreakSprite* cobj = nullptr;
	bool ok  = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

	cobj = (ens::CbreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) 
	{
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_myclass_CbreakSprite_setGridSideLenMin'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 1) 
	{
		double arg0;

		ok &= luaval_to_number(tolua_S, 2,&arg0, "CbreakSprite:setGridSideLenMax");
		if(!ok)
		{
			tolua_error(tolua_S,"invalid arguments in function 'lua_myclass_CbreakSprite_setGridSideLenMin'", nullptr);
			return 0;
		}
		cobj->setGridSideLenMin(arg0);
		return 0;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CbreakSprite:setGridSideLenMin",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_myclass_CbreakSprite_setGridSideLenMin'.",&tolua_err);
#endif

	return 0;
}


int lua_myclass_CbreakSprite_getState(lua_State* tolua_S)
{
	int argc = 0;
	ens::CbreakSprite* cobj = nullptr;
	bool ok  = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

	cobj = (ens::CbreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) 
	{
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_myclass_CbreakSprite_getState'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{

		if(!ok)
		{
			tolua_error(tolua_S,"invalid arguments in function 'lua_myclass_CbreakSprite_getState'", nullptr);
			return 0;
		}

		double ret = cobj->getState();
		tolua_pushnumber(tolua_S,(lua_Number)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CbreakSprite:getState",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_myclass_CbreakSprite_getState'.",&tolua_err);
#endif

	return 0;
}


int lua_myclass_CbreakSprite_reSet(lua_State* tolua_S)
{
	int argc = 0;
	ens::CbreakSprite* cobj = nullptr;
	bool ok  = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

	cobj = (ens::CbreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) 
	{
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_myclass_CbreakSprite_reSet'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S)-1;
	if (argc == 0) 
	{
		
		cobj->reSet();
		return 0;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CbreakSprite:reSet",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_myclass_CbreakSprite_reSet'.",&tolua_err);
#endif

	return 0;
}


int lua_myclass_CbreakSprite_createCfallOffAction(lua_State* tolua_S)
{
	int argc = 0;
	ens::CbreakSprite* cobj = nullptr;
	bool ok  = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

	cobj = (ens::CbreakSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) 
	{
		tolua_error(tolua_S,"invalid 'cobj' in function 'lua_myclass_CbreakSprite_createCfallOffAction'", nullptr);
		return 0;
	}
#endif
	
	argc = lua_gettop(tolua_S)-1;
	if (argc == 1) 
	{
		
		double arg0;
		ok &= luaval_to_number(tolua_S, 2,&arg0, "ens::breakEffect::CfallOffAction");
		if(!ok)
		{
			tolua_error(tolua_S,"invalid arguments in function 'lua_myclass_CbreakSprite_createCfallOffAction'", nullptr);
			return 0;
		}
		ens::breakEffect::CfallOffAction* ret = ens::breakEffect::CfallOffAction::create(arg0);
		object_to_luaval<ens::breakEffect::CfallOffAction>(tolua_S, "cc.ActionInterval",(ens::breakEffect::CfallOffAction*)ret);
		//cobj->runAction(ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "CbreakSprite:createCfallOffAction",argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'lua_myclass_CbreakSprite_createCfallOffAction'.",&tolua_err);
#endif

	return 0;
}



//register
int lua_register_myclass_CbreakSprite(lua_State* tolua_S)
{
	tolua_usertype(tolua_S,"CbreakSprite");
	tolua_cclass(tolua_S,"CbreakSprite","CbreakSprite","cc.Node",nullptr);
	tolua_beginmodule(tolua_S,"CbreakSprite");

		tolua_function(tolua_S,"new",lua_myclass_CbreakSprite_constructor);
		tolua_function(tolua_S,"init",lua_myclass_CbreakSprite_init);
		tolua_function(tolua_S,"create",lua_myclass_CbreakSprite_create);
		tolua_function(tolua_S,"doCrack",lua_myclass_CbreakSprite_doCrack);
		tolua_function(tolua_S,"generateDelayTimes",lua_myclass_CbreakSprite_generateDelayTimes);
		tolua_function(tolua_S,"getGridSideLenMax",lua_myclass_CbreakSprite_getGridSideLenMax);
		tolua_function(tolua_S,"setGridSideLenMax",lua_myclass_CbreakSprite_setGridSideLenMax);
		tolua_function(tolua_S,"getGridSideLenMin",lua_myclass_CbreakSprite_getGridSideLenMin);
		tolua_function(tolua_S,"setGridSideLenMin",lua_myclass_CbreakSprite_setGridSideLenMin);
		tolua_function(tolua_S,"getState",lua_myclass_CbreakSprite_getState);
		tolua_function(tolua_S,"reSet",lua_myclass_CbreakSprite_reSet);
		tolua_function(tolua_S,"createCfallOffAction",lua_myclass_CbreakSprite_createCfallOffAction);

	tolua_endmodule(tolua_S);

	std::string typeName = typeid(ens::CbreakSprite).name();
	g_luaType[typeName] = "CbreakSprite";
	g_typeCast["CbreakSprite"] = "CbreakSprite";

	return 1;
}



TOLUA_API int register_all_my_auto_manual(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	tolua_module(tolua_S,nullptr,0);
	tolua_beginmodule(tolua_S,nullptr);
	
	lua_register_myclass_CbreakSprite(tolua_S);
	//lua_register_myclass(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;

}



/*
//---------------------------------------------myclass---------------------------------------------//
int lua_myclass_new(lua_State* tolua_S)
{
	classA* cobj = new classA();
	tolua_pushusertype(tolua_S, cobj, "classA");
	return 1;
}

int lua_myclass_setTest(lua_State* tolua_S)
{
	classA* pTest = (classA* )tolua_tousertype(tolua_S, 1, 0);
	const char* pData = tolua_tostring(tolua_S, 1, 0);

	if(pData != NULL && pTest != NULL)
	{
		pTest->setTest(pData);
	}

	return 1;
}

int lua_register_myclass(lua_State* tolua_S)
{
	tolua_usertype(tolua_S,"classA");
	tolua_cclass(tolua_S,"classA","classA","",nullptr);
	tolua_beginmodule(tolua_S,"classA");

	tolua_function(tolua_S,"new",lua_myclass_new);
	tolua_function(tolua_S,"setTest",lua_myclass_setTest);

	tolua_endmodule(tolua_S);

	return 1;
}
//-------------------------------------------------------------------------------------------------//
*/