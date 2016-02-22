#include "DXSprint.h"

DXSprint::DXSprint(void)
{
	m_pDevice = NULL;

	m_iXCount = 0;

	m_iYCount = 0;

	m_pTex= NULL;//纹理

	m_pSprite = NULL;//精灵

	m_szFile = 0;//文件路径 


	m_iFx = 0;
	m_iFy = 0;

	m_iW = 0;//单位宽
	m_iH = 0;//单位高

	m_iCurTime = 0;//当前时间
	m_iPreTime = 0;//过去时间 

	m_iCurFrame = 0;//当前帧X
	m_iCurAction = 0;///当前帧Y


	m_iFarmeV = 0;

	m_iFarmeCount = 0;


}

DXSprint::~DXSprint(void)
{
	m_pTex -> Release();//纹理

	m_pSprite -> Release();//精灵
}
//读图

bool DXSprint::Load(LPDIRECT3DDEVICE9 pDevice,const char* szFile ,int iXCount ,int iYCount,float iFx , float iFy,int iFarmeV,D3DCOLOR	AlphablendClr)
{
		m_pDevice = pDevice;

		m_iXCount = iXCount;

		m_iYCount = iYCount;

		m_iFx = iFx;
		m_iFy = iFy;

		m_iFarmeV = iFarmeV;

		D3DXIMAGE_INFO info;

		D3DXCreateTextureFromFileEx(m_pDevice,
									   szFile,
									   D3DX_DEFAULT_NONPOW2,
									   D3DX_DEFAULT_NONPOW2,//宽高-不弄成2的n次方
									   1,					//多层渐进纹理层数
									   0,
									   D3DFMT_UNKNOWN,//色彩格式
									   D3DPOOL_DEFAULT, //存放的内存-显存
									   D3DX_DEFAULT,  //过滤方式
									   D3DX_DEFAULT, //多层渐进过滤方式
									   AlphablendClr,  //透明的颜色
									   &info,  //返回图片信息
									   NULL,  //调色板
									   &m_pTex
									);

		D3DXCreateSprite(m_pDevice,&m_pSprite);

		m_iW = info.Width/m_iXCount;
		m_iH = info.Height/m_iYCount;

		m_iCurFrame = 0;

	

		m_iCurTime = timeGetTime();

		m_iPreTime = m_iCurTime;

		return true;

}
//绘画

void DXSprint::Render(int x,int y,float fAngle /*= 0*/, float fScalW /*= 1*/, float fScalH /*= 1*/, D3DCOLOR AlphablendClr )
{
	m_pSprite->Begin( D3DXSPRITE_ALPHABLEND );


	float fX = m_iW*m_iFx*fScalW;
	float fY = m_iH*m_iFy*fScalH;

	D3DXMatrixTransformation2D( &m_mat,
		&D3DXVECTOR2(0,0),//缩放的中心点
		0,//
		&D3DXVECTOR2(fScalW,fScalH),//缩放值
		&D3DXVECTOR2( fX,fY ),//旋转中心
		fAngle,//旋转角度
		&D3DXVECTOR2(x-fX, y-fY )//位置
		);

	m_pSprite->SetTransform( &m_mat );

	


	RECT rect = 
	{
		m_iCurFrame*m_iW,
		m_iCurAction*m_iH,
		m_iCurFrame*m_iW+m_iW,
		m_iCurAction*m_iH+m_iH
	};

	m_pSprite->Draw( m_pTex, &rect, NULL, NULL,AlphablendClr );
	


	m_pSprite->End();
}
//绘图

void DXSprint::Render(D3DXVECTOR3 vPos, float fAngle /*= 0*/, float fScalW /*= 1*/, float fScalH /*= 1*/ , D3DCOLOR AlphablendClr /*= D3DCOLOR_ARGB(255,255,255,255)*/)
{
		Render(vPos.x ,vPos.y ,fAngle,fScalW,fScalH , AlphablendClr);
}

//换帧
bool DXSprint::ChangeFarme( int i  )
{

	m_iFarmeCount = 0;
	if(m_iFarmeV != 0)
	{
		m_iCurTime = timeGetTime();

		if(m_iFarmeCount < i)
		{
			if(m_iCurTime - m_iPreTime >= 1000/m_iFarmeV)
			{
				m_iCurFrame++;

				if(m_iCurFrame >= m_iXCount)
				{
					m_iCurFrame = 0;
					
					m_iCurAction++;
					if(m_iCurAction >= m_iYCount)
					{
						m_iCurAction = 0;

						m_iFarmeCount++;
						return true;
					}
					return true;
				}
				
				m_iPreTime = m_iCurTime;
			}
		}

	}
		return false;
}