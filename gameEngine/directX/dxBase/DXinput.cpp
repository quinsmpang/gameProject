#include "DXinput.h"

CDXinput::CDXinput(void)
{
	ZeroMemory(m_PreKBState,sizeof(m_PreKBState));
	ZeroMemory(m_CurKBState,sizeof(m_CurKBState));

	ZeroMemory(&m_PreMState,sizeof(m_PreMState));
	ZeroMemory(&m_CurMState,sizeof(m_CurMState));
}

CDXinput::~CDXinput(void)
{
}
bool CDXinput::Init(HINSTANCE hIns,HWND hWnd)
{
	m_hWnd = hWnd;
	//创建组件
	if(FAILED(DirectInput8Create(hIns,
						DIRECTINPUT_VERSION,
						IID_IDirectInput8,
						(void**)&m_pInput,
						NULL)))
	{

		MessageBox(m_hWnd,"DirectInput8 Create Failed","",MB_OK);

		return false;
	}
	//创建设备
	if(FAILED(m_pInput->CreateDevice(GUID_SysKeyboard,&m_pKeyBoard , NULL)))
	{
		MessageBox(m_hWnd, "DirectInput8 Create KeyBoard Failed", "", MB_OK );
	
		m_pInput->Release();

		return false;
	}
	//2)设置数据格式 - 标准数据对象
	m_pKeyBoard->SetDataFormat(&c_dfDIKeyboard);

	//3)
	m_pKeyBoard->SetCooperativeLevel(m_hWnd,DISCL_FOREGROUND|DISCL_NONEXCLUSIVE);
	//4)获取控制权
	m_pKeyBoard->Acquire();

	//=-==================================================================
	if(FAILED(m_pInput->CreateDevice(GUID_SysMouse,&m_pMouse,NULL)))
	{
		MessageBox(m_hWnd,"","",MB_OK);
		m_pInput->Release();
		m_pKeyBoard->Release();
		return false;

	}
	
	m_pMouse->SetDataFormat(&c_dfDIMouse);

	m_pMouse->SetCooperativeLevel(m_hWnd,DISCL_FOREGROUND|DISCL_NONEXCLUSIVE);


	m_pMouse->Acquire();


	return true;
}

void CDXinput::Update()
{
	if(m_pKeyBoard)
	{
		memcpy(&m_PreKBState,&m_CurKBState,sizeof(BYTE)*256);

		if(DI_OK != m_pKeyBoard->GetDeviceState(sizeof(byte)*256,m_CurKBState))
		{
			ZeroMemory(m_CurKBState,sizeof(m_CurKBState));

			m_pKeyBoard->Acquire();
		}

	}

	if(m_pMouse)
	{
		memcpy(&m_PreMState,&m_CurMState,sizeof(DIMOUSESTATE));

		if(DI_OK != m_pMouse->GetDeviceState(sizeof(DIMOUSESTATE),&m_CurMState))
		{
			ZeroMemory(&m_CurMState,sizeof(DIMOUSESTATE));

			m_pMouse->Acquire();
		}


	}


}