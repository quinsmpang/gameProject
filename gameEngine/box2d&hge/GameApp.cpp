#include "GameApp.h"

CGameApp::CGameApp(void)
{

	m_pHge = NULL;

	m_iGameState = GAME_MENU;

	m_pFont = NULL;

	m_pWorldAABB = NULL;
	m_pWorld = NULL;

	m_pGroundBodyDef = NULL;
	m_pGroundBody = NULL;
	m_pGroundShapeDef = NULL;
	m_pGroundSprite = NULL;
	m_GroundTx = 0;

	m_pBulletBodyDef = NULL;
	m_pBulletBody = NULL;
	m_pBulletShapeDef = NULL;
	m_pBulletSprite = NULL;
	m_BulletTx = 0;

	m_pBodyDef1 = NULL;
	m_pBody1 = NULL;
	m_pBodyShapeDef1 = NULL;
	m_pBodySprite1 = NULL;
	m_BodyTx1 = 0;

	m_pBodyDef2 = NULL;
	m_pBody2 = NULL;
	m_pBodyShapeDef2 = NULL;
	m_pBodySprite2 = NULL;
	m_BodyTx2 = 0;

	m_pBodyDef3 = NULL;
	m_pBody3 = NULL;
	m_pBodyShapeDef3 = NULL;
	m_pBodySprite3 = NULL;
	m_BodyTx3 = 0;

	m_fTimeStep = 1.0f / 60.0f;
	m_iTerations = 10;

	m_FootballPos.x = m_FootballPos.y = m_MousePos.x = m_MousePos.y = 0.0f;
	m_bIsMouse = false;

}

CGameApp::~CGameApp(void)
{
	SAFE_DELETE( m_pFont );

	SAFE_DELETE( m_pWorldAABB );
	SAFE_DELETE( m_pWorld );

	SAFE_DELETE( m_pGroundBodyDef );
	SAFE_DELETE( m_pGroundShapeDef );
	SAFE_DELETE( m_pGroundSprite );

	SAFE_DELETE( m_pBodyDef1 );
	SAFE_DELETE( m_pBodyShapeDef1 );
	SAFE_DELETE( m_pBodySprite1 );
}


//初始化
bool CGameApp::Init( HGE* pHge )
{

	m_pHge = pHge;

	m_pFont = new GfxFont( "宋体" , 30 , TRUE );



	//==============================建  立  精  灵==============================

	//--------------------建立鼠标精灵--------------------
	m_MouseTx = m_pHge->Texture_Load( "cur.png" );
	float fw = m_pHge->Texture_GetWidth( m_MouseTx , true );
	float fh = m_pHge->Texture_GetHeight( m_MouseTx , true );
	//建立精灵
	m_pMouseSprite = new hgeSprite( m_MouseTx ,0.0f , 0.0f , fw , fh );
	//设置精灵中心
	m_pMouseSprite->SetHotSpot(  fw * 0.5f , fh * 0.5f );



	//--------------------建立地面精灵--------------------
	//建立精灵纹理
	m_GroundTx = m_pHge->Texture_Load( "brick.png" );
	fw = m_pHge->Texture_GetWidth( m_GroundTx , true );
	fh = m_pHge->Texture_GetHeight( m_GroundTx , true );
	//建立精灵
	m_pGroundSprite = new hgeSprite( m_GroundTx ,0.0f , 0.0f , fw , fh );
	//设置精灵中心
	m_pGroundSprite->SetHotSpot(  fw * 0.5f , fh * 0.5f );



	//--------------------建立子弹精灵--------------------
	//建立精灵纹理
	m_BulletTx = m_pHge->Texture_Load( "bullet.png" );
	fw = m_pHge->Texture_GetWidth( m_BulletTx , true );
	fh = m_pHge->Texture_GetHeight( m_BulletTx , true );
	//建立精灵
	m_pBulletSprite = new hgeSprite( m_BulletTx ,0.0f , 0.0f , fw , fh );
	//设置精灵中心
	m_pBulletSprite->SetHotSpot(  fw * 0.5f , fh * 0.5f );



	//--------------------建立物体精灵1--------------------
	//建立精灵纹理
	m_BodyTx1 = m_pHge->Texture_Load( "box.png" );
	fw = m_pHge->Texture_GetWidth( m_BodyTx1 , true );
	fh = m_pHge->Texture_GetHeight( m_BodyTx1 , true );
	//建立精灵
	m_pBodySprite1 = new hgeSprite( m_BodyTx1 ,0.0f , 0.0f , fw , fh );
	//设置精灵中心
	m_pBodySprite1->SetHotSpot(  fw * 0.5f , fh * 0.5f );



	//--------------------建立物体精灵2--------------------
	//建立精灵纹理
	m_BodyTx2 = m_pHge->Texture_Load( "box.png" );
	fw = m_pHge->Texture_GetWidth( m_BodyTx2 , true );
	fh = m_pHge->Texture_GetHeight( m_BodyTx2 , true );
	//建立精灵
	m_pBodySprite2 = new hgeSprite( m_BodyTx2 ,0.0f , 0.0f , fw , fh );
	//设置精灵中心
	m_pBodySprite2->SetHotSpot(  fw * 0.5f , fh * 0.5f );



	//--------------------建立物体精灵3--------------------
	//建立精灵纹理
	m_BodyTx3 = m_pHge->Texture_Load( "football.png" );
	fw = m_pHge->Texture_GetWidth( m_BodyTx3 , true );
	fh = m_pHge->Texture_GetHeight( m_BodyTx3 , true );
	//建立精灵
	m_pBodySprite3 = new hgeSprite( m_BodyTx3 ,0.0f , 0.0f , fw , fh );
	//设置精灵中心
	m_pBodySprite3->SetHotSpot(  fw * 0.5f , fh * 0.5f );



	//==============================建  立  世  界==============================

	//--------------------建立世界对象--------------------
	//创建世界矩形信息结构体
	m_pWorldAABB = new b2AABB;
	//设置世界矩形
	m_pWorldAABB->lowerBound.Set( -100.0f , -100.0f );
	m_pWorldAABB->upperBound.Set( 100.0f , 100.0f );

	//定义重力向量（方向以及重力大小）
	b2Vec2 Gravity( 0.0f , 1.0f );

	//是否休眠
	bool IsSleep = true;

	//建立世界对象
	m_pWorld = new b2World( *m_pWorldAABB , Gravity , IsSleep );



	//==============================建  立  物  体==============================

	//--------------------建立地面--------------------
	//建立一个静态物体的定义(结构体)
	m_pGroundBodyDef = new b2BodyDef;

	//设置物体初始位置
	m_pGroundBodyDef->position.Set( 40.0f , 58.4f );
	//设置物体初始角度
	m_pGroundBodyDef->angle = 0.0f;

	//根据物体定义创建物体
	m_pGroundBody = m_pWorld->CreateBody( m_pGroundBodyDef );

	//建立一个物体的形状
	m_pGroundShapeDef = new b2PolygonDef;

	//设定物体形状的中心点
	fw = m_pHge->Texture_GetWidth( m_GroundTx , true ) * 0.1f * 0.5f;
	fh = m_pHge->Texture_GetHeight( m_GroundTx , true ) * 0.1f * 0.5f;
	m_pGroundShapeDef->SetAsBox( fw , fh );

	//根据物体形状信息结构体创建地面形状，以完成物体
	m_pGroundBody->CreateShape( m_pGroundShapeDef );
	m_pGroundBody->CreateShape( m_pGroundShapeDef );



	//--------------------建立地面1--------------------
	//建立一个静态物体的定义(结构体)
	m_pGroundBodyDef1 = new b2BodyDef;

	//设置物体初始位置
	m_pGroundBodyDef1->position.Set( 78.4f , 16.8f );
	//设置物体初始角度
	m_pGroundBodyDef1->angle = b2_pi * 0.5f;

	//根据物体定义创建物体
	m_pGroundBody1 = m_pWorld->CreateBody( m_pGroundBodyDef1 );

	//根据物体形状信息结构体创建地面形状，以完成物体
	m_pGroundBody1->CreateShape( m_pGroundShapeDef );



	//--------------------建立地面2--------------------
	//根据物体定义创建物体
	m_pGroundBodyDef1->position.Set( 1.6f , 16.8f );
	m_pGroundBody2 = m_pWorld->CreateBody( m_pGroundBodyDef1 );

	//根据物体形状信息结构体创建地面形状，以完成物体
	m_pGroundBody2->CreateShape( m_pGroundShapeDef );



	//--------------------建立地面3--------------------
	//根据物体定义创建物体
	m_pGroundBodyDef->position.Set( 40.0f , 1.6f );
	m_pGroundBody3 = m_pWorld->CreateBody( m_pGroundBodyDef );

	//根据物体形状信息结构体创建地面形状，以完成物体
	m_pGroundBody3->CreateShape( m_pGroundShapeDef );



	//--------------------建立子弹--------------------
	//建立一个动态物体的定义(结构体)
	m_pBulletBodyDef = new b2BodyDef;

	//设置物体初始位置
	m_pBulletBodyDef->position.Set( 30.0f , 7.0f );
	//设置物体初始角度
	m_pBulletBodyDef->angle = 0.0f;
	m_pBulletBodyDef->linearDamping = 0.05f;

	//根据物体定义创建物体
	m_pBulletBody = m_pWorld->CreateBody( m_pBulletBodyDef );

	//建立子弹后部的矩形形状
	m_pBulletShapeDef = new b2PolygonDef;

	//设定形状的中心点（系统根据X、Y生成特定大小的矩形）
	fw = 16.0f * 0.1f * 0.5f;
	fh = m_pHge->Texture_GetHeight( m_BulletTx , true ) * 0.1f * 0.5f;
	b2Vec2 box1( -2.4f , 0 );
	m_pBulletShapeDef->SetAsBox( fw , fh , box1 , 0.0f );

	//设置子弹的密度
	m_pBulletShapeDef->density = 0.5f;

	//设置子弹的摩擦力
	m_pBulletShapeDef->friction = 0.1f;

	//设置子弹的弹性
	m_pBulletShapeDef->restitution = 0.5f;

	//根据物体形状信息结构体创建物体形状，以完成物体
	m_pBulletBody->CreateShape( m_pBulletShapeDef );

	//建立子弹前部的圆形形状
	m_pBulletShapeDef1 = new b2CircleDef;

	//设定物体形状的圆心
	fw = 60.0f * 0.1f * 0.5f;
	m_pBulletShapeDef1->radius = fw;

	//设置子弹的密度
	m_pBulletShapeDef1->density = 0.5f;

	//设置子弹的摩擦力
	m_pBulletShapeDef1->friction = 0.1f;

	//设置子弹的弹性
	m_pBulletShapeDef1->restitution = 0.5f;
	b2Vec2 v(0.1f,0.0f);
	m_pBulletShapeDef1->localPosition = v;

	//根据物体形状信息结构体创建物体形状，以完成物体
	m_pBulletBody->CreateShape( m_pBulletShapeDef1 );

	//以物体形状计算
	m_pBulletBody->SetMassFromShapes();



	//--------------------建立物体1--------------------
	//建立一个动态物体的定义(结构体)
	m_pBodyDef1 = new b2BodyDef;

	//设置物体初始位置
	m_pBodyDef1->position.Set( 60.0f , 44.4f );
	//设置物体初始角度
	m_pBodyDef1->angle = 0.0f;

	//根据物体定义创建物体
	m_pBody1 = m_pWorld->CreateBody( m_pBodyDef1 );

	//建立一个物体的形状
	m_pBodyShapeDef1 = new b2PolygonDef;

	//设定物体形状的中心点
	fw = m_pHge->Texture_GetWidth( m_BodyTx1 , true ) * 0.1f * 0.5f;
	fh = m_pHge->Texture_GetHeight( m_BodyTx1 , true ) * 0.1f * 0.5f;
	m_pBodyShapeDef1->SetAsBox( fw , fh );

	//设置子弹的密度
	m_pBodyShapeDef1->density = 1.0f;

	//设置子弹的摩擦力
	m_pBodyShapeDef1->friction = 0.2f;

	//设置子弹的弹性
	m_pBodyShapeDef1->restitution = 0.3f;

	//根据物体形状信息结构体创建物体形状，以完成物体
	m_pBody1->CreateShape( m_pBodyShapeDef1 );

	//以物体形状计算
	m_pBody1->SetMassFromShapes();



	//--------------------建立物体2--------------------
	//建立一个动态物体的定义(结构体)
	m_pBodyDef2 = new b2BodyDef;

	//设置物体初始位置
	m_pBodyDef2->position.Set( 60.0f , 36.4f );
	//设置物体初始角度
	m_pBodyDef2->angle = 0.0f;

	//根据物体定义创建物体
	m_pBody2 = m_pWorld->CreateBody( m_pBodyDef2 );

	//建立一个物体的形状
	m_pBodyShapeDef2 = new b2PolygonDef;

	//设定物体形状的中心点
	fw = m_pHge->Texture_GetWidth( m_BodyTx2 , true ) * 0.1f * 0.5f;
	fh = m_pHge->Texture_GetHeight( m_BodyTx2 , true ) * 0.1f * 0.5f;
	m_pBodyShapeDef2->SetAsBox( fw , fh );

	//设置子弹的密度
	m_pBodyShapeDef2->density = 1.0f;

	//设置子弹的摩擦力
	m_pBodyShapeDef2->friction = 0.2f;

	//设置子弹的弹性
	m_pBodyShapeDef2->restitution = 0.3f;

	//根据物体形状信息结构体创建物体形状，以完成物体
	m_pBody2->CreateShape( m_pBodyShapeDef2 );

	//以物体形状计算
	m_pBody2->SetMassFromShapes();



	//--------------------建立物体3--------------------
	//建立一个动态物体的定义(结构体)
	m_pBodyDef3 = new b2BodyDef;

	//设置物体初始位置
	m_pBodyDef3->position.Set( 40.0f , 10.4f );
	//设置物体初始角度
	m_pBodyDef3->angle = 0.0f;
	m_pBodyDef3->linearDamping = 0.08f;

	//根据物体定义创建物体
	m_pBody3 = m_pWorld->CreateBody( m_pBodyDef3 );

	//建立一个物体的形状
	m_pBodyShapeDef3 = new b2CircleDef;

	//设定物体形状的中心点
	fw = m_pHge->Texture_GetWidth( m_BodyTx3 , true ) * 0.1f * 0.5f;
	m_pBodyShapeDef3->radius = fw;

	//设置子弹的密度
	m_pBodyShapeDef3->density = 0.01f;

	//设置子弹的摩擦力
	m_pBodyShapeDef3->friction = 0.5f;

	//设置子弹的弹性
	m_pBodyShapeDef3->restitution = 1.0f;

	//根据物体形状信息结构体创建物体形状，以完成物体
	m_pBody3->CreateShape( m_pBodyShapeDef3 );

	//以物体形状计算
	m_pBody3->SetMassFromShapes();


	return true;

}


//更新
bool CGameApp::Update()
{

	switch ( m_iGameState )
	{

	case GAME_MENU:
		{

			if ( m_pHge->Input_GetKeyState( HGEK_1 ) )
			{
				m_iGameState = GAME_PLAY1;

				//重置子弹位置
				b2Vec2 pos( 30.0f , 7.0f );
				m_pBulletBody->SetXForm( pos , 0.0f );
				b2Vec2 power( 0.0f , 0.0f );
				m_pBulletBody->SetLinearVelocity( power );
				m_pBulletBody->SetAngularVelocity( 0.0f );

				//重置物体1位置
				b2Vec2 pos1( 60.0f , 44.4f );
				m_pBody1->SetXForm( pos1 , 0.0f );
				b2Vec2 power1( 0.0f , 0.0f );
				m_pBody1->SetLinearVelocity( power1 );
				m_pBody1->SetAngularVelocity( 0.0f );

				//重置物体2位置
				b2Vec2 pos2( 60.0f , 36.4f );
				m_pBody2->SetXForm( pos2 , 0.0f );
				b2Vec2 power2( 0.0f , 0.0f );
				m_pBody2->SetLinearVelocity( power2 );
				m_pBody2->SetAngularVelocity( 0.0f );

				//重置物体3位置
				b2Vec2 pos3( 40.0f , 11.5f );
				m_pBody3->SetXForm( pos3 , 0.0f );
				b2Vec2 power3( 0.0f , 0.0f );
				m_pBody3->SetLinearVelocity( power3 );
				m_pBody3->SetAngularVelocity( 0.0f );

			}
			else if( m_pHge->Input_GetKeyState( HGEK_2 ) )
			{
				m_iGameState = GAME_PLAY2;

				//重置子弹位置
				m_pBulletBody->PutToSleep();
				b2Vec2 pos( 0.0f , -10.0f );
				m_pBulletBody->SetXForm( pos , 0.0f );
				b2Vec2 power( 0.0f , 0.0f );
				m_pBulletBody->SetLinearVelocity( power );
				m_pBulletBody->SetAngularVelocity( 0.0f );

				//重置物体1位置
				b2Vec2 pos1( 60.0f , 44.4f );
				m_pBody1->SetXForm( pos1 , 0.0f );
				b2Vec2 power1( 0.0f , 0.0f );
				m_pBody1->SetLinearVelocity( power1 );
				m_pBody1->SetAngularVelocity( 0.0f );

				//重置物体2位置
				b2Vec2 pos2( 60.0f , 36.4f );
				m_pBody2->SetXForm( pos2 , 0.0f );
				b2Vec2 power2( 0.0f , 0.0f );
				m_pBody2->SetLinearVelocity( power2 );
				m_pBody2->SetAngularVelocity( 0.0f );

				//重置物体3位置
				b2Vec2 pos3( 40.0f , 11.5f );
				m_pBody3->SetXForm( pos3 , 0.0f );
				b2Vec2 power3( 0.0f , 0.0f );
				m_pBody3->SetLinearVelocity( power3 );
				m_pBody3->SetAngularVelocity( 0.0f );
			}

		}
		break;

	case GAME_PLAY1:
		{

			m_pWorld->Step( m_fTimeStep , m_iTerations );

			if( m_pHge->Input_GetKeyState( HGEK_SPACE ) )
			{

				//重置子弹位置
				m_pBulletBody->PutToSleep();
				b2Vec2 pos( 5.0f , 30.0f );
				m_pBulletBody->SetXForm( pos , 0.0f );
				b2Vec2 power( 0.0f , 0.0f );
				m_pBulletBody->SetLinearVelocity( power );
				m_pBulletBody->SetAngularVelocity( 0.0f );

				//重置物体1位置
				b2Vec2 pos1( 60.0f , 44.4f );
				m_pBody1->SetXForm( pos1 , 0.0f );
				b2Vec2 power1( 0.0f , 0.0f );
				m_pBody1->SetLinearVelocity( power1 );
				m_pBody1->SetAngularVelocity( 0.0f );

				//重置物体2位置
				b2Vec2 pos2( 60.0f , 36.4f );
				m_pBody2->SetXForm( pos2 , 0.0f );
				b2Vec2 power2( 0.0f , 0.0f );
				m_pBody2->SetLinearVelocity( power2 );
				m_pBody2->SetAngularVelocity( 0.0f );

				//重置物体3位置
				b2Vec2 pos3( 40.0f , 11.5f );
				m_pBody3->SetXForm( pos3 , 0.0f );
				b2Vec2 power3( 0.0f , 0.0f );
				m_pBody3->SetLinearVelocity( power3 );
				m_pBody3->SetAngularVelocity( 0.0f );

			}
			else if( m_pHge->Input_GetKeyState( HGEK_P ) )
			{

				m_pBulletBody->WakeUp();
				b2Vec2 pos( 5.0f , 30.0f );
				m_pBulletBody->SetXForm( pos , 0.0f );
				b2Vec2 power( 5.0f , -3.0f );
				m_pBulletBody->SetLinearVelocity( power );
				m_pBulletBody->SetAngularVelocity( 0.0f );

			}

			if( m_pHge->Input_GetKeyState( HGEK_ESCAPE ) )
			{
				m_iGameState = GAME_MENU;
			}

		}
		break;

	case GAME_PLAY2:
		{

			m_pHge->Input_GetMousePos( &m_MousePos.x , &m_MousePos.y );

			RECT Football = { m_pBody3->GetPosition().x * 10 - 32 , m_pBody3->GetPosition().y * 10 - 32 , 
							  m_pBody3->GetPosition().x * 10 + 32 , m_pBody3->GetPosition().y * 10 + 32 };

			POINT pos = { m_MousePos.x , m_MousePos.y };

			if( m_MousePos.x <= 32.0f )
			{
				m_MousePos.x = 32.0f;
			}

			if( m_MousePos.x >= 768.0f )
			{
				m_MousePos.x = 768.0f;
			}

			if( m_MousePos.y <= 32.0f )
			{
				m_MousePos.y = 32.0f;
			}

			if( m_MousePos.y >= 568.0f )
			{
				m_MousePos.y = 568.0f;
			}

			if( ::PtInRect( &Football , pos ) && m_pHge->Input_GetKeyState( HGEK_LBUTTON ) )
			{

				b2Vec2 pos( m_MousePos.x * 0.1f , m_MousePos.y * 0.1f );
				m_pBody3->SetXForm( pos , 0.0f );
				m_bIsMouse = true;

			}



			m_pWorld->Step( m_fTimeStep , m_iTerations );

			if( m_pHge->Input_GetKeyState( HGEK_SPACE ) )
			{

				//重置物体1位置
				b2Vec2 pos1( 60.0f , 44.4f );
				m_pBody1->SetXForm( pos1 , 0.0f );
				b2Vec2 power1( 0.0f , 0.0f );
				m_pBody1->SetLinearVelocity( power1 );
				m_pBody1->SetAngularVelocity( 0.0f );

				//重置物体2位置
				b2Vec2 pos2( 60.0f , 36.4f );
				m_pBody2->SetXForm( pos2 , 0.0f );
				b2Vec2 power2( 0.0f , 0.0f );
				m_pBody2->SetLinearVelocity( power2 );
				m_pBody2->SetAngularVelocity( 0.0f );

				//重置物体3位置
				b2Vec2 pos3( 40.0f , 11.5f );
				m_pBody3->SetXForm( pos3 , 0.0f );
				b2Vec2 power3( 0.0f , 0.0f );
				m_pBody3->SetLinearVelocity( power3 );
				m_pBody3->SetAngularVelocity( 0.0f );

			}
			else if( m_pHge->Input_GetKeyState( HGEK_P ) )
			{

				m_pBody3->WakeUp();
				b2Vec2 pos( 5.0f , 30.0f );
				m_pBody3->SetXForm( pos , 0.0f );
				b2Vec2 power( 5.0f , -3.0f );
				m_pBody3->SetLinearVelocity( power );
				m_pBody3->SetAngularVelocity( 0.0f );

			}

			if( m_pHge->Input_GetKeyState( HGEK_ESCAPE ) )
			{
				m_iGameState = GAME_MENU;
			}

		}
		break;

	}

	return false;

}


//渲染画面、绘画
bool CGameApp::Render()
{

	switch ( m_iGameState )
	{

	case GAME_MENU:
		{

			m_pFont->SetColor( ARGB( 255 , 255 , 0 , 0 ) );
			m_pFont->Render( 230.0f , 200.0f , L"Box2d物理引擎测试小游戏" );
			m_pFont->Render( 310.0f , 285.0f , L"1、多形状碰撞" );
			m_pFont->Render( 310.0f , 370.0f , L"2、MiniGame" );

		}
		break;

	case GAME_PLAY1:
		{

			m_pGroundSprite->RenderEx( m_pGroundBody1->GetPosition().x * 10 , m_pGroundBody1->GetPosition().y * 10 , m_pGroundBody1->GetAngle() );

			m_pGroundSprite->RenderEx( m_pGroundBody2->GetPosition().x * 10 , m_pGroundBody2->GetPosition().y * 10 , m_pGroundBody2->GetAngle() );

			m_pGroundSprite->RenderEx( m_pGroundBody3->GetPosition().x * 10 , m_pGroundBody3->GetPosition().y * 10 , m_pGroundBody3->GetAngle() );

			m_pGroundSprite->RenderEx( m_pGroundBody->GetPosition().x * 10 , m_pGroundBody->GetPosition().y * 10 , m_pGroundBody->GetAngle() );

			m_pBulletSprite->RenderEx( m_pBulletBody->GetPosition().x * 10 , m_pBulletBody->GetPosition().y * 10 , m_pBulletBody->GetAngle() );

			m_pBodySprite1->RenderEx( m_pBody1->GetPosition().x * 10 , m_pBody1->GetPosition().y * 10 , m_pBody1->GetAngle() );

			m_pBodySprite2->RenderEx( m_pBody2->GetPosition().x * 10 , m_pBody2->GetPosition().y * 10 , m_pBody2->GetAngle() );

			m_pBodySprite3->RenderEx( m_pBody3->GetPosition().x * 10 , m_pBody3->GetPosition().y * 10 , m_pBody3->GetAngle() );

			m_pFont->SetColor( 0xff000000 );
			m_pFont->Print( 35.0f , 35.0f , "帧速度：%d／秒" , m_pHge->Timer_GetFPS() );

		}
		break;

	case GAME_PLAY2:
		{

			m_pGroundSprite->RenderEx( m_pGroundBody1->GetPosition().x * 10 , m_pGroundBody1->GetPosition().y * 10 , m_pGroundBody1->GetAngle() );

			m_pGroundSprite->RenderEx( m_pGroundBody2->GetPosition().x * 10 , m_pGroundBody2->GetPosition().y * 10 , m_pGroundBody2->GetAngle() );

			m_pGroundSprite->RenderEx( m_pGroundBody3->GetPosition().x * 10 , m_pGroundBody3->GetPosition().y * 10 , m_pGroundBody3->GetAngle() );

			m_pGroundSprite->RenderEx( m_pGroundBody->GetPosition().x * 10 , m_pGroundBody->GetPosition().y * 10 , m_pGroundBody->GetAngle() );

			m_pBulletSprite->RenderEx( m_pBulletBody->GetPosition().x * 10 , m_pBulletBody->GetPosition().y * 10 , m_pBulletBody->GetAngle() );

			m_pBodySprite1->RenderEx( m_pBody1->GetPosition().x * 10 , m_pBody1->GetPosition().y * 10 , m_pBody1->GetAngle() );

			m_pBodySprite2->RenderEx( m_pBody2->GetPosition().x * 10 , m_pBody2->GetPosition().y * 10 , m_pBody2->GetAngle() );

			m_pBodySprite3->RenderEx( m_pBody3->GetPosition().x * 10 , m_pBody3->GetPosition().y * 10 , m_pBody3->GetAngle() );

			m_pMouseSprite->Render( m_MousePos.x , m_MousePos.y );

			m_pFont->SetColor( 0xff000000 );
			m_pFont->Print( 35.0f , 35.0f , "帧速度：%d／秒" , m_pHge->Timer_GetFPS() );
			m_pFont->Print( 35.0f , 65.0f , "鼠标坐标：X：%f  Y：%f" , m_MousePos.x , m_MousePos.y );
			m_pFont->Print( 35.0f , 95.0f , "球的坐标：X：%f  Y：%f" , m_pBody3->GetPosition().x * 10 , m_pBody3->GetPosition().y * 10 );

		}
		break;

	}
	return false;

}