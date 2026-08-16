#include "common_rounded.hlsl"

float4 main(PS_INPUT i) : COLOR
{
    float2 centered_pos;
    float rounded_alpha = calculate_rounded_alpha(i, centered_pos);

    if (rounded_alpha <= 0.0f)
        discard;

    float fade = 1.0;
    if (has_flag(FLAG_FADE_TOP) || has_flag(FLAG_FADE_BOTTOM))
        fade = gradient_fade(centered_pos, SIZE * 0.5 - PAD);

    float3 c = tex2D(TexBase, i.pos * Tex1Size).rgb;
    return float4(c * fade, rounded_alpha * fade);
}
