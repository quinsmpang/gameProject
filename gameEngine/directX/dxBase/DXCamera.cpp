#include "DXCamera.h"

DXCamera::DXCamera(void)
{
}

DXCamera::~DXCamera(void)
{
}
bool DXCamera::Init(LPDIRECT3DDEVICE9 pDevice														//设备
					, int iType	 /*= 	CAMERA_TP*/															//类型
					, D3DXVECTOR3 vEye /*= D3DXVECTOR3(0 , 1, -10 )	*/					//眼睛点
					, D3DXVECTOR3 vLook		/*= D3DXVECTOR3(0,0,0)		*/				//看的点
					,D3DXVECTOR3 vUp		/*= D3DXVECTOR3(0,1,0)		*/					//正方向
					,float fFovy	/*=		D3DX_PI/4.0f	*/												//透视半角
					,float fAspect /*= 4.0f/3.0f */																//宽高比
					,float fNear /*= 1.0f */																			//近平面
					,float fFar  /*=  1000.0f;		*/															//远平面
					)
{
	m_pDevice = pDevice;

	m_iType = iType;

	m_vEye = vEye;

	m_vLook = vLook;

	m_vUp = vUp;

	m_fFovy = fFovy;

	m_fAspect = fAspect;

	m_fNear = fNear;

	m_fFar = fFar;

	m_marView = M44_IDENTITY;

	m_matProj = M44_IDENTITY;
	//摄像机点到观察点之间的距离
	m_fLen = D3DXVec3Length( &(m_vLook - m_vEye) );
	//俯角
	m_fPitch = asinf( (m_vEye.y - m_vLook.y) / m_fLen);
	//摆角
	m_fYaw = atan2f( (m_vEye.z-m_vLook.z), (m_vEye.x-m_vLook.x)) ;		




	return true;
}

void DXCamera::Updata()
{
	if( m_iType == CAMERA_TP)
	{
		m_vEye.x = m_vLook.x+m_fLen*cosf(m_fPitch)*cosf(m_fYaw);
		m_vEye.y = m_vLook.y+m_fLen*sinf(m_fPitch); 
		m_vEye.z = m_vLook.z+m_fLen*cosf(m_fPitch)*sinf(m_fYaw); 

	}
	else if(m_iType == CAMERA_FP)
	{
		m_vLook.x = m_vEye.x - m_fLen*cosf(m_fPitch)*cosf(m_fYaw);
		m_vLook.y = m_vEye.y - m_fLen*sinf(m_fPitch);
		m_vLook.z = m_vEye.z - m_fLen*cosf(m_fPitch)*sinf(m_fYaw);
	}

	D3DXMatrixLookAtLH( &m_marView , &m_vEye , &m_vLook , &m_vUp);
	m_pDevice->SetTransform(D3DTS_VIEW , &m_marView);


	D3DXMatrixPerspectiveFovLH( &m_matProj , m_fFovy,m_fAspect , m_fNear ,m_fFar);
	m_pDevice->SetTransform(D3DTS_PROJECTION , &m_matProj);


}