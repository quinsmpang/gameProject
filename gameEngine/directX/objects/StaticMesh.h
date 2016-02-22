#pragma once
#include "gd.h"

class CStaticMesh
{
public:
	CStaticMesh(void);

	~CStaticMesh(void);

	bool Load(LPDIRECT3DDEVICE9 pDevice , const char* szMesh);

	void Render();

	LPD3DXMESH GetMesh()
	{
		return m_pMesh;
	}


private:

	LPDIRECT3DDEVICE9	m_pDevice;

	LPD3DXMESH				m_pMesh;

	vector<D3DMATERIAL9>				m_MatD3DVector;//材质
	vector<LPDIRECT3DTEXTURE9>	m_TexVector;	//纹理

	DWORD						m_dwMatNum;		//材质纹理组数目(子集数)
};
