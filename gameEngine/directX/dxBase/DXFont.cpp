#include "DXFont.h"

CDXFont::CDXFont(void)
{
	m_pFontVector.clear();
}

CDXFont::~CDXFont(void)
{
}
bool CDXFont::Init(LPDIRECT3DDEVICE9 pDevice , const char* szIni)
{
	m_pDevice = pDevice;

	CReadIniFile iniFile(szIni);

	char sz[128] = {0};

	int		iSize = 0;
	int		iWeigth = 0;
	int     iItalic = 0;
	char	szFaceName[32] = {0};
	for ( int i = 0 ; ; i ++)
	{
		sprintf_s(sz , "Font%d" , i );

		if(iniFile.Go2Section(sz))
		{
			iniFile.ReadInt( "iSize" , iSize );

			iniFile.ReadInt( "iWeight" , iWeigth );

			iniFile.ReadInt( "bItalic" , iItalic );

			iniFile.ReadString("szFaceName" , szFaceName);

			LPD3DXFONT pFont = NULL;

			if( FAILED( D3DXCreateFont(m_pDevice,iSize,0,iWeigth,1,(iItalic!=0?true:false),GB2312_CHARSET,NULL,NULL,NULL,szFaceName,&pFont) ))
			{
				MessageBox(NULL,"D3DXCreateFont FAILED","",MB_OK);
				MB("D3DXCreateFont FAILED","",MB_OK);
				
			}
			
			m_pFontVector.push_back(pFont);
		}
		else
		{
			break;
		}
	}

	D3DXCreateSprite( m_pDevice, &m_pSprite );

	return true;

}

void CDXFont::Draw2D(int id , D3DXVECTOR3 v , char* szText , D3DXCOLOR clr)
{
	if ( id<0 || id >= (int)m_pFontVector.size() )
	{
		return;
	}

	RECT rc = { (long)v.x, (long)v.y, GAME_WIDTH,GAME_HEIGHT };

	m_pFontVector[id]->DrawTextA( NULL, szText, -1,
		&rc,
		DT_LEFT|DT_TOP,
		clr
		);
}

void CDXFont::Draw2D(int id , D3DXVECTOR3 v , int value , D3DXCOLOR clr)
{	
	char sz[32] = {0};
	itoa(value , sz , 10);

	if ( id<0 || id >= (int)m_pFontVector.size() )
	{
		return;
	}

	RECT rc = { (long)v.x, (long)v.y, GAME_WIDTH,GAME_HEIGHT };

	m_pFontVector[id]->DrawTextA( NULL, sz, -1,
		&rc,
		DT_LEFT|DT_TOP,
		clr
		);
	
}
void CDXFont::Draw2D(int id , D3DXVECTOR3 v , float value , D3DXCOLOR clr )
{
	char sz[32] = {0};

	sprintf_s(sz , "%f" ,value );

	if ( id<0 || id >= (int)m_pFontVector.size() )
	{
		return;
	}

	RECT rc = { (long)v.x, (long)v.y, GAME_WIDTH,GAME_HEIGHT };

	m_pFontVector[id]->DrawTextA( NULL, sz, -1,
		&rc,
		DT_LEFT|DT_TOP,
		clr
		);

}

void CDXFont::Draw2D( int id,D3DXVECTOR3 v, D3DXVECTOR3 vOut,D3DCOLOR clr )
{
	char szTex[64] = {0};

	sprintf_s( szTex, "%.2f,%.2f,%.2f", vOut.x, vOut.y, vOut.z );

	Draw2D( id, v, szTex, clr );
}
//
void CDXFont::Draw3D(int id , D3DXVECTOR3 v , char* szText , D3DXCOLOR clr)
{

	m_pSprite->Begin(D3DXSPRITE_OBJECTSPACE|D3DXSPRITE_ALPHABLEND);

	D3DXMATRIX		mat,matView = M44_IDENTITY;

	m_pDevice->GetTransform(D3DTS_VIEW,&matView);

	D3DXMatrixInverse(&matView,NULL,&matView);

	matView._41 = v.x;
	matView._42 = v.y;
	matView._43 = v.z;

	D3DXMATRIX matScal;
	D3DXMatrixScaling( &matScal, 0.01f,0.01f,0.01f );
	matView = matScal*matView;

	D3DXMatrixRotationX( &mat , D3DX_PI);

	mat *= matView;

	m_pDevice->SetTransform( D3DTS_WORLD , &mat );

	RECT rc = {-400,0,400,600 };

	m_pFontVector[id] ->DrawText(m_pSprite , szText , -1 ,&rc , DT_CENTER|DT_TOP,clr);

	m_pSprite->End();





}