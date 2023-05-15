Shader "VertexAnimation/LocalCoord_Matrix_MergedMesh/Standard_Instancing"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _VertAnimTex("PosTex", 2D) = "white" {}
        _NormalAnimTex("Normal Tex", 2D) = "white" {}
        _VertAnimTex_Scale("Scale", Vector) = (1,1,1,1)
        _VertAnimTex_Offset("Offset", Vector) = (0,0,0,0)
        _MatrixAnimTex("ModelTex", 2D) = "white"{}
        _MatrixAnimTex_M_Scale("ModelScale", float) = 1
        _MatrixAnimTex_M_Offset("ModelOffset", float) = 0
        _MatrixAnimTex_IT_M_Scale("ModelNormalScale", float) = 1
        _MatrixAnimTex_IT_M_Offset("ModelNormalOffset", float) = 0
        _AnimTex_AnimEnd("End (Time, Frame)", Vector) = (0, 0, 0, 0)
        _AnimTex_T("Time", float) = 0
        _AnimTex_FPS("Frame per Sec(FPS)", Float) = 30
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert
        #pragma multi_compile_instancing
        #pragma target 3.0
        #pragma multi_compile _ BILINEAR_OFF
        #include "VertexAnimationTexture.hlsl"
        #include "MatrixAnimationTexture.hlsl"

        sampler2D _MainTex;

        struct appdata {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 texcoord : TEXCOORD0;
            float4 texcoord1 : TEXCOORD1;
            float4 texcoord2 : TEXCOORD2;
            float4 texcoord3 : TEXCOORD3;
            float4 texcoord4 : TEXCOORD4;
            UNITY_VERTEX_INPUT_INSTANCE_ID
            uint vid : SV_VertexID;
        };

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void vert(inout appdata v) {
            float t = UNITY_ACCESS_INSTANCED_PROP(_AnimTex_T_arr, _AnimTex_T);
            t = clamp(t, 0, _AnimTex_AnimEnd.x);
            v.vertex.xyz = AnimTexVertexPos(v.vid, t);
            v.normal = normalize(AnimTexNormal(v.vid, t));

            //Some local pivot animation here.

            float meshId = v.texcoord4.x;
            float4x4 Matrix_M = ModelMatrixAnimTex(t, meshId);
            v.vertex = mul(Matrix_M, float4(v.vertex.xyz, 1));

            //High performance but low precision.
            //float3x3 Matrix_ITM = InvTransModelMatrixAnimTex(t, meshId);
            //v.normal = mul(Matrix_ITM, v.normal.xyz);

            //High precision but calculation cost is higher than above.
            v.normal = mul(transpose(Inverse(Matrix_M)), float4(v.normal.xyz, 1));
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack Off
}
