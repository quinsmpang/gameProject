#pragma once
#include <d3d9.h>
#include <d3dx9.h>


#ifndef V3_OUT
#define V3_OUT(v) {cout<<v.x<<","<<v.y<<","<<v.z<<endl;}
#endif

//零向量
#ifndef V3_ZERO
#define V3_ZERO D3DXVECTOR3(0,0,0)
#endif

#ifndef V3_ALLONE
#define V3_ALLONE D3DXVECTOR3(1.0f,1.0f,1.0f)
#endif

#ifndef V3_X
#define V3_X D3DXVECTOR3(1.0f,0.0f,0.0f)
#endif

#ifndef V3_Y
#define V3_Y D3DXVECTOR3(0.0f,1.0f,0.0f)
#endif

#ifndef V3_Z
#define V3_Z D3DXVECTOR3(0.0f,0.0f,1.0f)
#endif

//-------------------------------------------------------------------------------------------------------
#ifndef M44_OUT
#define M44_OUT(m) { for(int i=0; i<4; i++){ for(int j=0;j<4;j++){ cout<<m(i,j)<<" ";} cout<<endl;}}
#endif

//单位矩阵
#ifndef M44_IDENTITY
#define M44_IDENTITY D3DXMATRIX(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 )
#endif

//顶点   
struct Plane_Vertex
{
	float x,y,z;

	float u,v;
};

//输出框
int MB( const char* szText, 
	   const char* szTitle = "", 
	   int iStyle  = MB_OK);


//浮点插值运算
float Lerpf( float a, float b, float t );

//获取最大值
template<class T>
T GetMax( T a, T b, T c)
{
	return (a>b)?(a>c?a:c):(b>c?b:c);
}



//----------------全局函数------------------------------//
//欧拉角(旋转值)转方向
D3DXVECTOR3 RotToDir( D3DXVECTOR3 vRot,
					 D3DXVECTOR3 vBaseDir = D3DXVECTOR3(0,0,1)
					 );


//--------------------3D2D转换--------------------------//
//2D转3D
D3DXVECTOR3		DX2DTo3D(LPDIRECT3DDEVICE9	pDevice,D3DXVECTOR3 vPosScreen);
//3D转2D
D3DXVECTOR3		DX3DTo2D(LPDIRECT3DDEVICE9	pDevice,D3DXVECTOR3 vPosWorld);


//画线
void RenderLine( D3DXVECTOR3 vStart,D3DXVECTOR3 vEnd,LPDIRECT3DDEVICE9 pDevice );

//-------------------几何体----------------------------//
struct DXTRIANGLE;
struct DXSPHERE;
struct DXAABB;
//-------------------射线------------------------------//
struct DXRAY
{
	D3DXVECTOR3 vP0;  //起点
	D3DXVECTOR3 vDir; //方向

	DXRAY();

	//2个点构建(v0起点,如果iType==0,v1是射线方向,
	//否则v1为射线上的某一个点)
	DXRAY( D3DXVECTOR3 v0, D3DXVECTOR3 v1, int iType = 0 );

	//点相交
	bool Intersect( D3DXVECTOR3 vPoint );

	//与另一条射线相交(参数:射线,返回交点 )
	bool Intersect( DXRAY ray, D3DXVECTOR3* pvInterPoint = NULL );

	//射线与平面相交(参数:平面, 射线的长度,返回交点 )
	bool Intersect( D3DXPLANE pl, 
		float d = 1000, 
		D3DXVECTOR3* pvInterPoint = NULL );

	//是否与三角形相交( 参数:三角形,返回的距离)
	bool IntersectTri( DXTRIANGLE tri, float* pfDist = NULL );

	//是否与三角形相交( 参数:三角形,返回的交点)
	bool IntersectTri( DXTRIANGLE tri, D3DXVECTOR3* pvInterPoint = NULL );

};
//------------------三角形--------------------------------------------------------------------------------
struct DXTRIANGLE 
{
	D3DXVECTOR3 v1,v2,v3;

	DXTRIANGLE();

	DXTRIANGLE(D3DXVECTOR3 _v1,D3DXVECTOR3 _v2,D3DXVECTOR3 _v3);
	//获取重心
	D3DXVECTOR3 GetBarycenter()
	{
		return (v1+v2+v3)/3;
	}
	void SetPos(D3DXVECTOR3 _v1,D3DXVECTOR3 _v2,D3DXVECTOR3 _v3)
	{
		v1 = _v1;
		v2 = _v2;
		v3 = _v3;
	}
	//获取面积
	float  GetArea();
	//获取周长
	float GetPerimeter();
	//获取内心
	D3DXVECTOR3 GetInCenter( float* pfR );
	//获取外心
	D3DXVECTOR3 GetOutCenter( float* pfR );
	//一个点是否在三角形内
	bool IsPointIn( D3DXVECTOR3 v );
	//是否与射线相交( 参数:射线,返回的距离)
	bool IntersectRay( DXRAY ray, float* pfDist = NULL );

	//是否与射线相交( 参数:射线,返回的交点)
	bool IntersectRay( DXRAY ray, D3DXVECTOR3* pvInterPoint = NULL );

};
//-----球-------------------------------------------------------------------------------------------------
struct DXSPHERE
{
	D3DXVECTOR3 v0;

	float fR;

	DXSPHERE();

	DXSPHERE(D3DXVECTOR3 _v0,float _fR);

	void Transform( D3DXMATRIX mat );
	//获取体积
	float GetVolume();
	//获取表面积
	float GetArea();
	//点是否在圆内
	bool IsPointIn(D3DXVECTOR3  v);
	//是否与射线相交
	bool IntersectRay(DXRAY  ray,float* pfDist = NULL);
	//是否与平面相交
	bool IntersectPlane(D3DXPLANE  pl,float* pfDist = NULL);
	//是否与球相交
	bool IntersectSphere(DXSPHERE  sphere, float* pfdist = NULL);
	//是否与AABB相交
	bool IntersectAABB(DXAABB aabb,float* pfDist = NULL);


};


//-----AABB-----------------------------------------------------------------------------------------------
struct DXAABB
{
	D3DXVECTOR3	vMin,vMax;

	DXAABB();

	DXAABB(D3DXVECTOR3 _vMin,D3DXVECTOR3 _vMax);

	DXAABB(DXSPHERE sphere,bool bInside = true);
	//获取中心
	D3DXVECTOR3	GetCenter()
	{
		return (vMin+vMax)*0.5f;
	}
	//AABB变换
	void	TransForm(D3DXMATRIX  mat);

	//求一点在AABB上的最近点
	D3DXVECTOR3		GetClosestPoint(D3DXVECTOR3	vPoint);

	//与射线相交
	bool IntersectRay(DXRAY	ray,float* pfDist = NULL);
	//球相交
	bool IntersectSphere(DXSPHERE sphere);
	//与AABB相交
	bool IntersectAABB(DXAABB ab);
};

//------圆-------------------------------------------------------------------------------------------------
struct	DXCIRCLE
{
	D3DXVECTOR3 v0;   //圆心
	float		fR;   //半径

	DXCIRCLE();

	DXCIRCLE(D3DXVECTOR3	_v0, float _fR);
	//获取面积
	float GetArea();
	//获取周长
	float	GetPerimeter();
};