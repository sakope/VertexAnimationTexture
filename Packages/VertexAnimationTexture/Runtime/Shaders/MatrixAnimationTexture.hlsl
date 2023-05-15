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

float4x4 Inverse(float4x4 m)
{
    float n11 = m[0][0], n12 = m[1][0], n13 = m[2][0], n14 = m[3][0];
    float n21 = m[0][1], n22 = m[1][1], n23 = m[2][1], n24 = m[3][1];
    float n31 = m[0][2], n32 = m[1][2], n33 = m[2][2], n34 = m[3][2];
    float n41 = m[0][3], n42 = m[1][3], n43 = m[2][3], n44 = m[3][3];

    float t11 = n23 * n34 * n42 - n24 * n33 * n42 + n24 * n32 * n43 - n22 * n34 * n43 - n23 * n32 * n44 + n22 * n33 * n44;
    float t12 = n14 * n33 * n42 - n13 * n34 * n42 - n14 * n32 * n43 + n12 * n34 * n43 + n13 * n32 * n44 - n12 * n33 * n44;
    float t13 = n13 * n24 * n42 - n14 * n23 * n42 + n14 * n22 * n43 - n12 * n24 * n43 - n13 * n22 * n44 + n12 * n23 * n44;
    float t14 = n14 * n23 * n32 - n13 * n24 * n32 - n14 * n22 * n33 + n12 * n24 * n33 + n13 * n22 * n34 - n12 * n23 * n34;

    float det = n11 * t11 + n21 * t12 + n31 * t13 + n41 * t14;
    float idet = 1.0f / det;

    float4x4 invMatrix;

    invMatrix[0][0] = t11 * idet;
    invMatrix[0][1] = (n24 * n33 * n41 - n23 * n34 * n41 - n24 * n31 * n43 + n21 * n34 * n43 + n23 * n31 * n44 - n21 * n33 * n44) * idet;
    invMatrix[0][2] = (n22 * n34 * n41 - n24 * n32 * n41 + n24 * n31 * n42 - n21 * n34 * n42 - n22 * n31 * n44 + n21 * n32 * n44) * idet;
    invMatrix[0][3] = (n23 * n32 * n41 - n22 * n33 * n41 - n23 * n31 * n42 + n21 * n33 * n42 + n22 * n31 * n43 - n21 * n32 * n43) * idet;

    invMatrix[1][0] = t12 * idet;
    invMatrix[1][1] = (n13 * n34 * n41 - n14 * n33 * n41 + n14 * n31 * n43 - n11 * n34 * n43 - n13 * n31 * n44 + n11 * n33 * n44) * idet;
    invMatrix[1][2] = (n14 * n32 * n41 - n12 * n34 * n41 - n14 * n31 * n42 + n11 * n34 * n42 + n12 * n31 * n44 - n11 * n32 * n44) * idet;
    invMatrix[1][3] = (n12 * n33 * n41 - n13 * n32 * n41 + n13 * n31 * n42 - n11 * n33 * n42 - n12 * n31 * n43 + n11 * n32 * n43) * idet;

    invMatrix[2][0] = t13 * idet;
    invMatrix[2][1] = (n14 * n23 * n41 - n13 * n24 * n41 - n14 * n21 * n43 + n11 * n24 * n43 + n13 * n21 * n44 - n11 * n23 * n44) * idet;
    invMatrix[2][2] = (n12 * n24 * n41 - n14 * n22 * n41 + n14 * n21 * n42 - n11 * n24 * n42 - n12 * n21 * n44 + n11 * n22 * n44) * idet;
    invMatrix[2][3] = (n13 * n22 * n41 - n12 * n23 * n41 - n13 * n21 * n42 + n11 * n23 * n42 + n12 * n21 * n43 - n11 * n22 * n43) * idet;

    invMatrix[3][0] = t14 * idet;
    invMatrix[3][1] = (n13 * n24 * n31 - n14 * n23 * n31 + n14 * n21 * n33 - n11 * n24 * n33 - n13 * n21 * n34 + n11 * n23 * n34) * idet;
    invMatrix[3][2] = (n14 * n22 * n31 - n12 * n24 * n31 - n14 * n21 * n32 + n11 * n24 * n32 + n12 * n21 * n34 - n11 * n22 * n34) * idet;
    invMatrix[3][3] = (n12 * n23 * n31 - n13 * n22 * n31 + n13 * n21 * n32 - n11 * n23 * n32 - n12 * n21 * n33 + n11 * n22 * n33) * idet;

    return invMatrix;
}


#endif //MATRIX_ANIMATION_TEXTURE_INCLUDE
