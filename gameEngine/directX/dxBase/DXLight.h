#pragma once
#include  "GD.h"

class CDXLight
{
public:
	CDXLight(void);

	~CDXLight(void);

	bool Init(LPDIRECT3DDEVICE9	pDevice , const char* szFile);

	bool ActiveLight( int iID , int index , bool bActive = true ,bool bSpecular = false  )
	{
		if(iID < 0 || iID > (int)m_LightVector.size())
		{
			return false;
		}

		if(bActive)
		{
			m_pDevice->SetLight(index , m_LightVector[iID]);
			m_pDevice->LightEnable(index , true);
		}
		else
		{
			m_pDevice->LightEnable(index , false);
		}

		//是否激活镜面反射
		m_pDevice->SetRenderState( D3DRS_SPECULARENABLE, bSpecular );

		return true;
	}

	void SetPos(int iID , D3DXVECTOR3 v)
	{
		if(iID < 0 || iID > (int)m_LightVector.size())
		{
			return;
		}
		m_LightVector[iID]->Position = v;
	}
	void SetDir(int iID , D3DXVECTOR3 v)
	{
		if(iID < 0 || iID > (int)m_LightVector.size())
		{
			return;
		}
		m_LightVector[iID]->Direction = v;
	}
private:
	LPDIRECT3DDEVICE9			m_pDevice;

	vector<D3DLIGHT9*>			m_LightVector; //存放灯的容器

};
