#include ".\GameApp.h"

//HGEȫ��ָ��
HGE*					g_pHge = NULL;

//��Ϸ��ȫ��ָ��
CGameApp*			g_pGame = NULL;


//����
bool Update()
{

	if( g_pGame )
	{
		return g_pGame->Update();
	}

	return true;

}

//��Ⱦ
bool Render()
{

	if( !g_pHge || !g_pGame )
	{
		return false;
	}

	//��ʼ�滭
	g_pHge->Gfx_BeginScene();

	//����
	g_pHge->Gfx_Clear( ARGB( 255 , 160 , 255 , 255 ) );

	//�滭
	g_pGame->Render();

	//�����滭
	g_pHge->Gfx_EndScene();


	return true;

}



int WINAPI WinMain( HINSTANCE , HINSTANCE , LPSTR , int )
{

	//--------------------����HGE--------------------
	g_pHge = hgeCreate( HGE_VERSION );


	//--------------------����HGE��������--------------------
	//�Ƿ񴰿�����
	g_pHge->System_SetState( HGE_WINDOWED , true );

	//�Ƿ����Ȼ���
	g_pHge->System_SetState( HGE_ZBUFFER,true );

	//�Ƿ�������
	g_pHge->System_SetState( HGE_USESOUND , true );

	//�Ƿ��������
	g_pHge->System_SetState( HGE_HIDEMOUSE , true );

	//����֡����
	g_pHge->System_SetState( HGE_FRAMEFUNC , Update );
	//������Ⱦ����
	g_pHge->System_SetState( HGE_RENDERFUNC , Render );

	//���ô��ڴ�С
	g_pHge->System_SetState( HGE_SCREENWIDTH , GAME_WIDTH );
	g_pHge->System_SetState( HGE_SCREENHEIGHT , GAME_HEIGHT );

	//��ɫλ����32λɫ��
	g_pHge->System_SetState( HGE_SCREENBPP , 32 );

	//�޶����֡����Ϊ30֡/��
	//g_pHge->System_SetState( HGE_FPS , 30 );

	//ͼ��
	g_pHge->System_SetState( HGE_ICON , "" );

	//���ڱ���
	g_pHge->System_SetState( HGE_TITLE , "����DEMO" );



	//--------------------��ʼ���Լ�����HGE--------------------
	if ( g_pHge->System_Initiate() )
	{

		//������Ϸ����
		g_pGame = new CGameApp;

		//�����Ϸ�����ʼ���ɹ�������HGE
		if( g_pGame->Init( g_pHge ) )
		{
			//����HGE
			g_pHge->System_Start();
		}

	}


	//--------------------�رռ��ͷ�HGE--------------------
	//�ر�HGE
	g_pHge->System_Shutdown();

	//�ͷ�HGE
	g_pHge->Release();



	return 0;
}