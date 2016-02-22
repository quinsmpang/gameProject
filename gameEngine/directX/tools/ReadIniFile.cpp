//#include "StdAfx.h"
#include <windows.h>
#include <tchar.h>
#include <iostream>

#include ".\readinifile.h"

const int MAX_CHARNUM = 255;	//每次读取最大内容数
const int MAX_SECTION = 100;	//最大区数目



//************************************
// Method:    CReadIniFile
// FullName:  CReadIniFile::CReadIniFile
// Access:    public 
// Returns:   
// Qualifier://通过传入文件名构建对象
// Parameter: const char * strPathFile
//************************************
CReadIniFile::CReadIniFile( const char* strPathFile )
{
	//打开指定文件
	m_pFile = fopen( strPathFile, "r" );

	m_SectionPos = 0;
	m_pSections = NULL;
	m_iSectionCount = 0;

	//扫描区
	ScanSections();
}



//************************************
// Method:    CReadIniFile
// FullName:  CReadIniFile::CReadIniFile
// Access:    public 
// Returns:   
// Qualifier://通过传入FILE指针构建对象
// Parameter: FILE * pFile
//************************************
CReadIniFile::CReadIniFile( FILE* pFile )
{
	m_pFile = pFile;

	m_SectionPos = 0;
	m_pSections = NULL;
	m_iSectionCount = 0;
	ScanSections();
}

CReadIniFile::~CReadIniFile(void)
{	
	if (m_pSections)
	{
		delete [] m_pSections;
		m_pSections = 0;
	}
}


//************************************
// Method:    ScanSections
// FullName:  CReadIniFile::ScanSections
// Access:    protected 
// Returns:   int
// Qualifier://扫描并记录区域
//************************************
int CReadIniFile::ScanSections()
{
	m_iSectionCount = 0;
	if (!m_pFile)
		return 0;
	char text[MAX_CHARNUM];
	memset(text, 0, sizeof(char)*MAX_CHARNUM);

	fseek(m_pFile, 0, FILE_BEGIN);

	int len;
	section temp[MAX_SECTION];

	//通过检测行内是否存在[] 判定是否属于分区
	while (fgets(text, MAX_CHARNUM, m_pFile))
	{
		TrimSpace(text);
		len = strlen(text);
		if (text[0] == '[' && text[len-1] == ']')
		{
			text[len-1] = 0;

			//获得现在文件指针读取的位置，并记录
			fgetpos(m_pFile, &temp[m_iSectionCount].pos);

			//获取区名，并记录
			strcpy(temp[m_iSectionCount].name, &text[1]);

			//小写转大写
			MakeUpper(temp[m_iSectionCount].name);

			//区数目＋＋
			m_iSectionCount++;

			//大于最大区数目，则越界
			if (m_iSectionCount >= MAX_SECTION)
			{
				m_iSectionCount = 0;
				return 0;
			}
		}
	}

	//区数目大于0，则开空间记录区
	if (m_iSectionCount > 0)
	{
		//区指针指向新开区结构数组
		m_pSections = new section[m_iSectionCount];
	}

    // 区指针记录临时存放的区结构数据
	for (int i=0; i<m_iSectionCount; i++)
	{
		strcpy(m_pSections[i].name, temp[i].name);
		m_pSections[i].pos = temp[i].pos;
	}  

	return true;
}


//************************************
// Method:    TrimSpace
// FullName:  CReadIniFile::TrimSpace
// Access:    public 
// Returns:   void
// Qualifier://去除前后空格符
// Parameter: char * str
//************************************
void CReadIniFile::TrimSpace(char *str)
{
	int len = strlen(str);
	char *temp = str;
	int i=0;
	while ((str[i] == 8 || str[i] == 9 || str[i] == 10 || str[i] == 13 || str[i] == 32) && i<len)
	{
		i++;
	}
	temp = &(str[i]);
	i = len-1;
	while ((str[i] == 8 || str[i] == 9 || str[i] == 10 || str[i] == 13 || str[i] == 32) && i>0)
	{
		i--;
	}
	str[i+1] = 0;
	strcpy(str, temp);
}


//************************************
// Method:    MakeUpper
// FullName:  CReadIniFile::MakeUpper
// Access:    public 
// Returns:   void
// Qualifier://转换为大写
// Parameter: char * str
//************************************
void CReadIniFile::MakeUpper(char * str)
{
	int len = strlen(str);
	static int off = 'A'-'a';
	for (int i=0; i<len; i++)
	{
		if (str[i] <= 'z' && str[i] >= 'a')
			str[i] += off;
	}
}

//************************************
// Method:    GetSectionCount
// FullName:  CReadIniFile::GetSectionCount
// Access:    public 
// Returns:   int
// Qualifier: //获取区数目
//************************************
int CReadIniFile::GetSectionCount()
{
	return m_iSectionCount;
}


//************************************
// Method:    GetSectionNameByIndex
// FullName:  CReadIniFile::GetSectionNameByIndex
// Access:    public 
// Returns:   const char *
// Qualifier:	//通过区号获取区名（从0开始算）
// Parameter: int i
//************************************
const char * CReadIniFile::GetSectionNameByIndex(int i)
{
	if (i<0 || i>= m_iSectionCount)
		return NULL;
	return m_pSections[i].name;
}


//************************************
// Method:    Go2Section
// FullName:  CReadIniFile::Go2Section
// Access:    public 
// Returns:   bool
// Qualifier://跳转到指定区读取
// Parameter: const char * szSectionName
//************************************
bool CReadIniFile::Go2Section(const char *szSectionName)
{
	if (!m_pFile)
		return FALSE;

	char name[MAX_CHARNUM];
	if (szSectionName[0] == '[')
	{
		strcpy(name, &szSectionName[1]);
		int len = strlen(name);
		name[len-1] = 0;
	}
	else
		strcpy(name, szSectionName);

	MakeUpper(name);

	for (int i=0; i<m_iSectionCount; i++)
	{
		if (strcmp(m_pSections[i].name, name) == 0)
		{
			m_SectionPos = m_pSections[i].pos;
			return TRUE;
		}
	}

	return FALSE;
}


//************************************
// Method:    ReadString
// FullName:  CReadIniFile::ReadString
// Access:    public 
// Returns:   bool
// Qualifier://读取字符串
// Parameter: const char * szValueName 读取的内容标识
// Parameter: char * szValue
//************************************
bool CReadIniFile::ReadString(const char *szValueName, char *szValue)
{
	if (!m_pFile)
		return FALSE;

	char text[MAX_CHARNUM];
	char name[MAX_CHARNUM];
	char value[MAX_CHARNUM];
	strcpy(name, szValueName);
	MakeUpper(name);
	memset(text, 0, sizeof(char)*MAX_CHARNUM);
	char sep[] = "=;\n";
	char *token;
	value[0] = 0;

	fsetpos(m_pFile, &m_SectionPos);

	//查找到指定位置
	while ( strcmp(value, name) != 0 )
	{
		if( strstr(text, "["))
			return FALSE;
		if (!fgets(text, MAX_CHARNUM, m_pFile))
			return FALSE;
		TrimSpace(text);
		token = strtok(text, sep);
		if (!token)
			continue;

		strcpy(value, token);
		TrimSpace(value);
		MakeUpper(value);
	}

	//抽取数据，存于需要返出的变量上
	token = strtok(NULL, sep);
	if (token != NULL)
	{
		strcpy(value, token);
		TrimSpace(value);
		memcpy(szValue, value, strlen(value)+1);
	}
	else
		return FALSE;
	return TRUE;
}


//************************************
// Method:    ReadInt
// FullName:  CReadIniFile::ReadInt
// Access:    public 
// Returns:   bool
// Qualifier://读取整型数据
// Parameter: const char * szValueName	//读取的内容标识
// Parameter: INT & iValue				存放Int的变量
//************************************
bool CReadIniFile::ReadInt(const char *szValueName, INT & iValue)
{
	char szTemp[MAX_CHARNUM];
	memset(szTemp, 0, sizeof(char)*MAX_CHARNUM);
	if (ReadString(szValueName, szTemp))
	{
		//字符串朱娜
		iValue = atoi(szTemp);
		return true;
	}
	return false;
}


//************************************
// Method:    ReadIntArray
// FullName:  CReadIniFile::ReadIntArray
// Access:    public 
// Returns:   bool
// Qualifier: //读取整型数组
// Parameter: const char * szValueName //读取的内容标识
// Parameter: int * array
// Parameter: int num
//************************************
bool CReadIniFile::ReadIntArray(const char* szValueName, int * array, int num)
{
	if (!m_pFile)
		return false;
	char szTemp[MAX_CHARNUM];
	memset(szTemp, 0, sizeof(char)*MAX_CHARNUM);
	ReadString(szValueName, szTemp);
	char sep[] = ",\n";
	char *token;

	//再次抽取，分别分离出数据
	token = strtok(szTemp, sep);
	for (int i=0; i<num; i++)
	{
		if (!token)
			return false;
		array[i] = atoi(token);
		token = strtok(NULL, sep);
	}

	return true;
}

//************************************
// Method:    ReadFloat
// FullName:  CReadIniFile::ReadFloat
// Access:    public 
// Returns:   bool
// Qualifier:
// Parameter: const char * szValueName	//读取的内容标识
// Parameter: float & fValue
//************************************
bool CReadIniFile::ReadFloat(const char* szValueName, float & fValue)
{
	char szTemp[MAX_CHARNUM];
	memset(szTemp, 0, sizeof(char)*MAX_CHARNUM);
	if (ReadString(szValueName, szTemp))
	{
		//转浮点型
		fValue = (float)atof(szTemp);
		return true;
	}
	return false;
}

//************************************
// Method:    ReadFloatArray
// FullName:  CReadIniFile::ReadFloatArray
// Access:    public 
// Returns:   bool
// Qualifier:
// Parameter: const char * szValueName	//读取的内容标识
// Parameter: float * array
// Parameter: int num
//************************************
bool CReadIniFile::ReadFloatArray(const char* szValueName, float * array, int num)
{
	if (!m_pFile)
		return false;
	char szTemp[MAX_CHARNUM];
	memset(szTemp, 0, sizeof(char)*MAX_CHARNUM);
	ReadString(szValueName, szTemp);
	char sep[] = ",\n";
	char *token;

	//抽取字符串 转化为浮点型
	token = strtok(szTemp, sep);
	for (int i=0; i<num; i++)
	{
		if (!token)
			return false;
		array[i] = (FLOAT)atof(token);
		token = strtok(NULL, sep);
	}
	return true;
}

//************************************
// Method:    ReadDouble
// FullName:  CReadIniFile::ReadDouble
// Access:    public 
// Returns:   bool
// Qualifier:
// Parameter: const char * szValueName	//读取的内容标识
// Parameter: double & dValue
//************************************
bool CReadIniFile::ReadDouble(const char* szValueName, double & dValue)
{
	char szTemp[MAX_CHARNUM];
	memset(szTemp, 0, sizeof(char)*MAX_CHARNUM);
	if (ReadString(szValueName, szTemp))
	{
		dValue = atof(szTemp);
		return true;
	}
	return false;
}

//************************************
// Method:    ReadDoubleArray
// FullName:  CReadIniFile::ReadDoubleArray
// Access:    public 
// Returns:   bool
// Qualifier:
// Parameter: const char * szValueName	读取的内容标识
// Parameter: double * array
// Parameter: int num
//************************************
bool CReadIniFile::ReadDoubleArray(const char* szValueName, double * array, int num)
{
	if (!m_pFile)
		return false;
	char szTemp[MAX_CHARNUM];
	memset(szTemp, 0, sizeof(char)*MAX_CHARNUM);
	ReadString(szValueName, szTemp);
	char sep[] = ",\n";
	char *token;

	token = strtok(szTemp, sep);
	for (int i=0; i<num; i++)
	{
		if (!token)
			return false;
		array[i] = atof(token);
		token = strtok(NULL, sep);
	}
	return true;
}



bool CReadIniFile::ReadPoint2D( const char* szValueName, POINT2D& pos )
{
	int iAry[2] = {0};

	if( ReadIntArray( szValueName, iAry, 2 ) )
	{
		pos.x = iAry[0];
		pos.y = iAry[1];
		return true;
	}

	return false;
}



BOOL CReadIniFile::ReadVec3(CONST CHAR* pSzName, D3DXVECTOR3& v )
{
	float fAry[3] = {0};

	if( ReadFloatArray( pSzName, fAry, 3 ) )
	{
		v.x = fAry[0];
		v.y = fAry[1];	
		v.z = fAry[2];
		return TRUE;
	}

	return FALSE;
}

BOOL CReadIniFile::ReadColor(CONST CHAR* pSzName, D3DCOLOR& clr )
{
	int iAry[4] = {0};

	if( ReadIntArray( pSzName, iAry, 4 ) )
	{
		clr = D3DCOLOR_ARGB( iAry[0], iAry[1], iAry[2], iAry[3] );
		return TRUE;
	}

	return FALSE;
}

BOOL CReadIniFile::ReadColorValue(CONST CHAR* pSzName, D3DCOLORVALUE& clr )
{
	float fAry[4] = {0};

	if( ReadFloatArray( pSzName, fAry, 4 ) )
	{
		clr.r = fAry[0];
		clr.g = fAry[1];	
		clr.b = fAry[2];
		clr.a = fAry[3];
		return TRUE;
	}

	return FALSE;
}



