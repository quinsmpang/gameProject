#include "stdafx.h"
#include "Utility.h"

#define new VNEW


D3DXVECTOR3 Vec3Mutiply( const D3DXVECTOR3 &v1, const D3DXVECTOR3 &v2 )
{
	D3DXVECTOR3 vResult;
	vResult.x = v1.x * v2.x;
	vResult.y = v1.y * v2.y;
	vResult.z = v1.z * v2.z;
	return vResult;
}


void Vec3Perpendicular( D3DXVECTOR3 &out, const D3DXVECTOR3 &src )
{
	static D3DXVECTOR3 UNIT_X(1.f, 0.f, 0.f);
	static D3DXVECTOR3 UNIT_Y(0.f, 1.f, 0.f);

	static const float fSquareZero = static_cast<float>(1e-06 * 1e-06);

	D3DXVECTOR3 perp;
	D3DXVec3Cross( &perp, &src, &UNIT_X );

	// Check length
	if( D3DXVec3LengthSq(&perp) < fSquareZero )
	{
		/* This vector is the Y axis multiplied by a scalar, so we have 
		to use another axis.
		*/
		D3DXVec3Cross( &perp, &src, &UNIT_Y );
	}

	out = perp;
}

void RandomDeviant( D3DXVECTOR3 &result, const D3DXVECTOR3 &dir, float fAngle )
{
	D3DXVECTOR3 up;
	Vec3Perpendicular( up, dir );

	D3DXMATRIX m;
	D3DXMatrixRotationAxis( &m, &dir, UnitRandom() * D3DX_PI*2.f );
	D3DXVec3TransformNormal( &up, &up, &m );

	D3DXMatrixRotationAxis( &m, &up, fAngle );
	D3DXVec3TransformNormal( &result, &dir, &m );
}




// returns a random number
FORCEINLINE float asm_rand()
{

#if _MSC_VER == 1300

	static unsigned __int64 q = time( NULL );

	_asm {
		movq mm0, q

			// do the magic MMX thing
			pshufw mm1, mm0, 0x1E
			paddd mm0, mm1

			// move to integer memory location and free MMX
			movq q, mm0
			emms
	}

	return float( q );
#else
	// VC6 does not support pshufw
	return float( rand() );
#endif
}

// returns the maximum random number
FORCEINLINE float asm_rand_max()
{

#if _MSC_VER == 1300

	//	return std::numeric_limits< unsigned __int64 >::max();
	return 9223372036854775807.0f;
#else
	// VC6 does not support unsigned __int64
	return float( RAND_MAX );
#endif

}

float UnitRandom()
{
	return asm_rand() / asm_rand_max();
}

float RangeRandom(float fLow, float fHigh)
{
	return (fHigh-fLow)*UnitRandom() + fLow;
}

float SymmetricRandom()
{
	return 2.f * UnitRandom() - 1.f;
}

void ChangeFileNameToDDS( string &name )
{
	basic_string <char>::size_type indexChar = name.find_last_of( '.' );
	if( indexChar != -1 )
	{
		name = name.substr( 0, indexChar ) + ".dds";
	}
}