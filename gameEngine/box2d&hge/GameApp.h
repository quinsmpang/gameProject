#pragma once
#include "g_data.h"

class CGameApp
{
public:
	CGameApp(void);
	~CGameApp(void);

	//��ʼ��
	bool Init( HGE* pHge );

	//����
	bool Update();

	//��Ⱦ���桢�滭
	bool Render();



private:

	//HGEָ��
	HGE*						m_pHge;

	//��Ϸ��״̬
	int							m_iGameState;


	GfxFont*					m_pFont;


	//������νṹ��ָ��
	b2AABB*						m_pWorldAABB;

	//�������ָ��
	b2World*					m_pWorld;

	//��̬���嶨��ṹ��ָ��
	b2BodyDef*					m_pGroundBodyDef;	//�������嶨��
	b2BodyDef*					m_pGroundBodyDef1;	//�������嶨��

	//��̬����
	b2Body*						m_pGroundBody;		//��������
	b2Body*						m_pGroundBody1;		//��������
	b2Body*						m_pGroundBody2;		//��������
	b2Body*						m_pGroundBody3;		//��������

	//��̬���嶨��ṹ��ָ��
	b2BodyDef*					m_pBulletBodyDef;	//�ӵ����嶨��
	b2BodyDef*					m_pBodyDef1;		//���嶨��1
	b2BodyDef*					m_pBodyDef2;		//���嶨��2
	b2BodyDef*					m_pBodyDef3;		//���嶨��3

	//��̬����
	b2Body*						m_pBulletBody;		//�ӵ�����
	b2Body*						m_pBody1;			//����1
	b2Body*						m_pBody2;			//����2
	b2Body*						m_pBody3;			//����3

	//������״�ṹ��ָ��
	b2PolygonDef*				m_pGroundShapeDef;	//����������״
	b2PolygonDef*				m_pBulletShapeDef;	//�ӵ�������״
	b2CircleDef*				m_pBulletShapeDef1;	//�ӵ�������״
	b2PolygonDef*				m_pBodyShapeDef1;	//������״1
	b2PolygonDef*				m_pBodyShapeDef2;	//������״2
	b2CircleDef*				m_pBodyShapeDef3;	//������״3

	//����
	hgeSprite*					m_pMouseSprite;		//��꾫��
	hgeSprite*					m_pGroundSprite;	//�������徫��
	hgeSprite*					m_pBulletSprite;	//�ӵ����徫��
	hgeSprite*					m_pBodySprite1;		//���徫��1
	hgeSprite*					m_pBodySprite2;		//���徫��2
	hgeSprite*					m_pBodySprite3;		//���徫��3

	//����
	HTEXTURE					m_MouseTx;			//�������
	HTEXTURE					m_GroundTx;			//������������
	HTEXTURE					m_BulletTx;			//�ӵ���������
	HTEXTURE					m_BodyTx1;			//��������1
	HTEXTURE					m_BodyTx2;			//��������2
	HTEXTURE					m_BodyTx3;			//��������3


	//Box2d֡ʱ��
	float						m_fTimeStep;
	//Box2d��������
	int							m_iTerations;

	hgeVector					m_MousePos;

	hgeVector					m_FootballPos;

	bool						m_bIsMouse;
};
