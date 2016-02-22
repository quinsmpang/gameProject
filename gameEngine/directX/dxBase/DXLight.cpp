#include "DXLight.h"

CDXLight::CDXLight(void)
{
	m_LightVector.clear();
}

CDXLight::~CDXLight(void)
{
}
bool CDXLight::Init(LPDIRECT3DDEVICE9	pDevice , const char* szFile)
{
	m_pDevice = pDevice;

	CReadIniFile	iniFile(szFile);

	char szSecName[32] = {0};

	int Type = 0;
	D3DXVECTOR3 v;

	for (int i = 0 ;; i++)
	{
		sprintf_s(szSecName , "Light%d" ,i);

		if(iniFile.Go2Section(szSecName))
		{
			D3DLIGHT9* pLight = new D3DLIGHT9;

			iniFile.ReadInt( "Type" ,Type);

			pLight->Type = (D3DLIGHTTYPE)Type;
			//漫反射
			iniFile.ReadColorValue( "Diffuse" ,pLight->Diffuse);
			//镜面反射; 
			iniFile.ReadColorValue( "Specular" , pLight->Specular );
			//环境光;
			iniFile.ReadColorValue( "Ambient" , pLight->Ambient  );
			//位置 
			iniFile.ReadVec3( "Position" , v);
			pLight->Position = v;
			//方向
			iniFile.ReadVec3( "Direction" , v);
			pLight->Direction = v;
			//灯作用范围
			iniFile.ReadFloat( "Range" , pLight->Range);
			//内锥往外锥衰减
			iniFile.ReadFloat( "Falloff" , pLight->Falloff );
			//常量距离衰减
			iniFile.ReadFloat( "Attenuation0" , pLight->Attenuation0 );
			//线性距离衰减
			iniFile.ReadFloat( "Attenuation1" , pLight->Attenuation1 );
			//二次距离衰减  
			iniFile.ReadFloat( "Attenuation2" , pLight->Attenuation2 );
			//内锥角度 
			iniFile.ReadFloat( "Theta" , pLight->Theta );
			//外锥角度
			iniFile.ReadFloat( "Phi" , pLight->Phi );

			m_LightVector.push_back(pLight);
			

		}
		else
		{
			break;
		}
	}

	return true;
}