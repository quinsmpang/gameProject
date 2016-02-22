//****************************************//
//										 //
//			文件读取类					 //
//										 //
//****************************************//


#pragma once
#include <Windows.h>
#include "point2d.h"
#include <d3dx9.h>

class CReadIniFile
{
private:

	//文件区结构（存放区名和区文本地址）
	struct section
	{
		fpos_t pos;
		char name[200];
	};

	FILE *m_pFile;			//定义file文件，用于打开文档
	fpos_t m_SectionPos;	//当前文本读取位置
	section *m_pSections;	//指向区数组的指针
	int m_iSectionCount;	//区数目

protected:
	int ScanSections();		//扫描区

public:	

	CReadIniFile( const char* strPathFile );
	CReadIniFile( FILE* pFile );
	virtual ~CReadIniFile(void);
	static void TrimSpace(char *str);			//去除前后空格
	static void MakeUpper(char * str);			//字符串的小写转大写
	int GetSectionCount();						//获取区数目
	const char * GetSectionNameByIndex(int i);	//通过区号获取区名（从0开始算）	
	bool Go2Section(const char *);				//跳转到指定区读取
	
	bool ReadString(const char* , char* );		//读取字符串

	bool ReadInt(const char* , int &);			//读取整型数据
	bool ReadIntArray(const char* szValueName, int * array, int num);			//读取整型数组

	bool ReadFloat(const char* szValueName, float & fValue);					//读取浮点型数据
	bool ReadFloatArray(const char* szValueName, float * array, int num);		//读取浮点型数组
	
	bool ReadDouble(const char* szValueName, double & dValue);					//读取双精度浮点型数据
	bool ReadDoubleArray(const char* szValueName, double * array, int num);		//读取双精度浮点型数组
	//读取POINT2D
	bool ReadPoint2D( const char* szValueName, POINT2D& pos );

	virtual BOOL ReadVec3(CONST CHAR* pSzName, D3DXVECTOR3& v );
	virtual BOOL ReadColor(CONST CHAR* pSzName, D3DCOLOR& clr );
	virtual BOOL ReadColorValue(CONST CHAR* pSzName, D3DCOLORVALUE& clr );
};
