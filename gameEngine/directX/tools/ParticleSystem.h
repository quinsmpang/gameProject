
#ifndef PARTICLE_H_INCLUDED_Y_
#define PARTICLE_H_INCLUDED_Y_

#include <math.h>
#include ".\readinifile.h"

// Helper function to stuff a FLOAT into a DWORD argument
inline DWORD FtoDW( FLOAT f ) { return *((DWORD*)&f); }

#ifndef SAFE_DELETE
#define SAFE_DELETE(p)       { if(p) { delete (p);     (p)=NULL; } }
#endif

#ifndef SAFE_DELETE_ARRAY
#define SAFE_DELETE_ARRAY(p) { if(p) { delete[] (p);   (p)=NULL; } }
#endif

#ifndef SAFE_RELEASE
#define SAFE_RELEASE(p)      { if(p) { (p)->Release(); (p)=NULL; } }
#endif

#define	EMITTERTYPE_PLANAR_QUADRATE		0x0001		//方形
#define	EMITTERTYPE_PLANAR_ROUND		0x0002		
#define	EMITTERTYPE_CUBLIC				0x0011
#define	EMITTERTYPE_BALL				0x0012
#define EMITTERTYPE_POINTLIST			0x0021
#define	EMITTERTYPE_TRIANGLELIST		0x0022
#define EMITTERTYPE_CUSTOM				0xF001

#define PARTICLETYPE_SINGLE				0x0001
#define PARTICLETYPE_STRIP				0x0002

#define D3DFVF_PARTICILE D3DFVF_XYZ|D3DFVF_DIFFUSE

#define STRTEMP_SIZE 128



//-----------------------------------------------------------------------------
// Name:
// Desc:
//-----------------------------------------------------------------------------
class CParticleSystem
{
protected:

	//灵活顶点格式
	struct POINTVERTEX
	{
		D3DXVECTOR3 v;
		D3DCOLOR    color;
	};

	//粒子属性结构体
	struct PARTICLE
	{
		D3DXVECTOR3 m_vPos;       // 当前位置
		D3DXVECTOR3 m_vVel;       // 当前速度

		D3DXVECTOR3 m_vPos0;      // 初始位置
		D3DXVECTOR3 m_vVel0;      // 初始速度

		FLOAT       m_fTime0;     // 创建时间
		FLOAT       m_fFade;      // 权重 颜色的过渡
		DWORD		m_clrEmit;		//起始颜色
		DWORD		m_clrFade;		//颜色衰减

		PARTICLE*   m_pNext;      // 下一个粒子
	};

protected:
	float	  m_fGravity;		//加速度
	float	  m_fParticleLife;//生存周期
	float	  m_fParticleFade;//衰减
	float	  m_EmitRate;	//发射速率
	float	  m_EmitVel;	//初始速度
	float	  m_EmitAngle;	//发射的角度
	float	  m_EmitWidth;	//发射器宽度

	float	  m_fParticleSize; //粒子的大小
	float	  m_fTime;			//计算时间

	DWORD	  m_dwType;		//发射器类型

	DWORD     m_dwBase;		//当前使用的是缓冲区中的渲染的顶点起始位置
	DWORD     m_dwFlush;	//顶点小块的大小,每次渲染这一小块
	DWORD     m_dwDiscard;	//顶点数量

	DWORD     m_dwParticles;	//粒子数量
	DWORD     m_dwParticlesLim;	//粒子数量限制

	DWORD		m_clrEmit;		//起始颜色
	DWORD		m_clrFade;		//颜色衰减

	D3DXVECTOR3 m_vPosition;	//位置,世界坐标的位置,
	D3DXVECTOR3 m_vDirection;	//方向
	D3DXMATRIX  m_mDir;			

	PARTICLE* m_pParticles;		//活动粒子链表
	PARTICLE* m_pParticlesFree;	//空闲粒子链表

	// Geometry
	LPDIRECT3DVERTEXBUFFER9 m_pVB;	//顶点缓冲区指针
	LPDIRECT3DDEVICE9	m_pDevice;	//设备
	LPDIRECT3DTEXTURE9	m_pTexture;	//纹理

private:	
	
	//更新
	HRESULT Update( float fSecsPerFrame );

	//颜色的插值过渡
	DWORD	ColorLerp(DWORD color1,DWORD color2,float fWeight);

public:
	CParticleSystem(LPDIRECT3DDEVICE9 pDevice );

	~CParticleSystem();

	HRESULT RestoreDeviceObjects();
	HRESULT InvalidateDeviceObjects();



	//设置位置  （停止使用）
	void SetStartPosition(D3DXVECTOR3 pV) {m_vPosition = pV;};

	//设置角度
	void SetYawPitch(float yaw, float pitch);

	//通过位置读取配置数据
	HRESULT LoadFromFile(char* strFile,char *strSection);

	//渲染（ 帧间隔时间，位置）
	HRESULT Render( float fSecsPerFrame, D3DXVECTOR3 vPos = D3DXVECTOR3(0,0,0 ) );
};



#endif	// PARTICLE_H_INCLUDED