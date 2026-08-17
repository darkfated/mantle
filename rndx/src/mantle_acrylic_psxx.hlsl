#include "common_rounded.hlsl"

#define FRESNEL_WIDTH Constants0.y
#define NOISE_INTENSITY Constants0.z
#define NOISE_SCALE Constants0.w

#define BURN_COLOR Constants1
#define TINT_COLOR Constants2
#define FRESNEL_COLOR Constants3

#define FLAG_ACRYLIC_BURN 64.0
#define FLAG_ACRYLIC_TINT 128.0
#define FLAG_ACRYLIC_NOISE 256.0
#define FLAG_ACRYLIC_FRESNEL 512.0

float3 acrylic_burn(float3 base, float3 burn)
{
    return saturate(base + burn - 1.0);
}

float hash12(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.x + p3.y) * p3.z);
}

float value_noise(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash12(i);
    float b = hash12(i + float2(1.0, 0.0));
    float c = hash12(i + float2(0.0, 1.0));
    float d = hash12(i + float2(1.0, 1.0));

    return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
}

float4 main(PS_INPUT i) : COLOR
{
    float2 centered_pos;
    float rounded_alpha = calculate_rounded_alpha(i, centered_pos);

    if (rounded_alpha <= 0.0f)
        discard;

    float fade = 1.0;
    if (has_flag(FLAG_FADE_TOP) || has_flag(FLAG_FADE_BOTTOM))
        fade = gradient_fade(centered_pos, SIZE * 0.5 - PAD);

    float3 col = tex2D(TexBase, i.pos * Tex1Size).rgb;

    if (has_flag(FLAG_ACRYLIC_BURN))
    {
        float3 burned = acrylic_burn(col, BURN_COLOR.rgb);
        col = lerp(col, burned, BURN_COLOR.a);
    }

    if (has_flag(FLAG_ACRYLIC_TINT))
    {
        col = lerp(col, col * TINT_COLOR.rgb, TINT_COLOR.a);
    }

    if (has_flag(FLAG_ACRYLIC_NOISE))
    {
        float n = value_noise(centered_pos * NOISE_SCALE);
        col = lerp(col, float3(n, n, n), n * NOISE_INTENSITY);
    }

    if (has_flag(FLAG_ACRYLIC_FRESNEL))
    {
        float2 half_size = SIZE * 0.5 - PAD;
        float dist = rounded_arc_sdf(centered_pos, half_size, RADIUS);
        float inward = max(-dist, 0.0);
        float edge = exp(-inward * FRESNEL_WIDTH);
        col = lerp(col, FRESNEL_COLOR.rgb, edge * FRESNEL_COLOR.a);
    }

    return float4(col * fade * i.color.a, rounded_alpha * fade * i.color.a);
}