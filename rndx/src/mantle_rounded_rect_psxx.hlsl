#include "common_rounded.hlsl"

float4 main(PS_INPUT i) : COLOR
{
    float2 centered_pos;
    float alpha = calculate_rounded_alpha(i, centered_pos);

    if (alpha <= 0.0f)
        discard;

    float4 rect_color;
    if (has_flag(FLAG_USE_TEXTURE))
    {
        float2 rotated_uv = (centered_pos / (SIZE - 2.0 * PAD)) + 0.5;
        rect_color = tex2D(TexBase, rotated_uv) * i.color;
    }
    else
    {
        rect_color = i.color;
    }

    float fade = 1.0;
    if (has_flag(FLAG_FADE_TOP) || has_flag(FLAG_FADE_BOTTOM))
        fade = gradient_fade(centered_pos, SIZE * 0.5 - PAD);
    return float4(rect_color.rgb, rect_color.a * alpha * fade);
}
