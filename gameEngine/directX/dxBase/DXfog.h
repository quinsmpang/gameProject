#pragma once
#include "gd.h"

struct DXFOG_STRUCT
{
	int			iType;  //0 - 顶点雾, 1-像素雾
	int			iFogMode;  //计算方式 ( 1-EXP  2-EXP2  3-LINER(线性) )
	D3DCOLOR	fogClr;	//雾的颜色
	float		fStart;	//雾化起始距离
	float		fEnd;	//雾化结束距离
	float		fDenity;	//雾化浓度
};

class CDXfog
{
public:
	CDXfog(void);

	~CDXfog(void);

	bool Init(LPDIRECT3DDEVICE9 pDevice , const char* szFog);

	bool ActiveFog( int Id  ,  bool bFog = true)
	{
		if(Id<0 || Id > m_FogVector.size())
		{
			return false;
		}
		
		if(bFog)
		{
			m_pDevice->SetRenderState(D3DRS_FOGENABLE , true );

			if(m_FogVector[Id]->iType == 0)
			{
				m_pDevice->SetRenderState(D3DRS_FOGVERTEXMODE , m_FogVector[Id]->iFogMode);
			}
			else
			{
				m_pDevice->SetRenderState(D3DRS_FOGTABLEMODE , m_FogVector[Id]->iFogMode);
			}
			//颜色
			m_pDevice->SetRenderState(D3DRS_FOGCOLOR , m_FogVector[Id]->fogClr);
			//距离
			m_pDevice->SetRenderState(D3DRS_FOGSTART , *(DWORD*)&m_FogVector[Id]->fStart);
			m_pDevice->SetRenderState(D3DRS_FOGEND, *(DWORD*)&m_FogVector[Id]->fEnd);
			//浓度
			m_pDevice->SetRenderState(D3DRS_FOGDENSITY, *(DWORD*)&m_FogVector[Id]->fDenity);

			return true;
		
		}
		else
		{
				m_pDevice->SetRenderState(D3DRS_FOGENABLE , false );
		}




		return true;
	}

private:

	LPDIRECT3DDEVICE9			m_pDevice;

	vector<DXFOG_STRUCT*>   m_FogVector;

};
