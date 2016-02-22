#include "Terrain.h"

CTerrain::CTerrain(void)
{
	m_iType = TERRAIN_HEIGHTMAP;

	m_HeightVector.clear();

	m_iRow = 0;
	m_iCol = 0;

}

CTerrain::~CTerrain(void)
{
}
bool CTerrain::Init(LPDIRECT3DDEVICE9		pDevice , const char*	szTerrain)
{

	m_pDevice = pDevice;

	CReadIniFile		iniFile(szTerrain);

	iniFile.Go2Section("Terrain");

	iniFile.ReadInt("iType" , m_iType);

	char szText[256] = {0};




	if(m_iType == TERRAIN_HEIGHTMAP)
	{
		//读取高度图路径
		ZeroMemory( szText, sizeof(szText) );
		iniFile.ReadString("szHeightBmp" , szText);

		CImage	heightImg;
		heightImg.Load(szText);
		//获取高度图的宽高
		m_iRow = heightImg.GetHeight();
		m_iCol = heightImg.GetWidth();

		//读取主纹理路径
		ZeroMemory(szText , sizeof(szText));
		iniFile.ReadString("szTex" , szText);
		//创建主纹理
		D3DXCreateTextureFromFile(m_pDevice , szText ,&m_pTex);
		//读取透出图纹理路径
		ZeroMemory(szText , sizeof(szText));
		iniFile.ReadString("szDifBmp" , szText);

		CImage  difImg;
		difImg.Load(szText);

		//4 透出纹理
		ZeroMemory( szText, sizeof(szText) );
		iniFile.ReadString( "szDifTex", szText );
		D3DXCreateTextureFromFile( m_pDevice, szText, &m_pDifTex );

		//5 每方块大小
		
		iniFile.ReadFloat( "fCellSize", m_fCellSize );

		//6 最大高度
		float fMaxHeight = 0.0f;
		iniFile.ReadFloat( "fMaxHeight", fMaxHeight );

		//7 每行的纹理数
		int iTexSumPerRow = 0;
		iniFile.ReadInt( "iTexSumPerRow", iTexSumPerRow );
		//获取宽度和深度
		m_fWidth = (m_iCol-1)*m_fCellSize;
		m_fDepth = (m_iRow-1)*m_fCellSize;

		//顶点缓冲区大小
		int iVBSize = m_iRow*m_iCol*sizeof(TERRAIN_VERTEX);

		m_pDevice->CreateVertexBuffer( iVBSize
			,D3DUSAGE_WRITEONLY
			,FVF_TERRAIN
			,D3DPOOL_MANAGED
			,&m_pVB
			,NULL
			);

		TERRAIN_VERTEX*		pVertex = NULL;

		m_pVB->Lock( 0 , iVBSize, (void**)&pVertex ,D3DLOCK_READONLY);

		int iCurRow = 0;
		BYTE clr = 0;
		int iID = 0;

		for(float z = (m_fDepth/2) ; z >= (-m_fDepth/2) ; z-=m_fCellSize)
		{
			int iCurCol = 0;

			for( float x =(-m_fWidth/2); x<=(m_fWidth/2); x+=m_fCellSize)
			{
				//获取高度图（iCurCol ， iCurRow）点的颜色的低位值
				clr = heightImg.GetPixel(iCurCol , iCurRow)&0xff;
				//把以255为最大转换为100最大并放入容器
				m_HeightVector.push_back(clr/255.0f*fMaxHeight );

				//漫反射的alpha
				clr = (difImg.GetPixel(iCurCol,iCurRow))&0xff;

				iID = iCurRow*m_iCol+iCurCol;
				//坐标
				pVertex[iID].x = x;
				pVertex[iID].y = m_HeightVector[iID];
				pVertex[iID].z = z;
				//法线
				pVertex[iID].nx = 0;
				pVertex[iID].ny = 1;
				pVertex[iID].nz = 0;

				pVertex[iID].dif = D3DCOLOR_ARGB(clr ,0,0,0);

				pVertex[iID].tu0 = (iTexSumPerRow/float(m_iCol-1))*iCurCol;
				pVertex[iID].tv0 = (iTexSumPerRow/float(m_iRow-1))*iCurRow;


				pVertex[iID].tu1 = pVertex[iID].tu0;
				pVertex[iID].tv1 = pVertex[iID].tv0;

				iCurCol++;
			}

			iCurRow++;
		}

		m_pVB->Unlock();
		//索引缓冲区
		int iIBSize = (m_iRow-1)*(m_iCol-1)*6*sizeof(DWORD);

		m_pDevice->CreateIndexBuffer(iIBSize , D3DUSAGE_WRITEONLY,D3DFMT_INDEX32 , D3DPOOL_MANAGED
			,&m_pIB ,NULL);

		DWORD* pIndex =NULL;

		m_pIB->Lock( 0 , iIBSize , (void**)&pIndex ,D3DLOCK_READONLY);

		int iIndex = 0;

		for ( int iRow=0; iRow<(m_iRow-1); iRow++ )
		{
			for ( int iCol=0; iCol<(m_iCol-1); iCol++ )
			{

				pIndex[iIndex] = iRow*m_iCol+iCol; 
				pIndex[iIndex+1] = iRow*m_iCol+iCol+1;
				pIndex[iIndex+2] = iRow*m_iCol+iCol+1+m_iCol;

				pIndex[iIndex+3] = iRow*m_iCol+iCol; 
				pIndex[iIndex+4] = iRow*m_iCol+iCol+1+m_iCol;
				pIndex[iIndex+5] = iRow*m_iCol+iCol+m_iCol;

				iIndex += 6;
			}
		}

		m_pIB->Unlock();


	}
	else if(m_iType == TERRAIN_MESH)
	{
	}

	return true;
}

void CTerrain::Update(float fElapsedTime)
{
}

void CTerrain::Render()
{

	D3DXMATRIX mat = M44_IDENTITY;


	m_pDevice->SetTransform( D3DTS_WORLD, &mat );

	//
	m_pDevice->SetStreamSource( 0, m_pVB, 0, sizeof(TERRAIN_VERTEX) );

	m_pDevice->SetFVF( FVF_TERRAIN );

	m_pDevice->SetIndices( m_pIB );

	m_pDevice->SetTexture( 0, m_pTex );
	m_pDevice->SetTexture( 1, m_pDifTex );

	//混合方式 ARG1 op ARG2
	DWORD dwState[14];
	m_pDevice->GetTextureStageState( 0, D3DTSS_COLORARG1, &dwState[0] );
	m_pDevice->GetTextureStageState( 0, D3DTSS_COLORARG2, &dwState[1] );
	m_pDevice->GetTextureStageState( 0, D3DTSS_COLOROP, &dwState[2] );
	
	m_pDevice->GetTextureStageState( 1, D3DTSS_COLORARG1, &dwState[3] );
	m_pDevice->GetTextureStageState( 1, D3DTSS_COLORARG2, &dwState[4] );
	m_pDevice->GetTextureStageState( 1, D3DTSS_COLOROP, &dwState[5] );	
	
	m_pDevice->GetSamplerState( 0, D3DSAMP_MAGFILTER, &dwState[6] );
	m_pDevice->GetSamplerState( 0, D3DSAMP_MINFILTER, &dwState[7] );
	m_pDevice->GetSamplerState( 1, D3DSAMP_MAGFILTER, &dwState[8] );
	m_pDevice->GetSamplerState( 1, D3DSAMP_MINFILTER, &dwState[9] );

	m_pDevice->GetSamplerState( 0, D3DSAMP_ADDRESSU, &dwState[10] );
	m_pDevice->GetSamplerState( 0, D3DSAMP_ADDRESSV, &dwState[11] );
	m_pDevice->GetSamplerState( 1, D3DSAMP_ADDRESSU, &dwState[12] );
	m_pDevice->GetSamplerState( 1, D3DSAMP_ADDRESSV, &dwState[13] );

	m_pDevice->SetTextureStageState( 0, D3DTSS_COLORARG1, D3DTA_TEXTURE );
	m_pDevice->SetTextureStageState( 0, D3DTSS_COLORARG2, D3DTA_DIFFUSE );
	m_pDevice->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_SELECTARG1 );

	m_pDevice->SetTextureStageState( 1, D3DTSS_COLORARG1, D3DTA_TEXTURE);
	m_pDevice->SetTextureStageState( 1, D3DTSS_COLORARG2, D3DTA_CURRENT  );
	m_pDevice->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_BLENDDIFFUSEALPHA );

	m_pDevice->SetSamplerState( 0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );
	m_pDevice->SetSamplerState( 0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );
	m_pDevice->SetSamplerState( 1, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );
	m_pDevice->SetSamplerState( 1, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );

	m_pDevice->SetSamplerState( 0, D3DSAMP_ADDRESSU, D3DTADDRESS_WRAP );
	m_pDevice->SetSamplerState( 0, D3DSAMP_ADDRESSV, D3DTADDRESS_WRAP );
	m_pDevice->SetSamplerState( 1, D3DSAMP_ADDRESSU, D3DTADDRESS_WRAP );
	m_pDevice->SetSamplerState( 1, D3DSAMP_ADDRESSV, D3DTADDRESS_WRAP );


	m_pDevice->DrawIndexedPrimitive( D3DPT_TRIANGLELIST, 0,0,
		                        m_iRow*m_iCol,
								  0, (m_iRow-1)*(m_iCol-1)*2 
								  );

	m_pDevice->SetTextureStageState( 0, D3DTSS_COLORARG1, dwState[0] );
	m_pDevice->SetTextureStageState( 0, D3DTSS_COLORARG2, dwState[1] );
	m_pDevice->SetTextureStageState( 0, D3DTSS_COLOROP, dwState[2] );

	m_pDevice->SetTextureStageState( 1, D3DTSS_COLORARG1, dwState[3] );
	m_pDevice->SetTextureStageState( 1, D3DTSS_COLORARG2, dwState[4] );
	m_pDevice->SetTextureStageState( 1, D3DTSS_COLOROP, dwState[5] );	

	m_pDevice->SetSamplerState( 0, D3DSAMP_MAGFILTER, dwState[6] );
	m_pDevice->SetSamplerState( 0, D3DSAMP_MINFILTER, dwState[7] );
	m_pDevice->SetSamplerState( 1, D3DSAMP_MAGFILTER, dwState[8] );
	m_pDevice->SetSamplerState( 1, D3DSAMP_MINFILTER, dwState[9] );

	m_pDevice->SetSamplerState( 0, D3DSAMP_ADDRESSU, dwState[10] );
	m_pDevice->SetSamplerState( 0, D3DSAMP_ADDRESSV, dwState[11] );
	m_pDevice->SetSamplerState( 1, D3DSAMP_ADDRESSU, dwState[12] );
	m_pDevice->SetSamplerState( 1, D3DSAMP_ADDRESSV, dwState[13] );
}


//计算高度
bool CTerrain::CalcHeight( float x, float z,float& fH )
{
	//计算x,y离起点的距离
	x -= -m_fWidth/2;
	z = m_fDepth/2 - z;

	x /= m_fCellSize;
	z /= m_fCellSize;

	//位于第几行第几列
	int iCurRow = (int)z;
	int iCurCol = (int)x;

	if( iCurRow <0 || iCurRow >= m_iRow-1 
		|| iCurCol <0 || iCurCol >= m_iCol-1 )
	{
		return false;
	}

	//A -- B
	//|  / |
	//C -- D
	float fA  = GetHeight(iCurRow,iCurCol);
	float fB  = GetHeight(iCurRow,iCurCol+1);
	float fC  = GetHeight(iCurRow+1,iCurCol);
	float fD  = GetHeight(iCurRow+1,iCurCol+1);

	//计算位于那个三角形中
	float dx = fabs(x-iCurCol);
	float dz = fabs(z-iCurRow);

	//ABC
	if( dz < 1.0f -dx )
	{
		float fu = fB-fA;
		float fv = fC-fA;

		fH = fA+Lerpf(0,fu,dx)+Lerpf(0,fv,dz );
		return true;
	}
	//BDC
	else
	{
		float fu = fC-fD;
		float fv = fB-fD;

		fH = fD+Lerpf(0,fu,(1.0f-dx))+Lerpf(0,fv,(1.0f-dz) );
		return true;
	}
	return false;
}

//计算高度
bool CTerrain::CalcHeight( D3DXVECTOR3 v, float& fH )
{
	CalcHeight(v.x ,v.z , fH);

	return true;
}