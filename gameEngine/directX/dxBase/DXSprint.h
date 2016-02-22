#pragma once
#include ".\GD.h"

class DXSprint
{
public:
	DXSprint(void);

	~DXSprint(void);
	//读图
	/*
	pDevice				设备
	szFile				文件路径
	iXCount				X轴切分
	iYCount				Y轴切分
	iFx					x轴中心点比例
	iFy					y轴中心点比例
	iFarmeV				换帧速度
	AlphablendClr		指定某种颜色透明
	*/
	bool Load(LPDIRECT3DDEVICE9 pDevice,const char* szFile ,int iXCount  = 1, int iYCount = 1,float iFx  = 0, float iFy = 0,int iFarmeV = 1, D3DCOLOR AlphablendClr = D3DCOLOR_ARGB(0,0,0,0));
	//绘图
	/*
	x,y						坐标
	fAngle					旋转率
	fScalW					水平缩放倍数
	fScalH					垂直缩放倍数
	AlphablendClr			与哪种颜色混合
	*/
	void Render(int x,int y, float fAngle = 0, float fScalW = 1, float fScalH = 1 , D3DCOLOR AlphablendClr = D3DCOLOR_ARGB(255,255,255,255));
//绘图
	/*
	vPos					坐标
	fAngle					旋转率
	fScalW					水平缩放倍数
	fScalH					垂直缩放倍数
	AlphablendClr			与哪种颜色混合
	*/
	void Render(D3DXVECTOR3 vPos, float fAngle = 0, float fScalW = 1, float fScalH = 1 , D3DCOLOR AlphablendClr = D3DCOLOR_ARGB(255,255,255,255));

	bool ChangeFarme(int i  = 1);
	//切分后单位宽度
	int GetW()
	{

		return m_iW;
	}
	//切分后单位高度
	int GetH()
	{

		return m_iH;
	}

	int GetCurFrame()
	{
		return m_iCurFrame;
	}

	void SetCurFrameX(int iFrame)
	{
		m_iCurFrame = iFrame;
	}
	void SetCurFrameY(int iFrame)
	{
		m_iCurAction = iFrame;
	}
private:
	LPDIRECT3DDEVICE9					m_pDevice;//设备

	LPDIRECT3DTEXTURE9					m_pTex;//纹理

	LPD3DXSPRITE						m_pSprite;//精灵

	D3DXMATRIX							m_mat;  //矩阵

	char*								m_szFile;//文件路径 

	int									m_iXCount;//X轴切分
	int									m_iYCount;//Y轴切分

	float								m_iFx;//x轴中心点比例
	float								m_iFy;//y轴中心点比例

	int									m_iW;//切分后单位宽
	int									m_iH;//切分后单位高

	int									m_iCurTime;//当前时间
	int									m_iPreTime;//过去时间 

	int									m_iCurFrame;//当前帧	X
	int									m_iCurAction;//当前帧  Y


	int									m_iFarmeV;//帧速度
	int									m_iFarmeCount;//循环次数

};
