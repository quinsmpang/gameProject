#pragma once
#include ".\gd.h"
/*
* 骨骼动画
*/

//(D3DXFRAME是二叉树节点代表一个骨骼)
/*D3DXFRAME 中有：        LPSTR                   Name;                  //名字
 *                        D3DXMATRIX              TransformationMatrix;  //控制器(矩阵)
 *					      LPD3DXMESHCONTAINER     pMeshContainer;        //蒙皮容器
 *					      struct _D3DXFRAME       *pFrameSibling;        //兄弟节点
 *					      struct _D3DXFRAME       *pFrameFirstChild;     //子节点
 *蒙皮容器
 *D3DXMESHCONTAINER中有:  
 *						  LPSTR                   Name;                  //名字
 *						  D3DXMESHDATA            MeshData;              //网格数组
 *						  LPD3DXMATERIAL          pMaterials;            //材质数组
 *						  LPD3DXEFFECTINSTANCE    pEffects;              //特效对象
 *						  DWORD                   NumMaterials;          //材质数量
 *						  DWORD                  *pAdjacency;            //邻近三角形信息
 * 						  LPD3DXSKININFO          pSkinInfo;             //用于存储蒙皮信息
 *						  struct _D3DXMESHCONTAINER *pNextMeshContainer; //链式结构的next指针
 */


#define SafeRelease(pObject) if(pObject!=NULL){pObject->Release();pObject=NULL;}
#define SafeDelete(p) { if(p) { delete (p); (p)=NULL; } }
#define SafeDeleteArray(p) { if(p) { delete[] (p); (p)=NULL; } }



struct D3DXFRAME_DERIVED: public D3DXFRAME 
{
    D3DXMATRIXA16        CombinedTransformationMatrix; //新的骨骼矩阵 (用于每次更新)
};


//蒙皮容器加数据
struct D3DXMESHCONTAINER_DERIVED: public D3DXMESHCONTAINER
{
	LPDIRECT3DTEXTURE9*   ppTextures; 				  //纹理数组          
	LPD3DXMESH           pOrigMesh;  				  //原来的网格
	LPD3DXATTRIBUTERANGE  pAttributeTable;             //属性表
	DWORD                NumAttributeGroups;          //属性数量
	DWORD                NumInfl;                     //权重数量
	LPD3DXBUFFER         pBoneCombinationBuf;         //骨骼所在网格子集的组合属性缓冲区
	D3DXMATRIX**         ppBoneMatrixPtrs;            //用数组存放所有骨骼的骨骼矩阵
	D3DXMATRIX*          pBoneOffsetMatrices;         //骨骼的偏移矩阵
	DWORD                NumPaletteEntries;           //多个矩阵对同一个顶点进行变换，这样的矩阵最大数，相当于调色板的功能
};

//声明
class CSkinMesh;

//分配器
class CAllocateHierarchy: public ID3DXAllocateHierarchy//抽象基类
{
public:
	//实现4个纯虚函数
	//创建贞
	STDMETHOD(CreateFrame)(LPCTSTR Name, LPD3DXFRAME *ppNewFrame);

	//创建网格容器
#if ((D3D_SDK_VERSION & 0xFF)== 31)	//这里是Directx9.0b的
	STDMETHOD(CreateMeshContainer)(
		LPCTSTR Name, 
		LPD3DXMESHDATA pMeshData,
		LPD3DXMATERIAL pMaterials, 
		LPD3DXEFFECTINSTANCE pEffectInstances, 
		DWORD NumMaterials, 
		DWORD *pAdjacency, 
		LPD3DXSKININFO pSkinInfo, 
		LPD3DXMESHCONTAINER *ppNewMeshContainer);
#else						//这里是Directx9.0c的
	STDMETHOD(CreateMeshContainer)(
		LPCSTR Name, 
		CONST D3DXMESHDATA *pMeshData,
		CONST D3DXMATERIAL *pMaterials, 
		CONST D3DXEFFECTINSTANCE *pEffectInstances, 
		DWORD NumMaterials, 
		CONST DWORD *pAdjacency, 
		LPD3DXSKININFO pSkinInfo, 
		LPD3DXMESHCONTAINER *ppNewMeshContainer);
#endif

	//释放贞
	STDMETHOD(DestroyFrame)(LPD3DXFRAME pFrameToFree);

	//释放网格容器
	STDMETHOD(DestroyMeshContainer)(LPD3DXMESHCONTAINER pMeshContainerBase);

	//构造函数
	CAllocateHierarchy(CSkinMesh *pSkinMesh) :m_pSkinMesh(pSkinMesh) {}
	CSkinMesh*		m_pSkinMesh;
};

//动画模型类
class CSkinMesh  
{
public:
	D3DXMATRIX*					m_pBoneMatrices;    	//矩阵数组
	UINT						m_NumBoneMatricesMax;	//骨骼的数目
	D3DCAPS9					m_d3dCaps;	            //显卡功能结构

	DXSPHERE					m_Sphere;


private:

	
	LPD3DXFRAME					m_pFrameRoot;		    //指向根Frame(根节点)
	LPD3DXANIMATIONCONTROLLER	m_pAnimController;      //动画控制器
	DOUBLE						m_fAdvanceTime;		//帧间隔时间

	DOUBLE						m_CurActTime;			//正在播放动作的时间间隔

	char						m_szMesh[256];
	char						m_szCurActName[32];

public:
	static LPDIRECT3DDEVICE9	m_pDevice;				//设备

	CSkinMesh( LPDIRECT3DDEVICE9 pDevice );
	~CSkinMesh();

	//通过X文件读取骨骼动画模型
	HRESULT Load(const char* strFileName);

	//绘画
	VOID Render( D3DXMATRIX matWorld, DOUBLE dlTime = 0.02 );

	//通过名字设置播放的动作
	VOID SetAct( char *strName );

	//获取正在播放动作的时间间隔
	DOUBLE GetCurActTime()
	{
		return m_CurActTime;
	}

	//获取变换时间
	DOUBLE GetAdvanceTime()
	{
		return m_fAdvanceTime;
	}

	void GetMeshPath( char* szOut, int n = 256 )
	{
		strcpy_s( szOut,n, m_szMesh );
	}
	//
	//蒙皮
	HRESULT GenerateSkinnedMesh(D3DXMESHCONTAINER_DERIVED *pMeshContainer);
	
	//更新所有帧矩阵
	VOID UpdateFrameMatrices( LPD3DXFRAME pFrameBase, LPD3DXMATRIX pParentMatrix );
	
	//通过节点的名字找到节点的矩阵
	LRESULT GetFrameMatrix(LPD3DXFRAME pFrameBase, char *strFrameName,D3DMATRIX *pMat)
	{
		D3DXFRAME *pFrame ;

		if(pFrameBase!=NULL)
			pFrame = pFrameBase;
		else 
			pFrame = m_pFrameRoot;

		if(pFrame->Name!=NULL && 0==strcmp(pFrame->Name,strFrameName))
		{
			*pMat=((D3DXFRAME_DERIVED*)pFrame)->CombinedTransformationMatrix; 
			return S_OK;
		}
		if (pFrame->pFrameSibling != NULL)
		{
			if(S_OK==	GetFrameMatrix(pFrame->pFrameSibling,strFrameName,pMat))
				return S_OK;
		}
		if (pFrame->pFrameFirstChild != NULL)
		{
			if(S_OK==	GetFrameMatrix(pFrame->pFrameFirstChild,strFrameName,pMat))
				return S_OK;
		}
		return E_FAIL;
	}

private:
	HRESULT SetupBoneMatrixPointers( LPD3DXFRAME pFrame );
	HRESULT SetupBoneMatrixPointersOnMesh( LPD3DXMESHCONTAINER pMeshContainerBase );
	VOID DrawMeshContainer(LPD3DXMESHCONTAINER pMeshContainerBase, LPD3DXFRAME pFrameBase);
	VOID DrawFrame(LPD3DXFRAME pFrame);
};
