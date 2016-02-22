#pragma once

#include <dinput.h>

#pragma comment (lib,"dinput8.lib")
#pragma comment (lib, "dxguid.lib")

enum  DIMOUSE_KEY_ENUM
{
	DIK_LBUTTON = 1000,
	DIK_RBUTTON,
	DIK_MBUTTON
};

class CDXinput
{
public:
	CDXinput(void);

	~CDXinput(void);

	 bool Init(HINSTANCE hIns,HWND hWnd);

	 void Update();

	 bool	KeyDown(int iKey)
	 {
		 if(iKey >= 1000 )
		 {
				return (!(m_PreMState.rgbButtons[iKey - 1000] & 0x80 )
					&&(m_CurMState.rgbButtons[iKey - 1000] & 0x80));
		 }
		return		 (!(m_PreKBState[iKey]&0x80  )
						&&(m_CurKBState[iKey]&0x80));
	 }

	bool  KeyHold(int iKey)
	{

		if(iKey >= 1000 )
		{
			return ((m_PreMState.rgbButtons[iKey - 1000] & 0x80) &&
					(m_CurMState.rgbButtons[iKey - 1000] & 0x80));
		}
		
		return ((m_PreKBState[iKey]&0x80) &&
			(m_CurKBState[iKey]&0x80));
	}

	bool  KeyUp(int iKey)
	{
		if(iKey >= 1000)
		{
			return (m_PreMState.rgbButtons[iKey - 1000] & 0x80) &&
					!(m_CurMState.rgbButtons[iKey - 1000] & 0x80);
		}
		return (m_PreKBState[iKey]&0x80)&&
				!(m_CurKBState[iKey]&0x80);
	}

	long GetMouseMoveX()
	{
		return m_CurMState.lX;
	}

	long GetMouseMoveY()
	{
		return m_CurMState.lY;
	}
	
	long GetMouseMoveZ()
	{
		return m_CurMState.lZ;
	}

		//获取鼠标位置
	POINT GetMousePos()
	{
		POINT p = {0,0};

		//获取光标相对屏幕的位置
		::GetCursorPos( &p );

		//屏幕坐标转换为指定窗口的坐标
		::ScreenToClient( m_hWnd, &p );

		return p;	
	}

	bool IsMouseOver()
	{
		POINT p;
		::GetCursorPos( &p );

		RECT rc;
		::GetWindowRect( m_hWnd, &rc );

		if( ::PtInRect( &rc, p) )
		{
			return false;
		}

		return true;
	}


private:
	HWND					m_hWnd;

	LPDIRECTINPUT8			m_pInput;

	LPDIRECTINPUTDEVICE8	m_pKeyBoard;

	byte					m_PreKBState[256];
	byte					m_CurKBState[256];

	LPDIRECTINPUTDEVICE8	m_pMouse;

	DIMOUSESTATE			m_PreMState;
	DIMOUSESTATE			m_CurMState;

};
