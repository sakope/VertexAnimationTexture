Shader "VertexAnimation/LocalCoord_Matrix_MergedMesh/AutoRepeat" {
    Properties{
        _MainTex("Base (RGB) Gloss (A)", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)

        _VertAnimTex("PosTex", 2D) = "white" {}
        _VertAnimTex_Scale("Scale", Vector) = (1,1,1,1)
        _VertAnimTex_Offset("Offset", Vector) = (0,0,0,0)
        _NormalAnimTex("Normal Tex", 2D) = "white" {}
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
        Cull Off

        Pass {
            CGPROGRAM
            #pragma multi_compile _ BILINEAR_OFF
            #pragma vertex vert
            #pragma fragment frag
            //#pragma enable_d3d11_debug_symbols
            #include "UnityCG.cginc"
            #include "VertexAnimationTexture.hlsl"
            #include "MatrixAnimationTexture.hlsl"

            struct vsin {
                uint vid: SV_VertexID;
                float2 texcoord : TEXCOORD0;
                float2 meshId : TEXCOORD4;
            };

            struct vs2ps {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _Color;

            vs2ps vert(vsin v) {
                vs2ps OUT;
                float t = _AnimTex_T + _Time.y;
                t = clamp(t % _AnimTex_AnimEnd.x, 0, _AnimTex_AnimEnd.x);
                OUT.vertex.xyz = AnimTexVertexPos(v.vid, t);
                OUT.normal = AnimTexNormal(v.vid, t);

                //Some local pivot animation here.

                float4x4 Matrix_M = ModelMatrixAnimTex(t, v.meshId.x);
                OUT.vertex = mul(Matrix_M, float4(OUT.vertex.xyz, 1));

                //High performance but low precision.
                //float3x3 Matrix_ITM = InvTransModelMatrixAnimTex(t, v.meshId.x);
                //OUT.normal = mul(Matrix_ITM, OUT.normal);

                //High precision but calculation cost is higher than above.
                OUT.normal = mul(transpose(InverseMatrix((float3x3)Matrix_M)), OUT.normal);

                OUT.vertex = UnityObjectToClipPos(float4(OUT.vertex.xyz, 1));
                OUT.normal = UnityObjectToWorldNormal(OUT.normal);
                OUT.uv = v.texcoord;
                return OUT;
            }

            float4 frag(vs2ps IN) : COLOR {
                return tex2D(_MainTex, IN.uv) * _Color;
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM
            #pragma multi_compile _ BILINEAR_OFF
            #pragma multi_compile_shadowcaster
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "VertexAnimationTexture.hlsl"
            #include "MatrixAnimationTexture.hlsl"

            struct vsin {
                uint vid: SV_VertexID;
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
                float2 meshId : TEXCOORD4;
            };

            struct vs2ps {
                V2F_SHADOW_CASTER;
            };

            sampler2D _MainTex;
            float4 _Color;

            vs2ps vert(vsin v) {
                float t = _AnimTex_T + _Time.y;
                t = clamp(t % _AnimTex_AnimEnd.x, 0, _AnimTex_AnimEnd.x);
                v.vertex.xyz = AnimTexVertexPos(v.vid, t);
                v.normal = AnimTexNormal(v.vid, t);

                //Some local pivot animation here.

                float4x4 Matrix_M = ModelMatrixAnimTex(t, (uint)v.meshId.x);
                v.vertex = mul(Matrix_M, float4(v.vertex.xyz, 1));
                //High performance but low precision.
                //float3x3 Matrix_ITM = InvTransModelMatrixAnimTex(t, v.meshId.x);
                //v.normal = mul(Matrix_ITM, v.normal);

                //High precision but calculation cost is higher than above.
                v.normal = mul(transpose(InverseMatrix((float3x3)Matrix_M)), v.normal);


                vs2ps OUT;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(OUT);
                return OUT;
            }

            float4 frag(vs2ps IN) : COLOR {
                SHADOW_CASTER_FRAGMENT(IN);
            }
            ENDCG
        }
    }
    FallBack Off
}
