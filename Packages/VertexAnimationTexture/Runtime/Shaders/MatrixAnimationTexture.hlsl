#ifndef MATRIX_ANIMATION_TEXTURE_INCLUDE
#define MATRIX_ANIMATION_TEXTURE_INCLUDE

#include "AnimationTexture.hlsl"

sampler2D _MatrixAnimTex;
half4 _MatrixAnimTex_TexelSize;
float _MatrixAnimTex_M_Scale;
float _MatrixAnimTex_M_Offset;
float _MatrixAnimTex_IT_M_Scale;
float _MatrixAnimTex_IT_M_Offset;

float4x4 Matrix_M_Bilinear(float t) {
    float frame = min(t * _AnimTex_FPS, _AnimTex_AnimEnd.y);
    float frame1 = frame;
    float4x4 model1, model2;
    float2 uvc1, uvc2, uvc3, uvc4;
    uvc1.xy = (0.5 + float2(0, frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc2.xy = (0.5 + float2(1, frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc3.xy = (0.5 + float2(2, frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc4.xy = (0.5 + float2(3, frame1)) * _MatrixAnimTex_TexelSize.xy;
    model1._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model1._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model1._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model1._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    uvc1.y += 0.5;
    uvc2.y += 0.5;
    uvc3.y += 0.5;
    uvc4.y += 0.5;
    model2._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model2._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model2._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model2._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    return (model1 + model2 * COLOR_DEPTH_INV) * _MatrixAnimTex_M_Scale + _MatrixAnimTex_M_Offset;
}

float4x4 Matrix_M_Bilinear(float t, float meshId) {
    float frame = min(t * _AnimTex_FPS, _AnimTex_AnimEnd.y);
    float frame1 = frame;
    float4x4 model1, model2;
    float2 uvc1, uvc2, uvc3, uvc4;
    uvc1.xy = (0.5 + float2(0 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc2.xy = (0.5 + float2(1 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc3.xy = (0.5 + float2(2 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc4.xy = (0.5 + float2(3 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    model1._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model1._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model1._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model1._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    uvc1.y += 0.5;
    uvc2.y += 0.5;
    uvc3.y += 0.5;
    uvc4.y += 0.5;
    model2._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model2._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model2._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model2._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    return (model1 + model2 * COLOR_DEPTH_INV) * _MatrixAnimTex_M_Scale + _MatrixAnimTex_M_Offset;
}

float4x4 Matrix_M_Point(float t) {
    float frame = min(t * _AnimTex_FPS, _AnimTex_AnimEnd.y);
    float frame1 = floor(frame);
    float frame2 = min(frame1 + 1, _AnimTex_AnimEnd.y);
    float tFilter = frame - frame1;

    float4x4 model1, model2;
    float2 uvc1, uvc2, uvc3, uvc4;
    uvc1.xy = (0.5 + float2(0, frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc2.xy = (0.5 + float2(1, frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc3.xy = (0.5 + float2(2, frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc4.xy = (0.5 + float2(3, frame1)) * _MatrixAnimTex_TexelSize.xy;
    model1._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model1._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model1._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model1._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    uvc1.y += 0.5;
    uvc2.y += 0.5;
    uvc3.y += 0.5;
    uvc4.y += 0.5;
    model2._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model2._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model2._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model2._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    float4x4 model = (model1 + model2 * COLOR_DEPTH_INV) * _MatrixAnimTex_M_Scale + _MatrixAnimTex_M_Offset;

    uvc1.xy = (0.5 + float2(0, frame2)) * _MatrixAnimTex_TexelSize.xy;
    uvc2.xy = (0.5 + float2(1, frame2)) * _MatrixAnimTex_TexelSize.xy;
    uvc3.xy = (0.5 + float2(2, frame2)) * _MatrixAnimTex_TexelSize.xy;
    uvc4.xy = (0.5 + float2(3, frame2)) * _MatrixAnimTex_TexelSize.xy;
    model1._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model1._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model1._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model1._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    uvc1.y += 0.5;
    uvc2.y += 0.5;
    uvc3.y += 0.5;
    uvc4.y += 0.5;
    model2._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model2._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model2._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model2._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    model2 = (model1 + model2 / COLOR_DEPTH) * _MatrixAnimTex_M_Scale + _MatrixAnimTex_M_Offset;
    
    return model + (model2 - model) * tFilter; 
}			

float4x4 Matrix_M_Point(float t, float meshId) {
    float frame = min(t * _AnimTex_FPS, _AnimTex_AnimEnd.y);
    float frame1 = floor(frame);
    float frame2 = min(frame1 + 1, _AnimTex_AnimEnd.y);
    float tFilter = frame - frame1;

    float4x4 model1, model2;
    float2 uvc1, uvc2, uvc3, uvc4;
    uvc1.xy = (0.5 + float2(0 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc2.xy = (0.5 + float2(1 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc3.xy = (0.5 + float2(2 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc4.xy = (0.5 + float2(3 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    model1._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model1._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model1._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model1._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    uvc1.y += 0.5;
    uvc2.y += 0.5;
    uvc3.y += 0.5;
    uvc4.y += 0.5;
    model2._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model2._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model2._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model2._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    float4x4 model = (model1 + model2 * COLOR_DEPTH_INV) * _MatrixAnimTex_M_Scale + _MatrixAnimTex_M_Offset;

    uvc1.xy = (0.5 + float2(0 + (meshId * 8), frame2)) * _MatrixAnimTex_TexelSize.xy;
    uvc2.xy = (0.5 + float2(1 + (meshId * 8), frame2)) * _MatrixAnimTex_TexelSize.xy;
    uvc3.xy = (0.5 + float2(2 + (meshId * 8), frame2)) * _MatrixAnimTex_TexelSize.xy;
    uvc4.xy = (0.5 + float2(3 + (meshId * 8), frame2)) * _MatrixAnimTex_TexelSize.xy;
    model1._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model1._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model1._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model1._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    uvc1.y += 0.5;
    uvc2.y += 0.5;
    uvc3.y += 0.5;
    uvc4.y += 0.5;
    model2._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model2._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model2._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model2._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    model2 = (model1 + model2 / COLOR_DEPTH) * _MatrixAnimTex_M_Scale + _MatrixAnimTex_M_Offset;
    
    return model + (model2 - model) * tFilter; 
}			

float4x4 ModelMatrixAnimTex(float t) {
	#ifdef BILINEAR_OFF
    return Matrix_M_Point(t);
	#else
    return Matrix_M_Bilinear(t);
	#endif
}

float4x4 ModelMatrixAnimTex(float t, float meshId) {
	#ifdef BILINEAR_OFF
    return Matrix_M_Point(t, meshId);
	#else
    return Matrix_M_Bilinear(t, meshId);
	#endif
}

float4x4 Matrix_IT_M_Bilinear(float t) {
    float frame = min(t * _AnimTex_FPS, _AnimTex_AnimEnd.y);
    float frame1 = frame;
    float4x4 model1, model2;
    float2 uvc1, uvc2, uvc3, uvc4;
    uvc1.xy = (0.5 + float2(4, frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc2.xy = (0.5 + float2(5, frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc3.xy = (0.5 + float2(6, frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc4.xy = (0.5 + float2(7, frame1)) * _MatrixAnimTex_TexelSize.xy;
    model1._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model1._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model1._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model1._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    uvc1.y += 0.5;
    uvc2.y += 0.5;
    uvc3.y += 0.5;
    uvc4.y += 0.5;
    model2._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model2._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model2._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model2._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    return (model1 + model2 * COLOR_DEPTH_INV) * _MatrixAnimTex_IT_M_Scale + _MatrixAnimTex_IT_M_Offset;
}

float4x4 Matrix_IT_M_Bilinear(float t, float meshId) {
    float frame = min(t * _AnimTex_FPS, _AnimTex_AnimEnd.y);
    float frame1 = frame;
    float4x4 model1, model2;
    float2 uvc1, uvc2, uvc3, uvc4;
    uvc1.xy = (0.5 + float2(4 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc2.xy = (0.5 + float2(5 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc3.xy = (0.5 + float2(6 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc4.xy = (0.5 + float2(7 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    model1._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model1._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model1._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model1._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    uvc1.y += 0.5;
    uvc2.y += 0.5;
    uvc3.y += 0.5;
    uvc4.y += 0.5;
    model2._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model2._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model2._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model2._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    return (model1 + model2 * COLOR_DEPTH_INV) * _MatrixAnimTex_M_Scale + _MatrixAnimTex_M_Offset;
}

float4x4 Matrix_IT_M_Point(float t) {
    float frame = min(t * _AnimTex_FPS, _AnimTex_AnimEnd.y);
    float frame1 = floor(frame);
    float frame2 = min(frame1 + 1, _AnimTex_AnimEnd.y);
    float tFilter = frame - frame1;

    float4x4 model1, model2;
    float2 uvc1, uvc2, uvc3, uvc4;
    uvc1.xy = (0.5 + float2(4, frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc2.xy = (0.5 + float2(5, frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc3.xy = (0.5 + float2(6, frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc4.xy = (0.5 + float2(7, frame1)) * _MatrixAnimTex_TexelSize.xy;
    model1._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model1._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model1._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model1._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    uvc1.y += 0.5;
    uvc2.y += 0.5;
    uvc3.y += 0.5;
    uvc4.y += 0.5;
    model2._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model2._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model2._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model2._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    float4x4 model = (model1 + model2 * COLOR_DEPTH_INV) * _MatrixAnimTex_M_Scale + _MatrixAnimTex_M_Offset;

    uvc1.xy = (0.5 + float2(4, frame2)) * _MatrixAnimTex_TexelSize.xy;
    uvc2.xy = (0.5 + float2(5, frame2)) * _MatrixAnimTex_TexelSize.xy;
    uvc3.xy = (0.5 + float2(6, frame2)) * _MatrixAnimTex_TexelSize.xy;
    uvc4.xy = (0.5 + float2(7, frame2)) * _MatrixAnimTex_TexelSize.xy;
    model1._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model1._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model1._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model1._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    uvc1.y += 0.5;
    uvc2.y += 0.5;
    uvc3.y += 0.5;
    uvc4.y += 0.5;
    model2._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model2._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model2._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model2._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    model2 = (model1 + model2 / COLOR_DEPTH) * _MatrixAnimTex_M_Scale + _MatrixAnimTex_M_Offset;
    
    return model + (model2 - model) * tFilter; 
}

float4x4 Matrix_IT_M_Point(float t, float meshId)
{
    float frame = min(t * _AnimTex_FPS, _AnimTex_AnimEnd.y);
    float frame1 = floor(frame);
    float frame2 = min(frame1 + 1, _AnimTex_AnimEnd.y);
    float tFilter = frame - frame1;

    float4x4 model1, model2;
    float2 uvc1, uvc2, uvc3, uvc4;
    uvc1.xy = (0.5 + float2(4 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc2.xy = (0.5 + float2(5 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc3.xy = (0.5 + float2(6 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    uvc4.xy = (0.5 + float2(7 + (meshId * 8), frame1)) * _MatrixAnimTex_TexelSize.xy;
    model1._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model1._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model1._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model1._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    uvc1.y += 0.5;
    uvc2.y += 0.5;
    uvc3.y += 0.5;
    uvc4.y += 0.5;
    model2._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model2._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model2._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model2._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    float4x4 model = (model1 + model2 * COLOR_DEPTH_INV) * _MatrixAnimTex_M_Scale + _MatrixAnimTex_M_Offset;

    uvc1.xy = (0.5 + float2(4 + (meshId * 8), frame2)) * _MatrixAnimTex_TexelSize.xy;
    uvc2.xy = (0.5 + float2(5 + (meshId * 8), frame2)) * _MatrixAnimTex_TexelSize.xy;
    uvc3.xy = (0.5 + float2(6 + (meshId * 8), frame2)) * _MatrixAnimTex_TexelSize.xy;
    uvc4.xy = (0.5 + float2(7 + (meshId * 8), frame2)) * _MatrixAnimTex_TexelSize.xy;
    model1._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model1._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model1._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model1._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    uvc1.y += 0.5;
    uvc2.y += 0.5;
    uvc3.y += 0.5;
    uvc4.y += 0.5;
    model2._11_21_31_41 = tex2Dlod(_MatrixAnimTex, float4(uvc1, 0, 0)).rgba;
    model2._12_22_32_42 = tex2Dlod(_MatrixAnimTex, float4(uvc2, 0, 0)).rgba;
    model2._13_23_33_43 = tex2Dlod(_MatrixAnimTex, float4(uvc3, 0, 0)).rgba;
    model2._14_24_34_44 = tex2Dlod(_MatrixAnimTex, float4(uvc4, 0, 0)).rgba;
    model2 = (model1 + model2 / COLOR_DEPTH) * _MatrixAnimTex_M_Scale + _MatrixAnimTex_M_Offset;
    
    return model + (model2 - model) * tFilter; 
}	

float4x4 InvTransModelMatrixAnimTex(float t) {
    #ifdef BILINEAR_OFF
    return Matrix_IT_M_Point(t);
    #else
    return Matrix_IT_M_Bilinear(t);
    #endif
}

float4x4 InvTransModelMatrixAnimTex(float t, float meshId)
{
    #ifdef BILINEAR_OFF
    return Matrix_IT_M_Point(t, meshId);
    #else
    return Matrix_IT_M_Bilinear(t, meshId);
    #endif
}

float3x3 InverseMatrix(float3x3 m)
{
    float det = determinant(m);
    if (det == 0) return 0;
    return 1.0f / det *
        float3x3(
            m[1][1] * m[2][2] - m[1][2] * m[2][1],
            -(m[0][1] * m[2][2] - m[0][2] * m[2][1]),
            m[0][1] * m[1][2] - m[0][2] * m[1][1],

            -(m[1][0] * m[2][2] - m[1][2] * m[2][0]),
            m[0][0] * m[2][2] - m[0][2] * m[2][0],
            -(m[0][0] * m[1][2] - m[0][2] * m[1][0]),

            m[1][0] * m[2][1]- m[1][1] * m[2][0],
            -(m[0][0] * m[2][1] - m[0][1] * m[2][0]),
            m[0][0] * m[1][1] - m[0][1] * m[1][0]
        );
}

#endif //MATRIX_ANIMATION_TEXTURE_INCLUDE
