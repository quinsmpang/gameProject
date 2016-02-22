#pragma once
#include "gd.h"

class CDXFont
{
public:
	CDXFont(void);

	~CDXFont(void);

	bool Init(LPDIRECT3DDEVICE9 pDevice , const char* szIni);

	void Draw2D(int id , D3DXVECTOR3 v , char* szText , D3DXCOLOR clr = D3DCOLOR_XRGB(255,255,255));

	void Draw2D(int id , D3DXVECTOR3 v , int value , D3DXCOLOR clr = D3DCOLOR_XRGB(255,255,255));

	void Draw2D(int id , D3DXVECTOR3 v , float value , D3DXCOLOR clr = D3DCOLOR_XRGB(255,255,255));

	void Draw2D( int id,D3DXVECTOR3 v, D3DXVECTOR3 vOut,D3DCOLOR clr  = D3DCOLOR_XRGB( 255,255,255 ));

	void Draw3D(int id , D3DXVECTOR3 v , char* szText , D3DXCOLOR clr = D3DCOLOR_XRGB(255,255,255));

private:

	LPDIRECT3DDEVICE9 m_pDevice;

	vector<LPD3DXFONT> m_pFontVector;

	LPD3DXSPRITE			m_pSprite;


};
