/********************************************************************
为了优化将大部分纹理压缩为dds格式，此处加入
							将文件后缀名转为dds的辅助函数。
*********************************************************************/

#pragma once


#ifndef SAFE_DELETE
#define SAFE_DELETE(p)       { if(p) { delete (p);     (p)=NULL; } }
#endif    
#ifndef SAFE_DELETE_ARRAY
#define SAFE_DELETE_ARRAY(p) { if(p) { delete[] (p);   (p)=NULL; } }
#endif    
#ifndef SAFE_RELEASE
#define SAFE_RELEASE(p)      { if(p) { (p)->Release(); (p)=NULL; } }
#endif

#ifndef V
#define V(x)           { hr = x; }
#endif
#ifndef V_RETURN
#define V_RETURN(x)    { hr = x; if( FAILED(hr) ) { return hr; } }
#endif


#define COLOR_GETAVALUE( argb ) ( (BYTE)( ( argb ) >> 24 ) )
#define COLOR_GETRVALUE( argb ) ( (BYTE)( ( argb ) >> 16 ) )
#define COLOR_GETGVALUE( argb ) ( (BYTE)( ( argb ) >> 8 ) )
#define COLOR_GETBVALUE( argb ) ( (BYTE)( argb ) )

/** 与场景混合的类型
*/
enum SceneBlendType
{
	/// 不透明
	SBT_OPAQUE = 0,
	/// Alpha半透明
	SBT_TRANSPARENT_ALPHA,
	/// 使用源颜色做Alpha因子，实现半透明
	SBT_TRANSPARENT_COLOR,
	/// 与场景颜色相加，通常用来加亮
	SBT_ADD_COLOR,
	/// 与场景颜色相加,通常用来增加原场景的细节
	SBT_ADD_ALPHA,
	/// 与场景颜色相乘
	SBT_MODULATE,
	/// 与场景颜色相乘的2倍
	SBT_MODULATE2,
	/// 使用顶点色的Alpha通道，实现半透明
	SBT_TRANSPARENT_DIFFUSE,
	SBT_MAX_NUMBER,
};

/** 路径解析
	@remarks
		.x文件中有的文件名包含路径，此函数可以将路径去掉。
*/
inline void GetRealFileName( std::string &name )
{
	size_t pos = name.find_last_of( '/' );
	if( pos != std::string::npos )
	{
		name = name.substr( pos+1, name.size()-pos-1 );
		return;
	}
	pos = name.find_last_of( '\\' );
	if( pos != std::string::npos )
	{
		name = name.substr( pos+1, name.size()-pos-1 );
		return;
	}
}

/** 向量各分量相乘
*/
D3DXVECTOR3 Vec3Mutiply( const D3DXVECTOR3 &v1, const D3DXVECTOR3 &v2 );

/** 求一个向量的“垂直”向量
*/
void Vec3Perpendicular( D3DXVECTOR3 &out, const D3DXVECTOR3 &src );

/** 已知一向量和一角度定位的锥体，求穿过锥体顶点并位于锥体内的随机向量。
	@param
		dir 已知向量，锥体的轴
	@param
		fAngle 已知角度，轴到锥体某一边的弧度
	@param
		result 返回结果。穿过锥体顶点，并且位于锥体内的向量。

	求出粒子的发射方向等于该锥体内穿过发射器位置的一条射线。
*/
void RandomDeviant( D3DXVECTOR3 &result, const D3DXVECTOR3 &dir, float fAngle );

/** 随机值： 0-1
*/
float UnitRandom();

/** 随机值： fLow-fHigh
*/
float RangeRandom(float fLow, float fHigh);

/** 随机值： (-1) - (1)
*/
float SymmetricRandom();


void ChangeFileNameToDDS( string &name );

inline DWORD F2DW( FLOAT f )
{
	return *((DWORD*)&f); 
}
inline float DW2F( DWORD dw )
{
	return *((FLOAT*)&dw); 
}
