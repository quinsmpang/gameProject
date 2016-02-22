#pragma once
#include "gd.h"

enum CAMERA_TYPE_ENUM
{
	CAMERA_FP,
	CAMERA_TP
};

class DXCamera
{
public:
	DXCamera(void);

	~DXCamera(void);

	bool Init(LPDIRECT3DDEVICE9 pDevice														//设备
					, int iType	 = 	CAMERA_TP												//类型
					, D3DXVECTOR3 vEye = D3DXVECTOR3(1,36,-92 )							//眼睛点
					, D3DXVECTOR3 vLook		= D3DXVECTOR3(-1.94f,22.21f,54.48f)							//看的点
					,D3DXVECTOR3 vUp		= D3DXVECTOR3(0,1,0)							//正方向
					,float fFovy	=		D3DX_PI/4.0f									//透视半角
					,float fAspect = 4.0f/3.0f												//宽高比
					,float fNear = 0.01f														//近平面
					,float fFar  =  100000.0f													//远平面
					);

	 void Updata();

	 void CalcPitch(float f , float fk = 0.02f)
	 {
		 if( m_fPitch+f*fk > -D3DX_PI/2 && m_fPitch+f*fk < D3DX_PI/2 )
		 {
			 m_fPitch += f*fk;
		 }	
	 }

	 void CalcYaw( float f, float fk = 0.02f  )
	 {
		m_fYaw += f * fk;
	 }

	void CalcLen( float f, float fk = 0.01f  )
	{
		if( m_fLen+f*fk > 0 && m_fLen+f*fk < m_fFar )
		{
			m_fLen += f*fk;
		}		

	}
	D3DXVECTOR3 GetEyeVector()
	{
		return m_vEye;
	}

	D3DXVECTOR3 GetRight()
	{
		D3DXVECTOR3 vRight;
		D3DXVec3Cross( &vRight, &m_vUp, &(m_vLook-m_vEye) );
		D3DXVec3Normalize( &vRight, &vRight );
		return vRight;
	}

	D3DXVECTOR3 GetFront()
	{
		D3DXVECTOR3 vFront;
		D3DXVECTOR3 vE = m_vEye;
		vE.y = m_vLook.y;
		D3DXVec3Normalize( &vFront, &(m_vLook-vE) );
		
		return vFront;
	}

	void SetEye( D3DXVECTOR3 v )
	{
		m_vEye = v;
	}
	D3DXVECTOR3 GetEye()
	{
		return m_vEye;
	}

	void SetLook( D3DXVECTOR3 v)
	{
		m_vLook = v;
	}
	D3DXVECTOR3 GetLookAt()
	{
		return m_vLook;
	}
	void SetType( int Type)
	{
		m_iType = Type;
	}
	int GetType( )
	{
		return m_iType ;
	}

	float GetYaw()
	{
		return m_fYaw;
	}


private:
		LPDIRECT3DDEVICE9	m_pDevice;

		int								m_iType;
		//视图
		D3DXMATRIX				m_marView;

		D3DXVECTOR3				m_vEye ;

		D3DXVECTOR3				m_vLook;

		D3DXVECTOR3				m_vUp;


		
		float						m_fLen;		//eye到lookat的距离
		float						m_fPitch;  //仰角
		float						m_fYaw;		//摆角
		


		//投影
		D3DXMATRIX							m_matProj;
		float								m_fFovy;

		float								m_fAspect;

		float								m_fNear;

		float								m_fFar; 

};
