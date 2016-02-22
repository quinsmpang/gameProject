#pragma once

#include <Windows.h>
#include ".\include\\hge.h"
#include ".\include\\hgesprite.h"
#include ".\include\\hgevector.h"
#include ".\GfxFont.h"

#include ".\Box2d\\Include\\Box2D.h"

#pragma comment ( lib , "lib\\hge.lib" )
#pragma comment ( lib , "lib\\hgehelp.lib" )
#pragma comment ( lib , "Library\\box2d_d.lib" )

#pragma comment ( lib , "winmm.lib" )

using namespace std;


#ifndef SAFE_DELETE
#define SAFE_DELETE( p ) { if( p ) { delete( p ); ( p ) = NULL; } }
#endif



//游戏窗口大小
const int GAME_WIDTH = 800;						//宽度
const int GAME_HEIGHT = 600;					//高度



//游戏状态
enum GAME_STATE
{
	GAME_MENU,					//主菜单状态
	GAME_PLAY1,					//游戏状态1
	GAME_PLAY2,					//游戏状态2
	GAME_EXIT					//退出游戏
};