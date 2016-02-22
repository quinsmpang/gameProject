#pragma once
#include "GD.h"

#define FVF_WATER  D3DFVF_XYZ|D3DFVF_NORMAL|D3DFVF_TEX1

struct WATER_VERTEX 
{
	float x,y,z;
	float nx,ny,nz;
	float fu,fv;
};

class CWater
{
public:
	CWater(void);

	~CWater(void);

	bool Init(LPDIRECT3DDEVICE9	pDevice , const char* szWater , int ID = 0);

	void Updata(float fElapsedTime);

	void Render();

private:
	
	LPDIRECT3DDEVICE9					m_pDevice;

	LPDIRECT3DVERTEXBUFFER9		m_pVB;

	LPDIRECT3DINDEXBUFFER9			m_pIB;

	int												m_iType;

	LPDIRECT3DTEXTURE9					m_pTex[30];

	int												m_TexMaxNum;
	//行列数
	int												m_iCol; 
	int												m_iRow;
	//水面块大小
	float												m_CellSize;

	//当前纹理ID
	int												m_iCurTexID;

	float												m_ftime;
	float												m_fChangetime;



	D3DXVECTOR3								m_vPos;


	

	
};
