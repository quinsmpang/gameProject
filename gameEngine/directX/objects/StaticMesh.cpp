#include "StaticMesh.h"

CStaticMesh::CStaticMesh(void)
{

	m_pDevice = NULL;

	m_pMesh = NULL;


	m_MatD3DVector.clear();
	m_TexVector.clear();	

	m_dwMatNum = 0;

}

CStaticMesh::~CStaticMesh(void)
{
}
bool CStaticMesh::Load(LPDIRECT3DDEVICE9 pDevice , const char* szMesh)
{
	m_pDevice = pDevice;

	//邻接信息
	LPD3DXBUFFER pAdjacency = NULL; 
	//材质纹理
	LPD3DXBUFFER pMaterials = NULL;
	
	char szPath[128] = {0};
	//纹理路径
	char szTex[128] = {0};

	if(FAILED(D3DXLoadMeshFromXA(szMesh//文件名
										,D3DXMESH_MANAGED
										,m_pDevice
										,&pAdjacency
										,&pMaterials
										,NULL
										,&m_dwMatNum//子集数
										,&m_pMesh
										) ) )
	{
		sprintf_s( szPath, "Load Mesh Failed\n%s", szMesh );
		MB( szPath );

		return false;
	}
	//获取模型的材质纹理组首地址
	D3DXMATERIAL*  pMats = 	(D3DXMATERIAL*)pMaterials->GetBufferPointer();

	for( UINT i = 0 ; i < m_dwMatNum ;i++)
	{

		D3DMATERIAL9 matD3D = pMats[i].MatD3D;

		matD3D.Ambient = matD3D.Diffuse;

		m_MatD3DVector.push_back( matD3D );


		//
		LPDIRECT3DTEXTURE9		pTex;
		//模型是否有纹理
		if( pMats[i].pTextureFilename ) 
		{
			strcpy_s(szTex , szMesh);

			char* p = strrchr( szTex , '\\');

				if( p )
			{
				*(p+1) = '\0';
				strcat_s( szTex,pMats[i].pTextureFilename );
			}
			else
			{
				strcpy_s( szTex,pMats[i].pTextureFilename );
			}

			D3DXCreateTextureFromFile( m_pDevice, szTex, &pTex );
		}

		m_TexVector.push_back(pTex);
	}

	////优化模型
	//m_pMesh->OptimizeInplace( D3DXMESHOPT_ATTRSORT|D3DXMESHOPT_COMPACT|D3DXMESHOPT_VERTEXCACHE,
	//	                     (DWORD*)pAdjacency->GetBufferPointer(),
	//						   NULL,
	//						   NULL,
	//						   NULL 
	//						   );

	//释放邻接信息
	pAdjacency->Release();




	return true;
}

void CStaticMesh::Render()
{


	if( !m_pDevice || ! m_pMesh)
	{
		return;
	}

	for( UINT i = 0 ; i < m_dwMatNum ; i++)
	{
		//设置材质
		m_pDevice->SetMaterial( &m_MatD3DVector[i]);
		//设置纹理
		if( m_TexVector[i] )
		{
			m_pDevice->SetTexture( 0, m_TexVector[i] );
		}

		m_pMesh->DrawSubset(i);
	}
}