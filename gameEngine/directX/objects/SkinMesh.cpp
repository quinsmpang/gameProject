#include ".\skinmesh.h"

LPDIRECT3DDEVICE9 CSkinMesh::m_pDevice = NULL;

CSkinMesh::CSkinMesh( LPDIRECT3DDEVICE9 pDevice )
{
	m_pDevice = pDevice;
	m_pDevice->GetDeviceCaps( &m_d3dCaps );
	m_pAnimController = NULL;
	m_pFrameRoot = NULL;
	m_pBoneMatrices = NULL;
	m_NumBoneMatricesMax = 0;
	m_fAdvanceTime = 0.02f;

	ZeroMemory( m_szCurActName, sizeof(m_szCurActName) );
}

CSkinMesh::~CSkinMesh(void)
{
	CAllocateHierarchy Alloc(this);
	D3DXFrameDestroy(m_pFrameRoot, &Alloc);
	SafeRelease(m_pAnimController);
}

VOID CSkinMesh::SetAct(char *strName)
{
	if( strcmp( strName, m_szCurActName) == 0 )
	{
		return;
	}

	strcpy_s( m_szCurActName, strName );

	//一套动作
	ID3DXAnimationSet *t_pAniSet;

	//通过名字的获取动作
	m_pAnimController->GetAnimationSetByName(strName,&t_pAniSet);

	//设置当前播放的动作(栈号,动作)
	m_pAnimController->SetTrackAnimationSet( 0,t_pAniSet);





	//获得这个动作的时长(单位:秒)
	m_CurActTime = t_pAniSet->GetPeriod();
	double dl  = t_pAniSet->GetPeriodicPosition(0);
	//t_pAniSet->Release();
	t_pAniSet = NULL;
}

//全局函数 (将Name拷贝到pNewName)
HRESULT AllocateName( LPCTSTR Name, LPTSTR *pNewName )
{
	UINT cbLength;
	if (Name != NULL)
	{
		cbLength = lstrlen(Name) + 1;
		*pNewName = new TCHAR[cbLength];
		if (*pNewName == NULL)
			return E_OUTOFMEMORY;
		memcpy(*pNewName, Name, cbLength*sizeof(TCHAR));
	}
	else
	{
		*pNewName = NULL;
	}

	return S_OK;
}


HRESULT CSkinMesh::Load(const char* strFileName)
{
	strcpy_s( m_szMesh,strFileName );

	CAllocateHierarchy Alloc(this);

	//调用CAllocateHierarchy的函数在内存中创建Frame的层次结构体系
	if (FAILED(D3DXLoadMeshHierarchyFromX(
		strFileName,            //路径名
		D3DXMESH_MANAGED,       //网格选项 D3DXMESH类型枚举值 (资源管理器自动调度顶点缓冲区和索引缓冲区存储位置)
		m_pDevice,           //设备
		&Alloc,                 //分配器 (回调函数 自动调用CreateFrame和CreateMeshContainer)
		NULL,                   //加载器
		&m_pFrameRoot,          //贞的根节点地址
		&m_pAnimController      //动画控制器
		))) 
		return E_FAIL;
	
	//从根Frame开始，设置骨骼的动作变换矩阵到ppBoneMatrixPtrs数组
	if (FAILED(SetupBoneMatrixPointers(m_pFrameRoot)))
		return E_FAIL;
	//计算角色对象的包围球心和半径

	if (FAILED(D3DXFrameCalculateBoundingSphere(m_pFrameRoot, &m_Sphere.v0, &m_Sphere.fR)))
		return E_FAIL;
	return S_OK;
}

//创建骨头
HRESULT CAllocateHierarchy::CreateFrame(LPCTSTR Name, LPD3DXFRAME *ppNewFrame)
{
	D3DXFRAME_DERIVED *pFrame;

	*ppNewFrame = NULL;

	pFrame = new D3DXFRAME_DERIVED;
	if (pFrame == NULL)
	{
		delete pFrame;
		return E_OUTOFMEMORY;//内存不足
	}

	if (FAILED(AllocateName(Name, &pFrame->Name)))
	{
		delete pFrame;
		return E_FAIL;
	}

	//初始化帧的数据
	D3DXMatrixIdentity(&pFrame->TransformationMatrix);
	D3DXMatrixIdentity(&pFrame->CombinedTransformationMatrix);

	pFrame->pMeshContainer = NULL;
	pFrame->pFrameSibling = NULL;
	pFrame->pFrameFirstChild = NULL;

	*ppNewFrame = pFrame;
	pFrame = NULL;

	delete pFrame;
	return S_OK;
}

//创建蒙皮
#if ((D3D_SDK_VERSION & 0xFF) ==31)	//这里是Directx9.0b的
HRESULT CAllocateHierarchy::CreateMeshContainer(
	LPCTSTR Name, 
	LPD3DXMESHDATA pMeshData,
	LPD3DXMATERIAL pMaterials, 
	LPD3DXEFFECTINSTANCE pEffectInstances, 
	DWORD NumMaterials, 
	DWORD *pAdjacency, 
	LPD3DXSKININFO pSkinInfo, 
	LPD3DXMESHCONTAINER *ppNewMeshContainer) 
#else						//Direct9.0c
LRESULT CAllocateHierarchy::CreateMeshContainer(
	LPCTSTR Name, 
	CONST D3DXMESHDATA *pMeshData,
	CONST D3DXMATERIAL *pMaterials, 
	CONST D3DXEFFECTINSTANCE *pEffectInstances, 
	DWORD NumMaterials, 
	CONST DWORD *pAdjacency, 
	LPD3DXSKININFO pSkinInfo, 
	LPD3DXMESHCONTAINER *ppNewMeshContainer) 
#endif
{
	HRESULT hr;
	D3DXMESHCONTAINER_DERIVED *pMeshContainer = NULL;
	UINT NumFaces;
	UINT iMaterial;
	UINT iBone, cBones;

	LPD3DXMESH pMesh = NULL;

	*ppNewMeshContainer = NULL;

	if (pMeshData->Type != D3DXMESHTYPE_MESH)
	{
		hr = E_FAIL;
		goto e_Exit;
	}
	pMesh = pMeshData->pMesh;

	if (pMesh->GetFVF() == 0)
	{
		hr = E_FAIL;
		goto e_Exit;
	}

	pMeshContainer = new D3DXMESHCONTAINER_DERIVED;
	if (pMeshContainer == NULL)
	{
		hr = E_OUTOFMEMORY;
		goto e_Exit;
	}
	memset(pMeshContainer, 0, sizeof(D3DXMESHCONTAINER_DERIVED));

	hr = AllocateName(Name, &pMeshContainer->Name);
	if (FAILED(hr))
		goto e_Exit;

	NumFaces = pMesh->GetNumFaces();

	//如果没有法向量,则添加它们
	if (!(pMesh->GetFVF() & D3DFVF_NORMAL))
	{
		pMeshContainer->MeshData.Type = D3DXMESHTYPE_MESH;

		//先复制
		hr = pMesh->CloneMeshFVF( pMesh->GetOptions(), 
			pMesh->GetFVF() | D3DFVF_NORMAL, 
			CSkinMesh::m_pDevice, &pMeshContainer->MeshData.pMesh );
		if (FAILED(hr))
			goto e_Exit;
		pMesh = pMeshContainer->MeshData.pMesh;

		//生成法向量
		D3DXComputeNormals( pMesh, NULL );
	}
	else
	{
		pMeshContainer->MeshData.pMesh = pMesh;
		pMeshContainer->MeshData.Type = D3DXMESHTYPE_MESH;

		pMesh->AddRef();
	}
	pMeshContainer->NumMaterials = max(1, NumMaterials);
	pMeshContainer->pMaterials = new D3DXMATERIAL[pMeshContainer->NumMaterials];
	pMeshContainer->ppTextures = new LPDIRECT3DTEXTURE9[pMeshContainer->NumMaterials];
	pMeshContainer->pAdjacency = new DWORD[NumFaces*3];
	if ((pMeshContainer->pAdjacency == NULL) || (pMeshContainer->pMaterials == NULL))
	{
		hr = E_OUTOFMEMORY;
		goto e_Exit;
	}

	memcpy(pMeshContainer->pAdjacency, pAdjacency, sizeof(DWORD) * NumFaces*3);
	memset(pMeshContainer->ppTextures, 0, sizeof(LPDIRECT3DTEXTURE9) * pMeshContainer->NumMaterials);

	//如果有材质数据,生成纹理对象，并放入扩展后的网格容器中
	if (NumMaterials > 0)            
	{
		memcpy(pMeshContainer->pMaterials, pMaterials, sizeof(D3DXMATERIAL) * NumMaterials);

		for (iMaterial = 0; iMaterial < NumMaterials; iMaterial++)
		{
			if (pMeshContainer->pMaterials[iMaterial].pTextureFilename != NULL)
			{
				TCHAR* szTexName =pMeshContainer->pMaterials[iMaterial].pTextureFilename;
				TCHAR szTex[256] = {0};
				TCHAR szMesh[256] = {0};
				//中间路径(存放纹理的子文件夹路径)
				m_pSkinMesh->GetMeshPath( szMesh );

				strcpy_s( szTex, szMesh );
				char* p = strrchr( szTex, '\\' );

				if( p )
				{
					*(p+1) = '\0';
					strcat_s( szTex, szTexName );
				}
				else
				{
					strcpy_s( szTex, szTexName );
				}

				if( FAILED( D3DXCreateTextureFromFile( CSkinMesh::m_pDevice, szTex, 
					&pMeshContainer->ppTextures[iMaterial] ) ) )
				{
					pMeshContainer->ppTextures[iMaterial] = NULL;
				}

				pMeshContainer->pMaterials[iMaterial].pTextureFilename = NULL;
			}
		}
	}
	else //没有材质,则添加一个默认值
	{
		pMeshContainer->pMaterials[0].pTextureFilename = NULL;
		memset(&pMeshContainer->pMaterials[0].MatD3D, 0, sizeof(D3DMATERIAL9));
		pMeshContainer->pMaterials[0].MatD3D.Diffuse.r = 0.5f;
		pMeshContainer->pMaterials[0].MatD3D.Diffuse.g = 0.5f;
		pMeshContainer->pMaterials[0].MatD3D.Diffuse.b = 0.5f;
		pMeshContainer->pMaterials[0].MatD3D.Specular = pMeshContainer->pMaterials[0].MatD3D.Diffuse;
	}

	//存在蒙皮信息
	if (pSkinInfo != NULL)
	{
		pMeshContainer->pSkinInfo = pSkinInfo;
		pSkinInfo->AddRef();

		pMeshContainer->pOrigMesh = pMesh; //备份指针
		pMesh->AddRef();
		cBones = pSkinInfo->GetNumBones();
		pMeshContainer->pBoneOffsetMatrices = new D3DXMATRIX[cBones];
		if (pMeshContainer->pBoneOffsetMatrices == NULL)
		{
			hr = E_OUTOFMEMORY;
			goto e_Exit;
		}

		//取得骨骼的权重矩阵
		for (iBone = 0; iBone < cBones; iBone++)
		{
			pMeshContainer->pBoneOffsetMatrices[iBone] = *(pMeshContainer->pSkinInfo->GetBoneOffsetMatrix(iBone));
		}

		//生成蒙皮网格
		hr = m_pSkinMesh->GenerateSkinnedMesh(pMeshContainer);
		if (FAILED(hr))
			goto e_Exit;
	}

	*ppNewMeshContainer = pMeshContainer;
	pMeshContainer = NULL;
e_Exit:

	//释放网格容器
	if (pMeshContainer != NULL)
	{
		DestroyMeshContainer(pMeshContainer);
	}

	return hr;
}


HRESULT CAllocateHierarchy::DestroyMeshContainer(LPD3DXMESHCONTAINER pMeshContainerBase)
{
	UINT iMaterial;
	D3DXMESHCONTAINER_DERIVED *pMeshContainer = (D3DXMESHCONTAINER_DERIVED*)pMeshContainerBase;

	SafeDeleteArray( pMeshContainer->Name );
	SafeDeleteArray( pMeshContainer->pAdjacency );
	SafeDeleteArray( pMeshContainer->pMaterials );
	SafeDeleteArray( pMeshContainer->pBoneOffsetMatrices );

	//释放所有纹理对象
	if (pMeshContainer->ppTextures != NULL)
	{
		for (iMaterial = 0; iMaterial < pMeshContainer->NumMaterials; iMaterial++)
		{
			SafeRelease( pMeshContainer->ppTextures[iMaterial] );
		}
	}

	SafeDeleteArray( pMeshContainer->ppTextures );
	SafeDeleteArray( pMeshContainer->ppBoneMatrixPtrs );
	SafeRelease( pMeshContainer->pBoneCombinationBuf );
	SafeRelease( pMeshContainer->MeshData.pMesh );
	SafeRelease( pMeshContainer->pSkinInfo );
	SafeRelease( pMeshContainer->pOrigMesh );
	SafeDelete( pMeshContainer );
	return S_OK;
}
HRESULT CAllocateHierarchy::DestroyFrame(LPD3DXFRAME pFrameToFree) 
{
	SafeDeleteArray( pFrameToFree->Name );
	SafeDelete( pFrameToFree );
	return S_OK; 
}
//生成蒙皮网格
HRESULT CSkinMesh::GenerateSkinnedMesh(D3DXMESHCONTAINER_DERIVED *pMeshContainer)
{
	HRESULT hr = S_OK;
	if (pMeshContainer->pSkinInfo == NULL)
		return hr;
	DWORD NumMaxFaceInfl;
	//取得网格的顶点索引缓冲区
	LPDIRECT3DINDEXBUFFER9 pIB;
	hr = pMeshContainer->pOrigMesh->GetIndexBuffer(&pIB);
	if (FAILED(hr))
		return hr;
	//一个三角形面可以受到骨骼影响的最大骨骼个数
	hr = pMeshContainer->pSkinInfo->GetMaxFaceInfluences(pIB, pMeshContainer->pOrigMesh->GetNumFaces(), &NumMaxFaceInfl);
	pIB->Release();
	if (FAILED(hr))
		return hr;
	//除去法向量和光照处理所占用的矩阵,用2除减半
	pMeshContainer->NumPaletteEntries = min((m_d3dCaps.MaxVertexBlendMatrixIndex + 1)/2, 
	pMeshContainer->pSkinInfo->GetNumBones());
	SafeRelease( pMeshContainer->MeshData.pMesh );
	SafeRelease( pMeshContainer->pBoneCombinationBuf );
	//生成包含顶点骨骼权重、骨骼矩阵表和索引等信息的蒙皮网格
	hr = pMeshContainer->pSkinInfo->ConvertToIndexedBlendedMesh(
		pMeshContainer->pOrigMesh,
		NULL, 
		pMeshContainer->NumPaletteEntries, 
		pMeshContainer->pAdjacency, 
		NULL, NULL, NULL, 
		&pMeshContainer->NumInfl,
		&pMeshContainer->NumAttributeGroups, 
		&pMeshContainer->pBoneCombinationBuf, 
		&pMeshContainer->MeshData.pMesh);
	if (FAILED(hr))
		return hr;

	return hr;
}

//递归 遍历骨骼二叉树有pMeshContainer数据就处理
//就是把骨骼的世界变换矩阵给了蒙皮
HRESULT CSkinMesh::SetupBoneMatrixPointers(LPD3DXFRAME pFrame)
{
	if (pFrame->pMeshContainer != NULL)
	{
		//仅处理单一网格的情形,一但读出矩阵,就返回
		if (FAILED(SetupBoneMatrixPointersOnMesh(pFrame->pMeshContainer)))
			return E_FAIL;
	}

	if (pFrame->pFrameSibling != NULL)
	{
		if (FAILED(SetupBoneMatrixPointers(pFrame->pFrameSibling)))
			return E_FAIL;
	}

	if (pFrame->pFrameFirstChild != NULL)
	{
		if (FAILED(SetupBoneMatrixPointers(pFrame->pFrameFirstChild)))
			return E_FAIL;
	}
	return S_OK;
}

HRESULT CSkinMesh::SetupBoneMatrixPointersOnMesh(LPD3DXMESHCONTAINER pMeshContainerBase)
{
	UINT iBone, cBones;
	D3DXFRAME_DERIVED *pFrame;

	D3DXMESHCONTAINER_DERIVED *pMeshContainer = (D3DXMESHCONTAINER_DERIVED*)pMeshContainerBase;

	//存在蒙皮数据,取出骨骼矩阵,放入矩阵表ppBoneMatrixPtrs中
	if (pMeshContainer->pSkinInfo != NULL)
	{
		cBones = pMeshContainer->pSkinInfo->GetNumBones();  //骨骼数
		pMeshContainer->ppBoneMatrixPtrs = new D3DXMATRIX*[cBones];
		if (pMeshContainer->ppBoneMatrixPtrs == NULL)
			return E_OUTOFMEMORY;//内存不足

		for (iBone = 0; iBone < cBones; iBone++)
		{
			//找到骨骼所在的Frame
			pFrame = (D3DXFRAME_DERIVED*)D3DXFrameFind(m_pFrameRoot, pMeshContainer->pSkinInfo->GetBoneName(iBone));
			if (pFrame == NULL)
				return E_FAIL;
			//取出骨骼的动作变换矩阵....................
			pMeshContainer->ppBoneMatrixPtrs[iBone] = &pFrame->CombinedTransformationMatrix;
		}
	}
	return S_OK;
}

void CSkinMesh::Render( D3DXMATRIX matWorld, DOUBLE fAdvanceTime )
{
	//获取帧间隔时间
	m_fAdvanceTime = fAdvanceTime;

	HRESULT hr;
	//m_pDevice->SetTransform( D3DTS_WORLD, &matWorld );
	//调整角色的当前动画时间点
	if (m_pAnimController != NULL)
	{
		hr=m_pAnimController->AdvanceTime(m_fAdvanceTime,NULL);
	}
	//更新各个Frame的CombinedTransformationMatrix动作变换矩阵
	UpdateFrameMatrices(m_pFrameRoot, &matWorld);
	//渲染一帧
	DrawFrame(m_pFrameRoot);
}

//递归遍历
void CSkinMesh::UpdateFrameMatrices(LPD3DXFRAME pFrameBase, LPD3DXMATRIX pParentMatrix)
{
	D3DXFRAME_DERIVED *pFrame = (D3DXFRAME_DERIVED*)pFrameBase;
	if (pParentMatrix != NULL)
		D3DXMatrixMultiply(&pFrame->CombinedTransformationMatrix, &pFrame->TransformationMatrix, pParentMatrix);
	else
		pFrame->CombinedTransformationMatrix = pFrame->TransformationMatrix;

	if (pFrame->pFrameSibling != NULL)
	{
		UpdateFrameMatrices(pFrame->pFrameSibling, pParentMatrix);  //递归调用
	}

	if (pFrame->pFrameFirstChild != NULL)
	{
		UpdateFrameMatrices(pFrame->pFrameFirstChild, &pFrame->CombinedTransformationMatrix);
	}
}

//渲染一帧
void CSkinMesh::DrawFrame(LPD3DXFRAME pFrame)
{
	LPD3DXMESHCONTAINER pMeshContainer;

	pMeshContainer = pFrame->pMeshContainer;
	//蒙皮是链式结构
	while (pMeshContainer != NULL)
	{
		DrawMeshContainer(pMeshContainer, pFrame); //渲染网格
		pMeshContainer = pMeshContainer->pNextMeshContainer;
	}

	if (pFrame->pFrameSibling != NULL)
	{
		DrawFrame(pFrame->pFrameSibling);  //递归调用
	}

	if (pFrame->pFrameFirstChild != NULL)
	{
		DrawFrame(pFrame->pFrameFirstChild);
	}
}

//绘制MESH
void CSkinMesh::DrawMeshContainer(LPD3DXMESHCONTAINER pMeshContainerBase, LPD3DXFRAME pFrameBase)
{
	D3DXMESHCONTAINER_DERIVED *pMeshContainer = (D3DXMESHCONTAINER_DERIVED*)pMeshContainerBase;
	D3DXFRAME_DERIVED *pFrame = (D3DXFRAME_DERIVED*)pFrameBase;
	UINT iMaterial;
	UINT iAttrib;
	LPD3DXBONECOMBINATION pBoneComb;
	UINT iMatrixIndex;
	UINT iPaletteEntry;
	D3DXMATRIXA16 matTemp;

	if (pMeshContainer->pSkinInfo != NULL)
	{
		if (pMeshContainer->NumInfl)
			m_pDevice->SetRenderState(D3DRS_INDEXEDVERTEXBLENDENABLE, TRUE);
		if (pMeshContainer->NumInfl == 1)
			m_pDevice->SetRenderState(D3DRS_VERTEXBLEND, D3DVBF_0WEIGHTS);
		else
			m_pDevice->SetRenderState(D3DRS_VERTEXBLEND, pMeshContainer->NumInfl - 1);
		//取得网格子集的组合属性表(包括子集内的各个骨骼id) 
		pBoneComb =(LPD3DXBONECOMBINATION)pMeshContainer->pBoneCombinationBuf->GetBufferPointer();
		//每子集
		for (iAttrib = 0; iAttrib < pMeshContainer->NumAttributeGroups; iAttrib++)
		{
			//每个子集内的每个骨骼,逐个计算世界坐标变换矩阵
			for (iPaletteEntry = 0; iPaletteEntry < pMeshContainer->NumPaletteEntries; ++iPaletteEntry)
			{
				iMatrixIndex = pBoneComb[iAttrib].BoneId[iPaletteEntry]; //取出骨骼id
				if (iMatrixIndex != UINT_MAX)
				{
					D3DXMatrixMultiply( &matTemp, &pMeshContainer->pBoneOffsetMatrices[iMatrixIndex], pMeshContainer->ppBoneMatrixPtrs[iMatrixIndex] );
					m_pDevice->SetTransform( D3DTS_WORLDMATRIX( iPaletteEntry ), &matTemp );
				}
			}
			//设置材质
			m_pDevice->SetMaterial( &pMeshContainer->pMaterials[pBoneComb[iAttrib].AttribId].MatD3D );
			m_pDevice->SetTexture( 0, pMeshContainer->ppTextures[pBoneComb[iAttrib].AttribId] );
			//用当前的矩阵调板渲染网格子集
			pMeshContainer->MeshData.pMesh->DrawSubset( iAttrib );
		}
		//恢复渲染状态标志
		m_pDevice->SetRenderState(D3DRS_INDEXEDVERTEXBLENDENABLE, FALSE);
		m_pDevice->SetRenderState(D3DRS_VERTEXBLEND, 0);
	}   
	else  //网格没有骨骼动画数据
	{
		m_pDevice->SetTransform(D3DTS_WORLD, &pFrame->CombinedTransformationMatrix);
		for (iMaterial = 0; iMaterial < pMeshContainer->NumMaterials; iMaterial++)
		{
			m_pDevice->SetMaterial( &pMeshContainer->pMaterials[iMaterial].MatD3D );
			m_pDevice->SetTexture( 0, pMeshContainer->ppTextures[iMaterial] );
			pMeshContainer->MeshData.pMesh->DrawSubset(iMaterial);
		}
	}
}
