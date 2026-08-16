#include "common.hlsl"

float4 main(PS_INPUT i) : COLOR
{
    float2 halfpixel = TexBaseSize * 0.5;
    float2 off = halfpixel * Constants0.x;

    float3 sum = tex2D(TexBase, i.uv) * 4.0;
    sum += tex2D(TexBase, i.uv + float2(-off.x, -off.y));
    sum += tex2D(TexBase, i.uv + float2(-off.x,  off.y));
    sum += tex2D(TexBase, i.uv + float2( off.x, -off.y));
    sum += tex2D(TexBase, i.uv + float2( off.x,  off.y));

    return float4(sum / 8.0, 1.0);
}
