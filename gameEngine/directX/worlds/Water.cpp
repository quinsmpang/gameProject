#include "Water.h"

CWater::CWater(void)
{

	m_iType = 0;


	m_TexMaxNum = 0;

	m_iCol = 0; 
	m_iRow = 0;

	m_CellSize = 0;

	m_iCurTexID = 0;

	m_vPos = V3_ZERO;

	m_ftime= 0;



}

CWater::~CWater(void)
{
}
bool CWater::Init(LPDIRECT3DDEVICE9	pDevice , const char* szWater , int ID)
{

	m_pDevice = pDevice;
	CReadIniFile	iniFile(szWater);

	char sz[32] = {0};
	sprintf_s(sz , "Water%d" ,ID);
	iniFile.Go2Section(sz);


	char szFontName[128] = {0};
	char szLastName[32] = {0};

	char szPath[128] = {0};


	iniFile.ReadString("szFontName" ,szFontName );

	iniFile.ReadString("szLastName" ,szLastName );
	//最大纹理数(个数)
	iniFile.ReadInt("szNum" ,m_TexMaxNum);

	iniFile.ReadInt("iRow" , m_iRow);
	iniFile.ReadInt("iCol" , m_iCol);

	iniFile.ReadFloat("fCellSize" ,m_CellSize);

		//每行的纹理数
	int iTexSumPerRow = 0;
	iniFile.ReadInt( "iTexSumPerRow", iTexSumPerRow );

	iniFile.ReadVec3("vPos" ,m_vPos);

	iniFile.ReadFloat("fChangeTime" ,m_fChangetime);



	//顶点缓冲区
	int iVBSize = m_iRow*m_iCol * sizeof(WATER_VERTEX);

	m_pDevice->CreateVertexBuffer( iVBSize , D3DUSAGE_WRITEONLY ,FVF_WATER, D3DPOOL_MANAGED , &m_pVB , NULL);

	WATER_VERTEX* pData = NULL;

	m_pVB->Lock(0 , iVBSize , (void**)&pData ,D3DLOCK_READONLY);

	float fWidth = (m_iCol -1 ) * m_CellSize;

	float fDepth = (m_iRow -1 )* m_CellSize;

	int iCurRow = 0;
	int id = 0;

	for( float z = fDepth/2 ;z >= -fDepth/2 ; z-= m_CellSize)
	{
		int iCurCol = 0;
		for( float x = -fWidth/2 ; x<= fWidth/2 ; x+=m_CellSize)
		{

			id = iCurRow*m_iCol + iCurCol;

			pData[id].x = x;
			pData[id].y = 0;
			pData[id].z = z;

			pData[id].nx = 0;
			pData[id].ny = 1;
			pData[id].nz = 0;

			pData[id].fu = iTexSumPerRow/float(m_iCol -1) *iCurCol;
			pData[id].fv = iTexSumPerRow/float(m_iRow -1) *iCurRow;

			iCurCol++;

		}
		iCurRow++;
	}


	m_pVB->Unlock();
	//索引缓冲区
	int iIBSize = (m_iCol-1)*(m_iRow - 1) *6 *sizeof(DWORD);
	m_pDevice->CreateIndexBuffer(iIBSize , D3DUSAGE_WRITEONLY,D3DFMT_INDEX32, D3DPOOL_MANAGED , &m_pIB ,NULL);

	DWORD*	pIndex = NULL;

	m_pIB->Lock( 0 , iIBSize, (void**)&pIndex ,D3DLOCK_READONLY);

	int index = 0;

	for( int iRow = 0 ; iRow < m_iRow-1 ; iRow++)
	{
		for( int iCol = 0 ; iCol < m_iCol - 1  ; iCol++)
		{
			pIndex[index++] =  iRow * m_iCol +iCol;
			pIndex[index++] =  iRow * m_iCol +iCol + 1;
			pIndex[index++] =  iRow * m_iCol +iCol + m_iCol + 1;

			pIndex[index++] =  iRow * m_iCol +iCol;
			pIndex[index++] =  iRow * m_iCol +iCol + m_iCol + 1;
			pIndex[index++] =  iRow * m_iCol +iCol + m_iCol;
		}
	}
	m_pIB->Unlock();



//读纹理
	for (int i = 0 ; i < m_TexMaxNum ; i++)
	{
		sprintf_s(szPath , "%s%d%s" ,szFontName , i ,szLastName );

		D3DXCreateTextureFromFile(m_pDevice,szPath, &m_pTex[i]);

	}


	return true;
}

void CWater::Updata(float fElapsedTime)
{
	m_ftime += fElapsedTime;

	if(m_ftime > m_fChangetime)
	{
		m_iCurTexID++;
		if(m_iCurTexID > 29)
		{
			m_iCurTexID = 0;
		}
			m_ftime = 0;
	}

}

void CWater::Render()
{
	D3DXMATRIX	matWorld,matT,matS,matR = M44_IDENTITY;

	D3DXMatrixTranslation(&matT ,m_vPos.x,m_vPos.y,m_vPos.z);
	

	matWorld = matT;

	m_pDevice->SetTransform(D3DTS_WORLD , &matWorld);

	m_pDevice->SetStreamSource( 0 , m_pVB , 0 ,sizeof(WATER_VERTEX) );

	m_pDevice->SetFVF(FVF_WATER);

	m_pDevice->SetIndices( m_pIB );


	m_pDevice->SetTexture( 0, m_pTex[m_iCurTexID] );

	m_pDevice->SetRenderState( D3DRS_CULLMODE, D3DCULL_NONE );

	////混合方式 ARG1 op ARG2
	DWORD dwState[10];
	m_pDevice->GetTextureStageState( 0, D3DTSS_COLORARG1, &dwState[0] );
	m_pDevice->GetTextureStageState( 0, D3DTSS_COLORARG2, &dwState[1] );
	m_pDevice->GetTextureStageState( 0, D3DTSS_COLOROP, &dwState[2] );

	m_pDevice->GetSamplerState( 0, D3DSAMP_MAGFILTER, &dwState[3] );
	m_pDevice->GetSamplerState( 0, D3DSAMP_MINFILTER, &dwState[4] );


	m_pDevice->GetSamplerState( 0, D3DSAMP_ADDRESSU, &dwState[5] );
	m_pDevice->GetSamplerState( 0, D3DSAMP_ADDRESSV, &dwState[6] );


	m_pDevice->GetRenderState(D3DRS_ALPHABLENDENABLE , &dwState[7] );

	m_pDevice->GetRenderState(D3DRS_SRCBLEND , &dwState[8] );

	m_pDevice->GetRenderState(D3DRS_SRCBLEND , &dwState[9] );
	//纹理混合
	m_pDevice->SetTextureStageState( 0, D3DTSS_COLORARG1, D3DTA_TEXTURE );
	m_pDevice->SetTextureStageState( 0, D3DTSS_COLORARG2, D3DTA_DIFFUSE );
	m_pDevice->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_SELECTARG1 );


	m_pDevice->SetSamplerState( 0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );
	m_pDevice->SetSamplerState( 0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );

	m_pDevice->SetSamplerState( 0, D3DSAMP_ADDRESSU, D3DTADDRESS_WRAP );
	m_pDevice->SetSamplerState( 0, D3DSAMP_ADDRESSV, D3DTADDRESS_WRAP );


	m_pDevice->SetRenderState(  D3DRS_ALPHABLENDENABLE, TRUE );

	m_pDevice->SetRenderState(D3DRS_SRCBLEND ,D3DBLEND_SRCALPHA);

	m_pDevice->SetRenderState(D3DRS_DESTBLEND ,D3DBLEND_ONE);



	m_pDevice->DrawIndexedPrimitive( D3DPT_TRIANGLELIST, 0,0,
															m_iRow*m_iCol,
															0, (m_iRow-1)*(m_iCol-1)*2 
															);

	m_pDevice->SetTextureStageState( 0, D3DTSS_COLORARG1, dwState[0] );
	m_pDevice->SetTextureStageState( 0, D3DTSS_COLORARG2, dwState[1] );
	m_pDevice->SetTextureStageState( 0, D3DTSS_COLOROP, dwState[2] );

	

	m_pDevice->SetSamplerState( 0, D3DSAMP_MAGFILTER, dwState[3] );
	m_pDevice->SetSamplerState( 0, D3DSAMP_MINFILTER, dwState[4] );


	m_pDevice->SetSamplerState( 0, D3DSAMP_ADDRESSU, dwState[5] );
	m_pDevice->SetSamplerState( 0, D3DSAMP_ADDRESSV, dwState[6] );

	m_pDevice->SetRenderState(D3DRS_ALPHABLENDENABLE , dwState[7] );

	m_pDevice->SetRenderState(D3DRS_SRCBLEND , dwState[8] );

	m_pDevice->SetRenderState(D3DRS_SRCBLEND , dwState[9] );

	m_pDevice->SetRenderState( D3DRS_CULLMODE, D3DCULL_CCW );

	
}