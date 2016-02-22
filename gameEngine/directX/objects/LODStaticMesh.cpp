#include "LODStaticMesh.h"

CLODStaticMesh::CLODStaticMesh(void)
{

	m_pDevice = NULL;

	m_pMesh = NULL;


	m_MatD3DVector.clear();
	m_TexVector.clear();	

	m_dwMatNum = 0;

}

CLODStaticMesh::~CLODStaticMesh(void)
{
}
bool CLODStaticMesh::Load(LPDIRECT3DDEVICE9 pDevice , const char* szMesh)
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

	//优化模型
	m_pMesh->OptimizeInplace( D3DXMESHOPT_ATTRSORT|D3DXMESHOPT_COMPACT|D3DXMESHOPT_VERTEXCACHE,
		                     (DWORD*)pAdjacency->GetBufferPointer(),
							   NULL,
							   NULL,
							   NULL 
							   );
	//层次渐进模型
	LPD3DXMESH	pMesh = NULL;
	D3DXCleanMesh(D3DXCLEAN_SIMPLIFICATION
					,m_pMesh
					,(DWORD*)pAdjacency->GetBufferPointer()
					,&pMesh
					,(DWORD*)pAdjacency->GetBufferPointer()
					,NULL);

	m_pMesh->Release();
	m_pMesh = pMesh;

	D3DXWELDEPSILONS epsilons;
	ZeroMemory( &epsilons,sizeof(epsilons) );

	//融合重复定点
	D3DXWeldVertices(m_pMesh
					 ,D3DXWELDEPSILONS_WELDPARTIALMATCHES
					 ,&epsilons
					 ,(DWORD*)pAdjacency->GetBufferPointer()
					 ,(DWORD*)pAdjacency->GetBufferPointer()
					 ,NULL
					 ,NULL);


	D3DXGeneratePMesh(m_pMesh
						,(DWORD*)pAdjacency->GetBufferPointer()
						,NULL
						,NULL
						,1
						,D3DXMESHSIMP_FACE
						,&m_pPMesh);


	//释放邻接信息
	pAdjacency->Release();




	return true;
}

void CLODStaticMesh::Render()
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

void CLODStaticMesh::Render(int iNum, bool bSetFaces /*= true*/ )
{
	if( !m_pPMesh || !m_pDevice )
	{
		return;
	}

	if ( bSetFaces )
	{
		m_pPMesh->SetNumFaces( iNum );
	}
	else
	{
		m_pPMesh->SetNumVertices( iNum );
	}


	for ( UINT i=0; i<m_dwMatNum; i++ )
	{
		m_pDevice->SetMaterial( &m_MatD3DVector[i] );

		if( m_TexVector[i] )
		{
			m_pDevice->SetTexture(0,m_TexVector[i] );
		}

		m_pPMesh->DrawSubset(i);
	}

}