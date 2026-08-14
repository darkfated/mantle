#ifndef __MANTLE_COMMON_HLSL__
#define __MANTLE_COMMON_HLSL__

sampler TexBase : register(s0);
sampler Tex1 : register(s1);
sampler Tex2 : register(s2);
sampler Tex3 : register(s3);

float2 TexBaseSize : register(c4);
float2 Tex1Size : register(c5);
float2 Tex2Size : register(c6);
float2 Tex3Size : register(c7);

const float4 Constants0 : register(c0);
const float4 Constants1 : register(c1);
const float4 Constants2 : register(c2);
const float4 Constants3 : register(c3);
const float4 Constants4 : register(c4);

const float4 EyePosition : register(c10);

const float4 FogColor : register(c29);
#define DepthRange FogColor.w

const float4 HDRParams : register(c30);
#define TonemapScale HDRParams.x
#define LightmapScale HDRParams.y
#define EnvmapScale HDRParams.z
#define GammaScale HDRParams.w

struct PS_INPUT
{
    float2 uv : TEXCOORD0;
    float4 color : TEXCOORD1;
    float2 pos : VPOS;
};

#endif
