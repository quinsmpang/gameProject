#include "dxmath.h"
#include "GD.h"

//输出框
int MB( const char* szText, 
	   const char* szTitle, 
	   int iStyle )
{
	return MessageBox( FindWindow(CLASS_NAME, TITLE_NAME),
		szText,
		szTitle,
		iStyle 
		);
}

//浮点插值运算
float Lerpf( float a, float b, float t )
{
	return a*(1.0f-t)+b*t;
}


//----------------全局函数------------------//
//欧拉角(旋转值)转方向

D3DXVECTOR3 RotToDir( D3DXVECTOR3 vRot,
					  D3DXVECTOR3 vBaseDir 
					  )
{
	D3DXMATRIX	mat;

	D3DXMatrixRotationYawPitchRoll(&mat,vRot.y,vRot.x,vRot.z);

	D3DXVec3Normalize(&vBaseDir,&vBaseDir);

	D3DXVec3TransformNormal(&vBaseDir,&vBaseDir,&mat);

	return vBaseDir;

}


//2D转3D
D3DXVECTOR3		DX2DTo3D(LPDIRECT3DDEVICE9	pDevice,D3DXVECTOR3 vPosScreen)
{
	D3DVIEWPORT9	vp;
	D3DXVECTOR3		v(0,0,0);

	pDevice->GetViewport(&vp);

	D3DXMATRIX	matWorld, matView, matProj;

	D3DXMatrixIdentity( &matWorld );

	pDevice->GetTransform(D3DTS_VIEW, &matView);

	pDevice->GetTransform(D3DTS_PROJECTION, &matProj);

	D3DXVec3Unproject( &v ,&vPosScreen,&vp,&matProj,&matView,&matWorld);

	return v;
}
//3D转2D
D3DXVECTOR3		DX3DTo2D(LPDIRECT3DDEVICE9	pDevice,D3DXVECTOR3 vPosWorld)
{
	D3DVIEWPORT9	vp;
	D3DXVECTOR3		v(0,0,0);

	pDevice->GetViewport(&vp);

	D3DXMATRIX	matWorld, matView, matProj;

	D3DXMatrixIdentity( &matWorld );

	pDevice->GetTransform(D3DTS_VIEW, &matView);

	pDevice->GetTransform(D3DTS_PROJECTION, &matProj);

	D3DXVec3Project( &v ,&vPosWorld,&vp,&matProj,&matView,&matWorld);

	return v;
}

//画线
void RenderLine( D3DXVECTOR3 vStart,D3DXVECTOR3 vEnd,LPDIRECT3DDEVICE9 pDevice )
{
	struct FVF_LINE
	{
		D3DXVECTOR3 vPos;
		D3DCOLOR clr;
	};

	FVF_LINE line[]=
	{
		vStart, 0xffff00ff,
		vEnd,0xff00ff00
	};

	D3DXMATRIX mat;
	D3DXMatrixIdentity( &mat );

	pDevice->SetTransform( D3DTS_WORLD,&mat );
	pDevice->SetFVF( D3DFVF_XYZ | D3DFVF_DIFFUSE );

	pDevice->DrawPrimitiveUP( D3DPT_LINELIST, 1, (void*)line,sizeof(FVF_LINE) );

}
//-------------------几何体-------------------//
//-------------------射线-------------------//

DXRAY::DXRAY()
{
	vP0 = V3_ZERO;
	vDir = V3_X;
}

//2个点构建(v0起点,如果iType==0,v1是射线方向,
//否则v1为射线上的某一个点)
DXRAY::DXRAY( D3DXVECTOR3 v0, D3DXVECTOR3 v1, int iType )
{
	vP0 = v0;

	if ( iType == 0 )
	{
		D3DXVec3Normalize( &vDir, &v1 );
	}
	else
	{
		D3DXVec3Normalize( &vDir, &(v1-v0) );
	}

}

//点相交
bool DXRAY::Intersect( D3DXVECTOR3 vPoint )
{
	D3DXVECTOR3 v;
	D3DXVec3Normalize( &v, &(vPoint-vP0) );

	if ( vDir == v )
	{
		return true;
	}

	return false;
}

//与另一条射线相交
bool DXRAY::Intersect( DXRAY ray, D3DXVECTOR3* pvInterPoint )
{
	//Pt = vP0 + vDir*t;  
	//Pt是射线上某一个点, 
	//t大于0的变化值,离起点的距离
	//vP0 + vDir*t = ray.vP0 + ray.vDir*t2;
	D3DXVECTOR3 vCross;
	D3DXVec3Cross( &vCross, &vDir, &ray.vDir );
	float fCrossLen = D3DXVec3Length( &vCross );

	if( fCrossLen == 0.0f )
	{
		return false;
	}

	D3DXVECTOR3 vCross0(0,0,0);
	D3DXVec3Cross( &vCross0, &(ray.vP0-vP0), &ray.vDir );
	float t1 = D3DXVec3Dot( &vCross0, &vCross )/(fCrossLen*fCrossLen);

	D3DXVECTOR3 vCross1(0,0,0);
	D3DXVec3Cross( &vCross1, &(ray.vP0-vP0), &vDir );
	float t2 = D3DXVec3Dot( &vCross1, &vCross )/(fCrossLen*fCrossLen);	

	if( t1 > 0 && t2 > 0 )
	{
		D3DXVECTOR3 vPt0 = vP0+vDir*t1;
		D3DXVECTOR3 vPt1 = ray.vP0 + ray.vDir*t2;

		if ( vPt0 == vPt1 )
		{
			if ( pvInterPoint )
			{
				*pvInterPoint = vPt0;
			}

			return true;
		}
	}

	return false;
}

//射线与平面相交(参数:平面, 射线的长度,返回交点 )
bool DXRAY::Intersect( D3DXPLANE pl, 
			   float d, 
			   D3DXVECTOR3* pvInterPoint  )
{
	D3DXVECTOR3 vOut(0,0,0);
	D3DXVECTOR3 vEnd = vP0+vDir*d; //结束点

	//线和面相交
	if( D3DXPlaneIntersectLine( &vOut, &pl, &vP0, &vEnd  ) )
	{
		if( pvInterPoint )
		{
			*pvInterPoint = vOut;
		}

		return true;
	}

	return false;
}

//是否与三角形相交( 参数:三角形,返回的距离)
bool DXRAY::IntersectTri( DXTRIANGLE tri, float* pfDist )
{
	return  tri.IntersectRay( *this, pfDist );
}

//是否与三角形相交( 参数:三角形,返回的交点)
bool DXRAY::IntersectTri( DXTRIANGLE tri, D3DXVECTOR3* pvInterPoint )
{
	return tri.IntersectRay( *this, pvInterPoint );
}



//------------三角形-----------------------------------------------------------------------------------------------
DXTRIANGLE::DXTRIANGLE()
{
	v1 = V3_X;
	v2 = V3_Y;
	v3 = V3_Z;
}

DXTRIANGLE::DXTRIANGLE(D3DXVECTOR3 _v1,D3DXVECTOR3 _v2,D3DXVECTOR3 _v3)
{
	v1 = _v1;
	v2 = _v2;
	v3 = _v3;
}
//获取面积
float  DXTRIANGLE::GetArea()
{
	float l1 = D3DXVec3Length(&(v3 - v2));
	float l2 = D3DXVec3Length(&(v3 - v1));
	float l3 = D3DXVec3Length(&(v1 - v2));

	float s = (l1+l2+l3)/2;

	return sqrtf(s*( s- l1 )*(s - l2 )*( s - l3 ) );

}
//获取周长
float DXTRIANGLE::GetPerimeter()
{

	float l1 = D3DXVec3Length(&(v3 - v2));
	float l2 = D3DXVec3Length(&(v3 - v1));
	float l3 = D3DXVec3Length(&(v1 - v2));

	return l1+l2+l3;
}

//获取内心
D3DXVECTOR3 DXTRIANGLE::GetInCenter( float* pfR )
{
	float l1 = D3DXVec3Length( &(v3-v2) );
	float l2 = D3DXVec3Length( &(v1-v3) );
	float l3 = D3DXVec3Length( &(v2-v1) );

	float p = GetPerimeter();

	//求面积
	if( pfR )
	{
		*pfR = GetArea()/p;
	}

	return (l1*v1+l2*v2+l3*v3)/p;
}
//获取外心
D3DXVECTOR3 DXTRIANGLE::GetOutCenter( float* pfR )
{
	D3DXVECTOR3 e1 = v3-v2;
	D3DXVECTOR3 e2 = v1-v3;
	D3DXVECTOR3 e3 = v2-v1;


	float d1 = D3DXVec3Dot( &(-e2), &e3 );
	float d2 = D3DXVec3Dot( &(-e3), &e1 );
	float d3 = D3DXVec3Dot( &(-e1), &e2 );

	float c1 = d2*d3;
	float c2 = d3*d1;
	float c3 = d1*d2;

	float c = c1+c2+c3;

	//获取半径
	if ( pfR )
	{
		*pfR = sqrtf( (d1+d2)*(d2+d3)*(d3+d1)/c )/2;
	}

	return ( (c2+c3)*v1+(c3+c1)*v2+(c1+c2)*v3 ) / (2*c);
}
	//一个点是否在三角形内
bool  DXTRIANGLE::IsPointIn( D3DXVECTOR3 v )
{
	D3DXPLANE	pl;
	//3个点构建平面
	D3DXPlaneFromPoints(&pl,&v1,&v2,&v3);
	//点到面的距离
	if( D3DXPlaneDotCoord(&pl,&v) == 0.0f)
	{
		DXTRIANGLE		tri0(v1,v2,v);
		DXTRIANGLE		tri1(v2,v3,v);
		DXTRIANGLE		tri2(v3,v1,v);

		if( GetArea() == tri0.GetArea() + tri1.GetArea() + tri2.GetArea())
		{
			return true;
		}

	}

	return false;

}

//是否与射线相交( 参数:射线,返回的距离)
bool DXTRIANGLE::IntersectRay( DXRAY ray, float* pfDist  )
{
	bool b = D3DXIntersectTri( &v1,&v2,&v3,//三角形的点
												&ray.vP0,//射线的开始点
												&ray.vDir,//射线的方向
												NULL,NULL,
												pfDist);//起点到焦点的距离

	return b?true:false;
}

//( 参数:射线,返回的交点)
bool DXTRIANGLE::IntersectRay( DXRAY ray, D3DXVECTOR3* pvInterPoint  )
{

	float fDist = 0.0f;

	if( IntersectRay( ray, &fDist) )
	{
		if( pvInterPoint )
		{
			//焦点位置 = 起点 + 方向*距离
			*pvInterPoint = ray.vP0 + ray.vDir*fDist;
		}

		return true;
	}
	return false;
}
//-------球---------------------------------------------------------------------
DXSPHERE::DXSPHERE()
{
	v0 = V3_ZERO;

	fR = 1.0f;
}

DXSPHERE::DXSPHERE(D3DXVECTOR3 _v0,float _fR)
{
	v0 = _v0;

	fR = _fR;
}

void DXSPHERE::Transform( D3DXMATRIX mat )
{
	v0 += D3DXVECTOR3(mat._41,mat._42,mat._43 );

	float fScal = GetMax( mat._11,mat._22,mat._33 );

	fR *= fScal;

}
//获取体积
float DXSPHERE::GetVolume()
{
	return (4/3)*D3DX_PI*fR*fR*fR;

}
//获取表面积
float DXSPHERE::GetArea()
{
	return 4*D3DX_PI*fR*fR;
}
//点是否在圆内
bool DXSPHERE::IsPointIn(D3DXVECTOR3  v)
{
	if(D3DXVec3Length(&(v - v0)) <= fR)
	{
		return true;
	}
	return false;
}
//是否与射线相交
bool DXSPHERE::IntersectRay(DXRAY  ray,float* pfDist )
{
	bool b = D3DXSphereBoundProbe( &v0 , fR , &ray.vP0 , &ray.vDir);

	return b?true:false;
}
//是否与平面相交
bool DXSPHERE::IntersectPlane(D3DXPLANE  pl,float* pfDist )
{
	float fL = D3DXPlaneDotCoord(&pl,&v0);
	

	if(fL <= fR)
	{
		if(pfDist)
		{
			*pfDist = fL;
		}
		return true;
	}

	return false;
}
//是否与球相交
bool DXSPHERE::IntersectSphere(DXSPHERE  sphere, float* pfdist )
{
	if(D3DXVec3Length(&(v0 - sphere.v0)) <= fR + sphere.fR)
	{
		if(pfdist)
		{
			*pfdist = D3DXVec3Length(&(v0 - sphere.v0)) ;
		}
		return true;
	}

	return false;
}
//是否与AABB相交
bool DXSPHERE::IntersectAABB(DXAABB aabb,float*pfDist )
{
	return false;
}
///------AABB------------------------------------------------------------------------------------------------------------

DXAABB::DXAABB()
{

	vMin = V3_ZERO;
	vMax = V3_ZERO;
}

DXAABB::DXAABB(D3DXVECTOR3 _vMin,D3DXVECTOR3 _vMax)
{
	vMin = _vMin;
	vMax = _vMax;
}

DXAABB::DXAABB(DXSPHERE sphere,bool bInside )
{
	if( bInside )
	{
		vMin.x = sphere.v0.x-sphere.fR*0.707f;
		vMin.y = sphere.v0.y-sphere.fR*0.707f;
		vMin.z = sphere.v0.z-sphere.fR*0.707f;

		vMax.x = sphere.v0.x+sphere.fR*0.707f;
		vMax.y = sphere.v0.y+sphere.fR*0.707f;
		vMax.z = sphere.v0.z+sphere.fR*0.707f;

		
	}
	else
	{
		vMin.x = sphere.v0.x-sphere.fR;
		vMin.y = sphere.v0.y-sphere.fR;
		vMin.z = sphere.v0.z-sphere.fR;

		vMax.x = sphere.v0.x+sphere.fR;
		vMax.y = sphere.v0.y+sphere.fR;
		vMax.z = sphere.v0.z+sphere.fR;		
	}
}
//AABB变换
void	DXAABB::TransForm(D3DXMATRIX  mat)
{
	D3DXVECTOR3 v[8] = 
	{
		D3DXVECTOR3(vMin.x, vMin.y, vMin.z),
		D3DXVECTOR3(vMin.x, vMin.y, vMax.z),
		D3DXVECTOR3(vMax.x, vMin.y, vMax.z),
		D3DXVECTOR3(vMax.x, vMin.y, vMin.z),
		D3DXVECTOR3(vMin.x, vMax.y, vMin.z),
		D3DXVECTOR3(vMin.x, vMax.y, vMax.z),
		D3DXVECTOR3(vMax.x, vMax.y, vMax.z),
		D3DXVECTOR3(vMax.x, vMax.y, vMin.z)
	};

	for( int i = 0 ; i < 8 ; i++)
	{
		D3DXVec3TransformCoord(&v[i],&v[i],&mat);
	}

	vMin = v[0];
	vMax = v[0];


	for( int i = 1 ; i < 8 ; i++)
	{
		//vMin
		if( vMin.x > v[i].x )
		{
			vMin.x = v[i].x;
		}
		if( vMin.y > v[i].y )
		{
			vMin.y = v[i].y;
		}
		if( vMin.z > v[i].z)
		{
			vMin.z = v[i].z;
		}
		//vMax
		if(vMax.x < v[i].x)
		{
			vMax.x = v[i].x;
		}
		if(vMax.y < v[i].y)
		{
			vMax.y = v[i].y;
		}
		if(vMax.z < v[i].z)
		{
			vMax.z = v[i].z;
		}

	}
}
//求一点在AABB上的最近点
D3DXVECTOR3		DXAABB::GetClosestPoint(D3DXVECTOR3	vPoint)
{
	D3DXVECTOR3		vClosest = V3_ZERO;

	//X
	if(vPoint.x < vMin.x)
	{
		vClosest.x = vMin.x;
	}
	else if(vPoint.x > vMax.x)
	{
		vClosest.x = vMax.x;
	}
	else
	{
		vClosest.x = vPoint.x;
	}
	//Y
	if(vPoint.y < vMin.y)
	{
		vClosest.y = vMin.y;
	}
	else if(vPoint.y > vMax.y)
	{
		vClosest.y = vMax.y;
	}
	else
	{
		vClosest.y = vPoint.y;
	}
	//Z
	if(vPoint.z <vMin.z)
	{
		vClosest.z = vMin.z;
	}
	else if(vPoint.z > vMax.z)
	{
		vClosest.z = vMax.z;
	}
	else
	{
		vClosest.z = vPoint.z;
	}

	return vClosest;
}
//与射线相交
bool DXAABB::IntersectRay(DXRAY	ray,float* pfDist)
{
	BOOL b = D3DXBoxBoundProbe( &vMin, &vMax, &ray.vP0, &ray.vDir );

	return b?true:false;
}
//与球相交
bool DXAABB::IntersectSphere(DXSPHERE sphere)
{
	//获取圆心到AABB的最近点
	D3DXVECTOR3	v = GetClosestPoint(sphere.v0);

	if(D3DXVec3Length( &(v - sphere.v0) ) <= sphere.fR)
	{
		return true;
	}

	return false;
}
//与AABB相交
bool DXAABB::IntersectAABB(DXAABB ab)
{
	//X
	if(vMin.x > ab.vMax.x)
	{
		return false;
	}
	if(vMax.x < ab.vMin.x)
	{
		return false;
	}
	//Y
	if(vMin.y > ab.vMax.y)
	{
		return false;
	}
	if(vMax.y < ab.vMin.y)
	{
		return false;
	}
	//Z
	if(vMin.z >ab.vMax.z)
	{
		return false;
	}
	if(vMax.z < ab.vMin.z)
	{
		return false;
	}
	return true;
}

//-------圆-------------------------------------------------------------------------------------------------------------------
DXCIRCLE::DXCIRCLE()
{
	v0 = V3_ZERO;

	fR = 1.0f;
}
DXCIRCLE::DXCIRCLE(D3DXVECTOR3	_v0, float _fR)
{
	v0 = _v0;

	fR = _fR;
}
	//获取面积
float DXCIRCLE::GetArea()
{
	return D3DX_PI*fR*fR;
}
	//获取周长
float	DXCIRCLE::GetPerimeter()
{
	
	return 2*D3DX_PI*fR;
}