#pragma once
#include "g_data.h"

class CGameApp
{
public:
	CGameApp(void);
	~CGameApp(void);

	//初始化
	bool Init( HGE* pHge );

	//更新
	bool Update();

	//渲染画面、绘画
	bool Render();



private:

	//HGE指针
	HGE*						m_pHge;

	//游戏主状态
	int							m_iGameState;


	GfxFont*					m_pFont;


	//世界矩形结构体指针
	b2AABB*						m_pWorldAABB;

	//世界对象指针
	b2World*					m_pWorld;

	//静态物体定义结构体指针
	b2BodyDef*					m_pGroundBodyDef;	//地面物体定义
	b2BodyDef*					m_pGroundBodyDef1;	//地面物体定义

	//静态物体
	b2Body*						m_pGroundBody;		//地面物体
	b2Body*						m_pGroundBody1;		//地面物体
	b2Body*						m_pGroundBody2;		//地面物体
	b2Body*						m_pGroundBody3;		//地面物体

	//动态物体定义结构体指针
	b2BodyDef*					m_pBulletBodyDef;	//子弹物体定义
	b2BodyDef*					m_pBodyDef1;		//物体定义1
	b2BodyDef*					m_pBodyDef2;		//物体定义2
	b2BodyDef*					m_pBodyDef3;		//物体定义3

	//动态物体
	b2Body*						m_pBulletBody;		//子弹物体
	b2Body*						m_pBody1;			//物体1
	b2Body*						m_pBody2;			//物体2
	b2Body*						m_pBody3;			//物体3

	//物体形状结构体指针
	b2PolygonDef*				m_pGroundShapeDef;	//地面物体形状
	b2PolygonDef*				m_pBulletShapeDef;	//子弹物体形状
	b2CircleDef*				m_pBulletShapeDef1;	//子弹物体形状
	b2PolygonDef*				m_pBodyShapeDef1;	//物体形状1
	b2PolygonDef*				m_pBodyShapeDef2;	//物体形状2
	b2CircleDef*				m_pBodyShapeDef3;	//物体形状3

	//精灵
	hgeSprite*					m_pMouseSprite;		//鼠标精灵
	hgeSprite*					m_pGroundSprite;	//地面物体精灵
	hgeSprite*					m_pBulletSprite;	//子弹物体精灵
	hgeSprite*					m_pBodySprite1;		//物体精灵1
	hgeSprite*					m_pBodySprite2;		//物体精灵2
	hgeSprite*					m_pBodySprite3;		//物体精灵3

	//纹理
	HTEXTURE					m_MouseTx;			//鼠标纹理
	HTEXTURE					m_GroundTx;			//地面物体纹理
	HTEXTURE					m_BulletTx;			//子弹物体纹理
	HTEXTURE					m_BodyTx1;			//物体纹理1
	HTEXTURE					m_BodyTx2;			//物体纹理2
	HTEXTURE					m_BodyTx3;			//物体纹理3


	//Box2d帧时间
	float						m_fTimeStep;
	//Box2d迭代次数
	int							m_iTerations;

	hgeVector					m_MousePos;

	hgeVector					m_FootballPos;

	bool						m_bIsMouse;
};
