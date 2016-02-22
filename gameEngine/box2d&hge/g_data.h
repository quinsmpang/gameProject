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



//��Ϸ���ڴ�С
const int GAME_WIDTH = 800;						//���
const int GAME_HEIGHT = 600;					//�߶�



//��Ϸ״̬
enum GAME_STATE
{
	GAME_MENU,					//���˵�״̬
	GAME_PLAY1,					//��Ϸ״̬1
	GAME_PLAY2,					//��Ϸ״̬2
	GAME_EXIT					//�˳���Ϸ
};