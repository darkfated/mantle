sampler TexBase : register(s0);
sampler Tex1 : register(s1);
sampler Tex2 : register(s2);
sampler Tex3 : register(s3);

const float4 Constants0 : register(c0);
const float4 Constants1 : register(c1);
const float4 Constants2 : register(c2);
const float4 Constants3 : register(c3);

const float4x4 cModelViewProj : register(c4);
const float4x4 cViewProj : register(c8);

struct VS_INPUT
{
    float4 pos : POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR0;

    float4 normal : NORMAL;
};

struct VS_OUTPUT
{
    float4 projPos : POSITION;
    float2 uv : TEXCOORD0;
    float4 color : TEXCOORD1;
};
