#ifndef VERTEX_ANIMATION_TEXTURE_INCLUDE
#define VERTEX_ANIMATION_TEXTURE_INCLUDE

#include "AnimationTexture.hlsl"

sampler2D _VertAnimTex;
half4 _VertAnimTex_TexelSize;
float4 _VertAnimTex_Scale;
float4 _VertAnimTex_Offset;

sampler2D _NormalAnimTex;
half4 _NormalAnimTex_TexelSize;

float3 AnimTexVertexPos_Bilinear(uint vid, float t) {
    float frame = min(t * _AnimTex_FPS, _AnimTex_AnimEnd.y);
    float frame1 = frame;

    float2 uv = 0;
    uv.xy = (0.5 + float2(vid, frame1)) * _VertAnimTex_TexelSize.xy;
    float3 pos1 = tex2Dlod(_VertAnimTex, float4(uv, 0, 0)).rgb;
    uv.y += 0.5;
    float3 pos2 = tex2Dlod(_VertAnimTex, float4(uv, 0, 0)).rgb;
    float3 pos = (pos1 + pos2 * COLOR_DEPTH_INV) * _VertAnimTex_Scale.xyz + _VertAnimTex_Offset.xyz;
    
    return pos;
}

float3 AnimTexVertexPos_Point(uint vid, float t) {
    float frame = min(t * _AnimTex_FPS, _AnimTex_AnimEnd.y);
    float frame1 = floor(frame);
    float frame2 = min(frame1 + 1, _AnimTex_AnimEnd.y);
    float tFilter = frame - frame1;

    float4 uv = 0;
    uv.xy = (0.5 + float2(vid, frame1)) * _VertAnimTex_TexelSize.xy;
    float3 pos1 = tex2Dlod(_VertAnimTex, uv).rgb;
    uv.y += 0.5;
    float3 pos2 = tex2Dlod(_VertAnimTex, uv).rgb;
    float3 pos = (pos1 + pos2 * COLOR_DEPTH_INV) * _VertAnimTex_Scale.xyz + _VertAnimTex_Offset.xyz;
    
    uv.xy = (0.5 + float2(vid, frame2)) * _VertAnimTex_TexelSize.xy;
    pos1 = tex2Dlod(_VertAnimTex, uv).rgb;
    uv.y += 0.5;
    pos2 = tex2Dlod(_VertAnimTex, uv).rgb;
    pos2 = (pos1 + pos2 / COLOR_DEPTH) * _VertAnimTex_Scale.xyz + _VertAnimTex_Offset.xyz;
    
    return lerp(pos, pos2, tFilter);
}

float3 AnimTexVertexPos(uint vid, float t) {
    #ifdef BILINEAR_OFF
    return AnimTexVertexPos_Point(vid, t);
    #else
    return AnimTexVertexPos_Bilinear(vid, t);
    #endif
}

float3 AnimTexNormal(uint vid, float t) {
    float frame = min(t * _AnimTex_FPS, _AnimTex_AnimEnd.y);
    float frame1 = frame;

    float2 uv = 0;
    uv.xy = (0.5 + float2(vid, frame1)) * _NormalAnimTex_TexelSize.xy;
    float3 n1 = tex2Dlod(_NormalAnimTex, float4(uv, 0, 0)).rgb;
    uv.y += 0.5;
    float3 n2 = tex2Dlod(_NormalAnimTex, float4(uv, 0, 0)).rgb;
    float3 n = 2.0 * (n1 + n2 * COLOR_DEPTH_INV) - 1.0;

    return n;
}

#endif //VERTEX_ANIMATION_TEXTURE_INCLUDE
