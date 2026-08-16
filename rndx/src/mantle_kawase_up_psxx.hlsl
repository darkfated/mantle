#include "common.hlsl"

float4 main(PS_INPUT i) : COLOR
{
    float2 halfpixel = TexBaseSize * 0.5;
    float2 off = halfpixel * Constants0.x;

    float3 sum = tex2D(TexBase, i.uv + float2(-off.x * 2.0, 0.0));
    sum += tex2D(TexBase, i.uv + float2(-off.x,  off.y)) * 2.0;
    sum += tex2D(TexBase, i.uv + float2(0.0, off.y * 2.0));
    sum += tex2D(TexBase, i.uv + float2( off.x,  off.y)) * 2.0;
    sum += tex2D(TexBase, i.uv + float2( off.x * 2.0, 0.0));
    sum += tex2D(TexBase, i.uv + float2( off.x, -off.y)) * 2.0;
    sum += tex2D(TexBase, i.uv + float2(0.0, -off.y * 2.0));
    sum += tex2D(TexBase, i.uv + float2(-off.x, -off.y)) * 2.0;

    return float4(sum / 12.0, 1.0);
}
