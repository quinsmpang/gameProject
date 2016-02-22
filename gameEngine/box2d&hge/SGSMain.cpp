#include ".\GameApp.h"

//HGE全局指针
HGE*					g_pHge = NULL;

//游戏类全局指针
CGameApp*			g_pGame = NULL;


//更新
bool Update()
{

	if( g_pGame )
	{
		return g_pGame->Update();
	}

	return true;

}

//渲染
bool Render()
{

	if( !g_pHge || !g_pGame )
	{
		return false;
	}

	//开始绘画
	g_pHge->Gfx_BeginScene();

	//清屏
	g_pHge->Gfx_Clear( ARGB( 255 , 160 , 255 , 255 ) );

	//绘画
	g_pGame->Render();

	//结束绘画
	g_pHge->Gfx_EndScene();


	return true;

}



int WINAPI WinMain( HINSTANCE , HINSTANCE , LPSTR , int )
{

	//--------------------创建HGE--------------------
	g_pHge = hgeCreate( HGE_VERSION );


	//--------------------配置HGE基本属性--------------------
	//是否窗口运行
	g_pHge->System_SetState( HGE_WINDOWED , true );

	//是否打开深度缓冲
	g_pHge->System_SetState( HGE_ZBUFFER,true );

	//是否开启声音
	g_pHge->System_SetState( HGE_USESOUND , true );

	//是否隐藏鼠标
	g_pHge->System_SetState( HGE_HIDEMOUSE , true );

	//设置帧函数
	g_pHge->System_SetState( HGE_FRAMEFUNC , Update );
	//设置渲染函数
	g_pHge->System_SetState( HGE_RENDERFUNC , Render );

	//设置窗口大小
	g_pHge->System_SetState( HGE_SCREENWIDTH , GAME_WIDTH );
	g_pHge->System_SetState( HGE_SCREENHEIGHT , GAME_HEIGHT );

	//颜色位数，32位色彩
	g_pHge->System_SetState( HGE_SCREENBPP , 32 );

	//限定最高帧速率为30帧/秒
	//g_pHge->System_SetState( HGE_FPS , 30 );

	//图标
	g_pHge->System_SetState( HGE_ICON , "" );

	//窗口标题
	g_pHge->System_SetState( HGE_TITLE , "物理DEMO" );



	//--------------------初始化以及启动HGE--------------------
	if ( g_pHge->System_Initiate() )
	{

		//创建游戏主类
		g_pGame = new CGameApp;

		//如果游戏主类初始化成功就启动HGE
		if( g_pGame->Init( g_pHge ) )
		{
			//启动HGE
			g_pHge->System_Start();
		}

	}


	//--------------------关闭及释放HGE--------------------
	//关闭HGE
	g_pHge->System_Shutdown();

	//释放HGE
	g_pHge->Release();



	return 0;
}