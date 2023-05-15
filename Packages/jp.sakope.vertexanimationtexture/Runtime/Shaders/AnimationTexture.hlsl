#ifndef ANIMATION_TEXTURE_INCLUDE
#define ANIMATION_TEXTURE_INCLUDE

static const float COLOR_DEPTH = 255;
static const float COLOR_DEPTH_INV = 1.0 / COLOR_DEPTH;

float4 _AnimTex_AnimEnd;
float _AnimTex_FPS;

#if defined(INSTANCING_ON)
UNITY_INSTANCING_BUFFER_START(MyProps)
    UNITY_DEFINE_INSTANCED_PROP(float, _AnimTex_T)
    #define _AnimTex_T_arr MyProps
UNITY_INSTANCING_BUFFER_END(MyProps)
#else
float _AnimTex_T;
#endif

#endif //ANIMATION_TEXTURE_INCLUDE
