#include "DXfog.h"

CDXfog::CDXfog(void)
{
	m_FogVector.clear();
}

CDXfog::~CDXfog(void)
{
}
bool CDXfog::Init(LPDIRECT3DDEVICE9 pDevice , const char* szFog)
{

	m_pDevice = pDevice;
	CReadIniFile iniFile(szFog);

	char sz[32] = {0};

	

	for( int i = 0 ; ; i++)
	{
		sprintf_s(sz ,"Fog%d" , i );

		if( iniFile.Go2Section(sz))
		{
			DXFOG_STRUCT*  fog = new DXFOG_STRUCT;
			
			iniFile.ReadInt( "iType" , fog->iType);

			iniFile.ReadInt( "iFogMode" , fog->iFogMode);

			iniFile.ReadColor("fogClr" , fog->fogClr);

			iniFile.ReadFloat("fStart" ,fog->fStart);

			iniFile.ReadFloat("fEnd" ,fog->fEnd);

			iniFile.ReadFloat("fDenity" ,fog->fDenity);

			m_FogVector.push_back(fog);

				
		}
		else
		{
			break;
		}
	}

	return true;
}