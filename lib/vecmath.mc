// vecmath

// vecmath : transpiled from libs/vecmath/vecmath.h

import math;

// C99 modff: split x into integral and fractional parts, both with
// x's sign; the integral part lands in *iptr.
f32 modff(f32 x, f32* iptr) {
    noinit f32 i;
    if x >= 0.0f { i = floorf(x); } else { i = ceilf(x); }
    *iptr = i;
    return x - i;
}

/*
------------------------------------------------------------------------------
		 Licensing information can be found at the end of the file.
------------------------------------------------------------------------------

vecmath.h - v1.0 - vector/matrix math library for C/C++.
*/
/**

vecmath.h
=========

vecmath.h is a vector/matrix math library for C/C++, with some additional
helpers specifically for 3D math.

It's designed to support most of the functionality you would expect from
shader languages like GLSL and, primarily, HLSL, with matching behavior.
Other parts of the library have been modelled after the D3DX parts of the
DirectX SDK.

The goal of vecmath.h is to be a complete and comprehensive vector math
library. It makes no use of SIMD intrinsics or similar, but instead just
implements each function in the most straightforward way. It uses no complex
macro acrobatics to shorten the implementations, and no templates or the
like. Many compilers do a decent job optimizing the functions, but if you
need maximum speed, you are probably best off doing a custom SIMD intrinsics
implementation for your specific use case - but this also involves structuring
your data to allow for maximum parallelization.

Care has been taken to keep the API consistent and predictable, and most of
the functions should be easy to guess the name of, and it should be obvious
what they do in most cases, as standard terminology is used.

> vecmath.h is primarily designed to be a C library, but some care have been
> taken to make sure it works well when used from C++ too. It makes no claim
> to be using idiomatic "Modern C++" practices, but is instead taking a
> pragmatic approach, to leverage some C++ features when using the library
> from C++ code. This documentation points out all C++ specific behavior in
> blocks like this one.

> [!NOTE]
> In C++ all functions and types are wrapped in `namespace vecmath`.


Examples
--------

Here is a sample of how code using the vecmath.h library can look (this is
taken from a software renderer doing per-pixel lighting, as you would
typically see in a GPU shader written in HLSL or GLSL):

	vec3_t lighting( vec3_t albedo, vec3_t l, vec3_t n, vec3_t view, float spec, float gloss, float ambocc, vec3_t env ) {
		vec3_t sky = vec3( 0.95f, 0.95f, 0.99f );
		vec3_t ground= vec3( 0.3f, 0.2f, 0.1f );
		vec3_t lightcol= vec3( 0.9f, 0.85f, 0.8f );

		vec3_t r = normalize( 2.0f *  dot(n, l) * n - l);
		float sn = pow( 2.0f, 8.0f * gloss );
		float s = pow( saturate( dot( r, view ) ), sn ) * ( ( sn + 2.0f ) / ( 2 * VECMATH_PI ) );

		float diffuse = saturate( dot( n, l ) );
		float diffuse_wrapped = saturate( dot( n, l ) * 0.5f + 0.5f );
		vec3_t hemisphere = lerp( ground, sky, n.y * 0.5f + 0.5f ) * 0.5f * ambocc;
		vec3_t directional = lightcol * ( diffuse * 0.75f + diffuse_wrapped * 0.5f );
		vec3_t specular = s * albedo * ambocc;

		vec3_t color = albedo * ( directional + hemisphere ) + specular * 2.0f;
		color += env * spec;
		return color;
	}

The example above is in C, but it is also using the vecmath.h option to use the
clang extension for vector types, allowing operators `+`, `-`, `*`, `/` to be
used in C. It is also using the option to define aliases without prefixes for
nicer vecmath function names.

Without the clang vector type extension, and without stripping prefixes, the same
code would look like this:

	vec3_t lighting( vec3_t albedo, vec3_t l, vec3_t n, vec3_t view, float spec, float gloss, float ambocc, vec3_t env ) {
		vec3_t sky = vec3( 0.95f, 0.95f, 0.99f );
		vec3_t ground= vec3( 0.3f, 0.2f, 0.1f );
		vec3_t lightcol= vec3( 0.9f, 0.85f, 0.8f );

		vec3_t r = vec3_normalize( vec3_fmul( 2.0f, vec3_sub( vec3_fmul( vec3_dot(n, l), n ), l ) ) );
		float sn = vecmath_pow( 2.0f, 8.0f * gloss );
		float s = vecmath_pow( vecmath_saturate( vec3_dot( r, view ) ), sn ) * ( ( sn + 2.0f ) / ( 2 * VECMATH_PI ) );

		float diffuse = vecmath_saturate( vec3_dot( n, l ) );
		float diffuse_wrapped = vecmath_saturate( vec3_dot( n, l ) * 0.5f + 0.5f );
		vec3_t hemisphere = vec3_mulf( vec3_lerp( ground, sky, n.y * 0.5f + 0.5f ), 0.5f * ambocc );
		vec3_t directional = vec3_mulf( lightcol, diffuse * 0.75f + diffuse_wrapped * 0.5f );
		vec3_t specular = vec3_fmul( s, vec3_mulf( albedo, ambocc ) );

		vec3_t color = vec3_add( vec3_mul( albedo, vec3_add( directional, hemisphere ) ), vec3_mulf( specular, 2.0f ) );
		color = vec3_add( color, vec3_mulf( env, spec ) );
		return color;
	}

Which is admittedly not quite as nice, but still reasonable. Note that both
versions can be compiled with C++ as well.


Customization
-------------

There are a couple of aspects of vecmath.h that can be customized through
compile-time defines.

### Standard math functions

By default, vecmath.h will include the standard C <math.h> header, and use the
standard math functions defined there. However, you can override this to use
your own equivalents by defining one or more of the following macros:

`VECMATH_ABS`, `VECMATH_ACOS`, `VECMATH_ASIN`, `VECMATH_ATAN`, `VECMATH_ATAN2`,
`VECMATH_CEIL`, `VECMATH_COS`, `VECMATH_COSH`, `VECMATH_EXP`, `VECMATH_EXP2`,
`VECMATH_FLOOR`, `VECMATH_FMOD`, `VECMATH_FRAC`, `VECMATH_LOG`, `VECMATH_LOG10`,
`VECMATH_POW`, `VECMATH_SIN`, `VECMATH_SINH`, `VECMATH_SQRT`, `VECMATH_LOG2`,
`VECMATH_ROUND`, `VECMATH_TAN`, `VECMATH_TANH`, `VECMATH_TRUNC`

If you redefine every single one of these, vecmath.h will no longer include
the <math.h> header at all.


### Clang vector type extensions

The clang compiler has an extension named `ext_vector_type`, which allows for
defining a vector type of a specific size, and then be able to use operators
(+, -, *, /) to perform element-wise arithmetic.

You can enable this by defining `VECMATH_EXT_VECTOR_TYPE` before including
vecmath.h. It will only be enabled for compilers supporting it. If the compiler
does not support it, the `VECMATH_EXT_VECTOR_TYPE` define will be ignored.

Note that any usage code leveraging this feature, will of course only compile
in clang.

> In C++, operator overloading is used to achieve the same functionality, and
> there is no need to toggle it with any define.


Types
-----

There are three vector types:

* `vec2_t` two component vector, x/y
* `vec3_t` three component vector, x/y/z
* `vec4_t` four component vector, x/y/z/w

There are nine matrix types. A matrix is made up of a number of rows, where
each row is a vector type representing the columns of the matrix.

* `mat22_t` matrix with two rows (x/y) of vec2_t
* `mat23_t` matrix with two rows (x/y) of vec3_t
* `mat24_t` matrix with two rows (x/y) of vec4_t

- `mat32_t` matrix with three rows (x/y/z) of vec2_t
- `mat33_t` matrix with three rows (x/y/z) of vec3_t
- `mat34_t` matrix with three rows (x/y/z) of vec4_t

* `mat42_t` matrix with four rows (x/y/z/w) of vec2_t
* `mat43_t` matrix with four rows (x/y/z/w) of vec3_t
* `mat44_t` matrix with four rows (x/y/z/w) of vec4_t

Matrices are *row-major*, which means if you need to pass them on to an API
expecting column-major matrices (such as OpenGL) you need to transpose them
first.

> In C++, there are also class-equivalents of the types, without the `_t` suffix,
> which supports overloaded constructors and operators for a more idiomatic C++
> feel. These are named vec2, vec3, vec4, mat22, mat23, mat24, mat32, mat33,
> mat34, mat42, mat43 and mat44.

Note that all of these are simple structs of floats, with no padding, meaning
arrays are also just made up of tightly packed floats. Be aware though, that if
you define `VECMATH_EXT_VECTOR_TYPE`, the clang extension to get operator
overloading, padding of vector types might be introduced. No part of vecmath.h
itself relies on elements being tightly packed, but if your code does and you
enable `VECMATH_EXT_VECTOR_TYPE`, be aware that tight packing of elements is no
longer guaranteed (typically, vec2_t/vec3_t/vec4_t will all be 16 bytes in size).

For all of the types, both vector and matrices, there are a large number of
functions, operators and constructors defined, following a unified naming
convention and behavior.


Constructors
------------

All types can be constructed from their elements:

	vec2_t vec2( float x, float y )
	vec3_t vec3( float x, float y, float z )
	vec4_t vec4( float x, float y, float z, float w )

	mat22_t mat22( vec2_t x, vec2_t y )
	mat23_t mat23( vec3_t x, vec3_t y )
	mat24_t mat24( vec4_t x, vec4_t y )

	mat32_t mat32( vec2_t x, vec2_t y, vec2_t z )
	mat33_t mat33( vec3_t x, vec3_t y, vec3_t z )
	mat34_t mat34( vec4_t x, vec4_t y, vec4_t z )

	mat42_t mat42( vec2_t x, vec2_t y, vec2_t z, vec2_t w )
	mat43_t mat43( vec3_t x, vec3_t y, vec3_t z, vec3_t w )
	mat44_t mat44( vec4_t x, vec4_t y, vec4_t z, vec4_t w )

Note that for vectors, each element is a float, while for matrices, each
element is a vector.

> In C++, this is implemented as a constructor on the vec2, vec3, vec4, mat22,
> mat23, mat24, mat32, mat33, mat34, mat42, mat43 and mat44 classes, but the
> syntax for constructing is the same.

Both vectors and matrices can also be initialized with a single float value, which
will be propagated to every element of the vector or the matrices, and in the case
of matrices, to every column of every row.

	vec2_t vec2f( float v )
	vec3_t vec3f( float v )
	vec4_t vec4f( float v )

	mat22_t mat22f( float v )
	mat23_t mat23f( float v )
	mat24_t mat24f( float v )

	mat32_t mat32f( float v )
	mat33_t mat33f( float v )
	mat34_t mat34f( float v )

	mat42_t mat42f( float v )
	mat43_t mat43f( float v )
	mat44_t mat44f( float v )

All of these have the suffix `f` for float.

> In C++, there are also constructor overloads for all classes, allowing for
> passing a single float, without needing the suffix `f`. Do note that using
> those will of course make it so your code no longer compiles in C. Using
> the constructor functions with the `f` suffix works in both C and C++.

Additionally, for vec3_t and vec4_t, it is possible to construct them from a
vector with one less component plus a single float, or (in the case of vec4_t)
from two vec2_t.

	vec3_t vec3v2f( vec2_t v, float f )
	vec3_t vec3fv2( float f, vec2_t v )

	vec4_t vec4v3f( vec3_t v, float f )
	vec4_t vec4fv3( float f, vec3_t v )
	vec4_t vec4v2( vec2_t a, vec2_t b )

These have various suffixes to indicate which parameters are used - `v2f` for
a two-element vector followed by a single float, or `fv3` for a single float
followed by a three-element vector, etc.

> In C++, there are also constructor overloads for all of these, so you can use
> them without needing the suffixes. Do note that using them will of course make
> it so your code no longer compiles in C. Using the constructor functions with
> the suffixes works in both C and C++.


Accessing elements
------------------

Each element can of course be accessed using `.x`, `.y`, `.z` and `.w`. For
matrices, individual cells can be accessed using `.x.x`, `.x.y` etc, as would be
expected.

It is also possible to access elements by index. To get the value by index,
the functions are type name with suffix `_get`:

	float vec2_get( vec2_t vec, int index )
	float vec3_get( vec3_t vec, int index )
	float vec4_get( vec4_t vec, int index )

	vec2_t mat22_get( mat22_t m, int row )
	vec3_t mat23_get( mat23_t m, int row )
	vec4_t mat24_get( mat24_t m, int row )

	vec2_t mat32_get( mat32_t m, int row )
	vec3_t mat33_get( mat33_t m, int row )
	vec4_t mat34_get( mat34_t m, int row )

	vec2_t mat42_get( mat42_t m, int row )
	vec3_t mat43_get( mat43_t m, int row )
	vec4_t mat44_get( mat44_t m, int row )

To set a value by index, the functions are type name with suffix `_set`:

	void vec2_set( vec2_t* vec, int index, float f )
	void vec3_set( vec3_t* vec, int index, float f )
	void vec4_set( vec4_t* vec, int index, float f )

	void mat22_set( mat22_t* m, int row, vec2_t v )
	void mat23_set( mat23_t* m, int row, vec3_t v )
	void mat24_set( mat24_t* m, int row, vec4_t v )

	void mat32_set( mat32_t* m, int row, vec2_t v )
	void mat33_set( mat33_t* m, int row, vec3_t v )
	void mat34_set( mat34_t* m, int row, vec4_t v )

	void mat42_set( mat42_t* m, int row, vec2_t v )
	void mat43_set( mat43_t* m, int row, vec3_t v )
	void mat44_set( mat44_t* m, int row, vec4_t v )

> [!CAUTION]
> Do note that accessing elements by index, either using `*_get` or `*_set`,
> do NOT do any range checking on the `index` or `row` parameter. Passing
> an index outside of the valid range for the type you are accessing, will not
> return a valid result, and is likely to cause an access violation.

> In C++, there are also subscript operators, `operator[]` defined for all of
> the classes, allowing you to access elements, for setting or getting, using
> a syntax like `v[0]=2` or `m[3][2]=v[2]` ( the `3` indicates row 3, the `2`
> indicates column 2) etc. These are also NOT bounds checked, so use with care.


Operators
---------

A number of operators are defined, as functions, for all of the types,
performing element-wise negation, equality-test, addition, multiplication and
division, with variants supporting element-wise add/sub/mul/div between two of
the same type as well as any type with a single float.

The operator functions are defined in this general form, where `###` is the
type name (vec2, vec3, vec4, mat22, mat23, mat24, mat32, mat33, mat34, mat42,
mat43 or mat44):

	###_t ###_neg( ###_t v )
	int ###_eq( ###_t a, ###_t b )
	###_t ###_add( ###_t a, ###_t b )
	###_t ###_sub( ###_t a, ###_t b )
	###_t ###_mul( ###_t a, ###_t b )
	###_t ###_div( ###_t a, ###_t b )
	###_t ###_addf( ###_t a, float s )
	###_t ###_subf( ###_t a, float s )
	###_t ###_mulf( ###_t a, float s )
	###_t ###_divf( ###_t a, float s )

For example, for vec2_t the following operators are defined:

	vec2_t vec2_neg( vec2_t v )
	int vec2_eq( vec2_t a, vec2_t b )
	vec2_t vec2_add( vec2_t a, vec2_t b )
	vec2_t vec2_sub( vec2_t a, vec2_t b )
	vec2_t vec2_mul( vec2_t a, vec2_t b )
	vec2_t vec2_div( vec2_t a, vec2_t b )
	vec2_t vec2_addf( vec2_t a, float s )
	vec2_t vec2_subf( vec2_t a, float s )
	vec2_t vec2_mulf( vec2_t a, float s )
	vec2_t vec2_divf( vec2_t a, float s )

Note that for matrix types, the `###_mul` operator is named `###_mul_elem`,
so as to not cause confusion with matrix multiplication functions like
`mat44_mul_mat44` etc (which does full row-by-column multiplication).

> [!WARNING]
> The `###_mul_elem` functions (`mat22_mul_elem`, `mat44_mul_elem` etc) does
> NOT perform standard matrix multiplication - they perform element-wise
> multiplication, also known as Hadamard product. A separate set of functions,
> named on the form `###_mul_###`, for example `mat44_mul_mat44`, is provided
> for performing standard matrix multiplication between matrices of compatible
> dimensions (see the section on "Matrix Multiplication").

> For C++, all of these, except for the `###_mul_elem` functions, are also
> provided as C++ operator overloads. The multiplication operator `operator*`
> is mapped to the matrix multiplication functions, like `mat44_mul_mat44`
> rather than to the element-wise `###_mul_elem` functions. For vectors,
> multiplication operator maps to the element-wise `###_mul` functions.
>
> For multiplication of vector with matrix, or matrix with vector, the vector
> is treated as a 1xN or Nx1 matrix, and full matrix multiplication is performed.


Element-wise functions
----------------------

There is a large number of functions defined for every type, that perform
element-wise calculations. Here are their declarations for the vect2_t
type, but the naming is consistent for all other types (both vector and
matrix types):

	vec2_t vec2_abs( vec2_t m )
	vec2_t vec2_acos( vec2_t m )
	int vec2_all( vec2_t m )
	int vec2_any( vec2_t m )
	vec2_t vec2_asin( vec2_t m )
	vec2_t vec2_atan( vec2_t m )
	vec2_t vec2_atan2( vec2_t y, vec2_t x )
	vec2_t vec2_ceil( vec2_t m )
	vec2_t vec2_clamp( vec2_t m, vec2_t min_v, vec2_t max_v )
	vec2_t vec2_cos( vec2_t m )
	vec2_t vec2_cosh( vec2_t m )
	vec2_t vec2_degrees( vec2_t m )
	vec2_t vec2_exp( vec2_t m )
	vec2_t vec2_exp2( vec2_t m )
	vec2_t vec2_floor( vec2_t m )
	vec2_t vec2_fmod( vec2_t a, vec2_t b )
	vec2_t vec2_frac( vec2_t m )
	vec2_t vec2_lerp( vec2_t a, vec2_t b, float s )
	vec2_t vec2_log( vec2_t m )
	vec2_t vec2_log2( vec2_t m )
	vec2_t vec2_log10( vec2_t m )
	vec2_t vec2_max( vec2_t a, vec2_t b )
	vec2_t vec2_min( vec2_t a, vec2_t b )
	vec2_t vec2_pow( vec2_t a, vec2_t b )
	vec2_t vec2_radians( vec2_t m )
	vec2_t vec2_rcp( vec2_t m )
	vec2_t vec2_round( vec2_t m )
	vec2_t vec2_rsqrt( vec2_t m )
	vec2_t vec2_saturate( vec2_t m )
	vec2_t vec2_sign( vec2_t m )
	vec2_t vec2_sin( vec2_t m )
	vec2_t vec2_sinh( vec2_t m )
	vec2_t vec2_smoothstep( vec2_t min_v, vec2_t max_v, vec2_t m )
	vec2_t vec2_smootherstep( vec2_t min_v, vec2_t max_v, vec2_t m )
	vec2_t vec2_sqrt( vec2_t m )
	vec2_t vec2_step( vec2_t a, vec2_t b )
	vec2_t vec2_tan( vec2_t m )
	vec2_t vec2_tanh( vec2_t m )
	vec2_t vec2_trunc( vec2_t m )

These all perform, per element, the standard mathematical calculation suggested
by each function's name. The behavior is consistent with that of HLSL (or GLSL,
but is primarily modeled after HLSL).

In addition, the following are only defined for vector types (and are defined for
vector types of all three sizes), but not for matrix types:

	float vec2_distancesq( vec2_t a, vec2_t b )
	float vec2_distance( vec2_t a, vec2_t b )
	float vec2_dot( vec2_t a, vec2_t b )
	float vec2_lengthsq( vec2_t v )
	float vec2_length( vec2_t v )
	vec2_t vec2_normalize( vec2_t v )
	vec2_t vec2_reflect( vec2_t i, vec2_t n )
	vec2_t vec2_refract( vec2_t i, vec2_t n, float r )

and again, they work the same as in HLSL.

Finally, a cross-product function is only defined for vec3_t:

	vec3_t vec3_cross( vec3_t a, vec3_t b )


For completeness, all of these functions are also implemented in a version for
single floats, using a `vecmath_` prefix:

	float vecmath_abs( float v )
	float vecmath_acos( float v )
	int vecmath_all( float v )
	int vecmath_any( float v )
	float vecmath_asin( float v )
	float vecmath_atan( float v )
	float vecmath_atan2( float y, float x )
	float vecmath_ceil( float v )
	float vecmath_clamp( float v, float min_v, float max_v )
	float vecmath_cos( float v )
	float vecmath_cosh( float v )
	float vecmath_degrees( float v )
	float vecmath_distancesq( float a, float b )
	float vecmath_distance( float a, float b )
	float vecmath_dot( float a, float b )
	float vecmath_exp( float v )
	float vecmath_exp2( float v )
	float vecmath_floor( float v )
	float vecmath_fmod( float a, float b )
	float vecmath_frac( float v )
	float vecmath_lengthsq( float v )
	float vecmath_length( float v )
	float vecmath_lerp( float a, float b, float s )
	float vecmath_log( float v )
	float vecmath_log2( float v )
	float vecmath_log10( float v )
	float vecmath_max( float a, float b )
	float vecmath_min( float a, float b )
	float vecmath_normalize( float v )
	float vecmath_pow( float a, float b )
	float vecmath_radians( float v )
	float vecmath_rcp( float v )
	float vecmath_reflect( float i, float n )
	float vecmath_refract( float i, float n, float r )
	float vecmath_round( float v )
	float vecmath_rsqrt( float v )
	float vecmath_saturate( float v )
	float vecmath_sign( float v )
	float vecmath_sin( float v )
	float vecmath_sinh( float v )
	float vecmath_smoothstep( float min_v, float max_v, float v )
	float vecmath_smootherstep( float min_v, float max_v, float v )
	float vecmath_sqrt( float v )
	float vecmath_step( float edge, float x )
	float vecmath_tan( float v )
	float vecmath_tanh( float v )
	float vecmath_trunc( float v )


Transpose, determinant, inverse and identity matrices
-----------------------------------------------------

Transposing matrices are supported for all matrix types:

	mat22_t mat22_transpose( mat22_t m )
	mat32_t mat23_transpose( mat23_t m )
	mat23_t mat32_transpose( mat32_t m )
	mat33_t mat33_transpose( mat33_t m )
	mat42_t mat24_transpose( mat24_t m )
	mat43_t mat34_transpose( mat34_t m )
	mat24_t mat42_transpose( mat42_t m )
	mat34_t mat43_transpose( mat43_t m )
	mat44_t mat44_transpose( mat44_t m )

Calculating the determinant is supported for square matrices only:

	float mat22_determinant( mat22_t m)
	float mat33_determinant( mat33_t m)
	float mat44_determinant( mat44_t m)

As is computing the inverse:

	int mat22_inverse( mat22_t* out_matrix, float* out_determinant, mat22_t m )
	int mat33_inverse( mat33_t* out_matrix, float* out_determinant, mat33_t m )
	int mat44_inverse( mat44_t* out_matrix, float* out_determinant, mat44_t m )

Note that the inverse functions return 0 if the matrix cannot be inverted, and
non-zero if inversion was successful. Both the `out_matrix` and the
`out_determinant` parameters are optional and may be NULL. If non-NULL,
`out_determinant` will be set, and if non-NULL and inversion is successful,
`out_matrix` will be set.

There are helper functions to construct the identity matrix for each of the
square matrix sizes:

	mat22_t mat22_identity( void )
	mat33_t mat33_identity( void )
	mat44_t mat44_identity( void )

and also functions to test if a matrix is exactly identity:

	int mat22_is_identity( mat22_t m )
	int mat33_is_identity( mat33_t m )
	int mat44_is_identity( mat44_t m )

returning non-zero if the matrix is identity, as compared exactly (no
floating point epsilon is used).


Matrix multiplications
----------------------

Matrix multiplication is supported between all vectors and matrices, in any
valid combination of dimensions, all named on the form `###_mul_###` where
`###` is the type name of the first and second argument. The return type
depends on the dimensions of the types involved.

All valid combinations, along with their return types, are as follows:

	float vec2_mul_vec2( vec2_t a, vec2_t b )
	float vec3_mul_vec3( vec3_t a, vec3_t b )
	float vec4_mul_vec4( vec4_t a, vec4_t b )

	vec2_t vec2_mul_mat22( vec2_t a, mat22_t b )
	vec3_t vec2_mul_mat23( vec2_t a, mat23_t b )
	vec4_t vec2_mul_mat24( vec2_t a, mat24_t b )
	vec2_t vec3_mul_mat32( vec3_t a, mat32_t b )
	vec3_t vec3_mul_mat33( vec3_t a, mat33_t b )
	vec4_t vec3_mul_mat34( vec3_t a, mat34_t b )
	vec2_t vec4_mul_mat42( vec4_t a, mat42_t b )
	vec3_t vec4_mul_mat43( vec4_t a, mat43_t b )
	vec4_t vec4_mul_mat44( vec4_t a, mat44_t b )

	vec2_t mat22_mul_vec2( mat22_t a, vec2_t b )
	vec3_t mat32_mul_vec2( mat32_t a, vec2_t b )
	vec4_t mat42_mul_vec2( mat42_t a, vec2_t b )
	vec2_t mat23_mul_vec3( mat23_t a, vec3_t b )
	vec3_t mat33_mul_vec3( mat33_t a, vec3_t b )
	vec4_t mat43_mul_vec3( mat43_t a, vec3_t b )
	vec2_t mat24_mul_vec4( mat24_t a, vec4_t b )
	vec3_t mat34_mul_vec4( mat34_t a, vec4_t b )
	vec4_t mat44_mul_vec4( mat44_t a, vec4_t b )

	mat22_t mat22_mul_mat22( mat22_t a, mat22_t b )
	mat23_t mat22_mul_mat23( mat22_t a, mat23_t b )
	mat24_t mat22_mul_mat24( mat22_t a, mat24_t b )
	mat22_t mat23_mul_mat32( mat23_t a, mat32_t b )
	mat23_t mat23_mul_mat33( mat23_t a, mat33_t b )
	mat24_t mat23_mul_mat34( mat23_t a, mat34_t b )
	mat22_t mat24_mul_mat42( mat24_t a, mat42_t b )
	mat23_t mat24_mul_mat43( mat24_t a, mat43_t b )
	mat24_t mat24_mul_mat44( mat24_t a, mat44_t b )

	mat32_t mat32_mul_mat22( mat32_t a, mat22_t b )
	mat33_t mat32_mul_mat23( mat32_t a, mat23_t b )
	mat34_t mat32_mul_mat24( mat32_t a, mat24_t b )
	mat32_t mat33_mul_mat32( mat33_t a, mat32_t b )
	mat33_t mat33_mul_mat33( mat33_t a, mat33_t b )
	mat34_t mat33_mul_mat34( mat33_t a, mat34_t b )
	mat32_t mat34_mul_mat42( mat34_t a, mat42_t b )
	mat33_t mat34_mul_mat43( mat34_t a, mat43_t b )
	mat34_t mat34_mul_mat44( mat34_t a, mat44_t b )

	mat42_t mat42_mul_mat22( mat42_t a, mat22_t b )
	mat43_t mat42_mul_mat23( mat42_t a, mat23_t b )
	mat44_t mat42_mul_mat24( mat42_t a, mat24_t b )
	mat42_t mat43_mul_mat32( mat43_t a, mat32_t b )
	mat43_t mat43_mul_mat33( mat43_t a, mat33_t b )
	mat44_t mat43_mul_mat34( mat43_t a, mat34_t b )
	mat42_t mat44_mul_mat42( mat44_t a, mat42_t b )
	mat43_t mat44_mul_mat43( mat44_t a, mat43_t b )
	mat44_t mat44_mul_mat44( mat44_t a, mat44_t b )

When a vector is multiplied by another vector, this is equivalent to the dot
product. When a vector is multiplied by a matrix, the vector is treated like a
1xN matrix, or row vector. When a matrix is multiplied by a vector, the
vector is treated like a Nx1 matrix, or a column vector.


Quaternions
-----------

Quaternions are supported, and as they also have four elements, they are
represented by the `vec4_t` type.

The following functions operate on quaternions:

	vec4_t quat_normalize( vec4_t q )
	vec4_t quat_slerp( vec4_t a, vec4_t b, float t )
	vec4_t quat_barycentric( vec4_t q1, vec4_t q2, vec4_t q3, float f, float g )
	vec4_t quat_conjugate( vec4_t q )
	vec4_t quat_exp( vec4_t q )
	vec4_t quat_identity( void )
	vec4_t quat_inverse( vec4_t q )
	int quat_is_identity( vec4_t q )
	vec4_t quat_ln( vec4_t q )
	vec4_t quat_mul( vec4_t a, vec4_t b )
	vec4_t quat_rotation_axis( vec3_t axis, float angle )
	vec4_t quat_rotation_matrix( mat44_t m )
	vec4_t quat_rotation_yaw_pitch_roll(float yaw, float pitch, float roll)
	void quat_squad_setup( vec4_t* out_a, vec4_t* out_b, vec4_t* out_c, vec4_t q0, vec4_t q1, vec4_t q2, vec4_t q3 )
	vec4_t quat_squad(vec4_t q1, vec4_t a, vec4_t b, vec4_t c, float t )
	void quat_to_axis_angle( vec4_t q, vec3_t* out_axis, float* out_angle )
	vec3_t quat_rotate_vector( vec3_t v, vec4_t q )
	vec4_t quat_shortest_arc( vec3_t from, vec3_t to )
	vec4_t quat_from_mat33( mat33_t m )
	vec4_t quat_from_mat44( mat44_t m )
	float quat_angle( vec4_t a, vec4_t b )
	mat33_t mat33_from_quat( vec4_t q )
	mat44_t mat44_from_quat( vec4_t q )

The functionality and behavior of all of these are consistent with D3DX,
XNAMath or DirectXMath, and the support they have for quaternions.

> [!NOTE]
> As there is nothing in the API preventing you from using four-element
> vectors and quaternions interchangeably, care should be taken to use
> them in the correct way. For example, using `vec4_mul` to multiply two
> quaternions will give the wrong result - make sure to use `quat_mul`
> instead.


Matrix 3D utility functions
---------------------------

There are a number of utility functions for creating various matrices used in 3d
rendering (transformation and projection):

	mat44_t mat44_look_at_lh( vec3_t eye, vec3_t at, vec3_t up )
	mat44_t mat44_look_at_rh( vec3_t eye, vec3_t at, vec3_t up )
	mat44_t mat44_ortho_lh( float w, float h, float zn, float zf )
	mat44_t mat44_ortho_rh( float w, float h, float zn, float zf )
	mat44_t mat44_ortho_off_center_lh( float l, float r, float b, float t, float zn, float zf )
	mat44_t mat44_ortho_off_center_rh( float l, float r, float b, float t, float zn, float zf )
	mat44_t mat44_perspective_lh( float w, float h, float zn, float zf )
	mat44_t mat44_perspective_rh( float w, float h, float zn, float zf )
	mat44_t mat44_perspective_off_center_lh( float l, float r, float b, float t, float zn, float zf )
	mat44_t mat44_perspective_off_center_rh( float l, float r, float b, float t, float zn, float zf )
	mat44_t mat44_perspective_fov_lh( float fovy, float aspect, float zn, float zf )
	mat44_t mat44_perspective_fov_rh( float fovy, float aspect, float zn, float zf )
	mat44_t mat44_rotation_axis( vec3_t axis, float angle )
	mat44_t mat44_rotation_x( float angle )
	mat44_t mat44_rotation_y( float angle )
	mat44_t mat44_rotation_z( float angle )
	mat44_t mat44_rotation_yaw_pitch_roll( float yaw, float pitch, float roll )
	mat44_t mat44_scaling( float sx, float sy, float sz )
	mat44_t mat44_translation( float tx, float ty, float tz )

These all work the same as in DirectX (and most 3d math libraries).

There's also a function to decompose a transformation matrix into separate scale,
rotation and translation components:

	int mat44_decompose( vec3_t* out_scale, vec4_t* out_rotation, vec3_t* out_translation, mat44_t m )

Again, this works just like in D3DX, and returns a non-zero value if the matrix
could be successfully decomposed, and returns 0 if decomposition failed. If it
failed, `out_scale`, `out_rotation` and `out_translation` are not modified. It
is valid to pass NULL for any of the out parameters if you do not need that
result value.

Finally, there are transform helpers mirroring the ones in D3DX:

	vec4_t vec2_transform( vec2_t v, mat44_t m )
	vec2_t vec2_transform_coord( vec2_t v, mat44_t m )
	vec2_t vec2_transform_normal( vec2_t v, mat44_t m )
	vec4_t vec3_transform( vec3_t v, mat44_t m )
	vec3_t vec3_transform_coord( vec3_t v, mat44_t m )
	vec3_t vec3_transform_normal( vec3_t v, mat44_t m )
	vec4_t vec4_transform( vec4_t v, mat44_t m )


Vector swizzling
----------------

vecmath.h supports swizzling in the form swizzle-on-read, but does not support
swizzle-on-right, meaning you cannot assign to a swizzled target.

Swizzling is supported by defining separate swizzle functions for every single
combination of swizzling, on vec2/vec3 and vec4 types. That's hundreds of
functions, and we won't list them here, but let's at least look at the ones
returning vec2_t (the rest follows the same pattern, but with many more
variations):

	vec2_t vec2_xx( vec2_t v )
	vec2_t vec2_xy( vec2_t v )
	vec2_t vec2_yx( vec2_t v )
	vec2_t vec2_yy( vec2_t v )

	vec2_t vec3_xx( vec3_t v )
	vec2_t vec3_xy( vec3_t v )
	vec2_t vec3_xz( vec3_t v )
	vec2_t vec3_yx( vec3_t v )
	vec2_t vec3_yy( vec3_t v )
	vec2_t vec3_yz( vec3_t v )
	vec2_t vec3_zx( vec3_t v )
	vec2_t vec3_zy( vec3_t v )
	vec2_t vec3_zz( vec3_t v )

	vec2_t vec4_xx( vec4_t v )
	vec2_t vec4_xy( vec4_t v )
	vec2_t vec4_xz( vec4_t v )
	vec2_t vec4_xw( vec4_t v )
	vec2_t vec4_yx( vec4_t v )
	vec2_t vec4_yy( vec4_t v )
	vec2_t vec4_yz( vec4_t v )
	vec2_t vec4_yw( vec4_t v )
	vec2_t vec4_zx( vec4_t v )
	vec2_t vec4_zy( vec4_t v )
	vec2_t vec4_zz( vec4_t v )
	vec2_t vec4_zw( vec4_t v )
	vec2_t vec4_wx( vec4_t v )
	vec2_t vec4_wy( vec4_t v )
	vec2_t vec4_wz( vec4_t v )
	vec2_t vec4_ww( vec4_t v )

As we can see, the return type is decided by how many elements we have in the
function suffix (`_xx`, `_yx` etc) - all of the two elements in this example,
but variants exist with more elements as well, for other swizzling combinations.

The function prefix (`vec2_`, `vec3_`, `vec4_`) indicates the parameter type
as would be expected.

> For C++, swizzling is also supported in the form of member functions on the
> `vec2`, `vec3` and `vec4` classes, allowing swizzling in the form `v.xxx()`,
> `v.yyxx()`, `v.xy` etc. Note that the C swizzling functions are also available
> from C++.


C Generics and C++ overloads
----------------------------

All functions in vecmath.h are prefixed with the name of the type it operates
on (`vec2_`, `vec3_`, `vec4_`, `mat22_` etc ). From C11, there is the new
keyword `_Generic`, allowing for defining a macro dispatcher that allows the
use of the same name to invoke different functions depending on the type of
the arguments.

In vecmath.h you can define the preprocessor symbol `VECMATH_GENERICS`, and if
you are compiling with C11 or later, a full set of `vm_` macros will be defined
for calling functions without specifying a prefix. It allows you to do things
like `vm_add( a, b )` regardless of which vecmath.h types `a` and `b` are, as
long as they are the same type.

Unlike most other vm_ functions, which perform element-wise operations, the
`vm_mul` macro does not wrap the `*_mul_elem` element-wise multiply functions,
but instead the full matrix multiply `*_mul_*` functions, allowing for
expressions like `vm_mul( v4, m44 )`, `vm_mul( m44, v44 )`, `vm_mul( m44, m44 )`
etc.

The full set of generic function names are:

	vm_neg
	vm_eq
	vm_mul
	vm_add
	vm_sub
	vm_div
	vm_abs
	vm_acos
	vm_all
	vm_any
	vm_asin
	vm_atan
	vm_atan2
	vm_ceil
	vm_clamp
	vm_cos
	vm_cosh
	vm_cross
	vm_degrees
	vm_distancesq
	vm_distance
	vm_dot
	vm_exp
	vm_exp2
	vm_floor
	vm_fmod
	vm_frac
	vm_lengthsq
	vm_length
	vm_lerp
	vm_log
	vm_log2
	vm_log10
	vm_max
	vm_min
	vm_normalize
	vm_pow
	vm_radians
	vm_rcp
	vm_reflect
	vm_refract
	vm_round
	vm_rsqrt
	vm_saturate
	vm_sign
	vm_sin
	vm_sinh
	vm_smoothstep
	vm_smootherstep
	vm_sqrt
	vm_step
	vm_tan
	vm_tanh
	vm_trunc
	vm_transpose
	vm_determinant

> In C++, if `VECMATH_GENERICS` is defined, all these `vm_` functions will be
> defined as overloaded functions instead of using the `_Generic` macro for C,
> providing the same functionality as long as `VECMATH_GENERICS` is defined.

### Generics without the prefix

In addition to the `VECMATH_GENERICS` preprocessor symbol, it is also possible
to define the symbol `VECMATH_GENERICS_NO_PREFIX`, to create a set of aliases
for all the `vm_*` macros, that omits the `vm_` prefix, providing more natural
names like `add( a, b )`, `mul( v, m )` etc.

> [!CAUTION]
> Do note that defining `VECMATH_GENERICS_NO_PREFIX` will redefine names like
> `abs`, `sin`, `cos` etc, which will very much be in direct conflict with
> names from the C standard math library. Use this feature with care, as it can
> very easily lead to some pretty weird compilation errors.

> In C++, when `VECMATH_GENERICS_NO_PREFIX` is defined, all the function
> overloads are just defined without the prefix in the first place, and instead
> macros are defined to provide the `vm_` prefixed names as aliases. This avoids
> the global redefining of common math.h names, and also places the overloaded
> functions within the `vecmath` namespace, which further avoids collisions.


Unit tests
----------

vecmath.h contains an extensive test suite, consisting of over 1300 tests,
checking over 6000 assertions. These tests are implemented at the end of the
vecmath.h file, guarded by a conditional compile flag so they are ignored when
using the library normally.

To enable the tests, compile vecmath.h as a C or C++ file, and define the
preprocessor symbol VECMATH_RUN_TESTS.

Using MSVCs cl.exe it would look like this:

	cl -Tc vecmath.h -DVECMATH_RUN_TESTS

and using clang (gcc and tcc use similar syntax):

	clang -xc vecmath.h -DVECMATH_RUN_TESTS

The executable produced can then be run, and it will perform all tests and
print the result.

### DirectX D3D conformance tests

To ensure the correctness of the library, it seemed appropriate to test some
parts of it against a known correct implementation. So vecmath.h implements
a set of tests that compare its computations with those of Microsofts DirectX
library, specifically the D3DX part of DirectX 9. This is a very widely used
and well proven math library implementation, and testing vecmath.h against this
gives a high level of confidence.

To enable the running of D3DX tests, define the preprocessor symbol
`VECMATH_RUN_D3DX_TESTS` (in addition to `VECMATH_RUN_TESTS`), and make sure to
build with the correct include and library paths set for your installation of
d3d9.


### Using external testfw.h

By default, the tests are written using a handful of simple macros that check
for errors and print results. These macros are defined in the test code portion
of vecmath.h.

However, to get better test coverage (catching things like access violations and
other system exceptions, or memory leaks) and nicer printout of the result (for
example, using multi-colored output), it's possible to use the testfw.h single-
header lib, which can be found at:
https://github.com/mattiasgustavsson/libs/blob/main/testfw.h

To enable the use of testfw.h, the file must be placed in the same directory
as vecmath.h, and the preprocessor symbol VECMATH_USE_EXTERNAL_TESTFW must be
defined at compilation, like so:

	cl -Tc vecmath.h -DVECMATH_RUN_TESTS -DVECMATH_USE_EXTERNAL_TESTFW

if using msvc, or:

	clang -xc vecmath.h -DVECMATH_RUN_TESTS -DVECMATH_USE_EXTERNAL_TESTFW

if using clang (gcc and tcc use similar syntax).


*/
// types
struct vec2_t {
    f32 x;
    f32 y;
}

struct vec3_t {
    f32 x;
    f32 y;
    f32 z;
}

struct vec4_t {
    f32 x;
    f32 y;
    f32 z;
    f32 w;
}

struct mat22_t {
    vec2_t x;
    vec2_t y;
}

struct mat23_t {
    vec3_t x;
    vec3_t y;
}

struct mat24_t {
    vec4_t x;
    vec4_t y;
}

struct mat32_t {
    vec2_t x;
    vec2_t y;
    vec2_t z;
}

struct mat33_t {
    vec3_t x;
    vec3_t y;
    vec3_t z;
}

struct mat34_t {
    vec4_t x;
    vec4_t y;
    vec4_t z;
}

struct mat42_t {
    vec2_t x;
    vec2_t y;
    vec2_t z;
    vec2_t w;
}

struct mat43_t {
    vec3_t x;
    vec3_t y;
    vec3_t z;
    vec3_t w;
}

struct mat44_t {
    vec4_t x;
    vec4_t y;
    vec4_t z;
    vec4_t w;
}

// math defines
// If we are running tests on windows
f32 internal_vecmath_frac(f32 v) {
    f32 t;
    return fabsf(modff(v, &t));
}

f32 internal_vecmath_round(f32 x) {
    f32 i;
    f32 r;
    f32 fraction = modff(x, &i);
    modff(2.0f * fraction, &r);
    return i + r;
}

// functions
f32 vecmath_abs(f32 v) {
    return fabsf(v);
}

f32 vecmath_acos(f32 v) {
    return acosf(v);
}

i32 vecmath_all(f32 v) {
    return v != 0.0f;
}

i32 vecmath_any(f32 v) {
    return v != 0.0f;
}

f32 vecmath_asin(f32 v) {
    return asinf(v);
}

f32 vecmath_atan(f32 v) {
    return atanf(v);
}

f32 vecmath_atan2(f32 y, f32 x) {
    return atan2f(y, x);
}

f32 vecmath_ceil(f32 v) {
    return ceilf(v);
}

f32 vecmath_clamp(f32 v, f32 min_v, f32 max_v) {
    return v < min_v ? min_v : v > max_v ? max_v : v;
}

f32 vecmath_cos(f32 v) {
    return cosf(v);
}

f32 vecmath_cosh(f32 v) {
    return coshf(v);
}

f32 vecmath_degrees(f32 v) {
    f32 f = 57.29577951308232f;
    return v * f;
}

f32 vecmath_distancesq(f32 a, f32 b) {
    f32 x = b - a;
    return x * x;
}

f32 vecmath_distance(f32 a, f32 b) {
    return fabsf(b - a);
}

f32 vecmath_dot(f32 a, f32 b) {
    return a * b;
}

f32 vecmath_exp(f32 v) {
    return expf(v);
}

f32 vecmath_exp2(f32 v) {
    return powf(2.0f, v);
}

f32 vecmath_floor(f32 v) {
    return floorf(v);
}

f32 vecmath_fmod(f32 a, f32 b) {
    return fmodf(a, b);
}

f32 vecmath_frac(f32 v) {
    return internal_vecmath_frac(v);
}

f32 vecmath_lengthsq(f32 v) {
    return v * v;
}

f32 vecmath_length(f32 v) {
    return sqrtf(v * v);
}

f32 vecmath_lerp(f32 a, f32 b, f32 s) {
    return a + (b - a) * s;
}

f32 vecmath_log(f32 v) {
    return logf(v);
}

f32 vecmath_log2(f32 v) {
    return log10f(v) / log10f(2.0f);
}

f32 vecmath_log10(f32 v) {
    return log10f(v);
}

f32 vecmath_max(f32 a, f32 b) {
    return max(a, b);
}

f32 vecmath_min(f32 a, f32 b) {
    return min(a, b);
}

f32 vecmath_normalize(f32 v) {
    var l = sqrtf(v * v);
    return l == 0.0f ? v : v / l;
}

f32 vecmath_pow(f32 a, f32 b) {
    return powf(a, b);
}

f32 vecmath_radians(f32 v) {
    f32 f = 0.017453292519943302f;
    return v * f;
}

f32 vecmath_rcp(f32 v) {
    return 1.0f / v;
}

f32 vecmath_reflect(f32 i, f32 n) {
    return i - 2.0f * n * vecmath_dot(i, n);
}

f32 vecmath_refract(f32 i, f32 n, f32 r) {
    f32 n_i = vecmath_dot(n, i);
    f32 k = 1.0f - r * r * (1.0f - n_i * n_i);
    return k < 0.0f ? 0.0f : r * i - (r * n_i + sqrtf(k)) * n;
}

f32 vecmath_round(f32 v) {
    return internal_vecmath_round(v);
}

f32 vecmath_rsqrt(f32 v) {
    return 1.0f / sqrtf(v);
}

f32 vecmath_saturate(f32 v) {
    return v < 0.0f ? 0.0f : v > 1.0f ? 1.0f : v;
}

f32 vecmath_sign(f32 v) {
    return v < 0.0f ? -1.0f : v > 0.0f ? 1.0f : 0.0f;
}

f32 vecmath_sin(f32 v) {
    return sinf(v);
}

f32 vecmath_sinh(f32 v) {
    return sinhf(v);
}

f32 vecmath_smoothstep(f32 min_v, f32 max_v, f32 v) {
    f32 range = max_v - min_v;
    if range == 0.0f {
        return v < min_v ? 0.0f : 1.0f;
    }
    v = (v - min_v) / range;
    v = v < 0.0f ? 0.0f : v > 1.0f ? 1.0f : v;
    return v * v * (3.0f - 2.0f * v);
}

f32 vecmath_smootherstep(f32 min_v, f32 max_v, f32 v) {
    f32 range = max_v - min_v;
    if range == 0.0f {
        return v < min_v ? 0.0f : 1.0f;
    }
    v = (v - min_v) / range;
    v = v < 0.0f ? 0.0f : v > 1.0f ? 1.0f : v;
    return v * v * v * (v * (v * 6.0f - 15.0f) + 10.0f);
}

f32 vecmath_sqrt(f32 v) {
    return sqrtf(v);
}

f32 vecmath_step(f32 edge, f32 x) {
    return x >= edge ? 1.0f : 0.0f;
}

f32 vecmath_tan(f32 v) {
    return tanf(v);
}

f32 vecmath_tanh(f32 v) {
    return tanhf(v);
}

f32 vecmath_trunc(f32 v) {
    return v > 0.0f ? floorf(v) : ceilf(v);
}

// helpers for making `vm_*` generics easier to implement
f32 vecmath_fneg(f32 a) {
    return -a;
}

i32 vecmath_feq(f32 a, f32 b) {
    return a == b;
}

f32 vecmath_fadd(f32 a, f32 b) {
    return a + b;
}

f32 vecmath_fsub(f32 a, f32 b) {
    return a - b;
}

f32 vecmath_fmul(f32 a, f32 b) {
    return a * b;
}

f32 vecmath_fdiv(f32 a, f32 b) {
    return a / b;
}

// vec2
vec2_t vec2(f32 x, f32 y) {
    noinit vec2_t vec;
    vec.x = x;
    vec.y = y;
    return vec;
}

vec2_t vec2f(f32 v) {
    noinit vec2_t vec;
    vec.x = v;
    vec.y = v;
    return vec;
}

f32 vec2_get(vec2_t vec, i32 index) {
    return cast(f32*, &vec)[index];
}

void vec2_set(vec2_t* vec, i32 index, f32 f) {
    cast(f32*, vec)[index] = f;
}

// operators
vec2_t vec2_neg(vec2_t v) {
    return vec2(-v.x, -v.y);
}

i32 vec2_eq(vec2_t a, vec2_t b) {
    return a.x == b.x && a.y == b.y;
}

vec2_t vec2_add(vec2_t a, vec2_t b) {
    return vec2(a.x + b.x, a.y + b.y);
}

vec2_t vec2_sub(vec2_t a, vec2_t b) {
    return vec2(a.x - b.x, a.y - b.y);
}

vec2_t vec2_mul(vec2_t a, vec2_t b) {
    return vec2(a.x * b.x, a.y * b.y);
}

vec2_t vec2_div(vec2_t a, vec2_t b) {
    return vec2(a.x / b.x, a.y / b.y);
}

vec2_t vec2_addf(vec2_t a, f32 s) {
    return vec2(a.x + s, a.y + s);
}

vec2_t vec2_subf(vec2_t a, f32 s) {
    return vec2(a.x - s, a.y - s);
}

vec2_t vec2_mulf(vec2_t a, f32 s) {
    return vec2(a.x * s, a.y * s);
}

vec2_t vec2_divf(vec2_t a, f32 s) {
    return vec2(a.x / s, a.y / s);
}

vec2_t vec2_fadd(f32 s, vec2_t a) {
    return vec2_addf(a, s);
}

vec2_t vec2_fsub(f32 s, vec2_t a) {
    return vec2_sub(vec2f(s), a);
}

vec2_t vec2_fmul(f32 s, vec2_t a) {
    return vec2_mulf(a, s);
}

vec2_t vec2_fdiv(f32 s, vec2_t a) {
    return vec2_div(vec2f(s), a);
}

// functions
vec2_t vec2_abs(vec2_t v) {
    return vec2(vecmath_abs(v.x), vecmath_abs(v.y));
}

vec2_t vec2_acos(vec2_t v) {
    return vec2(vecmath_acos(v.x), vecmath_acos(v.y));
}

i32 vec2_all(vec2_t v) {
    return v.x != 0.0f && v.y != 0.0f;
}

i32 vec2_any(vec2_t v) {
    return v.x != 0.0f || v.y != 0.0f;
}

vec2_t vec2_asin(vec2_t v) {
    return vec2(vecmath_asin(v.x), vecmath_asin(v.y));
}

vec2_t vec2_atan(vec2_t v) {
    return vec2(vecmath_atan(v.x), vecmath_atan(v.y));
}

vec2_t vec2_atan2(vec2_t y, vec2_t x) {
    return vec2(vecmath_atan2(y.x, x.x), vecmath_atan2(y.y, x.y));
}

vec2_t vec2_ceil(vec2_t v) {
    return vec2(vecmath_ceil(v.x), vecmath_ceil(v.y));
}

vec2_t vec2_clamp(vec2_t v, vec2_t min_v, vec2_t max_v) {
    return vec2(vecmath_clamp(v.x, min_v.x, max_v.x), vecmath_clamp(v.y, min_v.y, max_v.y));
}

vec2_t vec2_cos(vec2_t v) {
    return vec2(vecmath_cos(v.x), vecmath_cos(v.y));
}

vec2_t vec2_cosh(vec2_t v) {
    return vec2(vecmath_cosh(v.x), vecmath_cosh(v.y));
}

f32 vec2_cross(vec2_t a, vec2_t b) {
    return a.x * b.y - a.y * b.x;
}

vec2_t vec2_degrees(vec2_t v) {
    return vec2(vecmath_degrees(v.x), vecmath_degrees(v.y));
}

f32 vec2_distancesq(vec2_t a, vec2_t b) {
    f32 x = b.x - a.x;
    f32 y = b.y - a.y;
    return x * x + y * y;
}

f32 vec2_distance(vec2_t a, vec2_t b) {
    f32 x = b.x - a.x;
    f32 y = b.y - a.y;
    return vecmath_sqrt(x * x + y * y);
}

f32 vec2_dot(vec2_t a, vec2_t b) {
    return a.x * b.x + a.y * b.y;
}

vec2_t vec2_exp(vec2_t v) {
    return vec2(vecmath_exp(v.x), vecmath_exp(v.y));
}

vec2_t vec2_exp2(vec2_t v) {
    return vec2(vecmath_exp2(v.x), vecmath_exp2(v.y));
}

vec2_t vec2_floor(vec2_t v) {
    return vec2(vecmath_floor(v.x), vecmath_floor(v.y));
}

vec2_t vec2_fmod(vec2_t a, vec2_t b) {
    return vec2(vecmath_fmod(a.x, b.x), vecmath_fmod(a.y, b.y));
}

vec2_t vec2_frac(vec2_t v) {
    return vec2(vecmath_frac(v.x), vecmath_frac(v.y));
}

f32 vec2_lengthsq(vec2_t v) {
    return v.x * v.x + v.y * v.y;
}

f32 vec2_length(vec2_t v) {
    return vecmath_sqrt(v.x * v.x + v.y * v.y);
}

vec2_t vec2_lerp(vec2_t a, vec2_t b, f32 s) {
    return vec2(vecmath_lerp(a.x, b.x, s), vecmath_lerp(a.y, b.y, s));
}

vec2_t vec2_log(vec2_t v) {
    return vec2(vecmath_log(v.x), vecmath_log(v.y));
}

vec2_t vec2_log2(vec2_t v) {
    return vec2(vecmath_log2(v.x), vecmath_log2(v.y));
}

vec2_t vec2_log10(vec2_t v) {
    return vec2(vecmath_log10(v.x), vecmath_log10(v.y));
}

vec2_t vec2_max(vec2_t a, vec2_t b) {
    return vec2(vecmath_max(a.x, b.x), vecmath_max(a.y, b.y));
}

vec2_t vec2_min(vec2_t a, vec2_t b) {
    return vec2(vecmath_min(a.x, b.x), vecmath_min(a.y, b.y));
}

vec2_t vec2_normalize(vec2_t v) {
    f32 l = vecmath_sqrt(v.x * v.x + v.y * v.y);
    return l == 0.0f ? v : vec2(v.x / l, v.y / l);
}

vec2_t vec2_pow(vec2_t a, vec2_t b) {
    return vec2(vecmath_pow(a.x, b.x), vecmath_pow(a.y, b.y));
}

vec2_t vec2_radians(vec2_t v) {
    return vec2(vecmath_radians(v.x), vecmath_radians(v.y));
}

vec2_t vec2_rcp(vec2_t v) {
    return vec2(vecmath_rcp(v.x), vecmath_rcp(v.y));
}

vec2_t vec2_reflect(vec2_t i, vec2_t n) {
    return vec2_sub(i, vec2_mulf(n, 2.0f * vec2_dot(i, n)));
}

vec2_t vec2_refract(vec2_t i, vec2_t n, f32 r) {
    f32 d = vec2_dot(n, i);
    f32 k = 1.0f - r * r * (1.0f - d * d);
    return k < 0.0f ? vec2f(0.0f) : vec2_sub(vec2_mulf(i, r), vec2_mulf(n, r * d + vecmath_sqrt(k)));
}

vec2_t vec2_round(vec2_t v) {
    return vec2(vecmath_round(v.x), vecmath_round(v.y));
}

vec2_t vec2_rsqrt(vec2_t v) {
    return vec2(vecmath_rcp(vecmath_sqrt(v.x)), vecmath_rcp(vecmath_sqrt(v.y)));
}

vec2_t vec2_saturate(vec2_t v) {
    return vec2(vecmath_saturate(v.x), vecmath_saturate(v.y));
}

vec2_t vec2_sign(vec2_t v) {
    return vec2(vecmath_sign(v.x), vecmath_sign(v.y));
}

vec2_t vec2_sin(vec2_t v) {
    return vec2(vecmath_sin(v.x), vecmath_sin(v.y));
}

vec2_t vec2_sinh(vec2_t v) {
    return vec2(vecmath_sinh(v.x), vecmath_sinh(v.y));
}

vec2_t vec2_smoothstep(vec2_t min_v, vec2_t max_v, vec2_t v) {
    return vec2(vecmath_smoothstep(min_v.x, max_v.x, v.x), vecmath_smoothstep(min_v.y, max_v.y, v.y));
}

vec2_t vec2_smootherstep(vec2_t min_v, vec2_t max_v, vec2_t v) {
    return vec2(vecmath_smootherstep(min_v.x, max_v.x, v.x), vecmath_smootherstep(min_v.y, max_v.y, v.y));
}

vec2_t vec2_sqrt(vec2_t v) {
    return vec2(vecmath_sqrt(v.x), vecmath_sqrt(v.y));
}

vec2_t vec2_step(vec2_t a, vec2_t b) {
    return vec2(vecmath_step(a.x, b.x), vecmath_step(a.y, b.y));
}

vec2_t vec2_tan(vec2_t v) {
    return vec2(vecmath_tan(v.x), vecmath_tan(v.y));
}

vec2_t vec2_tanh(vec2_t v) {
    return vec2(vecmath_tanh(v.x), vecmath_tanh(v.y));
}

vec2_t vec2_trunc(vec2_t v) {
    return vec2(vecmath_trunc(v.x), vecmath_trunc(v.y));
}

// vec3
vec3_t vec3(f32 x, f32 y, f32 z) {
    noinit vec3_t vec;
    vec.x = x;
    vec.y = y;
    vec.z = z;
    return vec;
}

vec3_t vec3f(f32 v) {
    noinit vec3_t vec;
    vec.x = v;
    vec.y = v;
    vec.z = v;
    return vec;
}

vec3_t vec3v2f(vec2_t v, f32 f) {
    noinit vec3_t vec;
    vec.x = v.x;
    vec.y = v.y;
    vec.z = f;
    return vec;
}

vec3_t vec3fv2(f32 f, vec2_t v) {
    noinit vec3_t vec;
    vec.x = f;
    vec.y = v.x;
    vec.z = v.y;
    return vec;
}

f32 vec3_get(vec3_t vec, i32 index) {
    return cast(f32*, &vec)[index];
}

void vec3_set(vec3_t* vec, i32 index, f32 f) {
    cast(f32*, vec)[index] = f;
}

// operators
vec3_t vec3_neg(vec3_t v) {
    return vec3(-v.x, -v.y, -v.z);
}

i32 vec3_eq(vec3_t a, vec3_t b) {
    return a.x == b.x && a.y == b.y && a.z == b.z;
}

vec3_t vec3_add(vec3_t a, vec3_t b) {
    return vec3(a.x + b.x, a.y + b.y, a.z + b.z);
}

vec3_t vec3_sub(vec3_t a, vec3_t b) {
    return vec3(a.x - b.x, a.y - b.y, a.z - b.z);
}

vec3_t vec3_mul(vec3_t a, vec3_t b) {
    return vec3(a.x * b.x, a.y * b.y, a.z * b.z);
}

vec3_t vec3_div(vec3_t a, vec3_t b) {
    return vec3(a.x / b.x, a.y / b.y, a.z / b.z);
}

vec3_t vec3_addf(vec3_t a, f32 s) {
    return vec3(a.x + s, a.y + s, a.z + s);
}

vec3_t vec3_subf(vec3_t a, f32 s) {
    return vec3(a.x - s, a.y - s, a.z - s);
}

vec3_t vec3_mulf(vec3_t a, f32 s) {
    return vec3(a.x * s, a.y * s, a.z * s);
}

vec3_t vec3_divf(vec3_t a, f32 s) {
    return vec3(a.x / s, a.y / s, a.z / s);
}

vec3_t vec3_fadd(f32 s, vec3_t a) {
    return vec3_addf(a, s);
}

vec3_t vec3_fsub(f32 s, vec3_t a) {
    return vec3_sub(vec3f(s), a);
}

vec3_t vec3_fmul(f32 s, vec3_t a) {
    return vec3_mulf(a, s);
}

vec3_t vec3_fdiv(f32 s, vec3_t a) {
    return vec3_div(vec3f(s), a);
}

// functions
vec3_t vec3_abs(vec3_t v) {
    return vec3(vecmath_abs(v.x), vecmath_abs(v.y), vecmath_abs(v.z));
}

vec3_t vec3_acos(vec3_t v) {
    return vec3(vecmath_acos(v.x), vecmath_acos(v.y), vecmath_acos(v.z));
}

i32 vec3_all(vec3_t v) {
    return v.x != 0.0f && v.y != 0.0f && v.z != 0.0f;
}

i32 vec3_any(vec3_t v) {
    return v.x != 0.0f || v.y != 0.0f || v.z != 0.0f;
}

vec3_t vec3_asin(vec3_t v) {
    return vec3(vecmath_asin(v.x), vecmath_asin(v.y), vecmath_asin(v.z));
}

vec3_t vec3_atan(vec3_t v) {
    return vec3(vecmath_atan(v.x), vecmath_atan(v.y), vecmath_atan(v.z));
}

vec3_t vec3_atan2(vec3_t y, vec3_t x) {
    return vec3(vecmath_atan2(y.x, x.x), vecmath_atan2(y.y, x.y), vecmath_atan2(y.z, x.z));
}

vec3_t vec3_ceil(vec3_t v) {
    return vec3(vecmath_ceil(v.x), vecmath_ceil(v.y), vecmath_ceil(v.z));
}

vec3_t vec3_clamp(vec3_t v, vec3_t min_v, vec3_t max_v) {
    return vec3(vecmath_clamp(v.x, min_v.x, max_v.x), vecmath_clamp(v.y, min_v.y, max_v.y), vecmath_clamp(v.z, min_v.z, max_v.z));
}

vec3_t vec3_cos(vec3_t v) {
    return vec3(vecmath_cos(v.x), vecmath_cos(v.y), vecmath_cos(v.z));
}

vec3_t vec3_cosh(vec3_t v) {
    return vec3(vecmath_cosh(v.x), vecmath_cosh(v.y), vecmath_cosh(v.z));
}

vec3_t vec3_cross(vec3_t a, vec3_t b) {
    return vec3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
}

vec3_t vec3_degrees(vec3_t v) {
    return vec3(vecmath_degrees(v.x), vecmath_degrees(v.y), vecmath_degrees(v.z));
}

f32 vec3_distancesq(vec3_t a, vec3_t b) {
    f32 x = b.x - a.x;
    f32 y = b.y - a.y;
    f32 z = b.z - a.z;
    return x * x + y * y + z * z;
}

f32 vec3_distance(vec3_t a, vec3_t b) {
    f32 x = b.x - a.x;
    f32 y = b.y - a.y;
    f32 z = b.z - a.z;
    return vecmath_sqrt(x * x + y * y + z * z);
}

f32 vec3_dot(vec3_t a, vec3_t b) {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

vec3_t vec3_exp(vec3_t v) {
    return vec3(vecmath_exp(v.x), vecmath_exp(v.y), vecmath_exp(v.z));
}

vec3_t vec3_exp2(vec3_t v) {
    return vec3(vecmath_exp2(v.x), vecmath_exp2(v.y), vecmath_exp2(v.z));
}

vec3_t vec3_floor(vec3_t v) {
    return vec3(vecmath_floor(v.x), vecmath_floor(v.y), vecmath_floor(v.z));
}

vec3_t vec3_fmod(vec3_t a, vec3_t b) {
    return vec3(vecmath_fmod(a.x, b.x), vecmath_fmod(a.y, b.y), vecmath_fmod(a.z, b.z));
}

vec3_t vec3_frac(vec3_t v) {
    return vec3(vecmath_frac(v.x), vecmath_frac(v.y), vecmath_frac(v.z));
}

f32 vec3_lengthsq(vec3_t v) {
    return v.x * v.x + v.y * v.y + v.z * v.z;
}

f32 vec3_length(vec3_t v) {
    return vecmath_sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

vec3_t vec3_lerp(vec3_t a, vec3_t b, f32 s) {
    return vec3(vecmath_lerp(a.x, b.x, s), vecmath_lerp(a.y, b.y, s), vecmath_lerp(a.z, b.z, s));
}

vec3_t vec3_log(vec3_t v) {
    return vec3(vecmath_log(v.x), vecmath_log(v.y), vecmath_log(v.z));
}

vec3_t vec3_log2(vec3_t v) {
    return vec3(vecmath_log2(v.x), vecmath_log2(v.y), vecmath_log2(v.z));
}

vec3_t vec3_log10(vec3_t v) {
    return vec3(vecmath_log10(v.x), vecmath_log10(v.y), vecmath_log10(v.z));
}

vec3_t vec3_max(vec3_t a, vec3_t b) {
    return vec3(vecmath_max(a.x, b.x), vecmath_max(a.y, b.y), vecmath_max(a.z, b.z));
}

vec3_t vec3_min(vec3_t a, vec3_t b) {
    return vec3(vecmath_min(a.x, b.x), vecmath_min(a.y, b.y), vecmath_min(a.z, b.z));
}

vec3_t vec3_normalize(vec3_t v) {
    f32 l = vecmath_sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
    return l == 0.0f ? v : vec3(v.x / l, v.y / l, v.z / l);
}

vec3_t vec3_pow(vec3_t a, vec3_t b) {
    return vec3(vecmath_pow(a.x, b.x), vecmath_pow(a.y, b.y), vecmath_pow(a.z, b.z));
}

vec3_t vec3_radians(vec3_t v) {
    return vec3(vecmath_radians(v.x), vecmath_radians(v.y), vecmath_radians(v.z));
}

vec3_t vec3_rcp(vec3_t v) {
    return vec3(vecmath_rcp(v.x), vecmath_rcp(v.y), vecmath_rcp(v.z));
}

vec3_t vec3_reflect(vec3_t i, vec3_t n) {
    return vec3_sub(i, vec3_mulf(n, 2.0f * vec3_dot(i, n)));
}

vec3_t vec3_refract(vec3_t i, vec3_t n, f32 r) {
    f32 d = vec3_dot(n, i);
    f32 k = 1.0f - r * r * (1.0f - d * d);
    return k < 0.0f ? vec3f(0.0f) : vec3_sub(vec3_mulf(i, r), vec3_mulf(n, r * d + vecmath_sqrt(k)));
}

vec3_t vec3_round(vec3_t v) {
    return vec3(vecmath_round(v.x), vecmath_round(v.y), vecmath_round(v.z));
}

vec3_t vec3_rsqrt(vec3_t v) {
    return vec3(vecmath_rcp(vecmath_sqrt(v.x)), vecmath_rcp(vecmath_sqrt(v.y)), vecmath_rcp(vecmath_sqrt(v.z)));
}

vec3_t vec3_saturate(vec3_t v) {
    return vec3(vecmath_saturate(v.x), vecmath_saturate(v.y), vecmath_saturate(v.z));
}

vec3_t vec3_sign(vec3_t v) {
    return vec3(vecmath_sign(v.x), vecmath_sign(v.y), vecmath_sign(v.z));
}

vec3_t vec3_sin(vec3_t v) {
    return vec3(vecmath_sin(v.x), vecmath_sin(v.y), vecmath_sin(v.z));
}

vec3_t vec3_sinh(vec3_t v) {
    return vec3(vecmath_sinh(v.x), vecmath_sinh(v.y), vecmath_sinh(v.z));
}

vec3_t vec3_smoothstep(vec3_t min_v, vec3_t max_v, vec3_t v) {
    return vec3(vecmath_smoothstep(min_v.x, max_v.x, v.x), vecmath_smoothstep(min_v.y, max_v.y, v.y), vecmath_smoothstep(min_v.z, max_v.z, v.z));
}

vec3_t vec3_smootherstep(vec3_t min_v, vec3_t max_v, vec3_t v) {
    return vec3(vecmath_smootherstep(min_v.x, max_v.x, v.x), vecmath_smootherstep(min_v.y, max_v.y, v.y), vecmath_smootherstep(min_v.z, max_v.z, v.z));
}

vec3_t vec3_sqrt(vec3_t v) {
    return vec3(vecmath_sqrt(v.x), vecmath_sqrt(v.y), vecmath_sqrt(v.z));
}

vec3_t vec3_step(vec3_t a, vec3_t b) {
    return vec3(vecmath_step(a.x, b.x), vecmath_step(a.y, b.y), vecmath_step(a.z, b.z));
}

vec3_t vec3_tan(vec3_t v) {
    return vec3(vecmath_tan(v.x), vecmath_tan(v.y), vecmath_tan(v.z));
}

vec3_t vec3_tanh(vec3_t v) {
    return vec3(vecmath_tanh(v.x), vecmath_tanh(v.y), vecmath_tanh(v.z));
}

vec3_t vec3_trunc(vec3_t v) {
    return vec3(vecmath_trunc(v.x), vecmath_trunc(v.y), vecmath_trunc(v.z));
}

// vec4
vec4_t vec4(f32 x, f32 y, f32 z, f32 w) {
    noinit vec4_t vec;
    vec.x = x;
    vec.y = y;
    vec.z = z;
    vec.w = w;
    return vec;
}

vec4_t vec4f(f32 v) {
    noinit vec4_t vec;
    vec.x = v;
    vec.y = v;
    vec.z = v;
    vec.w = v;
    return vec;
}

vec4_t vec4v3f(vec3_t v, f32 f) {
    noinit vec4_t vec;
    vec.x = v.x;
    vec.y = v.y;
    vec.z = v.z;
    vec.w = f;
    return vec;
}

vec4_t vec4fv3(f32 f, vec3_t v) {
    noinit vec4_t vec;
    vec.x = f;
    vec.y = v.x;
    vec.z = v.y;
    vec.w = v.z;
    return vec;
}

vec4_t vec4v2(vec2_t a, vec2_t b) {
    noinit vec4_t vec;
    vec.x = a.x;
    vec.y = a.y;
    vec.z = b.x;
    vec.w = b.y;
    return vec;
}

f32 vec4_get(vec4_t vec, i32 index) {
    return cast(f32*, &vec)[index];
}

void vec4_set(vec4_t* vec, i32 index, f32 f) {
    cast(f32*, vec)[index] = f;
}

// operators
vec4_t vec4_neg(vec4_t v) {
    return vec4(-v.x, -v.y, -v.z, -v.w);
}

i32 vec4_eq(vec4_t a, vec4_t b) {
    return a.x == b.x && a.y == b.y && a.z == b.z && a.w == b.w;
}

vec4_t vec4_add(vec4_t a, vec4_t b) {
    return vec4(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);
}

vec4_t vec4_sub(vec4_t a, vec4_t b) {
    return vec4(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w);
}

vec4_t vec4_mul(vec4_t a, vec4_t b) {
    return vec4(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w);
}

vec4_t vec4_div(vec4_t a, vec4_t b) {
    return vec4(a.x / b.x, a.y / b.y, a.z / b.z, a.w / b.w);
}

vec4_t vec4_addf(vec4_t a, f32 s) {
    return vec4(a.x + s, a.y + s, a.z + s, a.w + s);
}

vec4_t vec4_subf(vec4_t a, f32 s) {
    return vec4(a.x - s, a.y - s, a.z - s, a.w - s);
}

vec4_t vec4_mulf(vec4_t a, f32 s) {
    return vec4(a.x * s, a.y * s, a.z * s, a.w * s);
}

vec4_t vec4_divf(vec4_t a, f32 s) {
    return vec4(a.x / s, a.y / s, a.z / s, a.w / s);
}

vec4_t vec4_fadd(f32 s, vec4_t a) {
    return vec4_addf(a, s);
}

vec4_t vec4_fsub(f32 s, vec4_t a) {
    return vec4_sub(vec4f(s), a);
}

vec4_t vec4_fmul(f32 s, vec4_t a) {
    return vec4_mulf(a, s);
}

vec4_t vec4_fdiv(f32 s, vec4_t a) {
    return vec4_div(vec4f(s), a);
}

// functions
vec4_t vec4_abs(vec4_t v) {
    return vec4(vecmath_abs(v.x), vecmath_abs(v.y), vecmath_abs(v.z), vecmath_abs(v.w));
}

vec4_t vec4_acos(vec4_t v) {
    return vec4(vecmath_acos(v.x), vecmath_acos(v.y), vecmath_acos(v.z), vecmath_acos(v.w));
}

i32 vec4_all(vec4_t v) {
    return v.x != 0.0f && v.y != 0.0f && v.z != 0.0f && v.w != 0.0f;
}

i32 vec4_any(vec4_t v) {
    return v.x != 0.0f || v.y != 0.0f || v.z != 0.0f || v.w != 0.0f;
}

vec4_t vec4_asin(vec4_t v) {
    return vec4(vecmath_asin(v.x), vecmath_asin(v.y), vecmath_asin(v.z), vecmath_asin(v.w));
}

vec4_t vec4_atan(vec4_t v) {
    return vec4(vecmath_atan(v.x), vecmath_atan(v.y), vecmath_atan(v.z), vecmath_atan(v.w));
}

vec4_t vec4_atan2(vec4_t y, vec4_t x) {
    return vec4(vecmath_atan2(y.x, x.x), vecmath_atan2(y.y, x.y), vecmath_atan2(y.z, x.z), vecmath_atan2(y.w, x.w));
}

vec4_t vec4_ceil(vec4_t v) {
    return vec4(vecmath_ceil(v.x), vecmath_ceil(v.y), vecmath_ceil(v.z), vecmath_ceil(v.w));
}

vec4_t vec4_clamp(vec4_t v, vec4_t min_v, vec4_t max_v) {
    return vec4(vecmath_clamp(v.x, min_v.x, max_v.x), vecmath_clamp(v.y, min_v.y, max_v.y), vecmath_clamp(v.z, min_v.z, max_v.z), vecmath_clamp(v.w, min_v.w, max_v.w));
}

vec4_t vec4_cos(vec4_t v) {
    return vec4(vecmath_cos(v.x), vecmath_cos(v.y), vecmath_cos(v.z), vecmath_cos(v.w));
}

vec4_t vec4_cosh(vec4_t v) {
    return vec4(vecmath_cosh(v.x), vecmath_cosh(v.y), vecmath_cosh(v.z), vecmath_cosh(v.w));
}

vec4_t vec4_degrees(vec4_t v) {
    return vec4(vecmath_degrees(v.x), vecmath_degrees(v.y), vecmath_degrees(v.z), vecmath_degrees(v.w));
}

f32 vec4_distancesq(vec4_t a, vec4_t b) {
    f32 x = b.x - a.x;
    f32 y = b.y - a.y;
    f32 z = b.z - a.z;
    f32 w = b.w - a.w;
    return x * x + y * y + z * z + w * w;
}

f32 vec4_distance(vec4_t a, vec4_t b) {
    f32 x = b.x - a.x;
    f32 y = b.y - a.y;
    f32 z = b.z - a.z;
    f32 w = b.w - a.w;
    return vecmath_sqrt(x * x + y * y + z * z + w * w);
}

f32 vec4_dot(vec4_t a, vec4_t b) {
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
}

vec4_t vec4_exp(vec4_t v) {
    return vec4(vecmath_exp(v.x), vecmath_exp(v.y), vecmath_exp(v.z), vecmath_exp(v.w));
}

vec4_t vec4_exp2(vec4_t v) {
    return vec4(vecmath_exp2(v.x), vecmath_exp2(v.y), vecmath_exp2(v.z), vecmath_exp2(v.w));
}

vec4_t vec4_floor(vec4_t v) {
    return vec4(vecmath_floor(v.x), vecmath_floor(v.y), vecmath_floor(v.z), vecmath_floor(v.w));
}

vec4_t vec4_fmod(vec4_t a, vec4_t b) {
    return vec4(vecmath_fmod(a.x, b.x), vecmath_fmod(a.y, b.y), vecmath_fmod(a.z, b.z), vecmath_fmod(a.w, b.w));
}

vec4_t vec4_frac(vec4_t v) {
    return vec4(vecmath_frac(v.x), vecmath_frac(v.y), vecmath_frac(v.z), vecmath_frac(v.w));
}

f32 vec4_lengthsq(vec4_t v) {
    return v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w;
}

f32 vec4_length(vec4_t v) {
    return vecmath_sqrt(v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w);
}

vec4_t vec4_lerp(vec4_t a, vec4_t b, f32 s) {
    return vec4(vecmath_lerp(a.x, b.x, s), vecmath_lerp(a.y, b.y, s), vecmath_lerp(a.z, b.z, s), vecmath_lerp(a.w, b.w, s));
}

vec4_t vec4_log(vec4_t v) {
    return vec4(vecmath_log(v.x), vecmath_log(v.y), vecmath_log(v.z), vecmath_log(v.w));
}

vec4_t vec4_log2(vec4_t v) {
    return vec4(vecmath_log2(v.x), vecmath_log2(v.y), vecmath_log2(v.z), vecmath_log2(v.w));
}

vec4_t vec4_log10(vec4_t v) {
    return vec4(vecmath_log10(v.x), vecmath_log10(v.y), vecmath_log10(v.z), vecmath_log10(v.w));
}

vec4_t vec4_max(vec4_t a, vec4_t b) {
    return vec4(vecmath_max(a.x, b.x), vecmath_max(a.y, b.y), vecmath_max(a.z, b.z), vecmath_max(a.w, b.w));
}

vec4_t vec4_min(vec4_t a, vec4_t b) {
    return vec4(vecmath_min(a.x, b.x), vecmath_min(a.y, b.y), vecmath_min(a.z, b.z), vecmath_min(a.w, b.w));
}

vec4_t vec4_normalize(vec4_t v) {
    f32 l = vecmath_sqrt(v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w);
    return l == 0.0f ? v : vec4(v.x / l, v.y / l, v.z / l, v.w / l);
}

vec4_t vec4_pow(vec4_t a, vec4_t b) {
    return vec4(vecmath_pow(a.x, b.x), vecmath_pow(a.y, b.y), vecmath_pow(a.z, b.z), vecmath_pow(a.w, b.w));
}

vec4_t vec4_radians(vec4_t v) {
    return vec4(vecmath_radians(v.x), vecmath_radians(v.y), vecmath_radians(v.z), vecmath_radians(v.w));
}

vec4_t vec4_rcp(vec4_t v) {
    return vec4(vecmath_rcp(v.x), vecmath_rcp(v.y), vecmath_rcp(v.z), vecmath_rcp(v.w));
}

vec4_t vec4_reflect(vec4_t i, vec4_t n) {
    return vec4_sub(i, vec4_mulf(n, 2.0f * vec4_dot(i, n)));
}

vec4_t vec4_refract(vec4_t i, vec4_t n, f32 r) {
    f32 d = vec4_dot(n, i);
    f32 k = 1.0f - r * r * (1.0f - d * d);
    return k < 0.0f ? vec4f(0.0f) : vec4_sub(vec4_mulf(i, r), vec4_mulf(n, r * d + vecmath_sqrt(k)));
}

vec4_t vec4_round(vec4_t v) {
    return vec4(vecmath_round(v.x), vecmath_round(v.y), vecmath_round(v.z), vecmath_round(v.w));
}

vec4_t vec4_rsqrt(vec4_t v) {
    return vec4(vecmath_rcp(vecmath_sqrt(v.x)), vecmath_rcp(vecmath_sqrt(v.y)), vecmath_rcp(vecmath_sqrt(v.z)), vecmath_rcp(vecmath_sqrt(v.w)));
}

vec4_t vec4_saturate(vec4_t v) {
    return vec4(vecmath_saturate(v.x), vecmath_saturate(v.y), vecmath_saturate(v.z), vecmath_saturate(v.w));
}

vec4_t vec4_sign(vec4_t v) {
    return vec4(vecmath_sign(v.x), vecmath_sign(v.y), vecmath_sign(v.z), vecmath_sign(v.w));
}

vec4_t vec4_sin(vec4_t v) {
    return vec4(vecmath_sin(v.x), vecmath_sin(v.y), vecmath_sin(v.z), vecmath_sin(v.w));
}

vec4_t vec4_sinh(vec4_t v) {
    return vec4(vecmath_sinh(v.x), vecmath_sinh(v.y), vecmath_sinh(v.z), vecmath_sinh(v.w));
}

vec4_t vec4_smoothstep(vec4_t min_v, vec4_t max_v, vec4_t v) {
    return vec4(vecmath_smoothstep(min_v.x, max_v.x, v.x), vecmath_smoothstep(min_v.y, max_v.y, v.y), vecmath_smoothstep(min_v.z, max_v.z, v.z), vecmath_smoothstep(min_v.w, max_v.w, v.w));
}

vec4_t vec4_smootherstep(vec4_t min_v, vec4_t max_v, vec4_t v) {
    return vec4(vecmath_smootherstep(min_v.x, max_v.x, v.x), vecmath_smootherstep(min_v.y, max_v.y, v.y), vecmath_smootherstep(min_v.z, max_v.z, v.z), vecmath_smootherstep(min_v.w, max_v.w, v.w));
}

vec4_t vec4_sqrt(vec4_t v) {
    return vec4(vecmath_sqrt(v.x), vecmath_sqrt(v.y), vecmath_sqrt(v.z), vecmath_sqrt(v.w));
}

vec4_t vec4_step(vec4_t a, vec4_t b) {
    return vec4(vecmath_step(a.x, b.x), vecmath_step(a.y, b.y), vecmath_step(a.z, b.z), vecmath_step(a.w, b.w));
}

vec4_t vec4_tan(vec4_t v) {
    return vec4(vecmath_tan(v.x), vecmath_tan(v.y), vecmath_tan(v.z), vecmath_tan(v.w));
}

vec4_t vec4_tanh(vec4_t v) {
    return vec4(vecmath_tanh(v.x), vecmath_tanh(v.y), vecmath_tanh(v.z), vecmath_tanh(v.w));
}

vec4_t vec4_trunc(vec4_t v) {
    return vec4(vecmath_trunc(v.x), vecmath_trunc(v.y), vecmath_trunc(v.z), vecmath_trunc(v.w));
}

// mat22
mat22_t mat22(vec2_t x, vec2_t y) {
    noinit mat22_t m;
    m.x = x;
    m.y = y;
    return m;
}

mat22_t mat22f(f32 v) {
    vec2_t t = vec2f(v);
    return mat22(t, t);
}

vec2_t mat22_get(mat22_t m, i32 row) {
    return cast(vec2_t*, &m)[row];
}

void mat22_set(mat22_t* m, i32 row, vec2_t v) {
    cast(vec2_t*, m)[row] = v;
}

// operators
mat22_t mat22_neg(mat22_t m) {
    return mat22(vec2_neg(m.x), vec2_neg(m.y));
}

i32 mat22_eq(mat22_t a, mat22_t b) {
    return vec2_eq(a.x, b.x) && vec2_eq(a.y, b.y);
}

mat22_t mat22_add(mat22_t a, mat22_t b) {
    return mat22(vec2_add(a.x, b.x), vec2_add(a.y, b.y));
}

mat22_t mat22_sub(mat22_t a, mat22_t b) {
    return mat22(vec2_sub(a.x, b.x), vec2_sub(a.y, b.y));
}

mat22_t mat22_mul_elem(mat22_t a, mat22_t b) {
    return mat22(vec2_mul(a.x, b.x), vec2_mul(a.y, b.y));
}

mat22_t mat22_div(mat22_t a, mat22_t b) {
    return mat22(vec2_div(a.x, b.x), vec2_div(a.y, b.y));
}

mat22_t mat22_addf(mat22_t a, f32 s) {
    return mat22(vec2_addf(a.x, s), vec2_addf(a.y, s));
}

mat22_t mat22_subf(mat22_t a, f32 s) {
    return mat22(vec2_subf(a.x, s), vec2_subf(a.y, s));
}

mat22_t mat22_mulf(mat22_t a, f32 s) {
    return mat22(vec2_mulf(a.x, s), vec2_mulf(a.y, s));
}

mat22_t mat22_divf(mat22_t a, f32 s) {
    return mat22(vec2_divf(a.x, s), vec2_divf(a.y, s));
}

mat22_t mat22_fadd(f32 s, mat22_t a) {
    return mat22_addf(a, s);
}

mat22_t mat22_fsub(f32 s, mat22_t a) {
    return mat22_sub(mat22f(s), a);
}

mat22_t mat22_fmul(f32 s, mat22_t a) {
    return mat22_mulf(a, s);
}

mat22_t mat22_fdiv(f32 s, mat22_t a) {
    return mat22_div(mat22f(s), a);
}

// functions
mat22_t mat22_abs(mat22_t m) {
    return mat22(vec2_abs(m.x), vec2_abs(m.y));
}

mat22_t mat22_acos(mat22_t m) {
    return mat22(vec2_acos(m.x), vec2_acos(m.y));
}

i32 mat22_all(mat22_t m) {
    return vec2_all(m.x) && vec2_all(m.y);
}

i32 mat22_any(mat22_t m) {
    return vec2_any(m.x) || vec2_any(m.y);
}

mat22_t mat22_asin(mat22_t m) {
    return mat22(vec2_asin(m.x), vec2_asin(m.y));
}

mat22_t mat22_atan(mat22_t m) {
    return mat22(vec2_atan(m.x), vec2_atan(m.y));
}

mat22_t mat22_atan2(mat22_t y, mat22_t x) {
    return mat22(vec2_atan2(y.x, x.x), vec2_atan2(y.y, x.y));
}

mat22_t mat22_ceil(mat22_t m) {
    return mat22(vec2_ceil(m.x), vec2_ceil(m.y));
}

mat22_t mat22_clamp(mat22_t m, mat22_t min_v, mat22_t max_v) {
    return mat22(vec2_clamp(m.x, min_v.x, max_v.x), vec2_clamp(m.y, min_v.y, max_v.y));
}

mat22_t mat22_cos(mat22_t m) {
    return mat22(vec2_cos(m.x), vec2_cos(m.y));
}

mat22_t mat22_cosh(mat22_t m) {
    return mat22(vec2_cosh(m.x), vec2_cosh(m.y));
}

mat22_t mat22_degrees(mat22_t m) {
    return mat22(vec2_degrees(m.x), vec2_degrees(m.y));
}

mat22_t mat22_exp(mat22_t m) {
    return mat22(vec2_exp(m.x), vec2_exp(m.y));
}

mat22_t mat22_exp2(mat22_t m) {
    return mat22(vec2_exp2(m.x), vec2_exp2(m.y));
}

mat22_t mat22_floor(mat22_t m) {
    return mat22(vec2_floor(m.x), vec2_floor(m.y));
}

mat22_t mat22_fmod(mat22_t a, mat22_t b) {
    return mat22(vec2_fmod(a.x, b.x), vec2_fmod(a.y, b.y));
}

mat22_t mat22_frac(mat22_t m) {
    return mat22(vec2_frac(m.x), vec2_frac(m.y));
}

mat22_t mat22_lerp(mat22_t a, mat22_t b, f32 s) {
    return mat22(vec2_lerp(a.x, b.x, s), vec2_lerp(a.y, b.y, s));
}

mat22_t mat22_log(mat22_t m) {
    return mat22(vec2_log(m.x), vec2_log(m.y));
}

mat22_t mat22_log2(mat22_t m) {
    return mat22(vec2_log2(m.x), vec2_log2(m.y));
}

mat22_t mat22_log10(mat22_t m) {
    return mat22(vec2_log10(m.x), vec2_log10(m.y));
}

mat22_t mat22_max(mat22_t a, mat22_t b) {
    return mat22(vec2_max(a.x, b.x), vec2_max(a.y, b.y));
}

mat22_t mat22_min(mat22_t a, mat22_t b) {
    return mat22(vec2_min(a.x, b.x), vec2_min(a.y, b.y));
}

mat22_t mat22_pow(mat22_t a, mat22_t b) {
    return mat22(vec2_pow(a.x, b.x), vec2_pow(a.y, b.y));
}

mat22_t mat22_radians(mat22_t m) {
    return mat22(vec2_radians(m.x), vec2_radians(m.y));
}

mat22_t mat22_rcp(mat22_t m) {
    return mat22(vec2_rcp(m.x), vec2_rcp(m.y));
}

mat22_t mat22_round(mat22_t m) {
    return mat22(vec2_round(m.x), vec2_round(m.y));
}

mat22_t mat22_rsqrt(mat22_t m) {
    return mat22(vec2_rsqrt(m.x), vec2_rsqrt(m.y));
}

mat22_t mat22_saturate(mat22_t m) {
    return mat22(vec2_saturate(m.x), vec2_saturate(m.y));
}

mat22_t mat22_sign(mat22_t m) {
    return mat22(vec2_sign(m.x), vec2_sign(m.y));
}

mat22_t mat22_sin(mat22_t m) {
    return mat22(vec2_sin(m.x), vec2_sin(m.y));
}

mat22_t mat22_sinh(mat22_t m) {
    return mat22(vec2_sinh(m.x), vec2_sinh(m.y));
}

mat22_t mat22_smoothstep(mat22_t min_v, mat22_t max_v, mat22_t m) {
    return mat22(vec2_smoothstep(min_v.x, max_v.x, m.x), vec2_smoothstep(min_v.y, max_v.y, m.y));
}

mat22_t mat22_smootherstep(mat22_t min_v, mat22_t max_v, mat22_t m) {
    return mat22(vec2_smootherstep(min_v.x, max_v.x, m.x), vec2_smootherstep(min_v.y, max_v.y, m.y));
}

mat22_t mat22_sqrt(mat22_t m) {
    return mat22(vec2_sqrt(m.x), vec2_sqrt(m.y));
}

mat22_t mat22_step(mat22_t a, mat22_t b) {
    return mat22(vec2_step(a.x, b.x), vec2_step(a.y, b.y));
}

mat22_t mat22_tan(mat22_t m) {
    return mat22(vec2_tan(m.x), vec2_tan(m.y));
}

mat22_t mat22_tanh(mat22_t m) {
    return mat22(vec2_tanh(m.x), vec2_tanh(m.y));
}

mat22_t mat22_trunc(mat22_t m) {
    return mat22(vec2_trunc(m.x), vec2_trunc(m.y));
}

// mat23
mat23_t mat23(vec3_t x, vec3_t y) {
    noinit mat23_t m;
    m.x = x;
    m.y = y;
    return m;
}

mat23_t mat23f(f32 v) {
    vec3_t t = vec3f(v);
    return mat23(t, t);
}

vec3_t mat23_get(mat23_t m, i32 row) {
    return cast(vec3_t*, &m)[row];
}

void mat23_set(mat23_t* m, i32 row, vec3_t v) {
    cast(vec3_t*, m)[row] = v;
}

// operators
mat23_t mat23_neg(mat23_t m) {
    return mat23(vec3_neg(m.x), vec3_neg(m.y));
}

i32 mat23_eq(mat23_t a, mat23_t b) {
    return vec3_eq(a.x, b.x) && vec3_eq(a.y, b.y);
}

mat23_t mat23_add(mat23_t a, mat23_t b) {
    return mat23(vec3_add(a.x, b.x), vec3_add(a.y, b.y));
}

mat23_t mat23_sub(mat23_t a, mat23_t b) {
    return mat23(vec3_sub(a.x, b.x), vec3_sub(a.y, b.y));
}

mat23_t mat23_mul_elem(mat23_t a, mat23_t b) {
    return mat23(vec3_mul(a.x, b.x), vec3_mul(a.y, b.y));
}

mat23_t mat23_div(mat23_t a, mat23_t b) {
    return mat23(vec3_div(a.x, b.x), vec3_div(a.y, b.y));
}

mat23_t mat23_addf(mat23_t a, f32 s) {
    return mat23(vec3_addf(a.x, s), vec3_addf(a.y, s));
}

mat23_t mat23_subf(mat23_t a, f32 s) {
    return mat23(vec3_subf(a.x, s), vec3_subf(a.y, s));
}

mat23_t mat23_mulf(mat23_t a, f32 s) {
    return mat23(vec3_mulf(a.x, s), vec3_mulf(a.y, s));
}

mat23_t mat23_divf(mat23_t a, f32 s) {
    return mat23(vec3_divf(a.x, s), vec3_divf(a.y, s));
}

mat23_t mat23_fadd(f32 s, mat23_t a) {
    return mat23_addf(a, s);
}

mat23_t mat23_fsub(f32 s, mat23_t a) {
    return mat23_sub(mat23f(s), a);
}

mat23_t mat23_fmul(f32 s, mat23_t a) {
    return mat23_mulf(a, s);
}

mat23_t mat23_fdiv(f32 s, mat23_t a) {
    return mat23_div(mat23f(s), a);
}

// functions
mat23_t mat23_abs(mat23_t m) {
    return mat23(vec3_abs(m.x), vec3_abs(m.y));
}

mat23_t mat23_acos(mat23_t m) {
    return mat23(vec3_acos(m.x), vec3_acos(m.y));
}

i32 mat23_all(mat23_t m) {
    return vec3_all(m.x) && vec3_all(m.y);
}

i32 mat23_any(mat23_t m) {
    return vec3_any(m.x) || vec3_any(m.y);
}

mat23_t mat23_asin(mat23_t m) {
    return mat23(vec3_asin(m.x), vec3_asin(m.y));
}

mat23_t mat23_atan(mat23_t m) {
    return mat23(vec3_atan(m.x), vec3_atan(m.y));
}

mat23_t mat23_atan2(mat23_t y, mat23_t x) {
    return mat23(vec3_atan2(y.x, x.x), vec3_atan2(y.y, x.y));
}

mat23_t mat23_ceil(mat23_t m) {
    return mat23(vec3_ceil(m.x), vec3_ceil(m.y));
}

mat23_t mat23_clamp(mat23_t m, mat23_t min_v, mat23_t max_v) {
    return mat23(vec3_clamp(m.x, min_v.x, max_v.x), vec3_clamp(m.y, min_v.y, max_v.y));
}

mat23_t mat23_cos(mat23_t m) {
    return mat23(vec3_cos(m.x), vec3_cos(m.y));
}

mat23_t mat23_cosh(mat23_t m) {
    return mat23(vec3_cosh(m.x), vec3_cosh(m.y));
}

mat23_t mat23_degrees(mat23_t m) {
    return mat23(vec3_degrees(m.x), vec3_degrees(m.y));
}

mat23_t mat23_exp(mat23_t m) {
    return mat23(vec3_exp(m.x), vec3_exp(m.y));
}

mat23_t mat23_exp2(mat23_t m) {
    return mat23(vec3_exp2(m.x), vec3_exp2(m.y));
}

mat23_t mat23_floor(mat23_t m) {
    return mat23(vec3_floor(m.x), vec3_floor(m.y));
}

mat23_t mat23_fmod(mat23_t a, mat23_t b) {
    return mat23(vec3_fmod(a.x, b.x), vec3_fmod(a.y, b.y));
}

mat23_t mat23_frac(mat23_t m) {
    return mat23(vec3_frac(m.x), vec3_frac(m.y));
}

mat23_t mat23_lerp(mat23_t a, mat23_t b, f32 s) {
    return mat23(vec3_lerp(a.x, b.x, s), vec3_lerp(a.y, b.y, s));
}

mat23_t mat23_log(mat23_t m) {
    return mat23(vec3_log(m.x), vec3_log(m.y));
}

mat23_t mat23_log2(mat23_t m) {
    return mat23(vec3_log2(m.x), vec3_log2(m.y));
}

mat23_t mat23_log10(mat23_t m) {
    return mat23(vec3_log10(m.x), vec3_log10(m.y));
}

mat23_t mat23_max(mat23_t a, mat23_t b) {
    return mat23(vec3_max(a.x, b.x), vec3_max(a.y, b.y));
}

mat23_t mat23_min(mat23_t a, mat23_t b) {
    return mat23(vec3_min(a.x, b.x), vec3_min(a.y, b.y));
}

mat23_t mat23_pow(mat23_t a, mat23_t b) {
    return mat23(vec3_pow(a.x, b.x), vec3_pow(a.y, b.y));
}

mat23_t mat23_radians(mat23_t m) {
    return mat23(vec3_radians(m.x), vec3_radians(m.y));
}

mat23_t mat23_rcp(mat23_t m) {
    return mat23(vec3_rcp(m.x), vec3_rcp(m.y));
}

mat23_t mat23_round(mat23_t m) {
    return mat23(vec3_round(m.x), vec3_round(m.y));
}

mat23_t mat23_rsqrt(mat23_t m) {
    return mat23(vec3_rsqrt(m.x), vec3_rsqrt(m.y));
}

mat23_t mat23_saturate(mat23_t m) {
    return mat23(vec3_saturate(m.x), vec3_saturate(m.y));
}

mat23_t mat23_sign(mat23_t m) {
    return mat23(vec3_sign(m.x), vec3_sign(m.y));
}

mat23_t mat23_sin(mat23_t m) {
    return mat23(vec3_sin(m.x), vec3_sin(m.y));
}

mat23_t mat23_sinh(mat23_t m) {
    return mat23(vec3_sinh(m.x), vec3_sinh(m.y));
}

mat23_t mat23_smoothstep(mat23_t min_v, mat23_t max_v, mat23_t m) {
    return mat23(vec3_smoothstep(min_v.x, max_v.x, m.x), vec3_smoothstep(min_v.y, max_v.y, m.y));
}

mat23_t mat23_smootherstep(mat23_t min_v, mat23_t max_v, mat23_t m) {
    return mat23(vec3_smootherstep(min_v.x, max_v.x, m.x), vec3_smootherstep(min_v.y, max_v.y, m.y));
}

mat23_t mat23_sqrt(mat23_t m) {
    return mat23(vec3_sqrt(m.x), vec3_sqrt(m.y));
}

mat23_t mat23_step(mat23_t a, mat23_t b) {
    return mat23(vec3_step(a.x, b.x), vec3_step(a.y, b.y));
}

mat23_t mat23_tan(mat23_t m) {
    return mat23(vec3_tan(m.x), vec3_tan(m.y));
}

mat23_t mat23_tanh(mat23_t m) {
    return mat23(vec3_tanh(m.x), vec3_tanh(m.y));
}

mat23_t mat23_trunc(mat23_t m) {
    return mat23(vec3_trunc(m.x), vec3_trunc(m.y));
}

// mat24
mat24_t mat24(vec4_t x, vec4_t y) {
    noinit mat24_t m;
    m.x = x;
    m.y = y;
    return m;
}

mat24_t mat24f(f32 v) {
    vec4_t t = vec4f(v);
    return mat24(t, t);
}

vec4_t mat24_get(mat24_t m, i32 row) {
    return cast(vec4_t*, &m)[row];
}

void mat24_set(mat24_t* m, i32 row, vec4_t v) {
    cast(vec4_t*, m)[row] = v;
}

// operators
mat24_t mat24_neg(mat24_t m) {
    return mat24(vec4_neg(m.x), vec4_neg(m.y));
}

i32 mat24_eq(mat24_t a, mat24_t b) {
    return vec4_eq(a.x, b.x) && vec4_eq(a.y, b.y);
}

mat24_t mat24_add(mat24_t a, mat24_t b) {
    return mat24(vec4_add(a.x, b.x), vec4_add(a.y, b.y));
}

mat24_t mat24_sub(mat24_t a, mat24_t b) {
    return mat24(vec4_sub(a.x, b.x), vec4_sub(a.y, b.y));
}

mat24_t mat24_mul_elem(mat24_t a, mat24_t b) {
    return mat24(vec4_mul(a.x, b.x), vec4_mul(a.y, b.y));
}

mat24_t mat24_div(mat24_t a, mat24_t b) {
    return mat24(vec4_div(a.x, b.x), vec4_div(a.y, b.y));
}

mat24_t mat24_addf(mat24_t a, f32 s) {
    return mat24(vec4_addf(a.x, s), vec4_addf(a.y, s));
}

mat24_t mat24_subf(mat24_t a, f32 s) {
    return mat24(vec4_subf(a.x, s), vec4_subf(a.y, s));
}

mat24_t mat24_mulf(mat24_t a, f32 s) {
    return mat24(vec4_mulf(a.x, s), vec4_mulf(a.y, s));
}

mat24_t mat24_divf(mat24_t a, f32 s) {
    return mat24(vec4_divf(a.x, s), vec4_divf(a.y, s));
}

mat24_t mat24_fadd(f32 s, mat24_t a) {
    return mat24_addf(a, s);
}

mat24_t mat24_fsub(f32 s, mat24_t a) {
    return mat24_sub(mat24f(s), a);
}

mat24_t mat24_fmul(f32 s, mat24_t a) {
    return mat24_mulf(a, s);
}

mat24_t mat24_fdiv(f32 s, mat24_t a) {
    return mat24_div(mat24f(s), a);
}

// functions
mat24_t mat24_abs(mat24_t m) {
    return mat24(vec4_abs(m.x), vec4_abs(m.y));
}

mat24_t mat24_acos(mat24_t m) {
    return mat24(vec4_acos(m.x), vec4_acos(m.y));
}

i32 mat24_all(mat24_t m) {
    return vec4_all(m.x) && vec4_all(m.y);
}

i32 mat24_any(mat24_t m) {
    return vec4_any(m.x) || vec4_any(m.y);
}

mat24_t mat24_asin(mat24_t m) {
    return mat24(vec4_asin(m.x), vec4_asin(m.y));
}

mat24_t mat24_atan(mat24_t m) {
    return mat24(vec4_atan(m.x), vec4_atan(m.y));
}

mat24_t mat24_atan2(mat24_t y, mat24_t x) {
    return mat24(vec4_atan2(y.x, x.x), vec4_atan2(y.y, x.y));
}

mat24_t mat24_ceil(mat24_t m) {
    return mat24(vec4_ceil(m.x), vec4_ceil(m.y));
}

mat24_t mat24_clamp(mat24_t m, mat24_t min_v, mat24_t max_v) {
    return mat24(vec4_clamp(m.x, min_v.x, max_v.x), vec4_clamp(m.y, min_v.y, max_v.y));
}

mat24_t mat24_cos(mat24_t m) {
    return mat24(vec4_cos(m.x), vec4_cos(m.y));
}

mat24_t mat24_cosh(mat24_t m) {
    return mat24(vec4_cosh(m.x), vec4_cosh(m.y));
}

mat24_t mat24_degrees(mat24_t m) {
    return mat24(vec4_degrees(m.x), vec4_degrees(m.y));
}

mat24_t mat24_exp(mat24_t m) {
    return mat24(vec4_exp(m.x), vec4_exp(m.y));
}

mat24_t mat24_exp2(mat24_t m) {
    return mat24(vec4_exp2(m.x), vec4_exp2(m.y));
}

mat24_t mat24_floor(mat24_t m) {
    return mat24(vec4_floor(m.x), vec4_floor(m.y));
}

mat24_t mat24_fmod(mat24_t a, mat24_t b) {
    return mat24(vec4_fmod(a.x, b.x), vec4_fmod(a.y, b.y));
}

mat24_t mat24_frac(mat24_t m) {
    return mat24(vec4_frac(m.x), vec4_frac(m.y));
}

mat24_t mat24_lerp(mat24_t a, mat24_t b, f32 s) {
    return mat24(vec4_lerp(a.x, b.x, s), vec4_lerp(a.y, b.y, s));
}

mat24_t mat24_log(mat24_t m) {
    return mat24(vec4_log(m.x), vec4_log(m.y));
}

mat24_t mat24_log2(mat24_t m) {
    return mat24(vec4_log2(m.x), vec4_log2(m.y));
}

mat24_t mat24_log10(mat24_t m) {
    return mat24(vec4_log10(m.x), vec4_log10(m.y));
}

mat24_t mat24_max(mat24_t a, mat24_t b) {
    return mat24(vec4_max(a.x, b.x), vec4_max(a.y, b.y));
}

mat24_t mat24_min(mat24_t a, mat24_t b) {
    return mat24(vec4_min(a.x, b.x), vec4_min(a.y, b.y));
}

mat24_t mat24_pow(mat24_t a, mat24_t b) {
    return mat24(vec4_pow(a.x, b.x), vec4_pow(a.y, b.y));
}

mat24_t mat24_radians(mat24_t m) {
    return mat24(vec4_radians(m.x), vec4_radians(m.y));
}

mat24_t mat24_rcp(mat24_t m) {
    return mat24(vec4_rcp(m.x), vec4_rcp(m.y));
}

mat24_t mat24_round(mat24_t m) {
    return mat24(vec4_round(m.x), vec4_round(m.y));
}

mat24_t mat24_rsqrt(mat24_t m) {
    return mat24(vec4_rsqrt(m.x), vec4_rsqrt(m.y));
}

mat24_t mat24_saturate(mat24_t m) {
    return mat24(vec4_saturate(m.x), vec4_saturate(m.y));
}

mat24_t mat24_sign(mat24_t m) {
    return mat24(vec4_sign(m.x), vec4_sign(m.y));
}

mat24_t mat24_sin(mat24_t m) {
    return mat24(vec4_sin(m.x), vec4_sin(m.y));
}

mat24_t mat24_sinh(mat24_t m) {
    return mat24(vec4_sinh(m.x), vec4_sinh(m.y));
}

mat24_t mat24_smoothstep(mat24_t min_v, mat24_t max_v, mat24_t m) {
    return mat24(vec4_smoothstep(min_v.x, max_v.x, m.x), vec4_smoothstep(min_v.y, max_v.y, m.y));
}

mat24_t mat24_smootherstep(mat24_t min_v, mat24_t max_v, mat24_t m) {
    return mat24(vec4_smootherstep(min_v.x, max_v.x, m.x), vec4_smootherstep(min_v.y, max_v.y, m.y));
}

mat24_t mat24_sqrt(mat24_t m) {
    return mat24(vec4_sqrt(m.x), vec4_sqrt(m.y));
}

mat24_t mat24_step(mat24_t a, mat24_t b) {
    return mat24(vec4_step(a.x, b.x), vec4_step(a.y, b.y));
}

mat24_t mat24_tan(mat24_t m) {
    return mat24(vec4_tan(m.x), vec4_tan(m.y));
}

mat24_t mat24_tanh(mat24_t m) {
    return mat24(vec4_tanh(m.x), vec4_tanh(m.y));
}

mat24_t mat24_trunc(mat24_t m) {
    return mat24(vec4_trunc(m.x), vec4_trunc(m.y));
}

// mat32
mat32_t mat32(vec2_t x, vec2_t y, vec2_t z) {
    noinit mat32_t m;
    m.x = x;
    m.y = y;
    m.z = z;
    return m;
}

mat32_t mat32f(f32 v) {
    vec2_t t = vec2f(v);
    return mat32(t, t, t);
}

vec2_t mat32_get(mat32_t m, i32 row) {
    return cast(vec2_t*, &m)[row];
}

void mat32_set(mat32_t* m, i32 row, vec2_t v) {
    cast(vec2_t*, m)[row] = v;
}

// operators
mat32_t mat32_neg(mat32_t m) {
    return mat32(vec2_neg(m.x), vec2_neg(m.y), vec2_neg(m.z));
}

i32 mat32_eq(mat32_t a, mat32_t b) {
    return vec2_eq(a.x, b.x) && vec2_eq(a.y, b.y) && vec2_eq(a.z, b.z);
}

mat32_t mat32_add(mat32_t a, mat32_t b) {
    return mat32(vec2_add(a.x, b.x), vec2_add(a.y, b.y), vec2_add(a.z, b.z));
}

mat32_t mat32_sub(mat32_t a, mat32_t b) {
    return mat32(vec2_sub(a.x, b.x), vec2_sub(a.y, b.y), vec2_sub(a.z, b.z));
}

mat32_t mat32_mul_elem(mat32_t a, mat32_t b) {
    return mat32(vec2_mul(a.x, b.x), vec2_mul(a.y, b.y), vec2_mul(a.z, b.z));
}

mat32_t mat32_div(mat32_t a, mat32_t b) {
    return mat32(vec2_div(a.x, b.x), vec2_div(a.y, b.y), vec2_div(a.z, b.z));
}

mat32_t mat32_addf(mat32_t a, f32 s) {
    return mat32(vec2_addf(a.x, s), vec2_addf(a.y, s), vec2_addf(a.z, s));
}

mat32_t mat32_subf(mat32_t a, f32 s) {
    return mat32(vec2_subf(a.x, s), vec2_subf(a.y, s), vec2_subf(a.z, s));
}

mat32_t mat32_mulf(mat32_t a, f32 s) {
    return mat32(vec2_mulf(a.x, s), vec2_mulf(a.y, s), vec2_mulf(a.z, s));
}

mat32_t mat32_divf(mat32_t a, f32 s) {
    return mat32(vec2_divf(a.x, s), vec2_divf(a.y, s), vec2_divf(a.z, s));
}

mat32_t mat32_fadd(f32 s, mat32_t a) {
    return mat32_addf(a, s);
}

mat32_t mat32_fsub(f32 s, mat32_t a) {
    return mat32_sub(mat32f(s), a);
}

mat32_t mat32_fmul(f32 s, mat32_t a) {
    return mat32_mulf(a, s);
}

mat32_t mat32_fdiv(f32 s, mat32_t a) {
    return mat32_div(mat32f(s), a);
}

// functions
mat32_t mat32_abs(mat32_t m) {
    return mat32(vec2_abs(m.x), vec2_abs(m.y), vec2_abs(m.z));
}

mat32_t mat32_acos(mat32_t m) {
    return mat32(vec2_acos(m.x), vec2_acos(m.y), vec2_acos(m.z));
}

i32 mat32_all(mat32_t m) {
    return vec2_all(m.x) && vec2_all(m.y) && vec2_all(m.z);
}

i32 mat32_any(mat32_t m) {
    return vec2_any(m.x) || vec2_any(m.y) || vec2_any(m.z);
}

mat32_t mat32_asin(mat32_t m) {
    return mat32(vec2_asin(m.x), vec2_asin(m.y), vec2_asin(m.z));
}

mat32_t mat32_atan(mat32_t m) {
    return mat32(vec2_atan(m.x), vec2_atan(m.y), vec2_atan(m.z));
}

mat32_t mat32_atan2(mat32_t y, mat32_t x) {
    return mat32(vec2_atan2(y.x, x.x), vec2_atan2(y.y, x.y), vec2_atan2(y.z, x.z));
}

mat32_t mat32_ceil(mat32_t m) {
    return mat32(vec2_ceil(m.x), vec2_ceil(m.y), vec2_ceil(m.z));
}

mat32_t mat32_clamp(mat32_t m, mat32_t min_v, mat32_t max_v) {
    return mat32(vec2_clamp(m.x, min_v.x, max_v.x), vec2_clamp(m.y, min_v.y, max_v.y), vec2_clamp(m.z, min_v.z, max_v.z));
}

mat32_t mat32_cos(mat32_t m) {
    return mat32(vec2_cos(m.x), vec2_cos(m.y), vec2_cos(m.z));
}

mat32_t mat32_cosh(mat32_t m) {
    return mat32(vec2_cosh(m.x), vec2_cosh(m.y), vec2_cosh(m.z));
}

mat32_t mat32_degrees(mat32_t m) {
    return mat32(vec2_degrees(m.x), vec2_degrees(m.y), vec2_degrees(m.z));
}

mat32_t mat32_exp(mat32_t m) {
    return mat32(vec2_exp(m.x), vec2_exp(m.y), vec2_exp(m.z));
}

mat32_t mat32_exp2(mat32_t m) {
    return mat32(vec2_exp2(m.x), vec2_exp2(m.y), vec2_exp2(m.z));
}

mat32_t mat32_floor(mat32_t m) {
    return mat32(vec2_floor(m.x), vec2_floor(m.y), vec2_floor(m.z));
}

mat32_t mat32_fmod(mat32_t a, mat32_t b) {
    return mat32(vec2_fmod(a.x, b.x), vec2_fmod(a.y, b.y), vec2_fmod(a.z, b.z));
}

mat32_t mat32_frac(mat32_t m) {
    return mat32(vec2_frac(m.x), vec2_frac(m.y), vec2_frac(m.z));
}

mat32_t mat32_lerp(mat32_t a, mat32_t b, f32 s) {
    return mat32(vec2_lerp(a.x, b.x, s), vec2_lerp(a.y, b.y, s), vec2_lerp(a.z, b.z, s));
}

mat32_t mat32_log(mat32_t m) {
    return mat32(vec2_log(m.x), vec2_log(m.y), vec2_log(m.z));
}

mat32_t mat32_log2(mat32_t m) {
    return mat32(vec2_log2(m.x), vec2_log2(m.y), vec2_log2(m.z));
}

mat32_t mat32_log10(mat32_t m) {
    return mat32(vec2_log10(m.x), vec2_log10(m.y), vec2_log10(m.z));
}

mat32_t mat32_max(mat32_t a, mat32_t b) {
    return mat32(vec2_max(a.x, b.x), vec2_max(a.y, b.y), vec2_max(a.z, b.z));
}

mat32_t mat32_min(mat32_t a, mat32_t b) {
    return mat32(vec2_min(a.x, b.x), vec2_min(a.y, b.y), vec2_min(a.z, b.z));
}

mat32_t mat32_pow(mat32_t a, mat32_t b) {
    return mat32(vec2_pow(a.x, b.x), vec2_pow(a.y, b.y), vec2_pow(a.z, b.z));
}

mat32_t mat32_radians(mat32_t m) {
    return mat32(vec2_radians(m.x), vec2_radians(m.y), vec2_radians(m.z));
}

mat32_t mat32_rcp(mat32_t m) {
    return mat32(vec2_rcp(m.x), vec2_rcp(m.y), vec2_rcp(m.z));
}

mat32_t mat32_round(mat32_t m) {
    return mat32(vec2_round(m.x), vec2_round(m.y), vec2_round(m.z));
}

mat32_t mat32_rsqrt(mat32_t m) {
    return mat32(vec2_rsqrt(m.x), vec2_rsqrt(m.y), vec2_rsqrt(m.z));
}

mat32_t mat32_saturate(mat32_t m) {
    return mat32(vec2_saturate(m.x), vec2_saturate(m.y), vec2_saturate(m.z));
}

mat32_t mat32_sign(mat32_t m) {
    return mat32(vec2_sign(m.x), vec2_sign(m.y), vec2_sign(m.z));
}

mat32_t mat32_sin(mat32_t m) {
    return mat32(vec2_sin(m.x), vec2_sin(m.y), vec2_sin(m.z));
}

mat32_t mat32_sinh(mat32_t m) {
    return mat32(vec2_sinh(m.x), vec2_sinh(m.y), vec2_sinh(m.z));
}

mat32_t mat32_smoothstep(mat32_t min_v, mat32_t max_v, mat32_t m) {
    return mat32(vec2_smoothstep(min_v.x, max_v.x, m.x), vec2_smoothstep(min_v.y, max_v.y, m.y), vec2_smoothstep(min_v.z, max_v.z, m.z));
}

mat32_t mat32_smootherstep(mat32_t min_v, mat32_t max_v, mat32_t m) {
    return mat32(vec2_smootherstep(min_v.x, max_v.x, m.x), vec2_smootherstep(min_v.y, max_v.y, m.y), vec2_smootherstep(min_v.z, max_v.z, m.z));
}

mat32_t mat32_sqrt(mat32_t m) {
    return mat32(vec2_sqrt(m.x), vec2_sqrt(m.y), vec2_sqrt(m.z));
}

mat32_t mat32_step(mat32_t a, mat32_t b) {
    return mat32(vec2_step(a.x, b.x), vec2_step(a.y, b.y), vec2_step(a.z, b.z));
}

mat32_t mat32_tan(mat32_t m) {
    return mat32(vec2_tan(m.x), vec2_tan(m.y), vec2_tan(m.z));
}

mat32_t mat32_tanh(mat32_t m) {
    return mat32(vec2_tanh(m.x), vec2_tanh(m.y), vec2_tanh(m.z));
}

mat32_t mat32_trunc(mat32_t m) {
    return mat32(vec2_trunc(m.x), vec2_trunc(m.y), vec2_trunc(m.z));
}

// mat33
mat33_t mat33(vec3_t x, vec3_t y, vec3_t z) {
    noinit mat33_t m;
    m.x = x;
    m.y = y;
    m.z = z;
    return m;
}

mat33_t mat33f(f32 v) {
    vec3_t t = vec3f(v);
    return mat33(t, t, t);
}

vec3_t mat33_get(mat33_t m, i32 row) {
    return cast(vec3_t*, &m)[row];
}

void mat33_set(mat33_t* m, i32 row, vec3_t v) {
    cast(vec3_t*, m)[row] = v;
}

// operators
mat33_t mat33_neg(mat33_t m) {
    return mat33(vec3_neg(m.x), vec3_neg(m.y), vec3_neg(m.z));
}

i32 mat33_eq(mat33_t a, mat33_t b) {
    return vec3_eq(a.x, b.x) && vec3_eq(a.y, b.y) && vec3_eq(a.z, b.z);
}

mat33_t mat33_add(mat33_t a, mat33_t b) {
    return mat33(vec3_add(a.x, b.x), vec3_add(a.y, b.y), vec3_add(a.z, b.z));
}

mat33_t mat33_sub(mat33_t a, mat33_t b) {
    return mat33(vec3_sub(a.x, b.x), vec3_sub(a.y, b.y), vec3_sub(a.z, b.z));
}

mat33_t mat33_mul_elem(mat33_t a, mat33_t b) {
    return mat33(vec3_mul(a.x, b.x), vec3_mul(a.y, b.y), vec3_mul(a.z, b.z));
}

mat33_t mat33_div(mat33_t a, mat33_t b) {
    return mat33(vec3_div(a.x, b.x), vec3_div(a.y, b.y), vec3_div(a.z, b.z));
}

mat33_t mat33_addf(mat33_t a, f32 s) {
    return mat33(vec3_addf(a.x, s), vec3_addf(a.y, s), vec3_addf(a.z, s));
}

mat33_t mat33_subf(mat33_t a, f32 s) {
    return mat33(vec3_subf(a.x, s), vec3_subf(a.y, s), vec3_subf(a.z, s));
}

mat33_t mat33_mulf(mat33_t a, f32 s) {
    return mat33(vec3_mulf(a.x, s), vec3_mulf(a.y, s), vec3_mulf(a.z, s));
}

mat33_t mat33_divf(mat33_t a, f32 s) {
    return mat33(vec3_divf(a.x, s), vec3_divf(a.y, s), vec3_divf(a.z, s));
}

mat33_t mat33_fadd(f32 s, mat33_t a) {
    return mat33_addf(a, s);
}

mat33_t mat33_fsub(f32 s, mat33_t a) {
    return mat33_sub(mat33f(s), a);
}

mat33_t mat33_fmul(f32 s, mat33_t a) {
    return mat33_mulf(a, s);
}

mat33_t mat33_fdiv(f32 s, mat33_t a) {
    return mat33_div(mat33f(s), a);
}

// functions
mat33_t mat33_abs(mat33_t m) {
    return mat33(vec3_abs(m.x), vec3_abs(m.y), vec3_abs(m.z));
}

mat33_t mat33_acos(mat33_t m) {
    return mat33(vec3_acos(m.x), vec3_acos(m.y), vec3_acos(m.z));
}

i32 mat33_all(mat33_t m) {
    return vec3_all(m.x) && vec3_all(m.y) && vec3_all(m.z);
}

i32 mat33_any(mat33_t m) {
    return vec3_any(m.x) || vec3_any(m.y) || vec3_any(m.z);
}

mat33_t mat33_asin(mat33_t m) {
    return mat33(vec3_asin(m.x), vec3_asin(m.y), vec3_asin(m.z));
}

mat33_t mat33_atan(mat33_t m) {
    return mat33(vec3_atan(m.x), vec3_atan(m.y), vec3_atan(m.z));
}

mat33_t mat33_atan2(mat33_t y, mat33_t x) {
    return mat33(vec3_atan2(y.x, x.x), vec3_atan2(y.y, x.y), vec3_atan2(y.z, x.z));
}

mat33_t mat33_ceil(mat33_t m) {
    return mat33(vec3_ceil(m.x), vec3_ceil(m.y), vec3_ceil(m.z));
}

mat33_t mat33_clamp(mat33_t m, mat33_t min_v, mat33_t max_v) {
    return mat33(vec3_clamp(m.x, min_v.x, max_v.x), vec3_clamp(m.y, min_v.y, max_v.y), vec3_clamp(m.z, min_v.z, max_v.z));
}

mat33_t mat33_cos(mat33_t m) {
    return mat33(vec3_cos(m.x), vec3_cos(m.y), vec3_cos(m.z));
}

mat33_t mat33_cosh(mat33_t m) {
    return mat33(vec3_cosh(m.x), vec3_cosh(m.y), vec3_cosh(m.z));
}

mat33_t mat33_degrees(mat33_t m) {
    return mat33(vec3_degrees(m.x), vec3_degrees(m.y), vec3_degrees(m.z));
}

mat33_t mat33_exp(mat33_t m) {
    return mat33(vec3_exp(m.x), vec3_exp(m.y), vec3_exp(m.z));
}

mat33_t mat33_exp2(mat33_t m) {
    return mat33(vec3_exp2(m.x), vec3_exp2(m.y), vec3_exp2(m.z));
}

mat33_t mat33_floor(mat33_t m) {
    return mat33(vec3_floor(m.x), vec3_floor(m.y), vec3_floor(m.z));
}

mat33_t mat33_fmod(mat33_t a, mat33_t b) {
    return mat33(vec3_fmod(a.x, b.x), vec3_fmod(a.y, b.y), vec3_fmod(a.z, b.z));
}

mat33_t mat33_frac(mat33_t m) {
    return mat33(vec3_frac(m.x), vec3_frac(m.y), vec3_frac(m.z));
}

mat33_t mat33_lerp(mat33_t a, mat33_t b, f32 s) {
    return mat33(vec3_lerp(a.x, b.x, s), vec3_lerp(a.y, b.y, s), vec3_lerp(a.z, b.z, s));
}

mat33_t mat33_log(mat33_t m) {
    return mat33(vec3_log(m.x), vec3_log(m.y), vec3_log(m.z));
}

mat33_t mat33_log2(mat33_t m) {
    return mat33(vec3_log2(m.x), vec3_log2(m.y), vec3_log2(m.z));
}

mat33_t mat33_log10(mat33_t m) {
    return mat33(vec3_log10(m.x), vec3_log10(m.y), vec3_log10(m.z));
}

mat33_t mat33_max(mat33_t a, mat33_t b) {
    return mat33(vec3_max(a.x, b.x), vec3_max(a.y, b.y), vec3_max(a.z, b.z));
}

mat33_t mat33_min(mat33_t a, mat33_t b) {
    return mat33(vec3_min(a.x, b.x), vec3_min(a.y, b.y), vec3_min(a.z, b.z));
}

mat33_t mat33_pow(mat33_t a, mat33_t b) {
    return mat33(vec3_pow(a.x, b.x), vec3_pow(a.y, b.y), vec3_pow(a.z, b.z));
}

mat33_t mat33_radians(mat33_t m) {
    return mat33(vec3_radians(m.x), vec3_radians(m.y), vec3_radians(m.z));
}

mat33_t mat33_rcp(mat33_t m) {
    return mat33(vec3_rcp(m.x), vec3_rcp(m.y), vec3_rcp(m.z));
}

mat33_t mat33_round(mat33_t m) {
    return mat33(vec3_round(m.x), vec3_round(m.y), vec3_round(m.z));
}

mat33_t mat33_rsqrt(mat33_t m) {
    return mat33(vec3_rsqrt(m.x), vec3_rsqrt(m.y), vec3_rsqrt(m.z));
}

mat33_t mat33_saturate(mat33_t m) {
    return mat33(vec3_saturate(m.x), vec3_saturate(m.y), vec3_saturate(m.z));
}

mat33_t mat33_sign(mat33_t m) {
    return mat33(vec3_sign(m.x), vec3_sign(m.y), vec3_sign(m.z));
}

mat33_t mat33_sin(mat33_t m) {
    return mat33(vec3_sin(m.x), vec3_sin(m.y), vec3_sin(m.z));
}

mat33_t mat33_sinh(mat33_t m) {
    return mat33(vec3_sinh(m.x), vec3_sinh(m.y), vec3_sinh(m.z));
}

mat33_t mat33_smoothstep(mat33_t min_v, mat33_t max_v, mat33_t m) {
    return mat33(vec3_smoothstep(min_v.x, max_v.x, m.x), vec3_smoothstep(min_v.y, max_v.y, m.y), vec3_smoothstep(min_v.z, max_v.z, m.z));
}

mat33_t mat33_smootherstep(mat33_t min_v, mat33_t max_v, mat33_t m) {
    return mat33(vec3_smootherstep(min_v.x, max_v.x, m.x), vec3_smootherstep(min_v.y, max_v.y, m.y), vec3_smootherstep(min_v.z, max_v.z, m.z));
}

mat33_t mat33_sqrt(mat33_t m) {
    return mat33(vec3_sqrt(m.x), vec3_sqrt(m.y), vec3_sqrt(m.z));
}

mat33_t mat33_step(mat33_t a, mat33_t b) {
    return mat33(vec3_step(a.x, b.x), vec3_step(a.y, b.y), vec3_step(a.z, b.z));
}

mat33_t mat33_tan(mat33_t m) {
    return mat33(vec3_tan(m.x), vec3_tan(m.y), vec3_tan(m.z));
}

mat33_t mat33_tanh(mat33_t m) {
    return mat33(vec3_tanh(m.x), vec3_tanh(m.y), vec3_tanh(m.z));
}

mat33_t mat33_trunc(mat33_t m) {
    return mat33(vec3_trunc(m.x), vec3_trunc(m.y), vec3_trunc(m.z));
}

// mat34
mat34_t mat34(vec4_t x, vec4_t y, vec4_t z) {
    noinit mat34_t m;
    m.x = x;
    m.y = y;
    m.z = z;
    return m;
}

mat34_t mat34f(f32 v) {
    vec4_t t = vec4f(v);
    return mat34(t, t, t);
}

vec4_t mat34_get(mat34_t m, i32 row) {
    return cast(vec4_t*, &m)[row];
}

void mat34_set(mat34_t* m, i32 row, vec4_t v) {
    cast(vec4_t*, m)[row] = v;
}

// operators
mat34_t mat34_neg(mat34_t m) {
    return mat34(vec4_neg(m.x), vec4_neg(m.y), vec4_neg(m.z));
}

i32 mat34_eq(mat34_t a, mat34_t b) {
    return vec4_eq(a.x, b.x) && vec4_eq(a.y, b.y) && vec4_eq(a.z, b.z);
}

mat34_t mat34_add(mat34_t a, mat34_t b) {
    return mat34(vec4_add(a.x, b.x), vec4_add(a.y, b.y), vec4_add(a.z, b.z));
}

mat34_t mat34_sub(mat34_t a, mat34_t b) {
    return mat34(vec4_sub(a.x, b.x), vec4_sub(a.y, b.y), vec4_sub(a.z, b.z));
}

mat34_t mat34_mul_elem(mat34_t a, mat34_t b) {
    return mat34(vec4_mul(a.x, b.x), vec4_mul(a.y, b.y), vec4_mul(a.z, b.z));
}

mat34_t mat34_div(mat34_t a, mat34_t b) {
    return mat34(vec4_div(a.x, b.x), vec4_div(a.y, b.y), vec4_div(a.z, b.z));
}

mat34_t mat34_addf(mat34_t a, f32 s) {
    return mat34(vec4_addf(a.x, s), vec4_addf(a.y, s), vec4_addf(a.z, s));
}

mat34_t mat34_subf(mat34_t a, f32 s) {
    return mat34(vec4_subf(a.x, s), vec4_subf(a.y, s), vec4_subf(a.z, s));
}

mat34_t mat34_mulf(mat34_t a, f32 s) {
    return mat34(vec4_mulf(a.x, s), vec4_mulf(a.y, s), vec4_mulf(a.z, s));
}

mat34_t mat34_divf(mat34_t a, f32 s) {
    return mat34(vec4_divf(a.x, s), vec4_divf(a.y, s), vec4_divf(a.z, s));
}

mat34_t mat34_fadd(f32 s, mat34_t a) {
    return mat34_addf(a, s);
}

mat34_t mat34_fsub(f32 s, mat34_t a) {
    return mat34_sub(mat34f(s), a);
}

mat34_t mat34_fmul(f32 s, mat34_t a) {
    return mat34_mulf(a, s);
}

mat34_t mat34_fdiv(f32 s, mat34_t a) {
    return mat34_div(mat34f(s), a);
}

// functions
mat34_t mat34_abs(mat34_t m) {
    return mat34(vec4_abs(m.x), vec4_abs(m.y), vec4_abs(m.z));
}

mat34_t mat34_acos(mat34_t m) {
    return mat34(vec4_acos(m.x), vec4_acos(m.y), vec4_acos(m.z));
}

i32 mat34_all(mat34_t m) {
    return vec4_all(m.x) && vec4_all(m.y) && vec4_all(m.z);
}

i32 mat34_any(mat34_t m) {
    return vec4_any(m.x) || vec4_any(m.y) || vec4_any(m.z);
}

mat34_t mat34_asin(mat34_t m) {
    return mat34(vec4_asin(m.x), vec4_asin(m.y), vec4_asin(m.z));
}

mat34_t mat34_atan(mat34_t m) {
    return mat34(vec4_atan(m.x), vec4_atan(m.y), vec4_atan(m.z));
}

mat34_t mat34_atan2(mat34_t y, mat34_t x) {
    return mat34(vec4_atan2(y.x, x.x), vec4_atan2(y.y, x.y), vec4_atan2(y.z, x.z));
}

mat34_t mat34_ceil(mat34_t m) {
    return mat34(vec4_ceil(m.x), vec4_ceil(m.y), vec4_ceil(m.z));
}

mat34_t mat34_clamp(mat34_t m, mat34_t min_v, mat34_t max_v) {
    return mat34(vec4_clamp(m.x, min_v.x, max_v.x), vec4_clamp(m.y, min_v.y, max_v.y), vec4_clamp(m.z, min_v.z, max_v.z));
}

mat34_t mat34_cos(mat34_t m) {
    return mat34(vec4_cos(m.x), vec4_cos(m.y), vec4_cos(m.z));
}

mat34_t mat34_cosh(mat34_t m) {
    return mat34(vec4_cosh(m.x), vec4_cosh(m.y), vec4_cosh(m.z));
}

mat34_t mat34_degrees(mat34_t m) {
    return mat34(vec4_degrees(m.x), vec4_degrees(m.y), vec4_degrees(m.z));
}

mat34_t mat34_exp(mat34_t m) {
    return mat34(vec4_exp(m.x), vec4_exp(m.y), vec4_exp(m.z));
}

mat34_t mat34_exp2(mat34_t m) {
    return mat34(vec4_exp2(m.x), vec4_exp2(m.y), vec4_exp2(m.z));
}

mat34_t mat34_floor(mat34_t m) {
    return mat34(vec4_floor(m.x), vec4_floor(m.y), vec4_floor(m.z));
}

mat34_t mat34_fmod(mat34_t a, mat34_t b) {
    return mat34(vec4_fmod(a.x, b.x), vec4_fmod(a.y, b.y), vec4_fmod(a.z, b.z));
}

mat34_t mat34_frac(mat34_t m) {
    return mat34(vec4_frac(m.x), vec4_frac(m.y), vec4_frac(m.z));
}

mat34_t mat34_lerp(mat34_t a, mat34_t b, f32 s) {
    return mat34(vec4_lerp(a.x, b.x, s), vec4_lerp(a.y, b.y, s), vec4_lerp(a.z, b.z, s));
}

mat34_t mat34_log(mat34_t m) {
    return mat34(vec4_log(m.x), vec4_log(m.y), vec4_log(m.z));
}

mat34_t mat34_log2(mat34_t m) {
    return mat34(vec4_log2(m.x), vec4_log2(m.y), vec4_log2(m.z));
}

mat34_t mat34_log10(mat34_t m) {
    return mat34(vec4_log10(m.x), vec4_log10(m.y), vec4_log10(m.z));
}

mat34_t mat34_max(mat34_t a, mat34_t b) {
    return mat34(vec4_max(a.x, b.x), vec4_max(a.y, b.y), vec4_max(a.z, b.z));
}

mat34_t mat34_min(mat34_t a, mat34_t b) {
    return mat34(vec4_min(a.x, b.x), vec4_min(a.y, b.y), vec4_min(a.z, b.z));
}

mat34_t mat34_pow(mat34_t a, mat34_t b) {
    return mat34(vec4_pow(a.x, b.x), vec4_pow(a.y, b.y), vec4_pow(a.z, b.z));
}

mat34_t mat34_radians(mat34_t m) {
    return mat34(vec4_radians(m.x), vec4_radians(m.y), vec4_radians(m.z));
}

mat34_t mat34_rcp(mat34_t m) {
    return mat34(vec4_rcp(m.x), vec4_rcp(m.y), vec4_rcp(m.z));
}

mat34_t mat34_round(mat34_t m) {
    return mat34(vec4_round(m.x), vec4_round(m.y), vec4_round(m.z));
}

mat34_t mat34_rsqrt(mat34_t m) {
    return mat34(vec4_rsqrt(m.x), vec4_rsqrt(m.y), vec4_rsqrt(m.z));
}

mat34_t mat34_saturate(mat34_t m) {
    return mat34(vec4_saturate(m.x), vec4_saturate(m.y), vec4_saturate(m.z));
}

mat34_t mat34_sign(mat34_t m) {
    return mat34(vec4_sign(m.x), vec4_sign(m.y), vec4_sign(m.z));
}

mat34_t mat34_sin(mat34_t m) {
    return mat34(vec4_sin(m.x), vec4_sin(m.y), vec4_sin(m.z));
}

mat34_t mat34_sinh(mat34_t m) {
    return mat34(vec4_sinh(m.x), vec4_sinh(m.y), vec4_sinh(m.z));
}

mat34_t mat34_smoothstep(mat34_t min_v, mat34_t max_v, mat34_t m) {
    return mat34(vec4_smoothstep(min_v.x, max_v.x, m.x), vec4_smoothstep(min_v.y, max_v.y, m.y), vec4_smoothstep(min_v.z, max_v.z, m.z));
}

mat34_t mat34_smootherstep(mat34_t min_v, mat34_t max_v, mat34_t m) {
    return mat34(vec4_smootherstep(min_v.x, max_v.x, m.x), vec4_smootherstep(min_v.y, max_v.y, m.y), vec4_smootherstep(min_v.z, max_v.z, m.z));
}

mat34_t mat34_sqrt(mat34_t m) {
    return mat34(vec4_sqrt(m.x), vec4_sqrt(m.y), vec4_sqrt(m.z));
}

mat34_t mat34_step(mat34_t a, mat34_t b) {
    return mat34(vec4_step(a.x, b.x), vec4_step(a.y, b.y), vec4_step(a.z, b.z));
}

mat34_t mat34_tan(mat34_t m) {
    return mat34(vec4_tan(m.x), vec4_tan(m.y), vec4_tan(m.z));
}

mat34_t mat34_tanh(mat34_t m) {
    return mat34(vec4_tanh(m.x), vec4_tanh(m.y), vec4_tanh(m.z));
}

mat34_t mat34_trunc(mat34_t m) {
    return mat34(vec4_trunc(m.x), vec4_trunc(m.y), vec4_trunc(m.z));
}

// mat42
mat42_t mat42(vec2_t x, vec2_t y, vec2_t z, vec2_t w) {
    noinit mat42_t m;
    m.x = x;
    m.y = y;
    m.z = z;
    m.w = w;
    return m;
}

mat42_t mat42f(f32 v) {
    vec2_t t = vec2f(v);
    return mat42(t, t, t, t);
}

vec2_t mat42_get(mat42_t m, i32 row) {
    return cast(vec2_t*, &m)[row];
}

void mat42_set(mat42_t* m, i32 row, vec2_t v) {
    cast(vec2_t*, m)[row] = v;
}

// operators
mat42_t mat42_neg(mat42_t m) {
    return mat42(vec2_neg(m.x), vec2_neg(m.y), vec2_neg(m.z), vec2_neg(m.w));
}

i32 mat42_eq(mat42_t a, mat42_t b) {
    return vec2_eq(a.x, b.x) && vec2_eq(a.y, b.y) && vec2_eq(a.z, b.z) && vec2_eq(a.w, b.w);
}

mat42_t mat42_add(mat42_t a, mat42_t b) {
    return mat42(vec2_add(a.x, b.x), vec2_add(a.y, b.y), vec2_add(a.z, b.z), vec2_add(a.w, b.w));
}

mat42_t mat42_sub(mat42_t a, mat42_t b) {
    return mat42(vec2_sub(a.x, b.x), vec2_sub(a.y, b.y), vec2_sub(a.z, b.z), vec2_sub(a.w, b.w));
}

mat42_t mat42_mul_elem(mat42_t a, mat42_t b) {
    return mat42(vec2_mul(a.x, b.x), vec2_mul(a.y, b.y), vec2_mul(a.z, b.z), vec2_mul(a.w, b.w));
}

mat42_t mat42_div(mat42_t a, mat42_t b) {
    return mat42(vec2_div(a.x, b.x), vec2_div(a.y, b.y), vec2_div(a.z, b.z), vec2_div(a.w, b.w));
}

mat42_t mat42_addf(mat42_t a, f32 s) {
    return mat42(vec2_addf(a.x, s), vec2_addf(a.y, s), vec2_addf(a.z, s), vec2_addf(a.w, s));
}

mat42_t mat42_subf(mat42_t a, f32 s) {
    return mat42(vec2_subf(a.x, s), vec2_subf(a.y, s), vec2_subf(a.z, s), vec2_subf(a.w, s));
}

mat42_t mat42_mulf(mat42_t a, f32 s) {
    return mat42(vec2_mulf(a.x, s), vec2_mulf(a.y, s), vec2_mulf(a.z, s), vec2_mulf(a.w, s));
}

mat42_t mat42_divf(mat42_t a, f32 s) {
    return mat42(vec2_divf(a.x, s), vec2_divf(a.y, s), vec2_divf(a.z, s), vec2_divf(a.w, s));
}

mat42_t mat42_fadd(f32 s, mat42_t a) {
    return mat42_addf(a, s);
}

mat42_t mat42_fsub(f32 s, mat42_t a) {
    return mat42_sub(mat42f(s), a);
}

mat42_t mat42_fmul(f32 s, mat42_t a) {
    return mat42_mulf(a, s);
}

mat42_t mat42_fdiv(f32 s, mat42_t a) {
    return mat42_div(mat42f(s), a);
}

// functions
mat42_t mat42_abs(mat42_t m) {
    return mat42(vec2_abs(m.x), vec2_abs(m.y), vec2_abs(m.z), vec2_abs(m.w));
}

mat42_t mat42_acos(mat42_t m) {
    return mat42(vec2_acos(m.x), vec2_acos(m.y), vec2_acos(m.z), vec2_acos(m.w));
}

i32 mat42_all(mat42_t m) {
    return vec2_all(m.x) && vec2_all(m.y) && vec2_all(m.z) && vec2_all(m.w);
}

i32 mat42_any(mat42_t m) {
    return vec2_any(m.x) || vec2_any(m.y) || vec2_any(m.z) || vec2_any(m.w);
}

mat42_t mat42_asin(mat42_t m) {
    return mat42(vec2_asin(m.x), vec2_asin(m.y), vec2_asin(m.z), vec2_asin(m.w));
}

mat42_t mat42_atan(mat42_t m) {
    return mat42(vec2_atan(m.x), vec2_atan(m.y), vec2_atan(m.z), vec2_atan(m.w));
}

mat42_t mat42_atan2(mat42_t y, mat42_t x) {
    return mat42(vec2_atan2(y.x, x.x), vec2_atan2(y.y, x.y), vec2_atan2(y.z, x.z), vec2_atan2(y.w, x.w));
}

mat42_t mat42_ceil(mat42_t m) {
    return mat42(vec2_ceil(m.x), vec2_ceil(m.y), vec2_ceil(m.z), vec2_ceil(m.w));
}

mat42_t mat42_clamp(mat42_t m, mat42_t min_v, mat42_t max_v) {
    return mat42(vec2_clamp(m.x, min_v.x, max_v.x), vec2_clamp(m.y, min_v.y, max_v.y), vec2_clamp(m.z, min_v.z, max_v.z), vec2_clamp(m.w, min_v.w, max_v.w));
}

mat42_t mat42_cos(mat42_t m) {
    return mat42(vec2_cos(m.x), vec2_cos(m.y), vec2_cos(m.z), vec2_cos(m.w));
}

mat42_t mat42_cosh(mat42_t m) {
    return mat42(vec2_cosh(m.x), vec2_cosh(m.y), vec2_cosh(m.z), vec2_cosh(m.w));
}

mat42_t mat42_degrees(mat42_t m) {
    return mat42(vec2_degrees(m.x), vec2_degrees(m.y), vec2_degrees(m.z), vec2_degrees(m.w));
}

mat42_t mat42_exp(mat42_t m) {
    return mat42(vec2_exp(m.x), vec2_exp(m.y), vec2_exp(m.z), vec2_exp(m.w));
}

mat42_t mat42_exp2(mat42_t m) {
    return mat42(vec2_exp2(m.x), vec2_exp2(m.y), vec2_exp2(m.z), vec2_exp2(m.w));
}

mat42_t mat42_floor(mat42_t m) {
    return mat42(vec2_floor(m.x), vec2_floor(m.y), vec2_floor(m.z), vec2_floor(m.w));
}

mat42_t mat42_fmod(mat42_t a, mat42_t b) {
    return mat42(vec2_fmod(a.x, b.x), vec2_fmod(a.y, b.y), vec2_fmod(a.z, b.z), vec2_fmod(a.w, b.w));
}

mat42_t mat42_frac(mat42_t m) {
    return mat42(vec2_frac(m.x), vec2_frac(m.y), vec2_frac(m.z), vec2_frac(m.w));
}

mat42_t mat42_lerp(mat42_t a, mat42_t b, f32 s) {
    return mat42(vec2_lerp(a.x, b.x, s), vec2_lerp(a.y, b.y, s), vec2_lerp(a.z, b.z, s), vec2_lerp(a.w, b.w, s));
}

mat42_t mat42_log(mat42_t m) {
    return mat42(vec2_log(m.x), vec2_log(m.y), vec2_log(m.z), vec2_log(m.w));
}

mat42_t mat42_log2(mat42_t m) {
    return mat42(vec2_log2(m.x), vec2_log2(m.y), vec2_log2(m.z), vec2_log2(m.w));
}

mat42_t mat42_log10(mat42_t m) {
    return mat42(vec2_log10(m.x), vec2_log10(m.y), vec2_log10(m.z), vec2_log10(m.w));
}

mat42_t mat42_max(mat42_t a, mat42_t b) {
    return mat42(vec2_max(a.x, b.x), vec2_max(a.y, b.y), vec2_max(a.z, b.z), vec2_max(a.w, b.w));
}

mat42_t mat42_min(mat42_t a, mat42_t b) {
    return mat42(vec2_min(a.x, b.x), vec2_min(a.y, b.y), vec2_min(a.z, b.z), vec2_min(a.w, b.w));
}

mat42_t mat42_pow(mat42_t a, mat42_t b) {
    return mat42(vec2_pow(a.x, b.x), vec2_pow(a.y, b.y), vec2_pow(a.z, b.z), vec2_pow(a.w, b.w));
}

mat42_t mat42_radians(mat42_t m) {
    return mat42(vec2_radians(m.x), vec2_radians(m.y), vec2_radians(m.z), vec2_radians(m.w));
}

mat42_t mat42_rcp(mat42_t m) {
    return mat42(vec2_rcp(m.x), vec2_rcp(m.y), vec2_rcp(m.z), vec2_rcp(m.w));
}

mat42_t mat42_round(mat42_t m) {
    return mat42(vec2_round(m.x), vec2_round(m.y), vec2_round(m.z), vec2_round(m.w));
}

mat42_t mat42_rsqrt(mat42_t m) {
    return mat42(vec2_rsqrt(m.x), vec2_rsqrt(m.y), vec2_rsqrt(m.z), vec2_rsqrt(m.w));
}

mat42_t mat42_saturate(mat42_t m) {
    return mat42(vec2_saturate(m.x), vec2_saturate(m.y), vec2_saturate(m.z), vec2_saturate(m.w));
}

mat42_t mat42_sign(mat42_t m) {
    return mat42(vec2_sign(m.x), vec2_sign(m.y), vec2_sign(m.z), vec2_sign(m.w));
}

mat42_t mat42_sin(mat42_t m) {
    return mat42(vec2_sin(m.x), vec2_sin(m.y), vec2_sin(m.z), vec2_sin(m.w));
}

mat42_t mat42_sinh(mat42_t m) {
    return mat42(vec2_sinh(m.x), vec2_sinh(m.y), vec2_sinh(m.z), vec2_sinh(m.w));
}

mat42_t mat42_smoothstep(mat42_t min_v, mat42_t max_v, mat42_t m) {
    return mat42(vec2_smoothstep(min_v.x, max_v.x, m.x), vec2_smoothstep(min_v.y, max_v.y, m.y), vec2_smoothstep(min_v.z, max_v.z, m.z), vec2_smoothstep(min_v.w, max_v.w, m.w));
}

mat42_t mat42_smootherstep(mat42_t min_v, mat42_t max_v, mat42_t m) {
    return mat42(vec2_smootherstep(min_v.x, max_v.x, m.x), vec2_smootherstep(min_v.y, max_v.y, m.y), vec2_smootherstep(min_v.z, max_v.z, m.z), vec2_smootherstep(min_v.w, max_v.w, m.w));
}

mat42_t mat42_sqrt(mat42_t m) {
    return mat42(vec2_sqrt(m.x), vec2_sqrt(m.y), vec2_sqrt(m.z), vec2_sqrt(m.w));
}

mat42_t mat42_step(mat42_t a, mat42_t b) {
    return mat42(vec2_step(a.x, b.x), vec2_step(a.y, b.y), vec2_step(a.z, b.z), vec2_step(a.w, b.w));
}

mat42_t mat42_tan(mat42_t m) {
    return mat42(vec2_tan(m.x), vec2_tan(m.y), vec2_tan(m.z), vec2_tan(m.w));
}

mat42_t mat42_tanh(mat42_t m) {
    return mat42(vec2_tanh(m.x), vec2_tanh(m.y), vec2_tanh(m.z), vec2_tanh(m.w));
}

mat42_t mat42_trunc(mat42_t m) {
    return mat42(vec2_trunc(m.x), vec2_trunc(m.y), vec2_trunc(m.z), vec2_trunc(m.w));
}

// mat43
mat43_t mat43(vec3_t x, vec3_t y, vec3_t z, vec3_t w) {
    noinit mat43_t m;
    m.x = x;
    m.y = y;
    m.z = z;
    m.w = w;
    return m;
}

mat43_t mat43f(f32 v) {
    vec3_t t = vec3f(v);
    return mat43(t, t, t, t);
}

vec3_t mat43_get(mat43_t m, i32 row) {
    return cast(vec3_t*, &m)[row];
}

void mat43_set(mat43_t* m, i32 row, vec3_t v) {
    cast(vec3_t*, m)[row] = v;
}

// operators
mat43_t mat43_neg(mat43_t m) {
    return mat43(vec3_neg(m.x), vec3_neg(m.y), vec3_neg(m.z), vec3_neg(m.w));
}

i32 mat43_eq(mat43_t a, mat43_t b) {
    return vec3_eq(a.x, b.x) && vec3_eq(a.y, b.y) && vec3_eq(a.z, b.z) && vec3_eq(a.w, b.w);
}

mat43_t mat43_add(mat43_t a, mat43_t b) {
    return mat43(vec3_add(a.x, b.x), vec3_add(a.y, b.y), vec3_add(a.z, b.z), vec3_add(a.w, b.w));
}

mat43_t mat43_sub(mat43_t a, mat43_t b) {
    return mat43(vec3_sub(a.x, b.x), vec3_sub(a.y, b.y), vec3_sub(a.z, b.z), vec3_sub(a.w, b.w));
}

mat43_t mat43_mul_elem(mat43_t a, mat43_t b) {
    return mat43(vec3_mul(a.x, b.x), vec3_mul(a.y, b.y), vec3_mul(a.z, b.z), vec3_mul(a.w, b.w));
}

mat43_t mat43_div(mat43_t a, mat43_t b) {
    return mat43(vec3_div(a.x, b.x), vec3_div(a.y, b.y), vec3_div(a.z, b.z), vec3_div(a.w, b.w));
}

mat43_t mat43_addf(mat43_t a, f32 s) {
    return mat43(vec3_addf(a.x, s), vec3_addf(a.y, s), vec3_addf(a.z, s), vec3_addf(a.w, s));
}

mat43_t mat43_subf(mat43_t a, f32 s) {
    return mat43(vec3_subf(a.x, s), vec3_subf(a.y, s), vec3_subf(a.z, s), vec3_subf(a.w, s));
}

mat43_t mat43_mulf(mat43_t a, f32 s) {
    return mat43(vec3_mulf(a.x, s), vec3_mulf(a.y, s), vec3_mulf(a.z, s), vec3_mulf(a.w, s));
}

mat43_t mat43_divf(mat43_t a, f32 s) {
    return mat43(vec3_divf(a.x, s), vec3_divf(a.y, s), vec3_divf(a.z, s), vec3_divf(a.w, s));
}

mat43_t mat43_fadd(f32 s, mat43_t a) {
    return mat43_addf(a, s);
}

mat43_t mat43_fsub(f32 s, mat43_t a) {
    return mat43_sub(mat43f(s), a);
}

mat43_t mat43_fmul(f32 s, mat43_t a) {
    return mat43_mulf(a, s);
}

mat43_t mat43_fdiv(f32 s, mat43_t a) {
    return mat43_div(mat43f(s), a);
}

// functions
mat43_t mat43_abs(mat43_t m) {
    return mat43(vec3_abs(m.x), vec3_abs(m.y), vec3_abs(m.z), vec3_abs(m.w));
}

mat43_t mat43_acos(mat43_t m) {
    return mat43(vec3_acos(m.x), vec3_acos(m.y), vec3_acos(m.z), vec3_acos(m.w));
}

i32 mat43_all(mat43_t m) {
    return vec3_all(m.x) && vec3_all(m.y) && vec3_all(m.z) && vec3_all(m.w);
}

i32 mat43_any(mat43_t m) {
    return vec3_any(m.x) || vec3_any(m.y) || vec3_any(m.z) || vec3_any(m.w);
}

mat43_t mat43_asin(mat43_t m) {
    return mat43(vec3_asin(m.x), vec3_asin(m.y), vec3_asin(m.z), vec3_asin(m.w));
}

mat43_t mat43_atan(mat43_t m) {
    return mat43(vec3_atan(m.x), vec3_atan(m.y), vec3_atan(m.z), vec3_atan(m.w));
}

mat43_t mat43_atan2(mat43_t y, mat43_t x) {
    return mat43(vec3_atan2(y.x, x.x), vec3_atan2(y.y, x.y), vec3_atan2(y.z, x.z), vec3_atan2(y.w, x.w));
}

mat43_t mat43_ceil(mat43_t m) {
    return mat43(vec3_ceil(m.x), vec3_ceil(m.y), vec3_ceil(m.z), vec3_ceil(m.w));
}

mat43_t mat43_clamp(mat43_t m, mat43_t min_v, mat43_t max_v) {
    return mat43(vec3_clamp(m.x, min_v.x, max_v.x), vec3_clamp(m.y, min_v.y, max_v.y), vec3_clamp(m.z, min_v.z, max_v.z), vec3_clamp(m.w, min_v.w, max_v.w));
}

mat43_t mat43_cos(mat43_t m) {
    return mat43(vec3_cos(m.x), vec3_cos(m.y), vec3_cos(m.z), vec3_cos(m.w));
}

mat43_t mat43_cosh(mat43_t m) {
    return mat43(vec3_cosh(m.x), vec3_cosh(m.y), vec3_cosh(m.z), vec3_cosh(m.w));
}

mat43_t mat43_degrees(mat43_t m) {
    return mat43(vec3_degrees(m.x), vec3_degrees(m.y), vec3_degrees(m.z), vec3_degrees(m.w));
}

mat43_t mat43_exp(mat43_t m) {
    return mat43(vec3_exp(m.x), vec3_exp(m.y), vec3_exp(m.z), vec3_exp(m.w));
}

mat43_t mat43_exp2(mat43_t m) {
    return mat43(vec3_exp2(m.x), vec3_exp2(m.y), vec3_exp2(m.z), vec3_exp2(m.w));
}

mat43_t mat43_floor(mat43_t m) {
    return mat43(vec3_floor(m.x), vec3_floor(m.y), vec3_floor(m.z), vec3_floor(m.w));
}

mat43_t mat43_fmod(mat43_t a, mat43_t b) {
    return mat43(vec3_fmod(a.x, b.x), vec3_fmod(a.y, b.y), vec3_fmod(a.z, b.z), vec3_fmod(a.w, b.w));
}

mat43_t mat43_frac(mat43_t m) {
    return mat43(vec3_frac(m.x), vec3_frac(m.y), vec3_frac(m.z), vec3_frac(m.w));
}

mat43_t mat43_lerp(mat43_t a, mat43_t b, f32 s) {
    return mat43(vec3_lerp(a.x, b.x, s), vec3_lerp(a.y, b.y, s), vec3_lerp(a.z, b.z, s), vec3_lerp(a.w, b.w, s));
}

mat43_t mat43_log(mat43_t m) {
    return mat43(vec3_log(m.x), vec3_log(m.y), vec3_log(m.z), vec3_log(m.w));
}

mat43_t mat43_log2(mat43_t m) {
    return mat43(vec3_log2(m.x), vec3_log2(m.y), vec3_log2(m.z), vec3_log2(m.w));
}

mat43_t mat43_log10(mat43_t m) {
    return mat43(vec3_log10(m.x), vec3_log10(m.y), vec3_log10(m.z), vec3_log10(m.w));
}

mat43_t mat43_max(mat43_t a, mat43_t b) {
    return mat43(vec3_max(a.x, b.x), vec3_max(a.y, b.y), vec3_max(a.z, b.z), vec3_max(a.w, b.w));
}

mat43_t mat43_min(mat43_t a, mat43_t b) {
    return mat43(vec3_min(a.x, b.x), vec3_min(a.y, b.y), vec3_min(a.z, b.z), vec3_min(a.w, b.w));
}

mat43_t mat43_pow(mat43_t a, mat43_t b) {
    return mat43(vec3_pow(a.x, b.x), vec3_pow(a.y, b.y), vec3_pow(a.z, b.z), vec3_pow(a.w, b.w));
}

mat43_t mat43_radians(mat43_t m) {
    return mat43(vec3_radians(m.x), vec3_radians(m.y), vec3_radians(m.z), vec3_radians(m.w));
}

mat43_t mat43_rcp(mat43_t m) {
    return mat43(vec3_rcp(m.x), vec3_rcp(m.y), vec3_rcp(m.z), vec3_rcp(m.w));
}

mat43_t mat43_round(mat43_t m) {
    return mat43(vec3_round(m.x), vec3_round(m.y), vec3_round(m.z), vec3_round(m.w));
}

mat43_t mat43_rsqrt(mat43_t m) {
    return mat43(vec3_rsqrt(m.x), vec3_rsqrt(m.y), vec3_rsqrt(m.z), vec3_rsqrt(m.w));
}

mat43_t mat43_saturate(mat43_t m) {
    return mat43(vec3_saturate(m.x), vec3_saturate(m.y), vec3_saturate(m.z), vec3_saturate(m.w));
}

mat43_t mat43_sign(mat43_t m) {
    return mat43(vec3_sign(m.x), vec3_sign(m.y), vec3_sign(m.z), vec3_sign(m.w));
}

mat43_t mat43_sin(mat43_t m) {
    return mat43(vec3_sin(m.x), vec3_sin(m.y), vec3_sin(m.z), vec3_sin(m.w));
}

mat43_t mat43_sinh(mat43_t m) {
    return mat43(vec3_sinh(m.x), vec3_sinh(m.y), vec3_sinh(m.z), vec3_sinh(m.w));
}

mat43_t mat43_smoothstep(mat43_t min_v, mat43_t max_v, mat43_t m) {
    return mat43(vec3_smoothstep(min_v.x, max_v.x, m.x), vec3_smoothstep(min_v.y, max_v.y, m.y), vec3_smoothstep(min_v.z, max_v.z, m.z), vec3_smoothstep(min_v.w, max_v.w, m.w));
}

mat43_t mat43_smootherstep(mat43_t min_v, mat43_t max_v, mat43_t m) {
    return mat43(vec3_smootherstep(min_v.x, max_v.x, m.x), vec3_smootherstep(min_v.y, max_v.y, m.y), vec3_smootherstep(min_v.z, max_v.z, m.z), vec3_smootherstep(min_v.w, max_v.w, m.w));
}

mat43_t mat43_sqrt(mat43_t m) {
    return mat43(vec3_sqrt(m.x), vec3_sqrt(m.y), vec3_sqrt(m.z), vec3_sqrt(m.w));
}

mat43_t mat43_step(mat43_t a, mat43_t b) {
    return mat43(vec3_step(a.x, b.x), vec3_step(a.y, b.y), vec3_step(a.z, b.z), vec3_step(a.w, b.w));
}

mat43_t mat43_tan(mat43_t m) {
    return mat43(vec3_tan(m.x), vec3_tan(m.y), vec3_tan(m.z), vec3_tan(m.w));
}

mat43_t mat43_tanh(mat43_t m) {
    return mat43(vec3_tanh(m.x), vec3_tanh(m.y), vec3_tanh(m.z), vec3_tanh(m.w));
}

mat43_t mat43_trunc(mat43_t m) {
    return mat43(vec3_trunc(m.x), vec3_trunc(m.y), vec3_trunc(m.z), vec3_trunc(m.w));
}

// mat44
mat44_t mat44(vec4_t x, vec4_t y, vec4_t z, vec4_t w) {
    noinit mat44_t m;
    m.x = x;
    m.y = y;
    m.z = z;
    m.w = w;
    return m;
}

mat44_t mat44f(f32 v) {
    noinit mat44_t m;
    m.x = vec4f(v);
    m.y = vec4f(v);
    m.z = vec4f(v);
    m.w = vec4f(v);
    return m;
}

vec4_t mat44_get(mat44_t m, i32 row) {
    return cast(vec4_t*, &m)[row];
}

void mat44_set(mat44_t* m, i32 row, vec4_t v) {
    cast(vec4_t*, m)[row] = v;
}

// operators
mat44_t mat44_neg(mat44_t m) {
    return mat44(vec4_neg(m.x), vec4_neg(m.y), vec4_neg(m.z), vec4_neg(m.w));
}

i32 mat44_eq(mat44_t a, mat44_t b) {
    return vec4_eq(a.x, b.x) && vec4_eq(a.y, b.y) && vec4_eq(a.z, b.z) && vec4_eq(a.w, b.w);
}

mat44_t mat44_add(mat44_t a, mat44_t b) {
    return mat44(vec4_add(a.x, b.x), vec4_add(a.y, b.y), vec4_add(a.z, b.z), vec4_add(a.w, b.w));
}

mat44_t mat44_sub(mat44_t a, mat44_t b) {
    return mat44(vec4_sub(a.x, b.x), vec4_sub(a.y, b.y), vec4_sub(a.z, b.z), vec4_sub(a.w, b.w));
}

mat44_t mat44_mul_elem(mat44_t a, mat44_t b) {
    return mat44(vec4_mul(a.x, b.x), vec4_mul(a.y, b.y), vec4_mul(a.z, b.z), vec4_mul(a.w, b.w));
}

mat44_t mat44_div(mat44_t a, mat44_t b) {
    return mat44(vec4_div(a.x, b.x), vec4_div(a.y, b.y), vec4_div(a.z, b.z), vec4_div(a.w, b.w));
}

mat44_t mat44_addf(mat44_t a, f32 s) {
    return mat44(vec4_addf(a.x, s), vec4_addf(a.y, s), vec4_addf(a.z, s), vec4_addf(a.w, s));
}

mat44_t mat44_subf(mat44_t a, f32 s) {
    return mat44(vec4_subf(a.x, s), vec4_subf(a.y, s), vec4_subf(a.z, s), vec4_subf(a.w, s));
}

mat44_t mat44_mulf(mat44_t a, f32 s) {
    return mat44(vec4_mulf(a.x, s), vec4_mulf(a.y, s), vec4_mulf(a.z, s), vec4_mulf(a.w, s));
}

mat44_t mat44_divf(mat44_t a, f32 s) {
    return mat44(vec4_divf(a.x, s), vec4_divf(a.y, s), vec4_divf(a.z, s), vec4_divf(a.w, s));
}

mat44_t mat44_fadd(f32 s, mat44_t a) {
    return mat44_addf(a, s);
}

mat44_t mat44_fsub(f32 s, mat44_t a) {
    return mat44_sub(mat44f(s), a);
}

mat44_t mat44_fmul(f32 s, mat44_t a) {
    return mat44_mulf(a, s);
}

mat44_t mat44_fdiv(f32 s, mat44_t a) {
    return mat44_div(mat44f(s), a);
}

// functions
mat44_t mat44_abs(mat44_t m) {
    return mat44(vec4_abs(m.x), vec4_abs(m.y), vec4_abs(m.z), vec4_abs(m.w));
}

mat44_t mat44_acos(mat44_t m) {
    return mat44(vec4_acos(m.x), vec4_acos(m.y), vec4_acos(m.z), vec4_acos(m.w));
}

i32 mat44_all(mat44_t m) {
    return vec4_all(m.x) && vec4_all(m.y) && vec4_all(m.z) && vec4_all(m.w);
}

i32 mat44_any(mat44_t m) {
    return vec4_any(m.x) || vec4_any(m.y) || vec4_any(m.z) || vec4_any(m.w);
}

mat44_t mat44_asin(mat44_t m) {
    return mat44(vec4_asin(m.x), vec4_asin(m.y), vec4_asin(m.z), vec4_asin(m.w));
}

mat44_t mat44_atan(mat44_t m) {
    return mat44(vec4_atan(m.x), vec4_atan(m.y), vec4_atan(m.z), vec4_atan(m.w));
}

mat44_t mat44_atan2(mat44_t y, mat44_t x) {
    return mat44(vec4_atan2(y.x, x.x), vec4_atan2(y.y, x.y), vec4_atan2(y.z, x.z), vec4_atan2(y.w, x.w));
}

mat44_t mat44_ceil(mat44_t m) {
    return mat44(vec4_ceil(m.x), vec4_ceil(m.y), vec4_ceil(m.z), vec4_ceil(m.w));
}

mat44_t mat44_clamp(mat44_t m, mat44_t min_v, mat44_t max_v) {
    return mat44(vec4_clamp(m.x, min_v.x, max_v.x), vec4_clamp(m.y, min_v.y, max_v.y), vec4_clamp(m.z, min_v.z, max_v.z), vec4_clamp(m.w, min_v.w, max_v.w));
}

mat44_t mat44_cos(mat44_t m) {
    return mat44(vec4_cos(m.x), vec4_cos(m.y), vec4_cos(m.z), vec4_cos(m.w));
}

mat44_t mat44_cosh(mat44_t m) {
    return mat44(vec4_cosh(m.x), vec4_cosh(m.y), vec4_cosh(m.z), vec4_cosh(m.w));
}

mat44_t mat44_degrees(mat44_t m) {
    return mat44(vec4_degrees(m.x), vec4_degrees(m.y), vec4_degrees(m.z), vec4_degrees(m.w));
}

mat44_t mat44_exp(mat44_t m) {
    return mat44(vec4_exp(m.x), vec4_exp(m.y), vec4_exp(m.z), vec4_exp(m.w));
}

mat44_t mat44_exp2(mat44_t m) {
    return mat44(vec4_exp2(m.x), vec4_exp2(m.y), vec4_exp2(m.z), vec4_exp2(m.w));
}

mat44_t mat44_floor(mat44_t m) {
    return mat44(vec4_floor(m.x), vec4_floor(m.y), vec4_floor(m.z), vec4_floor(m.w));
}

mat44_t mat44_fmod(mat44_t a, mat44_t b) {
    return mat44(vec4_fmod(a.x, b.x), vec4_fmod(a.y, b.y), vec4_fmod(a.z, b.z), vec4_fmod(a.w, b.w));
}

mat44_t mat44_frac(mat44_t m) {
    return mat44(vec4_frac(m.x), vec4_frac(m.y), vec4_frac(m.z), vec4_frac(m.w));
}

mat44_t mat44_lerp(mat44_t a, mat44_t b, f32 s) {
    return mat44(vec4_lerp(a.x, b.x, s), vec4_lerp(a.y, b.y, s), vec4_lerp(a.z, b.z, s), vec4_lerp(a.w, b.w, s));
}

mat44_t mat44_log(mat44_t m) {
    return mat44(vec4_log(m.x), vec4_log(m.y), vec4_log(m.z), vec4_log(m.w));
}

mat44_t mat44_log2(mat44_t m) {
    return mat44(vec4_log2(m.x), vec4_log2(m.y), vec4_log2(m.z), vec4_log2(m.w));
}

mat44_t mat44_log10(mat44_t m) {
    return mat44(vec4_log10(m.x), vec4_log10(m.y), vec4_log10(m.z), vec4_log10(m.w));
}

mat44_t mat44_max(mat44_t a, mat44_t b) {
    return mat44(vec4_max(a.x, b.x), vec4_max(a.y, b.y), vec4_max(a.z, b.z), vec4_max(a.w, b.w));
}

mat44_t mat44_min(mat44_t a, mat44_t b) {
    return mat44(vec4_min(a.x, b.x), vec4_min(a.y, b.y), vec4_min(a.z, b.z), vec4_min(a.w, b.w));
}

mat44_t mat44_pow(mat44_t a, mat44_t b) {
    return mat44(vec4_pow(a.x, b.x), vec4_pow(a.y, b.y), vec4_pow(a.z, b.z), vec4_pow(a.w, b.w));
}

mat44_t mat44_radians(mat44_t m) {
    return mat44(vec4_radians(m.x), vec4_radians(m.y), vec4_radians(m.z), vec4_radians(m.w));
}

mat44_t mat44_rcp(mat44_t m) {
    return mat44(vec4_rcp(m.x), vec4_rcp(m.y), vec4_rcp(m.z), vec4_rcp(m.w));
}

mat44_t mat44_round(mat44_t m) {
    return mat44(vec4_round(m.x), vec4_round(m.y), vec4_round(m.z), vec4_round(m.w));
}

mat44_t mat44_rsqrt(mat44_t m) {
    return mat44(vec4_rsqrt(m.x), vec4_rsqrt(m.y), vec4_rsqrt(m.z), vec4_rsqrt(m.w));
}

mat44_t mat44_saturate(mat44_t m) {
    return mat44(vec4_saturate(m.x), vec4_saturate(m.y), vec4_saturate(m.z), vec4_saturate(m.w));
}

mat44_t mat44_sign(mat44_t m) {
    return mat44(vec4_sign(m.x), vec4_sign(m.y), vec4_sign(m.z), vec4_sign(m.w));
}

mat44_t mat44_sin(mat44_t m) {
    return mat44(vec4_sin(m.x), vec4_sin(m.y), vec4_sin(m.z), vec4_sin(m.w));
}

mat44_t mat44_sinh(mat44_t m) {
    return mat44(vec4_sinh(m.x), vec4_sinh(m.y), vec4_sinh(m.z), vec4_sinh(m.w));
}

mat44_t mat44_smoothstep(mat44_t min_v, mat44_t max_v, mat44_t m) {
    return mat44(vec4_smoothstep(min_v.x, max_v.x, m.x), vec4_smoothstep(min_v.y, max_v.y, m.y), vec4_smoothstep(min_v.z, max_v.z, m.z), vec4_smoothstep(min_v.w, max_v.w, m.w));
}

mat44_t mat44_smootherstep(mat44_t min_v, mat44_t max_v, mat44_t m) {
    return mat44(vec4_smootherstep(min_v.x, max_v.x, m.x), vec4_smootherstep(min_v.y, max_v.y, m.y), vec4_smootherstep(min_v.z, max_v.z, m.z), vec4_smootherstep(min_v.w, max_v.w, m.w));
}

mat44_t mat44_sqrt(mat44_t m) {
    return mat44(vec4_sqrt(m.x), vec4_sqrt(m.y), vec4_sqrt(m.z), vec4_sqrt(m.w));
}

mat44_t mat44_step(mat44_t a, mat44_t b) {
    return mat44(vec4_step(a.x, b.x), vec4_step(a.y, b.y), vec4_step(a.z, b.z), vec4_step(a.w, b.w));
}

mat44_t mat44_tan(mat44_t m) {
    return mat44(vec4_tan(m.x), vec4_tan(m.y), vec4_tan(m.z), vec4_tan(m.w));
}

mat44_t mat44_tanh(mat44_t m) {
    return mat44(vec4_tanh(m.x), vec4_tanh(m.y), vec4_tanh(m.z), vec4_tanh(m.w));
}

mat44_t mat44_trunc(mat44_t m) {
    return mat44(vec4_trunc(m.x), vec4_trunc(m.y), vec4_trunc(m.z), vec4_trunc(m.w));
}

// matrix math
mat22_t mat22_transpose(mat22_t m) {
    return mat22(vec2(m.x.x, m.y.x), vec2(m.x.y, m.y.y));
}

mat32_t mat23_transpose(mat23_t m) {
    return mat32(vec2(m.x.x, m.y.x), vec2(m.x.y, m.y.y), vec2(m.x.z, m.y.z));
}

mat23_t mat32_transpose(mat32_t m) {
    return mat23(vec3(m.x.x, m.y.x, m.z.x), vec3(m.x.y, m.y.y, m.z.y));
}

mat33_t mat33_transpose(mat33_t m) {
    return mat33(vec3(m.x.x, m.y.x, m.z.x), vec3(m.x.y, m.y.y, m.z.y), vec3(m.x.z, m.y.z, m.z.z));
}

mat42_t mat24_transpose(mat24_t m) {
    return mat42(vec2(m.x.x, m.y.x), vec2(m.x.y, m.y.y), vec2(m.x.z, m.y.z), vec2(m.x.w, m.y.w));
}

mat43_t mat34_transpose(mat34_t m) {
    return mat43(vec3(m.x.x, m.y.x, m.z.x), vec3(m.x.y, m.y.y, m.z.y), vec3(m.x.z, m.y.z, m.z.z), vec3(m.x.w, m.y.w, m.z.w));
}

mat24_t mat42_transpose(mat42_t m) {
    return mat24(vec4(m.x.x, m.y.x, m.z.x, m.w.x), vec4(m.x.y, m.y.y, m.z.y, m.w.y));
}

mat34_t mat43_transpose(mat43_t m) {
    return mat34(vec4(m.x.x, m.y.x, m.z.x, m.w.x), vec4(m.x.y, m.y.y, m.z.y, m.w.y), vec4(m.x.z, m.y.z, m.z.z, m.w.z));
}

mat44_t mat44_transpose(mat44_t m) {
    return mat44(vec4(m.x.x, m.y.x, m.z.x, m.w.x), vec4(m.x.y, m.y.y, m.z.y, m.w.y), vec4(m.x.z, m.y.z, m.z.z, m.w.z), vec4(m.x.w, m.y.w, m.z.w, m.w.w));
}

f32 mat22_determinant(mat22_t m) {
    return m.x.x * m.y.y - m.x.y * m.y.x;
}

f32 mat33_determinant(mat33_t m) {
    return m.x.x * m.y.y * m.z.z + m.x.y * m.y.z * m.z.x + m.x.z * m.y.x * m.z.y - m.x.x * m.y.z * m.z.y - m.x.y * m.y.x * m.z.z - m.x.z * m.y.y * m.z.x;
}

f32 mat44_determinant(mat44_t m) {
    return m.x.w * m.y.z * m.z.y * m.w.x - m.x.z * m.y.w * m.z.y * m.w.x - m.x.w * m.y.y * m.z.z * m.w.x + m.x.y * m.y.w * m.z.z * m.w.x + m.x.z * m.y.y * m.z.w * m.w.x - m.x.y * m.y.z * m.z.w * m.w.x - m.x.w * m.y.z * m.z.x * m.w.y + m.x.z * m.y.w * m.z.x * m.w.y + m.x.w * m.y.x * m.z.z * m.w.y - m.x.x * m.y.w * m.z.z * m.w.y - m.x.z * m.y.x * m.z.w * m.w.y + m.x.x * m.y.z * m.z.w * m.w.y + m.x.w * m.y.y * m.z.x * m.w.z - m.x.y * m.y.w * m.z.x * m.w.z - m.x.w * m.y.x * m.z.y * m.w.z + m.x.x * m.y.w * m.z.y * m.w.z + m.x.y * m.y.x * m.z.w * m.w.z - m.x.x * m.y.y * m.z.w * m.w.z - m.x.z * m.y.y * m.z.x * m.w.w + m.x.y * m.y.z * m.z.x * m.w.w + m.x.z * m.y.x * m.z.y * m.w.w - m.x.x * m.y.z * m.z.y * m.w.w - m.x.y * m.y.x * m.z.z * m.w.w + m.x.x * m.y.y * m.z.z * m.w.w;
}

i32 mat22_inverse(mat22_t* out_matrix, f32* out_determinant, mat22_t m) {
    f32 d = mat22_determinant(m);
    if out_determinant != null {
        *out_determinant = d;
    }
    if d != 0.0f && out_matrix {
        *out_matrix = mat22(vec2(m.y.y / d, -m.x.y / d), vec2(-m.y.x / d, m.x.x / d));
    }
    return d != 0.0f;
}

i32 mat33_inverse(mat33_t* out_matrix, f32* out_determinant, mat33_t m) {
    f32 d = mat33_determinant(m);
    if out_determinant != null {
        *out_determinant = d;
    }
    if d != 0.0f && out_matrix {
        *out_matrix = mat33(vec3((m.y.y * m.z.z - m.y.z * m.z.y) / d, (m.x.z * m.z.y - m.x.y * m.z.z) / d, (m.x.y * m.y.z - m.x.z * m.y.y) / d), vec3((m.y.z * m.z.x - m.y.x * m.z.z) / d, (m.x.x * m.z.z - m.x.z * m.z.x) / d, (m.x.z * m.y.x - m.x.x * m.y.z) / d), vec3((m.y.x * m.z.y - m.y.y * m.z.x) / d, (m.x.y * m.z.x - m.x.x * m.z.y) / d, (m.x.x * m.y.y - m.x.y * m.y.x) / d));
    }
    return d != 0.0f;
}

i32 mat44_inverse(mat44_t* out_matrix, f32* out_determinant, mat44_t m) {
    f32 d = mat44_determinant(m);
    if out_determinant != null {
        *out_determinant = d;
    }
    if d != 0.0f && out_matrix {
        *out_matrix = mat44(vec4((m.y.z * m.z.w * m.w.y - m.y.w * m.z.z * m.w.y + m.y.w * m.z.y * m.w.z - m.y.y * m.z.w * m.w.z - m.y.z * m.z.y * m.w.w + m.y.y * m.z.z * m.w.w) / d, (m.x.w * m.z.z * m.w.y - m.x.z * m.z.w * m.w.y - m.x.w * m.z.y * m.w.z + m.x.y * m.z.w * m.w.z + m.x.z * m.z.y * m.w.w - m.x.y * m.z.z * m.w.w) / d, (m.x.z * m.y.w * m.w.y - m.x.w * m.y.z * m.w.y + m.x.w * m.y.y * m.w.z - m.x.y * m.y.w * m.w.z - m.x.z * m.y.y * m.w.w + m.x.y * m.y.z * m.w.w) / d, (m.x.w * m.y.z * m.z.y - m.x.z * m.y.w * m.z.y - m.x.w * m.y.y * m.z.z + m.x.y * m.y.w * m.z.z + m.x.z * m.y.y * m.z.w - m.x.y * m.y.z * m.z.w) / d), vec4((m.y.w * m.z.z * m.w.x - m.y.z * m.z.w * m.w.x - m.y.w * m.z.x * m.w.z + m.y.x * m.z.w * m.w.z + m.y.z * m.z.x * m.w.w - m.y.x * m.z.z * m.w.w) / d, (m.x.z * m.z.w * m.w.x - m.x.w * m.z.z * m.w.x + m.x.w * m.z.x * m.w.z - m.x.x * m.z.w * m.w.z - m.x.z * m.z.x * m.w.w + m.x.x * m.z.z * m.w.w) / d, (m.x.w * m.y.z * m.w.x - m.x.z * m.y.w * m.w.x - m.x.w * m.y.x * m.w.z + m.x.x * m.y.w * m.w.z + m.x.z * m.y.x * m.w.w - m.x.x * m.y.z * m.w.w) / d, (m.x.z * m.y.w * m.z.x - m.x.w * m.y.z * m.z.x + m.x.w * m.y.x * m.z.z - m.x.x * m.y.w * m.z.z - m.x.z * m.y.x * m.z.w + m.x.x * m.y.z * m.z.w) / d), vec4((m.y.y * m.z.w * m.w.x - m.y.w * m.z.y * m.w.x + m.y.w * m.z.x * m.w.y - m.y.x * m.z.w * m.w.y - m.y.y * m.z.x * m.w.w + m.y.x * m.z.y * m.w.w) / d, (m.x.w * m.z.y * m.w.x - m.x.y * m.z.w * m.w.x - m.x.w * m.z.x * m.w.y + m.x.x * m.z.w * m.w.y + m.x.y * m.z.x * m.w.w - m.x.x * m.z.y * m.w.w) / d, (m.x.y * m.y.w * m.w.x - m.x.w * m.y.y * m.w.x + m.x.w * m.y.x * m.w.y - m.x.x * m.y.w * m.w.y - m.x.y * m.y.x * m.w.w + m.x.x * m.y.y * m.w.w) / d, (m.x.w * m.y.y * m.z.x - m.x.y * m.y.w * m.z.x - m.x.w * m.y.x * m.z.y + m.x.x * m.y.w * m.z.y + m.x.y * m.y.x * m.z.w - m.x.x * m.y.y * m.z.w) / d), vec4((m.y.z * m.z.y * m.w.x - m.y.y * m.z.z * m.w.x - m.y.z * m.z.x * m.w.y + m.y.x * m.z.z * m.w.y + m.y.y * m.z.x * m.w.z - m.y.x * m.z.y * m.w.z) / d, (m.x.y * m.z.z * m.w.x - m.x.z * m.z.y * m.w.x + m.x.z * m.z.x * m.w.y - m.x.x * m.z.z * m.w.y - m.x.y * m.z.x * m.w.z + m.x.x * m.z.y * m.w.z) / d, (m.x.z * m.y.y * m.w.x - m.x.y * m.y.z * m.w.x - m.x.z * m.y.x * m.w.y + m.x.x * m.y.z * m.w.y + m.x.y * m.y.x * m.w.z - m.x.x * m.y.y * m.w.z) / d, (m.x.y * m.y.z * m.z.x - m.x.z * m.y.y * m.z.x + m.x.z * m.y.x * m.z.y - m.x.x * m.y.z * m.z.y - m.x.y * m.y.x * m.z.z + m.x.x * m.y.y * m.z.z) / d));
    }
    return d != 0.0f;
}

mat22_t mat22_identity() {
    return mat22(vec2(1.0f, 0.0f), vec2(0.0f, 1.0f));
}

mat33_t mat33_identity() {
    return mat33(vec3(1.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 0.0f, 1.0f));
}

mat44_t mat44_identity() {
    return mat44(vec4(1.0f, 0.0f, 0.0f, 0.0f), vec4(0.0f, 1.0f, 0.0f, 0.0f), vec4(0.0f, 0.0f, 1.0f, 0.0f), vec4(0.0f, 0.0f, 0.0f, 1.0f));
}

i32 mat22_is_identity(mat22_t m) {
    return m.x.x == 1.0f && m.x.y == 0.0f && m.y.x == 0.0f && m.y.y == 1.0f;
}

i32 mat33_is_identity(mat33_t m) {
    return m.x.x == 1.0f && m.x.y == 0.0f && m.x.z == 0.0f && m.y.x == 0.0f && m.y.y == 1.0f && m.y.z == 0.0f && m.z.x == 0.0f && m.z.y == 0.0f && m.z.z == 1.0f;
}

i32 mat44_is_identity(mat44_t m) {
    return m.x.x == 1.0f && m.x.y == 0.0f && m.x.z == 0.0f && m.x.w == 0.0f && m.y.x == 0.0f && m.y.y == 1.0f && m.y.z == 0.0f && m.y.w == 0.0f && m.z.x == 0.0f && m.z.y == 0.0f && m.z.z == 1.0f && m.z.w == 0.0f && m.w.x == 0.0f && m.w.y == 0.0f && m.w.z == 0.0f && m.w.w == 1.0f;
}

// matrix multiplications
f32 vec2_mul_vec2(vec2_t a, vec2_t b) {
    return vec2_dot(a, b);
}

f32 vec3_mul_vec3(vec3_t a, vec3_t b) {
    return vec3_dot(a, b);
}

f32 vec4_mul_vec4(vec4_t a, vec4_t b) {
    return vec4_dot(a, b);
}

vec2_t vec2_mul_mat22(vec2_t a, mat22_t b) {
    return vec2(a.x * b.x.x + a.y * b.y.x, a.x * b.x.y + a.y * b.y.y);
}

vec3_t vec2_mul_mat23(vec2_t a, mat23_t b) {
    return vec3(a.x * b.x.x + a.y * b.y.x, a.x * b.x.y + a.y * b.y.y, a.x * b.x.z + a.y * b.y.z);
}

vec4_t vec2_mul_mat24(vec2_t a, mat24_t b) {
    return vec4(a.x * b.x.x + a.y * b.y.x, a.x * b.x.y + a.y * b.y.y, a.x * b.x.z + a.y * b.y.z, a.x * b.x.w + a.y * b.y.w);
}

vec2_t vec3_mul_mat32(vec3_t a, mat32_t b) {
    return vec2(a.x * b.x.x + a.y * b.y.x + a.z * b.z.x, a.x * b.x.y + a.y * b.y.y + a.z * b.z.y);
}

vec3_t vec3_mul_mat33(vec3_t a, mat33_t b) {
    return vec3(a.x * b.x.x + a.y * b.y.x + a.z * b.z.x, a.x * b.x.y + a.y * b.y.y + a.z * b.z.y, a.x * b.x.z + a.y * b.y.z + a.z * b.z.z);
}

vec4_t vec3_mul_mat34(vec3_t a, mat34_t b) {
    return vec4(a.x * b.x.x + a.y * b.y.x + a.z * b.z.x, a.x * b.x.y + a.y * b.y.y + a.z * b.z.y, a.x * b.x.z + a.y * b.y.z + a.z * b.z.z, a.x * b.x.w + a.y * b.y.w + a.z * b.z.w);
}

vec2_t vec4_mul_mat42(vec4_t a, mat42_t b) {
    return vec2(a.x * b.x.x + a.y * b.y.x + a.z * b.z.x + a.w * b.w.x, a.x * b.x.y + a.y * b.y.y + a.z * b.z.y + a.w * b.w.y);
}

vec3_t vec4_mul_mat43(vec4_t a, mat43_t b) {
    return vec3(a.x * b.x.x + a.y * b.y.x + a.z * b.z.x + a.w * b.w.x, a.x * b.x.y + a.y * b.y.y + a.z * b.z.y + a.w * b.w.y, a.x * b.x.z + a.y * b.y.z + a.z * b.z.z + a.w * b.w.z);
}

vec4_t vec4_mul_mat44(vec4_t a, mat44_t b) {
    return vec4(a.x * b.x.x + a.y * b.y.x + a.z * b.z.x + a.w * b.w.x, a.x * b.x.y + a.y * b.y.y + a.z * b.z.y + a.w * b.w.y, a.x * b.x.z + a.y * b.y.z + a.z * b.z.z + a.w * b.w.z, a.x * b.x.w + a.y * b.y.w + a.z * b.z.w + a.w * b.w.w);
}

vec2_t mat22_mul_vec2(mat22_t a, vec2_t b) {
    return vec2(a.x.x * b.x + a.x.y * b.y, a.y.x * b.x + a.y.y * b.y);
}

vec3_t mat32_mul_vec2(mat32_t a, vec2_t b) {
    return vec3(a.x.x * b.x + a.x.y * b.y, a.y.x * b.x + a.y.y * b.y, a.z.x * b.x + a.z.y * b.y);
}

vec4_t mat42_mul_vec2(mat42_t a, vec2_t b) {
    return vec4(a.x.x * b.x + a.x.y * b.y, a.y.x * b.x + a.y.y * b.y, a.z.x * b.x + a.z.y * b.y, a.w.x * b.x + a.w.y * b.y);
}

vec2_t mat23_mul_vec3(mat23_t a, vec3_t b) {
    return vec2(a.x.x * b.x + a.x.y * b.y + a.x.z * b.z, a.y.x * b.x + a.y.y * b.y + a.y.z * b.z);
}

vec3_t mat33_mul_vec3(mat33_t a, vec3_t b) {
    return vec3(a.x.x * b.x + a.x.y * b.y + a.x.z * b.z, a.y.x * b.x + a.y.y * b.y + a.y.z * b.z, a.z.x * b.x + a.z.y * b.y + a.z.z * b.z);
}

vec4_t mat43_mul_vec3(mat43_t a, vec3_t b) {
    return vec4(a.x.x * b.x + a.x.y * b.y + a.x.z * b.z, a.y.x * b.x + a.y.y * b.y + a.y.z * b.z, a.z.x * b.x + a.z.y * b.y + a.z.z * b.z, a.w.x * b.x + a.w.y * b.y + a.w.z * b.z);
}

vec2_t mat24_mul_vec4(mat24_t a, vec4_t b) {
    return vec2(a.x.x * b.x + a.x.y * b.y + a.x.z * b.z + a.x.w * b.w, a.y.x * b.x + a.y.y * b.y + a.y.z * b.z + a.y.w * b.w);
}

vec3_t mat34_mul_vec4(mat34_t a, vec4_t b) {
    return vec3(a.x.x * b.x + a.x.y * b.y + a.x.z * b.z + a.x.w * b.w, a.y.x * b.x + a.y.y * b.y + a.y.z * b.z + a.y.w * b.w, a.z.x * b.x + a.z.y * b.y + a.z.z * b.z + a.z.w * b.w);
}

vec4_t mat44_mul_vec4(mat44_t a, vec4_t b) {
    return vec4(a.x.x * b.x + a.x.y * b.y + a.x.z * b.z + a.x.w * b.w, a.y.x * b.x + a.y.y * b.y + a.y.z * b.z + a.y.w * b.w, a.z.x * b.x + a.z.y * b.y + a.z.z * b.z + a.z.w * b.w, a.w.x * b.x + a.w.y * b.y + a.w.z * b.z + a.w.w * b.w);
}

mat22_t mat22_mul_mat22(mat22_t a, mat22_t b) {
    return mat22(vec2(a.x.x * b.x.x + a.x.y * b.y.x, a.x.x * b.x.y + a.x.y * b.y.y), vec2(a.y.x * b.x.x + a.y.y * b.y.x, a.y.x * b.x.y + a.y.y * b.y.y));
}

mat23_t mat22_mul_mat23(mat22_t a, mat23_t b) {
    return mat23(vec3(a.x.x * b.x.x + a.x.y * b.y.x, a.x.x * b.x.y + a.x.y * b.y.y, a.x.x * b.x.z + a.x.y * b.y.z), vec3(a.y.x * b.x.x + a.y.y * b.y.x, a.y.x * b.x.y + a.y.y * b.y.y, a.y.x * b.x.z + a.y.y * b.y.z));
}

mat24_t mat22_mul_mat24(mat22_t a, mat24_t b) {
    return mat24(vec4(a.x.x * b.x.x + a.x.y * b.y.x, a.x.x * b.x.y + a.x.y * b.y.y, a.x.x * b.x.z + a.x.y * b.y.z, a.x.x * b.x.w + a.x.y * b.y.w), vec4(a.y.x * b.x.x + a.y.y * b.y.x, a.y.x * b.x.y + a.y.y * b.y.y, a.y.x * b.x.z + a.y.y * b.y.z, a.y.x * b.x.w + a.y.y * b.y.w));
}

mat22_t mat23_mul_mat32(mat23_t a, mat32_t b) {
    return mat22(vec2(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y), vec2(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y));
}

mat23_t mat23_mul_mat33(mat23_t a, mat33_t b) {
    return mat23(vec3(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y, a.x.x * b.x.z + a.x.y * b.y.z + a.x.z * b.z.z), vec3(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y, a.y.x * b.x.z + a.y.y * b.y.z + a.y.z * b.z.z));
}

mat24_t mat23_mul_mat34(mat23_t a, mat34_t b) {
    return mat24(vec4(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y, a.x.x * b.x.z + a.x.y * b.y.z + a.x.z * b.z.z, a.x.x * b.x.w + a.x.y * b.y.w + a.x.z * b.z.w), vec4(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y, a.y.x * b.x.z + a.y.y * b.y.z + a.y.z * b.z.z, a.y.x * b.x.w + a.y.y * b.y.w + a.y.z * b.z.w));
}

mat22_t mat24_mul_mat42(mat24_t a, mat42_t b) {
    return mat22(vec2(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x + a.x.w * b.w.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y + a.x.w * b.w.y), vec2(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x + a.y.w * b.w.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y + a.y.w * b.w.y));
}

mat23_t mat24_mul_mat43(mat24_t a, mat43_t b) {
    return mat23(vec3(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x + a.x.w * b.w.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y + a.x.w * b.w.y, a.x.x * b.x.z + a.x.y * b.y.z + a.x.z * b.z.z + a.x.w * b.w.z), vec3(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x + a.y.w * b.w.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y + a.y.w * b.w.y, a.y.x * b.x.z + a.y.y * b.y.z + a.y.z * b.z.z + a.y.w * b.w.z));
}

mat24_t mat24_mul_mat44(mat24_t a, mat44_t b) {
    return mat24(vec4(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x + a.x.w * b.w.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y + a.x.w * b.w.y, a.x.x * b.x.z + a.x.y * b.y.z + a.x.z * b.z.z + a.x.w * b.w.z, a.x.x * b.x.w + a.x.y * b.y.w + a.x.z * b.z.w + a.x.w * b.w.w), vec4(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x + a.y.w * b.w.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y + a.y.w * b.w.y, a.y.x * b.x.z + a.y.y * b.y.z + a.y.z * b.z.z + a.y.w * b.w.z, a.y.x * b.x.w + a.y.y * b.y.w + a.y.z * b.z.w + a.y.w * b.w.w));
}

mat32_t mat32_mul_mat22(mat32_t a, mat22_t b) {
    return mat32(vec2(a.x.x * b.x.x + a.x.y * b.y.x, a.x.x * b.x.y + a.x.y * b.y.y), vec2(a.y.x * b.x.x + a.y.y * b.y.x, a.y.x * b.x.y + a.y.y * b.y.y), vec2(a.z.x * b.x.x + a.z.y * b.y.x, a.z.x * b.x.y + a.z.y * b.y.y));
}

mat33_t mat32_mul_mat23(mat32_t a, mat23_t b) {
    return mat33(vec3(a.x.x * b.x.x + a.x.y * b.y.x, a.x.x * b.x.y + a.x.y * b.y.y, a.x.x * b.x.z + a.x.y * b.y.z), vec3(a.y.x * b.x.x + a.y.y * b.y.x, a.y.x * b.x.y + a.y.y * b.y.y, a.y.x * b.x.z + a.y.y * b.y.z), vec3(a.z.x * b.x.x + a.z.y * b.y.x, a.z.x * b.x.y + a.z.y * b.y.y, a.z.x * b.x.z + a.z.y * b.y.z));
}

mat34_t mat32_mul_mat24(mat32_t a, mat24_t b) {
    return mat34(vec4(a.x.x * b.x.x + a.x.y * b.y.x, a.x.x * b.x.y + a.x.y * b.y.y, a.x.x * b.x.z + a.x.y * b.y.z, a.x.x * b.x.w + a.x.y * b.y.w), vec4(a.y.x * b.x.x + a.y.y * b.y.x, a.y.x * b.x.y + a.y.y * b.y.y, a.y.x * b.x.z + a.y.y * b.y.z, a.y.x * b.x.w + a.y.y * b.y.w), vec4(a.z.x * b.x.x + a.z.y * b.y.x, a.z.x * b.x.y + a.z.y * b.y.y, a.z.x * b.x.z + a.z.y * b.y.z, a.z.x * b.x.w + a.z.y * b.y.w));
}

mat32_t mat33_mul_mat32(mat33_t a, mat32_t b) {
    return mat32(vec2(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y), vec2(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y), vec2(a.z.x * b.x.x + a.z.y * b.y.x + a.z.z * b.z.x, a.z.x * b.x.y + a.z.y * b.y.y + a.z.z * b.z.y));
}

mat33_t mat33_mul_mat33(mat33_t a, mat33_t b) {
    return mat33(vec3(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y, a.x.x * b.x.z + a.x.y * b.y.z + a.x.z * b.z.z), vec3(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y, a.y.x * b.x.z + a.y.y * b.y.z + a.y.z * b.z.z), vec3(a.z.x * b.x.x + a.z.y * b.y.x + a.z.z * b.z.x, a.z.x * b.x.y + a.z.y * b.y.y + a.z.z * b.z.y, a.z.x * b.x.z + a.z.y * b.y.z + a.z.z * b.z.z));
}

mat34_t mat33_mul_mat34(mat33_t a, mat34_t b) {
    return mat34(vec4(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y, a.x.x * b.x.z + a.x.y * b.y.z + a.x.z * b.z.z, a.x.x * b.x.w + a.x.y * b.y.w + a.x.z * b.z.w), vec4(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y, a.y.x * b.x.z + a.y.y * b.y.z + a.y.z * b.z.z, a.y.x * b.x.w + a.y.y * b.y.w + a.y.z * b.z.w), vec4(a.z.x * b.x.x + a.z.y * b.y.x + a.z.z * b.z.x, a.z.x * b.x.y + a.z.y * b.y.y + a.z.z * b.z.y, a.z.x * b.x.z + a.z.y * b.y.z + a.z.z * b.z.z, a.z.x * b.x.w + a.z.y * b.y.w + a.z.z * b.z.w));
}

mat32_t mat34_mul_mat42(mat34_t a, mat42_t b) {
    return mat32(vec2(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x + a.x.w * b.w.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y + a.x.w * b.w.y), vec2(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x + a.y.w * b.w.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y + a.y.w * b.w.y), vec2(a.z.x * b.x.x + a.z.y * b.y.x + a.z.z * b.z.x + a.z.w * b.w.x, a.z.x * b.x.y + a.z.y * b.y.y + a.z.z * b.z.y + a.z.w * b.w.y));
}

mat33_t mat34_mul_mat43(mat34_t a, mat43_t b) {
    return mat33(vec3(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x + a.x.w * b.w.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y + a.x.w * b.w.y, a.x.x * b.x.z + a.x.y * b.y.z + a.x.z * b.z.z + a.x.w * b.w.z), vec3(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x + a.y.w * b.w.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y + a.y.w * b.w.y, a.y.x * b.x.z + a.y.y * b.y.z + a.y.z * b.z.z + a.y.w * b.w.z), vec3(a.z.x * b.x.x + a.z.y * b.y.x + a.z.z * b.z.x + a.z.w * b.w.x, a.z.x * b.x.y + a.z.y * b.y.y + a.z.z * b.z.y + a.z.w * b.w.y, a.z.x * b.x.z + a.z.y * b.y.z + a.z.z * b.z.z + a.z.w * b.w.z));
}

mat34_t mat34_mul_mat44(mat34_t a, mat44_t b) {
    return mat34(vec4(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x + a.x.w * b.w.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y + a.x.w * b.w.y, a.x.x * b.x.z + a.x.y * b.y.z + a.x.z * b.z.z + a.x.w * b.w.z, a.x.x * b.x.w + a.x.y * b.y.w + a.x.z * b.z.w + a.x.w * b.w.w), vec4(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x + a.y.w * b.w.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y + a.y.w * b.w.y, a.y.x * b.x.z + a.y.y * b.y.z + a.y.z * b.z.z + a.y.w * b.w.z, a.y.x * b.x.w + a.y.y * b.y.w + a.y.z * b.z.w + a.y.w * b.w.w), vec4(a.z.x * b.x.x + a.z.y * b.y.x + a.z.z * b.z.x + a.z.w * b.w.x, a.z.x * b.x.y + a.z.y * b.y.y + a.z.z * b.z.y + a.z.w * b.w.y, a.z.x * b.x.z + a.z.y * b.y.z + a.z.z * b.z.z + a.z.w * b.w.z, a.z.x * b.x.w + a.z.y * b.y.w + a.z.z * b.z.w + a.z.w * b.w.w));
}

mat42_t mat42_mul_mat22(mat42_t a, mat22_t b) {
    return mat42(vec2(a.x.x * b.x.x + a.x.y * b.y.x, a.x.x * b.x.y + a.x.y * b.y.y), vec2(a.y.x * b.x.x + a.y.y * b.y.x, a.y.x * b.x.y + a.y.y * b.y.y), vec2(a.z.x * b.x.x + a.z.y * b.y.x, a.z.x * b.x.y + a.z.y * b.y.y), vec2(a.w.x * b.x.x + a.w.y * b.y.x, a.w.x * b.x.y + a.w.y * b.y.y));
}

mat43_t mat42_mul_mat23(mat42_t a, mat23_t b) {
    return mat43(vec3(a.x.x * b.x.x + a.x.y * b.y.x, a.x.x * b.x.y + a.x.y * b.y.y, a.x.x * b.x.z + a.x.y * b.y.z), vec3(a.y.x * b.x.x + a.y.y * b.y.x, a.y.x * b.x.y + a.y.y * b.y.y, a.y.x * b.x.z + a.y.y * b.y.z), vec3(a.z.x * b.x.x + a.z.y * b.y.x, a.z.x * b.x.y + a.z.y * b.y.y, a.z.x * b.x.z + a.z.y * b.y.z), vec3(a.w.x * b.x.x + a.w.y * b.y.x, a.w.x * b.x.y + a.w.y * b.y.y, a.w.x * b.x.z + a.w.y * b.y.z));
}

mat44_t mat42_mul_mat24(mat42_t a, mat24_t b) {
    return mat44(vec4(a.x.x * b.x.x + a.x.y * b.y.x, a.x.x * b.x.y + a.x.y * b.y.y, a.x.x * b.x.z + a.x.y * b.y.z, a.x.x * b.x.w + a.x.y * b.y.w), vec4(a.y.x * b.x.x + a.y.y * b.y.x, a.y.x * b.x.y + a.y.y * b.y.y, a.y.x * b.x.z + a.y.y * b.y.z, a.y.x * b.x.w + a.y.y * b.y.w), vec4(a.z.x * b.x.x + a.z.y * b.y.x, a.z.x * b.x.y + a.z.y * b.y.y, a.z.x * b.x.z + a.z.y * b.y.z, a.z.x * b.x.w + a.z.y * b.y.w), vec4(a.w.x * b.x.x + a.w.y * b.y.x, a.w.x * b.x.y + a.w.y * b.y.y, a.w.x * b.x.z + a.w.y * b.y.z, a.w.x * b.x.w + a.w.y * b.y.w));
}

mat42_t mat43_mul_mat32(mat43_t a, mat32_t b) {
    return mat42(vec2(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y), vec2(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y), vec2(a.z.x * b.x.x + a.z.y * b.y.x + a.z.z * b.z.x, a.z.x * b.x.y + a.z.y * b.y.y + a.z.z * b.z.y), vec2(a.w.x * b.x.x + a.w.y * b.y.x + a.w.z * b.z.x, a.w.x * b.x.y + a.w.y * b.y.y + a.w.z * b.z.y));
}

mat43_t mat43_mul_mat33(mat43_t a, mat33_t b) {
    return mat43(vec3(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y, a.x.x * b.x.z + a.x.y * b.y.z + a.x.z * b.z.z), vec3(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y, a.y.x * b.x.z + a.y.y * b.y.z + a.y.z * b.z.z), vec3(a.z.x * b.x.x + a.z.y * b.y.x + a.z.z * b.z.x, a.z.x * b.x.y + a.z.y * b.y.y + a.z.z * b.z.y, a.z.x * b.x.z + a.z.y * b.y.z + a.z.z * b.z.z), vec3(a.w.x * b.x.x + a.w.y * b.y.x + a.w.z * b.z.x, a.w.x * b.x.y + a.w.y * b.y.y + a.w.z * b.z.y, a.w.x * b.x.z + a.w.y * b.y.z + a.w.z * b.z.z));
}

mat44_t mat43_mul_mat34(mat43_t a, mat34_t b) {
    return mat44(vec4(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y, a.x.x * b.x.z + a.x.y * b.y.z + a.x.z * b.z.z, a.x.x * b.x.w + a.x.y * b.y.w + a.x.z * b.z.w), vec4(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y, a.y.x * b.x.z + a.y.y * b.y.z + a.y.z * b.z.z, a.y.x * b.x.w + a.y.y * b.y.w + a.y.z * b.z.w), vec4(a.z.x * b.x.x + a.z.y * b.y.x + a.z.z * b.z.x, a.z.x * b.x.y + a.z.y * b.y.y + a.z.z * b.z.y, a.z.x * b.x.z + a.z.y * b.y.z + a.z.z * b.z.z, a.z.x * b.x.w + a.z.y * b.y.w + a.z.z * b.z.w), vec4(a.w.x * b.x.x + a.w.y * b.y.x + a.w.z * b.z.x, a.w.x * b.x.y + a.w.y * b.y.y + a.w.z * b.z.y, a.w.x * b.x.z + a.w.y * b.y.z + a.w.z * b.z.z, a.w.x * b.x.w + a.w.y * b.y.w + a.w.z * b.z.w));
}

mat42_t mat44_mul_mat42(mat44_t a, mat42_t b) {
    return mat42(vec2(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x + a.x.w * b.w.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y + a.x.w * b.w.y), vec2(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x + a.y.w * b.w.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y + a.y.w * b.w.y), vec2(a.z.x * b.x.x + a.z.y * b.y.x + a.z.z * b.z.x + a.z.w * b.w.x, a.z.x * b.x.y + a.z.y * b.y.y + a.z.z * b.z.y + a.z.w * b.w.y), vec2(a.w.x * b.x.x + a.w.y * b.y.x + a.w.z * b.z.x + a.w.w * b.w.x, a.w.x * b.x.y + a.w.y * b.y.y + a.w.z * b.z.y + a.w.w * b.w.y));
}

mat43_t mat44_mul_mat43(mat44_t a, mat43_t b) {
    return mat43(vec3(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x + a.x.w * b.w.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y + a.x.w * b.w.y, a.x.x * b.x.z + a.x.y * b.y.z + a.x.z * b.z.z + a.x.w * b.w.z), vec3(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x + a.y.w * b.w.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y + a.y.w * b.w.y, a.y.x * b.x.z + a.y.y * b.y.z + a.y.z * b.z.z + a.y.w * b.w.z), vec3(a.z.x * b.x.x + a.z.y * b.y.x + a.z.z * b.z.x + a.z.w * b.w.x, a.z.x * b.x.y + a.z.y * b.y.y + a.z.z * b.z.y + a.z.w * b.w.y, a.z.x * b.x.z + a.z.y * b.y.z + a.z.z * b.z.z + a.z.w * b.w.z), vec3(a.w.x * b.x.x + a.w.y * b.y.x + a.w.z * b.z.x + a.w.w * b.w.x, a.w.x * b.x.y + a.w.y * b.y.y + a.w.z * b.z.y + a.w.w * b.w.y, a.w.x * b.x.z + a.w.y * b.y.z + a.w.z * b.z.z + a.w.w * b.w.z));
}

mat44_t mat44_mul_mat44(mat44_t a, mat44_t b) {
    return mat44(vec4(a.x.x * b.x.x + a.x.y * b.y.x + a.x.z * b.z.x + a.x.w * b.w.x, a.x.x * b.x.y + a.x.y * b.y.y + a.x.z * b.z.y + a.x.w * b.w.y, a.x.x * b.x.z + a.x.y * b.y.z + a.x.z * b.z.z + a.x.w * b.w.z, a.x.x * b.x.w + a.x.y * b.y.w + a.x.z * b.z.w + a.x.w * b.w.w), vec4(a.y.x * b.x.x + a.y.y * b.y.x + a.y.z * b.z.x + a.y.w * b.w.x, a.y.x * b.x.y + a.y.y * b.y.y + a.y.z * b.z.y + a.y.w * b.w.y, a.y.x * b.x.z + a.y.y * b.y.z + a.y.z * b.z.z + a.y.w * b.w.z, a.y.x * b.x.w + a.y.y * b.y.w + a.y.z * b.z.w + a.y.w * b.w.w), vec4(a.z.x * b.x.x + a.z.y * b.y.x + a.z.z * b.z.x + a.z.w * b.w.x, a.z.x * b.x.y + a.z.y * b.y.y + a.z.z * b.z.y + a.z.w * b.w.y, a.z.x * b.x.z + a.z.y * b.y.z + a.z.z * b.z.z + a.z.w * b.w.z, a.z.x * b.x.w + a.z.y * b.y.w + a.z.z * b.z.w + a.z.w * b.w.w), vec4(a.w.x * b.x.x + a.w.y * b.y.x + a.w.z * b.z.x + a.w.w * b.w.x, a.w.x * b.x.y + a.w.y * b.y.y + a.w.z * b.z.y + a.w.w * b.w.y, a.w.x * b.x.z + a.w.y * b.y.z + a.w.z * b.z.z + a.w.w * b.w.z, a.w.x * b.x.w + a.w.y * b.y.w + a.w.z * b.z.w + a.w.w * b.w.w));
}

// quaternions
vec4_t quat_normalize(vec4_t q) {
    return vec4_normalize(q);
}

vec4_t quat_slerp(vec4_t a, vec4_t b, f32 t) {
    f32 dot = vec4_dot(a, b);
    if dot < 0.0f {
        b = vec4_neg(b);
        dot = -dot;
    }
    if dot > 0.9995f {
        vec4_t result = vec4_add(vec4_mulf(a, 1.0f - t), vec4_mulf(b, t));
        return quat_normalize(result);
    }
    f32 theta = vecmath_acos(dot);
    f32 sin_theta = vecmath_sin(theta);
    f32 s0 = vecmath_sin((1.0f - t) * theta) / sin_theta;
    f32 s1 = vecmath_sin(t * theta) / sin_theta;
    return vec4_add(vec4_mulf(a, s0), vec4_mulf(b, s1));
}

vec4_t quat_barycentric(vec4_t q1, vec4_t q2, vec4_t q3, f32 f, f32 g) {
    f32 fg = f + g;
    return fg == 0.0f ? q1 : quat_slerp(quat_slerp(q1, q2, fg), quat_slerp(q1, q3, fg), g / fg);
}

vec4_t quat_conjugate(vec4_t q) {
    return vec4(-q.x, -q.y, -q.z, q.w);
}

vec4_t quat_exp(vec4_t q) {
    vec3_t v = vec3(q.x, q.y, q.z);
    f32 angle = vecmath_sqrt(vec3_dot(v, v));
    f32 s = angle > 1.0e-5f ? vecmath_sin(angle) / angle : 1.0f;
    return vec4(v.x * s, v.y * s, v.z * s, vecmath_cos(angle));
}

vec4_t quat_identity() {
    return vec4(0.0f, 0.0f, 0.0f, 1.0f);
}

vec4_t quat_inverse(vec4_t q) {
    f32 dot = vec4_dot(q, q);
    return dot == 0.0f ? quat_identity() : vec4_mulf(vec4(-q.x, -q.y, -q.z, q.w), 1.0f / dot);
}

i32 quat_is_identity(vec4_t q) {
    return q.x == 0.0f && q.y == 0.0f && q.z == 0.0f && q.w == 1.0f;
}

vec4_t quat_ln(vec4_t q) {
    f32 epsilon = 1.0f - 1.0e-5f;
    f32 w = q.w;
    vec3_t v = vec3(q.x, q.y, q.z);
    noinit vec4_t result;
    if vecmath_abs(w) < epsilon {
        f32 theta = vecmath_acos(w);
        f32 sin_theta = vecmath_sin(theta);
        f32 scale = theta / sin_theta;
        result = vec4(v.x * scale, v.y * scale, v.z * scale, 0.0f);
    } else {
        result = vec4(v.x, v.y, v.z, 0.0f);
    }
    return result;
}

vec4_t quat_mul(vec4_t a, vec4_t b) {
    return vec4(b.w * a.x + b.x * a.w + b.y * a.z - b.z * a.y, b.w * a.y - b.x * a.z + b.y * a.w + b.z * a.x, b.w * a.z + b.x * a.y - b.y * a.x + b.z * a.w, b.w * a.w - b.x * a.x - b.y * a.y - b.z * a.z);
}

vec4_t quat_rotation_axis(vec3_t axis, f32 angle) {
    return vec4v3f(vec3_mulf(vec3_normalize(axis), vecmath_sin(angle * 0.5f)), vecmath_cos(angle * 0.5f));
}

vec4_t quat_rotation_matrix(mat44_t m) {
    f32 trace = m.x.x + m.y.y + m.z.z;
    if trace > 0.0f {
        f32 s = vecmath_sqrt(trace + 1.0f) * 2.0f;
        return vec4((m.y.z - m.z.y) / s, (m.z.x - m.x.z) / s, (m.x.y - m.y.x) / s, 0.25f * s);
    } else if m.x.x > m.y.y && m.x.x > m.z.z {
        f32 s = vecmath_sqrt(1.0f + m.x.x - m.y.y - m.z.z) * 2.0f;
        return vec4(0.25f * s, (m.x.y + m.y.x) / s, (m.x.z + m.z.x) / s, (m.y.z - m.z.y) / s);
    } else if m.y.y > m.z.z {
        f32 s = vecmath_sqrt(1.0f + m.y.y - m.x.x - m.z.z) * 2.0f;
        return vec4((m.y.x + m.x.y) / s, 0.25f * s, (m.y.z + m.z.y) / s, (m.z.x - m.x.z) / s);
    } else {
        f32 s = vecmath_sqrt(1.0f + m.z.z - m.x.x - m.y.y) * 2.0f;
        return vec4((m.z.x + m.x.z) / s, (m.z.y + m.y.z) / s, 0.25f * s, (m.x.y - m.y.x) / s);
    }
}

vec4_t quat_rotation_yaw_pitch_roll(f32 yaw, f32 pitch, f32 roll) {
    f32 hy = yaw * 0.5f;
    f32 hp = pitch * 0.5f;
    f32 hr = roll * 0.5f;
    f32 cy = vecmath_cos(hy);
    f32 sy = vecmath_sin(hy);
    f32 cp = vecmath_cos(hp);
    f32 sp = vecmath_sin(hp);
    f32 cr = vecmath_cos(hr);
    f32 sr = vecmath_sin(hr);
    return vec4(cr * sp * cy + sr * cp * sy, cr * cp * sy - sr * sp * cy, sr * cp * cy - cr * sp * sy, cr * cp * cy + sr * sp * sy);
}

void quat_squad_setup(vec4_t* out_a, vec4_t* out_b, vec4_t* out_c, vec4_t q0, vec4_t q1, vec4_t q2, vec4_t q3) {
    vec4_t sq2 = vec4_dot(vec4_add(q1, q2), vec4_add(q1, q2)) < vec4_dot(vec4_sub(q1, q2), vec4_sub(q1, q2)) ? vec4_neg(q2) : q2;
    vec4_t sq0 = vec4_dot(vec4_add(q0, q1), vec4_add(q0, q1)) < vec4_dot(vec4_sub(q0, q1), vec4_sub(q0, q1)) ? vec4_neg(q0) : q0;
    vec4_t sq3 = vec4_dot(vec4_add(sq2, q3), vec4_add(sq2, q3)) < vec4_dot(vec4_sub(sq2, q3), vec4_sub(sq2, q3)) ? vec4_neg(q3) : q3;
    vec4_t invq1 = quat_inverse(q1);
    vec4_t invq2 = quat_inverse(sq2);
    vec4_t lnq0 = quat_ln(quat_mul(invq1, sq0));
    vec4_t lnq2 = quat_ln(quat_mul(invq1, sq2));
    vec4_t lnq1 = quat_ln(quat_mul(invq2, q1));
    vec4_t lnq3 = quat_ln(quat_mul(invq2, sq3));
    vec4_t expq02 = quat_exp(vec4_mulf(vec4_add(lnq0, lnq2), -0.25f));
    vec4_t expq13 = quat_exp(vec4_mulf(vec4_add(lnq1, lnq3), -0.25f));
    if out_a != null {
        *out_a = quat_mul(q1, expq02);
    }
    if out_b != null {
        *out_b = quat_mul(sq2, expq13);
    }
    if out_c != null {
        *out_c = sq2;
    }
}

vec4_t quat_squad(vec4_t q1, vec4_t a, vec4_t b, vec4_t c, f32 t) {
    return quat_slerp(quat_slerp(q1, c, t), quat_slerp(a, b, t), 2.0f * t * (1.0f - t));
}

void quat_to_axis_angle(vec4_t q, vec3_t* out_axis, f32* out_angle) {
    if out_angle != null {
        *out_angle = 2.0f * vecmath_acos(q.w);
    }
    if out_axis != null {
        *out_axis = vec3(q.x, q.y, q.z);
    }
}

vec3_t quat_rotate_vector(vec3_t v, vec4_t q) {
    vec3_t u = vec3(q.x, q.y, q.z);
    f32 s = q.w;
    vec3_t t = vec3_mulf(vec3_cross(u, v), 2.0f);
    return vec3_add(v, vec3_add(vec3_mulf(t, s), vec3_cross(u, t)));
}

vec4_t quat_shortest_arc(vec3_t from_var, vec3_t to) {
    vec3_t f = vec3_normalize(from_var);
    vec3_t t = vec3_normalize(to);
    f32 d = vec3_dot(f, t);
    if d == 1.0f {
        return quat_identity();
    }
    if d == -1.0f {
        vec3_t axis = vecmath_abs(f.x) < 1.0f ? vec3(1.0f, 0.0f, 0.0f) : vec3(0.0f, 1.0f, 0.0f);
        axis = vec3_normalize(vec3_cross(f, axis));
        return quat_rotation_axis(axis, 3.1415926499999998f);
    }
    vec3_t axis = vec3_cross(f, t);
    f32 s = vecmath_sqrt((1.0f + d) * 2.0f);
    f32 invs = 1.0f / s;
    return vec4(axis.x * invs, axis.y * invs, axis.z * invs, 0.5f * s);
}

vec4_t quat_from_mat33(mat33_t m) {
    f32 trace = m.x.x + m.y.y + m.z.z;
    if trace > 0.0f {
        f32 s = vecmath_sqrt(trace + 1.0f) * 2.0f;
        f32 invs = 1.0f / s;
        return vec4((m.y.z - m.z.y) * invs, (m.z.x - m.x.z) * invs, (m.x.y - m.y.x) * invs, 0.25f * s);
    }
    if m.x.x > m.y.y && m.x.x > m.z.z {
        f32 s = vecmath_sqrt(1.0f + m.x.x - m.y.y - m.z.z) * 2.0f;
        f32 invs = 1.0f / s;
        return vec4(0.25f * s, (m.x.y + m.y.x) * invs, (m.x.z + m.z.x) * invs, (m.y.z - m.z.y) * invs);
    }
    if m.y.y > m.z.z {
        f32 s = vecmath_sqrt(1.0f + m.y.y - m.x.x - m.z.z) * 2.0f;
        f32 invs = 1.0f / s;
        return vec4((m.x.y + m.y.x) * invs, 0.25f * s, (m.y.z + m.z.y) * invs, (m.z.x - m.x.z) * invs);
    }
    f32 s = vecmath_sqrt(1.0f + m.z.z - m.x.x - m.y.y) * 2.0f;
    f32 invs = 1.0f / s;
    return vec4((m.x.z + m.z.x) * invs, (m.y.z + m.z.y) * invs, 0.25f * s, (m.x.y - m.y.x) * invs);
}

vec4_t quat_from_mat44(mat44_t m) {
    return quat_from_mat33(mat33(vec3(m.x.x, m.x.y, m.x.z), vec3(m.y.x, m.y.y, m.y.z), vec3(m.z.x, m.z.y, m.z.z)));
}

f32 quat_angle(vec4_t a, vec4_t b) {
    f32 d = vec4_dot(a, b);
    d = vecmath_clamp(d, -1.0f, 1.0f);
    return 2.0f * vecmath_acos(vecmath_abs(d));
}

mat33_t mat33_from_quat(vec4_t q) {
    f32 x = q.x;
    f32 y = q.y;
    f32 z = q.z;
    f32 w = q.w;
    f32 xx = x * x;
    f32 yy = y * y;
    f32 zz = z * z;
    f32 xy = x * y;
    f32 xz = x * z;
    f32 yz = y * z;
    f32 wx = w * x;
    f32 wy = w * y;
    f32 wz = w * z;
    return mat33(vec3(1.0f - 2.0f * (yy + zz), 2.0f * (xy + wz), 2.0f * (xz - wy)), vec3(2.0f * (xy - wz), 1.0f - 2.0f * (xx + zz), 2.0f * (yz + wx)), vec3(2.0f * (xz + wy), 2.0f * (yz - wx), 1.0f - 2.0f * (xx + yy)));
}

mat44_t mat44_from_quat(vec4_t q) {
    mat33_t r = mat33_from_quat(q);
    return mat44(vec4(r.x.x, r.x.y, r.x.z, 0.0f), vec4(r.y.x, r.y.y, r.y.z, 0.0f), vec4(r.z.x, r.z.y, r.z.z, 0.0f), vec4(0.0f, 0.0f, 0.0f, 1.0f));
}

// matrix utils
mat44_t mat44_look_at_lh(vec3_t eye, vec3_t at, vec3_t up) {
    vec3_t zaxis = vec3_normalize(vec3_sub(at, eye));
    vec3_t xaxis = vec3_normalize(vec3_cross(up, zaxis));
    vec3_t yaxis = vec3_cross(zaxis, xaxis);
    return mat44(vec4(xaxis.x, yaxis.x, zaxis.x, 0.0f), vec4(xaxis.y, yaxis.y, zaxis.y, 0.0f), vec4(xaxis.z, yaxis.z, zaxis.z, 0.0f), vec4(-vec3_dot(xaxis, eye), -vec3_dot(yaxis, eye), -vec3_dot(zaxis, eye), 1.0f));
}

mat44_t mat44_look_at_rh(vec3_t eye, vec3_t at, vec3_t up) {
    vec3_t zaxis = vec3_normalize(vec3_sub(eye, at));
    vec3_t xaxis = vec3_normalize(vec3_cross(up, zaxis));
    vec3_t yaxis = vec3_cross(zaxis, xaxis);
    return mat44(vec4(xaxis.x, yaxis.x, zaxis.x, 0.0f), vec4(xaxis.y, yaxis.y, zaxis.y, 0.0f), vec4(xaxis.z, yaxis.z, zaxis.z, 0.0f), vec4(-vec3_dot(xaxis, eye), -vec3_dot(yaxis, eye), -vec3_dot(zaxis, eye), 1.0f));
}

mat44_t mat44_ortho_lh(f32 w, f32 h, f32 zn, f32 zf) {
    return mat44(vec4(2.0f / w, 0.0f, 0.0f, 0.0f), vec4(0.0f, 2.0f / h, 0.0f, 0.0f), vec4(0.0f, 0.0f, 1.0f / (zf - zn), 0.0f), vec4(0.0f, 0.0f, zn / (zn - zf), 1.0f));
}

mat44_t mat44_ortho_rh(f32 w, f32 h, f32 zn, f32 zf) {
    return mat44(vec4(2.0f / w, 0.0f, 0.0f, 0.0f), vec4(0.0f, 2.0f / h, 0.0f, 0.0f), vec4(0.0f, 0.0f, 1.0f / (zn - zf), 0.0f), vec4(0.0f, 0.0f, zn / (zn - zf), 1.0f));
}

mat44_t mat44_ortho_off_center_lh(f32 l, f32 r, f32 b, f32 t, f32 zn, f32 zf) {
    return mat44(vec4(2.0f / (r - l), 0.0f, 0.0f, 0.0f), vec4(0.0f, 2.0f / (t - b), 0.0f, 0.0f), vec4(0.0f, 0.0f, 1.0f / (zf - zn), 0.0f), vec4((l + r) / (l - r), (t + b) / (b - t), zn / (zn - zf), 1.0f));
}

mat44_t mat44_ortho_off_center_rh(f32 l, f32 r, f32 b, f32 t, f32 zn, f32 zf) {
    return mat44(vec4(2.0f / (r - l), 0.0f, 0.0f, 0.0f), vec4(0.0f, 2.0f / (t - b), 0.0f, 0.0f), vec4(0.0f, 0.0f, 1.0f / (zn - zf), 0.0f), vec4((l + r) / (l - r), (t + b) / (b - t), zn / (zn - zf), 1.0f));
}

mat44_t mat44_perspective_lh(f32 w, f32 h, f32 zn, f32 zf) {
    return mat44(vec4(2.0f * zn / w, 0.0f, 0.0f, 0.0f), vec4(0.0f, 2.0f * zn / h, 0.0f, 0.0f), vec4(0.0f, 0.0f, zf / (zf - zn), 1.0f), vec4(0.0f, 0.0f, zn * zf / (zn - zf), 0.0f));
}

mat44_t mat44_perspective_rh(f32 w, f32 h, f32 zn, f32 zf) {
    return mat44(vec4(2.0f * zn / w, 0.0f, 0.0f, 0.0f), vec4(0.0f, 2.0f * zn / h, 0.0f, 0.0f), vec4(0.0f, 0.0f, zf / (zn - zf), -1.0f), vec4(0.0f, 0.0f, zn * zf / (zn - zf), 0.0f));
}

mat44_t mat44_perspective_off_center_lh(f32 l, f32 r, f32 b, f32 t, f32 zn, f32 zf) {
    return mat44(vec4(2.0f * zn / (r - l), 0.0f, 0.0f, 0.0f), vec4(0.0f, 2.0f * zn / (t - b), 0.0f, 0.0f), vec4((l + r) / (l - r), (t + b) / (b - t), zf / (zf - zn), 1.0f), vec4(0.0f, 0.0f, zn * zf / (zn - zf), 0.0f));
}

mat44_t mat44_perspective_off_center_rh(f32 l, f32 r, f32 b, f32 t, f32 zn, f32 zf) {
    return mat44(vec4(2.0f * zn / (r - l), 0.0f, 0.0f, 0.0f), vec4(0.0f, 2.0f * zn / (t - b), 0.0f, 0.0f), vec4((l + r) / (r - l), (t + b) / (t - b), zf / (zn - zf), -1.0f), vec4(0.0f, 0.0f, zn * zf / (zn - zf), 0.0f));
}

mat44_t mat44_perspective_fov_lh(f32 fovy, f32 aspect, f32 zn, f32 zf) {
    f32 yscale = 1.0f / vecmath_tan(fovy * 0.5f);
    f32 xscale = yscale / aspect;
    return mat44(vec4(xscale, 0.0f, 0.0f, 0.0f), vec4(0.0f, yscale, 0.0f, 0.0f), vec4(0.0f, 0.0f, zf / (zf - zn), 1.0f), vec4(0.0f, 0.0f, -zn * zf / (zf - zn), 0.0f));
}

mat44_t mat44_perspective_fov_rh(f32 fovy, f32 aspect, f32 zn, f32 zf) {
    f32 yscale = 1.0f / vecmath_tan(fovy * 0.5f);
    f32 xscale = yscale / aspect;
    return mat44(vec4(xscale, 0.0f, 0.0f, 0.0f), vec4(0.0f, yscale, 0.0f, 0.0f), vec4(0.0f, 0.0f, zf / (zn - zf), -1.0f), vec4(0.0f, 0.0f, zn * zf / (zn - zf), 0.0f));
}

mat44_t mat44_rotation_axis(vec3_t axis, f32 angle) {
    axis = vec3_normalize(axis);
    f32 s = vecmath_sin(angle);
    f32 c = vecmath_cos(angle);
    f32 ic = 1.0f - c;
    f32 xyic = axis.x * axis.y * ic;
    f32 xzic = axis.x * axis.z * ic;
    f32 yzic = axis.y * axis.z * ic;
    f32 xs = axis.x * s;
    f32 ys = axis.y * s;
    f32 zs = axis.z * s;
    return mat44(vec4(c + axis.x * axis.x * ic, xyic + zs, xzic - ys, 0.0f), vec4(xyic - zs, c + axis.y * axis.y * ic, yzic + xs, 0.0f), vec4(xzic + ys, yzic - xs, c + axis.z * axis.z * ic, 0.0f), vec4(0.0f, 0.0f, 0.0f, 1.0f));
}

mat44_t mat44_rotation_x(f32 angle) {
    f32 s = vecmath_sin(angle);
    f32 c = vecmath_cos(angle);
    return mat44(vec4(1.0f, 0.0f, 0.0f, 0.0f), vec4(0.0f, c, s, 0.0f), vec4(0.0f, -s, c, 0.0f), vec4(0.0f, 0.0f, 0.0f, 1.0f));
}

mat44_t mat44_rotation_y(f32 angle) {
    f32 s = vecmath_sin(angle);
    f32 c = vecmath_cos(angle);
    return mat44(vec4(c, 0.0f, -s, 0.0f), vec4(0.0f, 1.0f, 0.0f, 0.0f), vec4(s, 0.0f, c, 0.0f), vec4(0.0f, 0.0f, 0.0f, 1.0f));
}

mat44_t mat44_rotation_z(f32 angle) {
    f32 s = vecmath_sin(angle);
    f32 c = vecmath_cos(angle);
    return mat44(vec4(c, s, 0.0f, 0.0f), vec4(-s, c, 0.0f, 0.0f), vec4(0.0f, 0.0f, 1.0f, 0.0f), vec4(0.0f, 0.0f, 0.0f, 1.0f));
}

mat44_t mat44_rotation_yaw_pitch_roll(f32 yaw, f32 pitch, f32 roll) {
    return mat44_mul_mat44(mat44_mul_mat44(mat44_rotation_z(roll), mat44_rotation_x(pitch)), mat44_rotation_y(yaw));
}

mat44_t mat44_scaling(f32 sx, f32 sy, f32 sz) {
    return mat44(vec4(sx, 0.0f, 0.0f, 0.0f), vec4(0.0f, sy, 0.0f, 0.0f), vec4(0.0f, 0.0f, sz, 0.0f), vec4(0.0f, 0.0f, 0.0f, 1.0f));
}

mat44_t mat44_translation(f32 tx, f32 ty, f32 tz) {
    return mat44(vec4(1.0f, 0.0f, 0.0f, 0.0f), vec4(0.0f, 1.0f, 0.0f, 0.0f), vec4(0.0f, 0.0f, 1.0f, 0.0f), vec4(tx, ty, tz, 1.0f));
}

i32 mat44_decompose(vec3_t* out_scale, vec4_t* out_rotation, vec3_t* out_translation, mat44_t m) {
    vec3_t x = vec3(m.x.x, m.x.y, m.x.z);
    vec3_t y = vec3(m.y.x, m.y.y, m.y.z);
    vec3_t z = vec3(m.z.x, m.z.y, m.z.z);
    f32 sx = vec3_length(x);
    f32 sy = vec3_length(y);
    f32 sz = vec3_length(z);
    i32 i0;
    i32 i1;
    i32 i2;
    if sx < sy {
        if sy < sz {
            i0 = 2;
            i1 = 1;
            i2 = 0;
        } else {
            i0 = 1;
            if sx < sz {
                i1 = 2;
                i2 = 0;
            } else {
                i1 = 0;
                i2 = 2;
            }
        }
    } else {
        if sx < sz {
            i0 = 2;
            i1 = 0;
            i2 = 1;
        } else {
            i0 = 0;
            if sy < sz {
                i1 = 2;
                i2 = 1;
            } else {
                i1 = 1;
                i2 = 2;
            }
        }
    }
    vec3_t*[3] v = {&x, &y, &z};
    f32*[3] s = {&sx, &sy, &sz};
    if *s[i0] < 0.0001f {
        *v[i0] = vec3(i0 == 0 ? 1.0f : 0.0f, i0 == 1 ? 1.0f : 0.0f, i0 == 2 ? 1.0f : 0.0f);
    }
    *v[i0] = vec3_normalize(*v[i0]);
    if *s[i1] < 0.0001f {
        f32 ax = vecmath_abs(v[i0].x);
        f32 ay = vecmath_abs(v[i0].y);
        f32 az = vecmath_abs(v[i0].z);
        i32 j2;
        if ax < ay {
            if ay < az {
                j2 = 0;
            } else {
                if ax < az {
                    j2 = 0;
                } else {
                    j2 = 2;
                }
            }
        } else {
            if ax < az {
                j2 = 1;
            } else {
                if ay < az {
                    j2 = 1;
                } else {
                    j2 = 2;
                }
            }
        }
        *v[i1] = vec3_cross(*v[i0], vec3(j2 == 0 ? 1.0f : 0.0f, j2 == 1 ? 1.0f : 0.0f, j2 == 2 ? 1.0f : 0.0f));
    }
    *v[i1] = vec3_normalize(*v[i1]);
    if *s[i2] < 0.0001f {
        *v[i2] = vec3_cross(*v[i0], *v[i1]);
    }
    *v[i2] = vec3_normalize(*v[i2]);
    f32 det = vec3_dot(x, vec3_cross(y, z));
    if det < 0.0f {
        *s[i0] = -*s[i0];
        *v[i0] = vec3_neg(*v[i0]);
        det = -det;
    }
    if vecmath_abs(det - 1.0f) > 0.0001f {
        return 0;
    }
    f32 trace = x.x + y.y + z.z;
    f32 w;
    f32 qx;
    f32 qy;
    f32 qz;
    if trace > 0.0f {
        f32 r = vecmath_sqrt(trace + 1.0f) * 2.0f;
        w = 0.25f * r;
        qx = (z.y - y.z) / r;
        qy = (x.z - z.x) / r;
        qz = (y.x - x.y) / r;
    } else if x.x > y.y && x.x > z.z {
        f32 r = vecmath_sqrt(1.0f + x.x - y.y - z.z) * 2.0f;
        w = (z.y - y.z) / r;
        qx = 0.25f * r;
        qy = (x.y + y.x) / r;
        qz = (x.z + z.x) / r;
    } else if y.y > z.z {
        f32 r = vecmath_sqrt(1.0f + y.y - x.x - z.z) * 2.0f;
        w = (x.z - z.x) / r;
        qx = (x.y + y.x) / r;
        qy = 0.25f * r;
        qz = (y.z + z.y) / r;
    } else {
        f32 r = vecmath_sqrt(1.0f + z.z - x.x - y.y) * 2.0f;
        w = (y.x - x.y) / r;
        qx = (x.z + z.x) / r;
        qy = (y.z + z.y) / r;
        qz = 0.25f * r;
    }
    if out_translation != null {
        *out_translation = vec3(m.w.x, m.w.y, m.w.z);
    }
    if out_rotation != null {
        *out_rotation = vec4(qx, qy, qz, w);
    }
    if out_scale != null {
        *out_scale = vec3(sx, sy, sz);
    }
    return 1;
}

vec4_t vec2_transform(vec2_t v, mat44_t m) {
    return vec4_mul_mat44(vec4(v.x, v.y, 0.0f, 1.0f), m);
}

vec2_t vec2_transform_coord(vec2_t v, mat44_t m) {
    vec4_t t = vec4_mul_mat44(vec4(v.x, v.y, 0.0f, 1.0f), m);
    return vec2(t.x / t.w, t.y / t.w);
}

vec2_t vec2_transform_normal(vec2_t v, mat44_t m) {
    vec4_t t = vec4_mul_mat44(vec4(v.x, v.y, 0.0f, 0.0f), m);
    return vec2(t.x, t.y);
}

vec4_t vec3_transform(vec3_t v, mat44_t m) {
    return vec4_mul_mat44(vec4(v.x, v.y, v.z, 1.0f), m);
}

vec3_t vec3_transform_coord(vec3_t v, mat44_t m) {
    vec4_t t = vec4_mul_mat44(vec4(v.x, v.y, v.z, 1.0f), m);
    return vec3(t.x / t.w, t.y / t.w, t.z / t.w);
}

vec3_t vec3_transform_normal(vec3_t v, mat44_t m) {
    vec4_t t = vec4_mul_mat44(vec4(v.x, v.y, v.z, 0.0f), m);
    return vec3(t.x, t.y, t.z);
}

vec4_t vec4_transform(vec4_t v, mat44_t m) {
    return vec4_mul_mat44(v, m);
}

// swizzling
vec2_t vec2_xx(vec2_t v) {
    return vec2(v.x, v.x);
}

vec2_t vec2_xy(vec2_t v) {
    return vec2(v.x, v.y);
}

vec2_t vec2_yx(vec2_t v) {
    return vec2(v.y, v.x);
}

vec2_t vec2_yy(vec2_t v) {
    return vec2(v.y, v.y);
}

vec2_t vec3_xx(vec3_t v) {
    return vec2(v.x, v.x);
}

vec2_t vec3_xy(vec3_t v) {
    return vec2(v.x, v.y);
}

vec2_t vec3_xz(vec3_t v) {
    return vec2(v.x, v.z);
}

vec2_t vec3_yx(vec3_t v) {
    return vec2(v.y, v.x);
}

vec2_t vec3_yy(vec3_t v) {
    return vec2(v.y, v.y);
}

vec2_t vec3_yz(vec3_t v) {
    return vec2(v.y, v.z);
}

vec2_t vec3_zx(vec3_t v) {
    return vec2(v.z, v.x);
}

vec2_t vec3_zy(vec3_t v) {
    return vec2(v.z, v.y);
}

vec2_t vec3_zz(vec3_t v) {
    return vec2(v.z, v.z);
}

vec2_t vec4_xx(vec4_t v) {
    return vec2(v.x, v.x);
}

vec2_t vec4_xy(vec4_t v) {
    return vec2(v.x, v.y);
}

vec2_t vec4_xz(vec4_t v) {
    return vec2(v.x, v.z);
}

vec2_t vec4_xw(vec4_t v) {
    return vec2(v.x, v.w);
}

vec2_t vec4_yx(vec4_t v) {
    return vec2(v.y, v.x);
}

vec2_t vec4_yy(vec4_t v) {
    return vec2(v.y, v.y);
}

vec2_t vec4_yz(vec4_t v) {
    return vec2(v.y, v.z);
}

vec2_t vec4_yw(vec4_t v) {
    return vec2(v.y, v.w);
}

vec2_t vec4_zx(vec4_t v) {
    return vec2(v.z, v.x);
}

vec2_t vec4_zy(vec4_t v) {
    return vec2(v.z, v.y);
}

vec2_t vec4_zz(vec4_t v) {
    return vec2(v.z, v.z);
}

vec2_t vec4_zw(vec4_t v) {
    return vec2(v.z, v.w);
}

vec2_t vec4_wx(vec4_t v) {
    return vec2(v.w, v.x);
}

vec2_t vec4_wy(vec4_t v) {
    return vec2(v.w, v.y);
}

vec2_t vec4_wz(vec4_t v) {
    return vec2(v.w, v.z);
}

vec2_t vec4_ww(vec4_t v) {
    return vec2(v.w, v.w);
}

vec3_t vec2_xxx(vec2_t v) {
    return vec3(v.x, v.x, v.x);
}

vec3_t vec2_xxy(vec2_t v) {
    return vec3(v.x, v.x, v.y);
}

vec3_t vec2_xyx(vec2_t v) {
    return vec3(v.x, v.y, v.x);
}

vec3_t vec2_xyy(vec2_t v) {
    return vec3(v.x, v.y, v.y);
}

vec3_t vec2_yxx(vec2_t v) {
    return vec3(v.y, v.x, v.x);
}

vec3_t vec2_yxy(vec2_t v) {
    return vec3(v.y, v.x, v.y);
}

vec3_t vec2_yyx(vec2_t v) {
    return vec3(v.y, v.y, v.x);
}

vec3_t vec2_yyy(vec2_t v) {
    return vec3(v.y, v.y, v.y);
}

vec3_t vec3_xxx(vec3_t v) {
    return vec3(v.x, v.x, v.x);
}

vec3_t vec3_xxy(vec3_t v) {
    return vec3(v.x, v.x, v.y);
}

vec3_t vec3_xxz(vec3_t v) {
    return vec3(v.x, v.x, v.z);
}

vec3_t vec3_xyx(vec3_t v) {
    return vec3(v.x, v.y, v.x);
}

vec3_t vec3_xyy(vec3_t v) {
    return vec3(v.x, v.y, v.y);
}

vec3_t vec3_xyz(vec3_t v) {
    return vec3(v.x, v.y, v.z);
}

vec3_t vec3_xzx(vec3_t v) {
    return vec3(v.x, v.z, v.x);
}

vec3_t vec3_xzy(vec3_t v) {
    return vec3(v.x, v.z, v.y);
}

vec3_t vec3_xzz(vec3_t v) {
    return vec3(v.x, v.z, v.z);
}

vec3_t vec3_yxx(vec3_t v) {
    return vec3(v.y, v.x, v.x);
}

vec3_t vec3_yxy(vec3_t v) {
    return vec3(v.y, v.x, v.y);
}

vec3_t vec3_yxz(vec3_t v) {
    return vec3(v.y, v.x, v.z);
}

vec3_t vec3_yyx(vec3_t v) {
    return vec3(v.y, v.y, v.x);
}

vec3_t vec3_yyy(vec3_t v) {
    return vec3(v.y, v.y, v.y);
}

vec3_t vec3_yyz(vec3_t v) {
    return vec3(v.y, v.y, v.z);
}

vec3_t vec3_yzx(vec3_t v) {
    return vec3(v.y, v.z, v.x);
}

vec3_t vec3_yzy(vec3_t v) {
    return vec3(v.y, v.z, v.y);
}

vec3_t vec3_yzz(vec3_t v) {
    return vec3(v.y, v.z, v.z);
}

vec3_t vec3_zxx(vec3_t v) {
    return vec3(v.z, v.x, v.x);
}

vec3_t vec3_zxy(vec3_t v) {
    return vec3(v.z, v.x, v.y);
}

vec3_t vec3_zxz(vec3_t v) {
    return vec3(v.z, v.x, v.z);
}

vec3_t vec3_zyx(vec3_t v) {
    return vec3(v.z, v.y, v.x);
}

vec3_t vec3_zyy(vec3_t v) {
    return vec3(v.z, v.y, v.y);
}

vec3_t vec3_zyz(vec3_t v) {
    return vec3(v.z, v.y, v.z);
}

vec3_t vec3_zzx(vec3_t v) {
    return vec3(v.z, v.z, v.x);
}

vec3_t vec3_zzy(vec3_t v) {
    return vec3(v.z, v.z, v.y);
}

vec3_t vec3_zzz(vec3_t v) {
    return vec3(v.z, v.z, v.z);
}

vec3_t vec4_xxx(vec4_t v) {
    return vec3(v.x, v.x, v.x);
}

vec3_t vec4_xxy(vec4_t v) {
    return vec3(v.x, v.x, v.y);
}

vec3_t vec4_xxz(vec4_t v) {
    return vec3(v.x, v.x, v.z);
}

vec3_t vec4_xxw(vec4_t v) {
    return vec3(v.x, v.x, v.w);
}

vec3_t vec4_xyx(vec4_t v) {
    return vec3(v.x, v.y, v.x);
}

vec3_t vec4_xyy(vec4_t v) {
    return vec3(v.x, v.y, v.y);
}

vec3_t vec4_xyz(vec4_t v) {
    return vec3(v.x, v.y, v.z);
}

vec3_t vec4_xyw(vec4_t v) {
    return vec3(v.x, v.y, v.w);
}

vec3_t vec4_xzx(vec4_t v) {
    return vec3(v.x, v.z, v.x);
}

vec3_t vec4_xzy(vec4_t v) {
    return vec3(v.x, v.z, v.y);
}

vec3_t vec4_xzz(vec4_t v) {
    return vec3(v.x, v.z, v.z);
}

vec3_t vec4_xzw(vec4_t v) {
    return vec3(v.x, v.z, v.w);
}

vec3_t vec4_xwx(vec4_t v) {
    return vec3(v.x, v.w, v.x);
}

vec3_t vec4_xwy(vec4_t v) {
    return vec3(v.x, v.w, v.y);
}

vec3_t vec4_xwz(vec4_t v) {
    return vec3(v.x, v.w, v.z);
}

vec3_t vec4_xww(vec4_t v) {
    return vec3(v.x, v.w, v.w);
}

vec3_t vec4_yxx(vec4_t v) {
    return vec3(v.y, v.x, v.x);
}

vec3_t vec4_yxy(vec4_t v) {
    return vec3(v.y, v.x, v.y);
}

vec3_t vec4_yxz(vec4_t v) {
    return vec3(v.y, v.x, v.z);
}

vec3_t vec4_yxw(vec4_t v) {
    return vec3(v.y, v.x, v.w);
}

vec3_t vec4_yyx(vec4_t v) {
    return vec3(v.y, v.y, v.x);
}

vec3_t vec4_yyy(vec4_t v) {
    return vec3(v.y, v.y, v.y);
}

vec3_t vec4_yyz(vec4_t v) {
    return vec3(v.y, v.y, v.z);
}

vec3_t vec4_yyw(vec4_t v) {
    return vec3(v.y, v.y, v.w);
}

vec3_t vec4_yzx(vec4_t v) {
    return vec3(v.y, v.z, v.x);
}

vec3_t vec4_yzy(vec4_t v) {
    return vec3(v.y, v.z, v.y);
}

vec3_t vec4_yzz(vec4_t v) {
    return vec3(v.y, v.z, v.z);
}

vec3_t vec4_yzw(vec4_t v) {
    return vec3(v.y, v.z, v.w);
}

vec3_t vec4_ywx(vec4_t v) {
    return vec3(v.y, v.w, v.x);
}

vec3_t vec4_ywy(vec4_t v) {
    return vec3(v.y, v.w, v.y);
}

vec3_t vec4_ywz(vec4_t v) {
    return vec3(v.y, v.w, v.z);
}

vec3_t vec4_yww(vec4_t v) {
    return vec3(v.y, v.w, v.w);
}

vec3_t vec4_zxx(vec4_t v) {
    return vec3(v.z, v.x, v.x);
}

vec3_t vec4_zxy(vec4_t v) {
    return vec3(v.z, v.x, v.y);
}

vec3_t vec4_zxz(vec4_t v) {
    return vec3(v.z, v.x, v.z);
}

vec3_t vec4_zxw(vec4_t v) {
    return vec3(v.z, v.x, v.w);
}

vec3_t vec4_zyx(vec4_t v) {
    return vec3(v.z, v.y, v.x);
}

vec3_t vec4_zyy(vec4_t v) {
    return vec3(v.z, v.y, v.y);
}

vec3_t vec4_zyz(vec4_t v) {
    return vec3(v.z, v.y, v.z);
}

vec3_t vec4_zyw(vec4_t v) {
    return vec3(v.z, v.y, v.w);
}

vec3_t vec4_zzx(vec4_t v) {
    return vec3(v.z, v.z, v.x);
}

vec3_t vec4_zzy(vec4_t v) {
    return vec3(v.z, v.z, v.y);
}

vec3_t vec4_zzz(vec4_t v) {
    return vec3(v.z, v.z, v.z);
}

vec3_t vec4_zzw(vec4_t v) {
    return vec3(v.z, v.z, v.w);
}

vec3_t vec4_zwx(vec4_t v) {
    return vec3(v.z, v.w, v.x);
}

vec3_t vec4_zwy(vec4_t v) {
    return vec3(v.z, v.w, v.y);
}

vec3_t vec4_zwz(vec4_t v) {
    return vec3(v.z, v.w, v.z);
}

vec3_t vec4_zww(vec4_t v) {
    return vec3(v.z, v.w, v.w);
}

vec3_t vec4_wxx(vec4_t v) {
    return vec3(v.w, v.x, v.x);
}

vec3_t vec4_wxy(vec4_t v) {
    return vec3(v.w, v.x, v.y);
}

vec3_t vec4_wxz(vec4_t v) {
    return vec3(v.w, v.x, v.z);
}

vec3_t vec4_wxw(vec4_t v) {
    return vec3(v.w, v.x, v.w);
}

vec3_t vec4_wyx(vec4_t v) {
    return vec3(v.w, v.y, v.x);
}

vec3_t vec4_wyy(vec4_t v) {
    return vec3(v.w, v.y, v.y);
}

vec3_t vec4_wyz(vec4_t v) {
    return vec3(v.w, v.y, v.z);
}

vec3_t vec4_wyw(vec4_t v) {
    return vec3(v.w, v.y, v.w);
}

vec3_t vec4_wzx(vec4_t v) {
    return vec3(v.w, v.z, v.x);
}

vec3_t vec4_wzy(vec4_t v) {
    return vec3(v.w, v.z, v.y);
}

vec3_t vec4_wzz(vec4_t v) {
    return vec3(v.w, v.z, v.z);
}

vec3_t vec4_wzw(vec4_t v) {
    return vec3(v.w, v.z, v.w);
}

vec3_t vec4_wwx(vec4_t v) {
    return vec3(v.w, v.w, v.x);
}

vec3_t vec4_wwy(vec4_t v) {
    return vec3(v.w, v.w, v.y);
}

vec3_t vec4_wwz(vec4_t v) {
    return vec3(v.w, v.w, v.z);
}

vec3_t vec4_www(vec4_t v) {
    return vec3(v.w, v.w, v.w);
}

vec4_t vec2_xxxx(vec2_t v) {
    return vec4(v.x, v.x, v.x, v.x);
}

vec4_t vec2_xxxy(vec2_t v) {
    return vec4(v.x, v.x, v.x, v.y);
}

vec4_t vec2_xxyx(vec2_t v) {
    return vec4(v.x, v.x, v.y, v.x);
}

vec4_t vec2_xxyy(vec2_t v) {
    return vec4(v.x, v.x, v.y, v.y);
}

vec4_t vec2_xyxx(vec2_t v) {
    return vec4(v.x, v.y, v.x, v.x);
}

vec4_t vec2_xyxy(vec2_t v) {
    return vec4(v.x, v.y, v.x, v.y);
}

vec4_t vec2_xyyx(vec2_t v) {
    return vec4(v.x, v.y, v.y, v.x);
}

vec4_t vec2_xyyy(vec2_t v) {
    return vec4(v.x, v.y, v.y, v.y);
}

vec4_t vec2_yxxx(vec2_t v) {
    return vec4(v.y, v.x, v.x, v.x);
}

vec4_t vec2_yxxy(vec2_t v) {
    return vec4(v.y, v.x, v.x, v.y);
}

vec4_t vec2_yxyx(vec2_t v) {
    return vec4(v.y, v.x, v.y, v.x);
}

vec4_t vec2_yxyy(vec2_t v) {
    return vec4(v.y, v.x, v.y, v.y);
}

vec4_t vec2_yyxx(vec2_t v) {
    return vec4(v.y, v.y, v.x, v.x);
}

vec4_t vec2_yyxy(vec2_t v) {
    return vec4(v.y, v.y, v.x, v.y);
}

vec4_t vec2_yyyx(vec2_t v) {
    return vec4(v.y, v.y, v.y, v.x);
}

vec4_t vec2_yyyy(vec2_t v) {
    return vec4(v.y, v.y, v.y, v.y);
}

vec4_t vec3_xxxx(vec3_t v) {
    return vec4(v.x, v.x, v.x, v.x);
}

vec4_t vec3_xxxy(vec3_t v) {
    return vec4(v.x, v.x, v.x, v.y);
}

vec4_t vec3_xxxz(vec3_t v) {
    return vec4(v.x, v.x, v.x, v.z);
}

vec4_t vec3_xxyx(vec3_t v) {
    return vec4(v.x, v.x, v.y, v.x);
}

vec4_t vec3_xxyy(vec3_t v) {
    return vec4(v.x, v.x, v.y, v.y);
}

vec4_t vec3_xxyz(vec3_t v) {
    return vec4(v.x, v.x, v.y, v.z);
}

vec4_t vec3_xxzx(vec3_t v) {
    return vec4(v.x, v.x, v.z, v.x);
}

vec4_t vec3_xxzy(vec3_t v) {
    return vec4(v.x, v.x, v.z, v.y);
}

vec4_t vec3_xxzz(vec3_t v) {
    return vec4(v.x, v.x, v.z, v.z);
}

vec4_t vec3_xyxx(vec3_t v) {
    return vec4(v.x, v.y, v.x, v.x);
}

vec4_t vec3_xyxy(vec3_t v) {
    return vec4(v.x, v.y, v.x, v.y);
}

vec4_t vec3_xyxz(vec3_t v) {
    return vec4(v.x, v.y, v.x, v.z);
}

vec4_t vec3_xyyx(vec3_t v) {
    return vec4(v.x, v.y, v.y, v.x);
}

vec4_t vec3_xyyy(vec3_t v) {
    return vec4(v.x, v.y, v.y, v.y);
}

vec4_t vec3_xyyz(vec3_t v) {
    return vec4(v.x, v.y, v.y, v.z);
}

vec4_t vec3_xyzx(vec3_t v) {
    return vec4(v.x, v.y, v.z, v.x);
}

vec4_t vec3_xyzy(vec3_t v) {
    return vec4(v.x, v.y, v.z, v.y);
}

vec4_t vec3_xyzz(vec3_t v) {
    return vec4(v.x, v.y, v.z, v.z);
}

vec4_t vec3_xzxx(vec3_t v) {
    return vec4(v.x, v.z, v.x, v.x);
}

vec4_t vec3_xzxy(vec3_t v) {
    return vec4(v.x, v.z, v.x, v.y);
}

vec4_t vec3_xzxz(vec3_t v) {
    return vec4(v.x, v.z, v.x, v.z);
}

vec4_t vec3_xzyx(vec3_t v) {
    return vec4(v.x, v.z, v.y, v.x);
}

vec4_t vec3_xzyy(vec3_t v) {
    return vec4(v.x, v.z, v.y, v.y);
}

vec4_t vec3_xzyz(vec3_t v) {
    return vec4(v.x, v.z, v.y, v.z);
}

vec4_t vec3_xzzx(vec3_t v) {
    return vec4(v.x, v.z, v.z, v.x);
}

vec4_t vec3_xzzy(vec3_t v) {
    return vec4(v.x, v.z, v.z, v.y);
}

vec4_t vec3_xzzz(vec3_t v) {
    return vec4(v.x, v.z, v.z, v.z);
}

vec4_t vec3_yxxx(vec3_t v) {
    return vec4(v.y, v.x, v.x, v.x);
}

vec4_t vec3_yxxy(vec3_t v) {
    return vec4(v.y, v.x, v.x, v.y);
}

vec4_t vec3_yxxz(vec3_t v) {
    return vec4(v.y, v.x, v.x, v.z);
}

vec4_t vec3_yxyx(vec3_t v) {
    return vec4(v.y, v.x, v.y, v.x);
}

vec4_t vec3_yxyy(vec3_t v) {
    return vec4(v.y, v.x, v.y, v.y);
}

vec4_t vec3_yxyz(vec3_t v) {
    return vec4(v.y, v.x, v.y, v.z);
}

vec4_t vec3_yxzx(vec3_t v) {
    return vec4(v.y, v.x, v.z, v.x);
}

vec4_t vec3_yxzy(vec3_t v) {
    return vec4(v.y, v.x, v.z, v.y);
}

vec4_t vec3_yxzz(vec3_t v) {
    return vec4(v.y, v.x, v.z, v.z);
}

vec4_t vec3_yyxx(vec3_t v) {
    return vec4(v.y, v.y, v.x, v.x);
}

vec4_t vec3_yyxy(vec3_t v) {
    return vec4(v.y, v.y, v.x, v.y);
}

vec4_t vec3_yyxz(vec3_t v) {
    return vec4(v.y, v.y, v.x, v.z);
}

vec4_t vec3_yyyx(vec3_t v) {
    return vec4(v.y, v.y, v.y, v.x);
}

vec4_t vec3_yyyy(vec3_t v) {
    return vec4(v.y, v.y, v.y, v.y);
}

vec4_t vec3_yyyz(vec3_t v) {
    return vec4(v.y, v.y, v.y, v.z);
}

vec4_t vec3_yyzx(vec3_t v) {
    return vec4(v.y, v.y, v.z, v.x);
}

vec4_t vec3_yyzy(vec3_t v) {
    return vec4(v.y, v.y, v.z, v.y);
}

vec4_t vec3_yyzz(vec3_t v) {
    return vec4(v.y, v.y, v.z, v.z);
}

vec4_t vec3_yzxx(vec3_t v) {
    return vec4(v.y, v.z, v.x, v.x);
}

vec4_t vec3_yzxy(vec3_t v) {
    return vec4(v.y, v.z, v.x, v.y);
}

vec4_t vec3_yzxz(vec3_t v) {
    return vec4(v.y, v.z, v.x, v.z);
}

vec4_t vec3_yzyx(vec3_t v) {
    return vec4(v.y, v.z, v.y, v.x);
}

vec4_t vec3_yzyy(vec3_t v) {
    return vec4(v.y, v.z, v.y, v.y);
}

vec4_t vec3_yzyz(vec3_t v) {
    return vec4(v.y, v.z, v.y, v.z);
}

vec4_t vec3_yzzx(vec3_t v) {
    return vec4(v.y, v.z, v.z, v.x);
}

vec4_t vec3_yzzy(vec3_t v) {
    return vec4(v.y, v.z, v.z, v.y);
}

vec4_t vec3_yzzz(vec3_t v) {
    return vec4(v.y, v.z, v.z, v.z);
}

vec4_t vec3_zxxx(vec3_t v) {
    return vec4(v.z, v.x, v.x, v.x);
}

vec4_t vec3_zxxy(vec3_t v) {
    return vec4(v.z, v.x, v.x, v.y);
}

vec4_t vec3_zxxz(vec3_t v) {
    return vec4(v.z, v.x, v.x, v.z);
}

vec4_t vec3_zxyx(vec3_t v) {
    return vec4(v.z, v.x, v.y, v.x);
}

vec4_t vec3_zxyy(vec3_t v) {
    return vec4(v.z, v.x, v.y, v.y);
}

vec4_t vec3_zxyz(vec3_t v) {
    return vec4(v.z, v.x, v.y, v.z);
}

vec4_t vec3_zxzx(vec3_t v) {
    return vec4(v.z, v.x, v.z, v.x);
}

vec4_t vec3_zxzy(vec3_t v) {
    return vec4(v.z, v.x, v.z, v.y);
}

vec4_t vec3_zxzz(vec3_t v) {
    return vec4(v.z, v.x, v.z, v.z);
}

vec4_t vec3_zyxx(vec3_t v) {
    return vec4(v.z, v.y, v.x, v.x);
}

vec4_t vec3_zyxy(vec3_t v) {
    return vec4(v.z, v.y, v.x, v.y);
}

vec4_t vec3_zyxz(vec3_t v) {
    return vec4(v.z, v.y, v.x, v.z);
}

vec4_t vec3_zyyx(vec3_t v) {
    return vec4(v.z, v.y, v.y, v.x);
}

vec4_t vec3_zyyy(vec3_t v) {
    return vec4(v.z, v.y, v.y, v.y);
}

vec4_t vec3_zyyz(vec3_t v) {
    return vec4(v.z, v.y, v.y, v.z);
}

vec4_t vec3_zyzx(vec3_t v) {
    return vec4(v.z, v.y, v.z, v.x);
}

vec4_t vec3_zyzy(vec3_t v) {
    return vec4(v.z, v.y, v.z, v.y);
}

vec4_t vec3_zyzz(vec3_t v) {
    return vec4(v.z, v.y, v.z, v.z);
}

vec4_t vec3_zzxx(vec3_t v) {
    return vec4(v.z, v.z, v.x, v.x);
}

vec4_t vec3_zzxy(vec3_t v) {
    return vec4(v.z, v.z, v.x, v.y);
}

vec4_t vec3_zzxz(vec3_t v) {
    return vec4(v.z, v.z, v.x, v.z);
}

vec4_t vec3_zzyx(vec3_t v) {
    return vec4(v.z, v.z, v.y, v.x);
}

vec4_t vec3_zzyy(vec3_t v) {
    return vec4(v.z, v.z, v.y, v.y);
}

vec4_t vec3_zzyz(vec3_t v) {
    return vec4(v.z, v.z, v.y, v.z);
}

vec4_t vec3_zzzx(vec3_t v) {
    return vec4(v.z, v.z, v.z, v.x);
}

vec4_t vec3_zzzy(vec3_t v) {
    return vec4(v.z, v.z, v.z, v.y);
}

vec4_t vec3_zzzz(vec3_t v) {
    return vec4(v.z, v.z, v.z, v.z);
}

vec4_t vec4_xxxx(vec4_t v) {
    return vec4(v.x, v.x, v.x, v.x);
}

vec4_t vec4_xxxy(vec4_t v) {
    return vec4(v.x, v.x, v.x, v.y);
}

vec4_t vec4_xxxz(vec4_t v) {
    return vec4(v.x, v.x, v.x, v.z);
}

vec4_t vec4_xxxw(vec4_t v) {
    return vec4(v.x, v.x, v.x, v.w);
}

vec4_t vec4_xxyx(vec4_t v) {
    return vec4(v.x, v.x, v.y, v.x);
}

vec4_t vec4_xxyy(vec4_t v) {
    return vec4(v.x, v.x, v.y, v.y);
}

vec4_t vec4_xxyz(vec4_t v) {
    return vec4(v.x, v.x, v.y, v.z);
}

vec4_t vec4_xxyw(vec4_t v) {
    return vec4(v.x, v.x, v.y, v.w);
}

vec4_t vec4_xxzx(vec4_t v) {
    return vec4(v.x, v.x, v.z, v.x);
}

vec4_t vec4_xxzy(vec4_t v) {
    return vec4(v.x, v.x, v.z, v.y);
}

vec4_t vec4_xxzz(vec4_t v) {
    return vec4(v.x, v.x, v.z, v.z);
}

vec4_t vec4_xxzw(vec4_t v) {
    return vec4(v.x, v.x, v.z, v.w);
}

vec4_t vec4_xxwx(vec4_t v) {
    return vec4(v.x, v.x, v.w, v.x);
}

vec4_t vec4_xxwy(vec4_t v) {
    return vec4(v.x, v.x, v.w, v.y);
}

vec4_t vec4_xxwz(vec4_t v) {
    return vec4(v.x, v.x, v.w, v.z);
}

vec4_t vec4_xxww(vec4_t v) {
    return vec4(v.x, v.x, v.w, v.w);
}

vec4_t vec4_xyxx(vec4_t v) {
    return vec4(v.x, v.y, v.x, v.x);
}

vec4_t vec4_xyxy(vec4_t v) {
    return vec4(v.x, v.y, v.x, v.y);
}

vec4_t vec4_xyxz(vec4_t v) {
    return vec4(v.x, v.y, v.x, v.z);
}

vec4_t vec4_xyxw(vec4_t v) {
    return vec4(v.x, v.y, v.x, v.w);
}

vec4_t vec4_xyyx(vec4_t v) {
    return vec4(v.x, v.y, v.y, v.x);
}

vec4_t vec4_xyyy(vec4_t v) {
    return vec4(v.x, v.y, v.y, v.y);
}

vec4_t vec4_xyyz(vec4_t v) {
    return vec4(v.x, v.y, v.y, v.z);
}

vec4_t vec4_xyyw(vec4_t v) {
    return vec4(v.x, v.y, v.y, v.w);
}

vec4_t vec4_xyzx(vec4_t v) {
    return vec4(v.x, v.y, v.z, v.x);
}

vec4_t vec4_xyzy(vec4_t v) {
    return vec4(v.x, v.y, v.z, v.y);
}

vec4_t vec4_xyzz(vec4_t v) {
    return vec4(v.x, v.y, v.z, v.z);
}

vec4_t vec4_xyzw(vec4_t v) {
    return vec4(v.x, v.y, v.z, v.w);
}

vec4_t vec4_xywx(vec4_t v) {
    return vec4(v.x, v.y, v.w, v.x);
}

vec4_t vec4_xywy(vec4_t v) {
    return vec4(v.x, v.y, v.w, v.y);
}

vec4_t vec4_xywz(vec4_t v) {
    return vec4(v.x, v.y, v.w, v.z);
}

vec4_t vec4_xyww(vec4_t v) {
    return vec4(v.x, v.y, v.w, v.w);
}

vec4_t vec4_xzxx(vec4_t v) {
    return vec4(v.x, v.z, v.x, v.x);
}

vec4_t vec4_xzxy(vec4_t v) {
    return vec4(v.x, v.z, v.x, v.y);
}

vec4_t vec4_xzxz(vec4_t v) {
    return vec4(v.x, v.z, v.x, v.z);
}

vec4_t vec4_xzxw(vec4_t v) {
    return vec4(v.x, v.z, v.x, v.w);
}

vec4_t vec4_xzyx(vec4_t v) {
    return vec4(v.x, v.z, v.y, v.x);
}

vec4_t vec4_xzyy(vec4_t v) {
    return vec4(v.x, v.z, v.y, v.y);
}

vec4_t vec4_xzyz(vec4_t v) {
    return vec4(v.x, v.z, v.y, v.z);
}

vec4_t vec4_xzyw(vec4_t v) {
    return vec4(v.x, v.z, v.y, v.w);
}

vec4_t vec4_xzzx(vec4_t v) {
    return vec4(v.x, v.z, v.z, v.x);
}

vec4_t vec4_xzzy(vec4_t v) {
    return vec4(v.x, v.z, v.z, v.y);
}

vec4_t vec4_xzzz(vec4_t v) {
    return vec4(v.x, v.z, v.z, v.z);
}

vec4_t vec4_xzzw(vec4_t v) {
    return vec4(v.x, v.z, v.z, v.w);
}

vec4_t vec4_xzwx(vec4_t v) {
    return vec4(v.x, v.z, v.w, v.x);
}

vec4_t vec4_xzwy(vec4_t v) {
    return vec4(v.x, v.z, v.w, v.y);
}

vec4_t vec4_xzwz(vec4_t v) {
    return vec4(v.x, v.z, v.w, v.z);
}

vec4_t vec4_xzww(vec4_t v) {
    return vec4(v.x, v.z, v.w, v.w);
}

vec4_t vec4_xwxx(vec4_t v) {
    return vec4(v.x, v.w, v.x, v.x);
}

vec4_t vec4_xwxy(vec4_t v) {
    return vec4(v.x, v.w, v.x, v.y);
}

vec4_t vec4_xwxz(vec4_t v) {
    return vec4(v.x, v.w, v.x, v.z);
}

vec4_t vec4_xwxw(vec4_t v) {
    return vec4(v.x, v.w, v.x, v.w);
}

vec4_t vec4_xwyx(vec4_t v) {
    return vec4(v.x, v.w, v.y, v.x);
}

vec4_t vec4_xwyy(vec4_t v) {
    return vec4(v.x, v.w, v.y, v.y);
}

vec4_t vec4_xwyz(vec4_t v) {
    return vec4(v.x, v.w, v.y, v.z);
}

vec4_t vec4_xwyw(vec4_t v) {
    return vec4(v.x, v.w, v.y, v.w);
}

vec4_t vec4_xwzx(vec4_t v) {
    return vec4(v.x, v.w, v.z, v.x);
}

vec4_t vec4_xwzy(vec4_t v) {
    return vec4(v.x, v.w, v.z, v.y);
}

vec4_t vec4_xwzz(vec4_t v) {
    return vec4(v.x, v.w, v.z, v.z);
}

vec4_t vec4_xwzw(vec4_t v) {
    return vec4(v.x, v.w, v.z, v.w);
}

vec4_t vec4_xwwx(vec4_t v) {
    return vec4(v.x, v.w, v.w, v.x);
}

vec4_t vec4_xwwy(vec4_t v) {
    return vec4(v.x, v.w, v.w, v.y);
}

vec4_t vec4_xwwz(vec4_t v) {
    return vec4(v.x, v.w, v.w, v.z);
}

vec4_t vec4_xwww(vec4_t v) {
    return vec4(v.x, v.w, v.w, v.w);
}

vec4_t vec4_yxxx(vec4_t v) {
    return vec4(v.y, v.x, v.x, v.x);
}

vec4_t vec4_yxxy(vec4_t v) {
    return vec4(v.y, v.x, v.x, v.y);
}

vec4_t vec4_yxxz(vec4_t v) {
    return vec4(v.y, v.x, v.x, v.z);
}

vec4_t vec4_yxxw(vec4_t v) {
    return vec4(v.y, v.x, v.x, v.w);
}

vec4_t vec4_yxyx(vec4_t v) {
    return vec4(v.y, v.x, v.y, v.x);
}

vec4_t vec4_yxyy(vec4_t v) {
    return vec4(v.y, v.x, v.y, v.y);
}

vec4_t vec4_yxyz(vec4_t v) {
    return vec4(v.y, v.x, v.y, v.z);
}

vec4_t vec4_yxyw(vec4_t v) {
    return vec4(v.y, v.x, v.y, v.w);
}

vec4_t vec4_yxzx(vec4_t v) {
    return vec4(v.y, v.x, v.z, v.x);
}

vec4_t vec4_yxzy(vec4_t v) {
    return vec4(v.y, v.x, v.z, v.y);
}

vec4_t vec4_yxzz(vec4_t v) {
    return vec4(v.y, v.x, v.z, v.z);
}

vec4_t vec4_yxzw(vec4_t v) {
    return vec4(v.y, v.x, v.z, v.w);
}

vec4_t vec4_yxwx(vec4_t v) {
    return vec4(v.y, v.x, v.w, v.x);
}

vec4_t vec4_yxwy(vec4_t v) {
    return vec4(v.y, v.x, v.w, v.y);
}

vec4_t vec4_yxwz(vec4_t v) {
    return vec4(v.y, v.x, v.w, v.z);
}

vec4_t vec4_yxww(vec4_t v) {
    return vec4(v.y, v.x, v.w, v.w);
}

vec4_t vec4_yyxx(vec4_t v) {
    return vec4(v.y, v.y, v.x, v.x);
}

vec4_t vec4_yyxy(vec4_t v) {
    return vec4(v.y, v.y, v.x, v.y);
}

vec4_t vec4_yyxz(vec4_t v) {
    return vec4(v.y, v.y, v.x, v.z);
}

vec4_t vec4_yyxw(vec4_t v) {
    return vec4(v.y, v.y, v.x, v.w);
}

vec4_t vec4_yyyx(vec4_t v) {
    return vec4(v.y, v.y, v.y, v.x);
}

vec4_t vec4_yyyy(vec4_t v) {
    return vec4(v.y, v.y, v.y, v.y);
}

vec4_t vec4_yyyz(vec4_t v) {
    return vec4(v.y, v.y, v.y, v.z);
}

vec4_t vec4_yyyw(vec4_t v) {
    return vec4(v.y, v.y, v.y, v.w);
}

vec4_t vec4_yyzx(vec4_t v) {
    return vec4(v.y, v.y, v.z, v.x);
}

vec4_t vec4_yyzy(vec4_t v) {
    return vec4(v.y, v.y, v.z, v.y);
}

vec4_t vec4_yyzz(vec4_t v) {
    return vec4(v.y, v.y, v.z, v.z);
}

vec4_t vec4_yyzw(vec4_t v) {
    return vec4(v.y, v.y, v.z, v.w);
}

vec4_t vec4_yywx(vec4_t v) {
    return vec4(v.y, v.y, v.w, v.x);
}

vec4_t vec4_yywy(vec4_t v) {
    return vec4(v.y, v.y, v.w, v.y);
}

vec4_t vec4_yywz(vec4_t v) {
    return vec4(v.y, v.y, v.w, v.z);
}

vec4_t vec4_yyww(vec4_t v) {
    return vec4(v.y, v.y, v.w, v.w);
}

vec4_t vec4_yzxx(vec4_t v) {
    return vec4(v.y, v.z, v.x, v.x);
}

vec4_t vec4_yzxy(vec4_t v) {
    return vec4(v.y, v.z, v.x, v.y);
}

vec4_t vec4_yzxz(vec4_t v) {
    return vec4(v.y, v.z, v.x, v.z);
}

vec4_t vec4_yzxw(vec4_t v) {
    return vec4(v.y, v.z, v.x, v.w);
}

vec4_t vec4_yzyx(vec4_t v) {
    return vec4(v.y, v.z, v.y, v.x);
}

vec4_t vec4_yzyy(vec4_t v) {
    return vec4(v.y, v.z, v.y, v.y);
}

vec4_t vec4_yzyz(vec4_t v) {
    return vec4(v.y, v.z, v.y, v.z);
}

vec4_t vec4_yzyw(vec4_t v) {
    return vec4(v.y, v.z, v.y, v.w);
}

vec4_t vec4_yzzx(vec4_t v) {
    return vec4(v.y, v.z, v.z, v.x);
}

vec4_t vec4_yzzy(vec4_t v) {
    return vec4(v.y, v.z, v.z, v.y);
}

vec4_t vec4_yzzz(vec4_t v) {
    return vec4(v.y, v.z, v.z, v.z);
}

vec4_t vec4_yzzw(vec4_t v) {
    return vec4(v.y, v.z, v.z, v.w);
}

vec4_t vec4_yzwx(vec4_t v) {
    return vec4(v.y, v.z, v.w, v.x);
}

vec4_t vec4_yzwy(vec4_t v) {
    return vec4(v.y, v.z, v.w, v.y);
}

vec4_t vec4_yzwz(vec4_t v) {
    return vec4(v.y, v.z, v.w, v.z);
}

vec4_t vec4_yzww(vec4_t v) {
    return vec4(v.y, v.z, v.w, v.w);
}

vec4_t vec4_ywxx(vec4_t v) {
    return vec4(v.y, v.w, v.x, v.x);
}

vec4_t vec4_ywxy(vec4_t v) {
    return vec4(v.y, v.w, v.x, v.y);
}

vec4_t vec4_ywxz(vec4_t v) {
    return vec4(v.y, v.w, v.x, v.z);
}

vec4_t vec4_ywxw(vec4_t v) {
    return vec4(v.y, v.w, v.x, v.w);
}

vec4_t vec4_ywyx(vec4_t v) {
    return vec4(v.y, v.w, v.y, v.x);
}

vec4_t vec4_ywyy(vec4_t v) {
    return vec4(v.y, v.w, v.y, v.y);
}

vec4_t vec4_ywyz(vec4_t v) {
    return vec4(v.y, v.w, v.y, v.z);
}

vec4_t vec4_ywyw(vec4_t v) {
    return vec4(v.y, v.w, v.y, v.w);
}

vec4_t vec4_ywzx(vec4_t v) {
    return vec4(v.y, v.w, v.z, v.x);
}

vec4_t vec4_ywzy(vec4_t v) {
    return vec4(v.y, v.w, v.z, v.y);
}

vec4_t vec4_ywzz(vec4_t v) {
    return vec4(v.y, v.w, v.z, v.z);
}

vec4_t vec4_ywzw(vec4_t v) {
    return vec4(v.y, v.w, v.z, v.w);
}

vec4_t vec4_ywwx(vec4_t v) {
    return vec4(v.y, v.w, v.w, v.x);
}

vec4_t vec4_ywwy(vec4_t v) {
    return vec4(v.y, v.w, v.w, v.y);
}

vec4_t vec4_ywwz(vec4_t v) {
    return vec4(v.y, v.w, v.w, v.z);
}

vec4_t vec4_ywww(vec4_t v) {
    return vec4(v.y, v.w, v.w, v.w);
}

vec4_t vec4_zxxx(vec4_t v) {
    return vec4(v.z, v.x, v.x, v.x);
}

vec4_t vec4_zxxy(vec4_t v) {
    return vec4(v.z, v.x, v.x, v.y);
}

vec4_t vec4_zxxz(vec4_t v) {
    return vec4(v.z, v.x, v.x, v.z);
}

vec4_t vec4_zxxw(vec4_t v) {
    return vec4(v.z, v.x, v.x, v.w);
}

vec4_t vec4_zxyx(vec4_t v) {
    return vec4(v.z, v.x, v.y, v.x);
}

vec4_t vec4_zxyy(vec4_t v) {
    return vec4(v.z, v.x, v.y, v.y);
}

vec4_t vec4_zxyz(vec4_t v) {
    return vec4(v.z, v.x, v.y, v.z);
}

vec4_t vec4_zxyw(vec4_t v) {
    return vec4(v.z, v.x, v.y, v.w);
}

vec4_t vec4_zxzx(vec4_t v) {
    return vec4(v.z, v.x, v.z, v.x);
}

vec4_t vec4_zxzy(vec4_t v) {
    return vec4(v.z, v.x, v.z, v.y);
}

vec4_t vec4_zxzz(vec4_t v) {
    return vec4(v.z, v.x, v.z, v.z);
}

vec4_t vec4_zxzw(vec4_t v) {
    return vec4(v.z, v.x, v.z, v.w);
}

vec4_t vec4_zxwx(vec4_t v) {
    return vec4(v.z, v.x, v.w, v.x);
}

vec4_t vec4_zxwy(vec4_t v) {
    return vec4(v.z, v.x, v.w, v.y);
}

vec4_t vec4_zxwz(vec4_t v) {
    return vec4(v.z, v.x, v.w, v.z);
}

vec4_t vec4_zxww(vec4_t v) {
    return vec4(v.z, v.x, v.w, v.w);
}

vec4_t vec4_zyxx(vec4_t v) {
    return vec4(v.z, v.y, v.x, v.x);
}

vec4_t vec4_zyxy(vec4_t v) {
    return vec4(v.z, v.y, v.x, v.y);
}

vec4_t vec4_zyxz(vec4_t v) {
    return vec4(v.z, v.y, v.x, v.z);
}

vec4_t vec4_zyxw(vec4_t v) {
    return vec4(v.z, v.y, v.x, v.w);
}

vec4_t vec4_zyyx(vec4_t v) {
    return vec4(v.z, v.y, v.y, v.x);
}

vec4_t vec4_zyyy(vec4_t v) {
    return vec4(v.z, v.y, v.y, v.y);
}

vec4_t vec4_zyyz(vec4_t v) {
    return vec4(v.z, v.y, v.y, v.z);
}

vec4_t vec4_zyyw(vec4_t v) {
    return vec4(v.z, v.y, v.y, v.w);
}

vec4_t vec4_zyzx(vec4_t v) {
    return vec4(v.z, v.y, v.z, v.x);
}

vec4_t vec4_zyzy(vec4_t v) {
    return vec4(v.z, v.y, v.z, v.y);
}

vec4_t vec4_zyzz(vec4_t v) {
    return vec4(v.z, v.y, v.z, v.z);
}

vec4_t vec4_zyzw(vec4_t v) {
    return vec4(v.z, v.y, v.z, v.w);
}

vec4_t vec4_zywx(vec4_t v) {
    return vec4(v.z, v.y, v.w, v.x);
}

vec4_t vec4_zywy(vec4_t v) {
    return vec4(v.z, v.y, v.w, v.y);
}

vec4_t vec4_zywz(vec4_t v) {
    return vec4(v.z, v.y, v.w, v.z);
}

vec4_t vec4_zyww(vec4_t v) {
    return vec4(v.z, v.y, v.w, v.w);
}

vec4_t vec4_zzxx(vec4_t v) {
    return vec4(v.z, v.z, v.x, v.x);
}

vec4_t vec4_zzxy(vec4_t v) {
    return vec4(v.z, v.z, v.x, v.y);
}

vec4_t vec4_zzxz(vec4_t v) {
    return vec4(v.z, v.z, v.x, v.z);
}

vec4_t vec4_zzxw(vec4_t v) {
    return vec4(v.z, v.z, v.x, v.w);
}

vec4_t vec4_zzyx(vec4_t v) {
    return vec4(v.z, v.z, v.y, v.x);
}

vec4_t vec4_zzyy(vec4_t v) {
    return vec4(v.z, v.z, v.y, v.y);
}

vec4_t vec4_zzyz(vec4_t v) {
    return vec4(v.z, v.z, v.y, v.z);
}

vec4_t vec4_zzyw(vec4_t v) {
    return vec4(v.z, v.z, v.y, v.w);
}

vec4_t vec4_zzzx(vec4_t v) {
    return vec4(v.z, v.z, v.z, v.x);
}

vec4_t vec4_zzzy(vec4_t v) {
    return vec4(v.z, v.z, v.z, v.y);
}

vec4_t vec4_zzzz(vec4_t v) {
    return vec4(v.z, v.z, v.z, v.z);
}

vec4_t vec4_zzzw(vec4_t v) {
    return vec4(v.z, v.z, v.z, v.w);
}

vec4_t vec4_zzwx(vec4_t v) {
    return vec4(v.z, v.z, v.w, v.x);
}

vec4_t vec4_zzwy(vec4_t v) {
    return vec4(v.z, v.z, v.w, v.y);
}

vec4_t vec4_zzwz(vec4_t v) {
    return vec4(v.z, v.z, v.w, v.z);
}

vec4_t vec4_zzww(vec4_t v) {
    return vec4(v.z, v.z, v.w, v.w);
}

vec4_t vec4_zwxx(vec4_t v) {
    return vec4(v.z, v.w, v.x, v.x);
}

vec4_t vec4_zwxy(vec4_t v) {
    return vec4(v.z, v.w, v.x, v.y);
}

vec4_t vec4_zwxz(vec4_t v) {
    return vec4(v.z, v.w, v.x, v.z);
}

vec4_t vec4_zwxw(vec4_t v) {
    return vec4(v.z, v.w, v.x, v.w);
}

vec4_t vec4_zwyx(vec4_t v) {
    return vec4(v.z, v.w, v.y, v.x);
}

vec4_t vec4_zwyy(vec4_t v) {
    return vec4(v.z, v.w, v.y, v.y);
}

vec4_t vec4_zwyz(vec4_t v) {
    return vec4(v.z, v.w, v.y, v.z);
}

vec4_t vec4_zwyw(vec4_t v) {
    return vec4(v.z, v.w, v.y, v.w);
}

vec4_t vec4_zwzx(vec4_t v) {
    return vec4(v.z, v.w, v.z, v.x);
}

vec4_t vec4_zwzy(vec4_t v) {
    return vec4(v.z, v.w, v.z, v.y);
}

vec4_t vec4_zwzz(vec4_t v) {
    return vec4(v.z, v.w, v.z, v.z);
}

vec4_t vec4_zwzw(vec4_t v) {
    return vec4(v.z, v.w, v.z, v.w);
}

vec4_t vec4_zwwx(vec4_t v) {
    return vec4(v.z, v.w, v.w, v.x);
}

vec4_t vec4_zwwy(vec4_t v) {
    return vec4(v.z, v.w, v.w, v.y);
}

vec4_t vec4_zwwz(vec4_t v) {
    return vec4(v.z, v.w, v.w, v.z);
}

vec4_t vec4_zwww(vec4_t v) {
    return vec4(v.z, v.w, v.w, v.w);
}

vec4_t vec4_wxxx(vec4_t v) {
    return vec4(v.w, v.x, v.x, v.x);
}

vec4_t vec4_wxxy(vec4_t v) {
    return vec4(v.w, v.x, v.x, v.y);
}

vec4_t vec4_wxxz(vec4_t v) {
    return vec4(v.w, v.x, v.x, v.z);
}

vec4_t vec4_wxxw(vec4_t v) {
    return vec4(v.w, v.x, v.x, v.w);
}

vec4_t vec4_wxyx(vec4_t v) {
    return vec4(v.w, v.x, v.y, v.x);
}

vec4_t vec4_wxyy(vec4_t v) {
    return vec4(v.w, v.x, v.y, v.y);
}

vec4_t vec4_wxyz(vec4_t v) {
    return vec4(v.w, v.x, v.y, v.z);
}

vec4_t vec4_wxyw(vec4_t v) {
    return vec4(v.w, v.x, v.y, v.w);
}

vec4_t vec4_wxzx(vec4_t v) {
    return vec4(v.w, v.x, v.z, v.x);
}

vec4_t vec4_wxzy(vec4_t v) {
    return vec4(v.w, v.x, v.z, v.y);
}

vec4_t vec4_wxzz(vec4_t v) {
    return vec4(v.w, v.x, v.z, v.z);
}

vec4_t vec4_wxzw(vec4_t v) {
    return vec4(v.w, v.x, v.z, v.w);
}

vec4_t vec4_wxwx(vec4_t v) {
    return vec4(v.w, v.x, v.w, v.x);
}

vec4_t vec4_wxwy(vec4_t v) {
    return vec4(v.w, v.x, v.w, v.y);
}

vec4_t vec4_wxwz(vec4_t v) {
    return vec4(v.w, v.x, v.w, v.z);
}

vec4_t vec4_wxww(vec4_t v) {
    return vec4(v.w, v.x, v.w, v.w);
}

vec4_t vec4_wyxx(vec4_t v) {
    return vec4(v.w, v.y, v.x, v.x);
}

vec4_t vec4_wyxy(vec4_t v) {
    return vec4(v.w, v.y, v.x, v.y);
}

vec4_t vec4_wyxz(vec4_t v) {
    return vec4(v.w, v.y, v.x, v.z);
}

vec4_t vec4_wyxw(vec4_t v) {
    return vec4(v.w, v.y, v.x, v.w);
}

vec4_t vec4_wyyx(vec4_t v) {
    return vec4(v.w, v.y, v.y, v.x);
}

vec4_t vec4_wyyy(vec4_t v) {
    return vec4(v.w, v.y, v.y, v.y);
}

vec4_t vec4_wyyz(vec4_t v) {
    return vec4(v.w, v.y, v.y, v.z);
}

vec4_t vec4_wyyw(vec4_t v) {
    return vec4(v.w, v.y, v.y, v.w);
}

vec4_t vec4_wyzx(vec4_t v) {
    return vec4(v.w, v.y, v.z, v.x);
}

vec4_t vec4_wyzy(vec4_t v) {
    return vec4(v.w, v.y, v.z, v.y);
}

vec4_t vec4_wyzz(vec4_t v) {
    return vec4(v.w, v.y, v.z, v.z);
}

vec4_t vec4_wyzw(vec4_t v) {
    return vec4(v.w, v.y, v.z, v.w);
}

vec4_t vec4_wywx(vec4_t v) {
    return vec4(v.w, v.y, v.w, v.x);
}

vec4_t vec4_wywy(vec4_t v) {
    return vec4(v.w, v.y, v.w, v.y);
}

vec4_t vec4_wywz(vec4_t v) {
    return vec4(v.w, v.y, v.w, v.z);
}

vec4_t vec4_wyww(vec4_t v) {
    return vec4(v.w, v.y, v.w, v.w);
}

vec4_t vec4_wzxx(vec4_t v) {
    return vec4(v.w, v.z, v.x, v.x);
}

vec4_t vec4_wzxy(vec4_t v) {
    return vec4(v.w, v.z, v.x, v.y);
}

vec4_t vec4_wzxz(vec4_t v) {
    return vec4(v.w, v.z, v.x, v.z);
}

vec4_t vec4_wzxw(vec4_t v) {
    return vec4(v.w, v.z, v.x, v.w);
}

vec4_t vec4_wzyx(vec4_t v) {
    return vec4(v.w, v.z, v.y, v.x);
}

vec4_t vec4_wzyy(vec4_t v) {
    return vec4(v.w, v.z, v.y, v.y);
}

vec4_t vec4_wzyz(vec4_t v) {
    return vec4(v.w, v.z, v.y, v.z);
}

vec4_t vec4_wzyw(vec4_t v) {
    return vec4(v.w, v.z, v.y, v.w);
}

vec4_t vec4_wzzx(vec4_t v) {
    return vec4(v.w, v.z, v.z, v.x);
}

vec4_t vec4_wzzy(vec4_t v) {
    return vec4(v.w, v.z, v.z, v.y);
}

vec4_t vec4_wzzz(vec4_t v) {
    return vec4(v.w, v.z, v.z, v.z);
}

vec4_t vec4_wzzw(vec4_t v) {
    return vec4(v.w, v.z, v.z, v.w);
}

vec4_t vec4_wzwx(vec4_t v) {
    return vec4(v.w, v.z, v.w, v.x);
}

vec4_t vec4_wzwy(vec4_t v) {
    return vec4(v.w, v.z, v.w, v.y);
}

vec4_t vec4_wzwz(vec4_t v) {
    return vec4(v.w, v.z, v.w, v.z);
}

vec4_t vec4_wzww(vec4_t v) {
    return vec4(v.w, v.z, v.w, v.w);
}

vec4_t vec4_wwxx(vec4_t v) {
    return vec4(v.w, v.w, v.x, v.x);
}

vec4_t vec4_wwxy(vec4_t v) {
    return vec4(v.w, v.w, v.x, v.y);
}

vec4_t vec4_wwxz(vec4_t v) {
    return vec4(v.w, v.w, v.x, v.z);
}

vec4_t vec4_wwxw(vec4_t v) {
    return vec4(v.w, v.w, v.x, v.w);
}

vec4_t vec4_wwyx(vec4_t v) {
    return vec4(v.w, v.w, v.y, v.x);
}

vec4_t vec4_wwyy(vec4_t v) {
    return vec4(v.w, v.w, v.y, v.y);
}

vec4_t vec4_wwyz(vec4_t v) {
    return vec4(v.w, v.w, v.y, v.z);
}

vec4_t vec4_wwyw(vec4_t v) {
    return vec4(v.w, v.w, v.y, v.w);
}

vec4_t vec4_wwzx(vec4_t v) {
    return vec4(v.w, v.w, v.z, v.x);
}

vec4_t vec4_wwzy(vec4_t v) {
    return vec4(v.w, v.w, v.z, v.y);
}

vec4_t vec4_wwzz(vec4_t v) {
    return vec4(v.w, v.w, v.z, v.z);
}

vec4_t vec4_wwzw(vec4_t v) {
    return vec4(v.w, v.w, v.z, v.w);
}

vec4_t vec4_wwwx(vec4_t v) {
    return vec4(v.w, v.w, v.w, v.x);
}

vec4_t vec4_wwwy(vec4_t v) {
    return vec4(v.w, v.w, v.w, v.y);
}

vec4_t vec4_wwwz(vec4_t v) {
    return vec4(v.w, v.w, v.w, v.z);
}

vec4_t vec4_wwww(vec4_t v) {
    return vec4(v.w, v.w, v.w, v.w);
}

