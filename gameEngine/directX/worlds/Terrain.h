#pragma once
#include "gd.h"
#include<atlimage.h>

#define	FVF_TERRAIN  D3DFVF_XYZ|D3DFVF_NORMAL|D3DFVF_DIFFUSE|D3DFVF_TEX2

struct	TERRAIN_VERTEX
{
	float x,y,z;
	float nx,ny,nz;
	D3DCOLOR  dif;
	float tu0,tv0;
	float tu1,tv1;

};

enum TERRAIN_TYPE_ENUM
{
	TERRAIN_HEIGHTMAP,
	TERRAIN_MESH
};

class CTerrain
{
public:
	CTerrain(void);

	~CTerrain(void);

	bool Init(LPDIRECT3DDEVICE9		pDevice , const char*	szTerrain);

	void Update(float fElapsedTime);

	void Render();

		//计算高度
	bool CalcHeight( float x, float z,float& fH );
	
	//计算高度
	bool CalcHeight( D3DXVECTOR3 v, float& fH );


		//获取指定行列的点的高度
	float GetHeight( int iRow, int iCol )
	{
		if( iRow<0 || iRow > m_iRow-1 || iCol < 0 || iCol > m_iCol-1 )
		{
			return 0;
		}

		return m_HeightVector[iRow*m_iCol+iCol];
	}

private:
	//设备
	LPDIRECT3DDEVICE9	m_pDevice;

	int m_iType;

	LPDIRECT3DVERTEXBUFFER9		m_pVB;

	LPDIRECT3DINDEXBUFFER9			m_pIB;

	LPDIRECT3DTEXTURE9				m_pTex;  //主纹理
	LPDIRECT3DTEXTURE9				m_pDifTex; //透出纹理

	int		m_iRow;
	int		m_iCol;

float					m_fWidth;  //宽度
float					m_fDepth;	//深度

float					m_fCellSize;


	//高度容器
	vector<float>			m_HeightVector;


};
