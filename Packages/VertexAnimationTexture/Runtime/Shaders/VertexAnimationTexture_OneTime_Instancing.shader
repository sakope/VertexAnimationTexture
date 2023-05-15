Shader "VertexAnimation/WorldCoord/OneTime_Instancing"
{ 
    Properties
    {
        _MainTex("Base (RGB) Gloss (A)", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)

        _VertAnimTex("PosTex", 2D) = "white" {}
        _VertAnimTex_Scale("Scale", Vector) = (1,1,1,1)
        _VertAnimTex_Offset("Offset", Vector) = (0,0,0,0)
        _NormalAnimTex("Normal Tex", 2D) = "white" {}
        _AnimTex_AnimEnd("End (Time, Frame)", Vector) = (0, 0, 0, 0)
        _AnimTex_T("Time", float) = 0
        _AnimTex_FPS("Frame per Sec(FPS)", Float) = 30
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma multi_compile _ BILINEAR_OFF
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "VertexAnimationTexture.hlsl"

            struct vsin {
                uint vid: SV_VertexID;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct vs2ps {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            sampler2D _MainTex;
            float4 _Color;
            
            vs2ps vert(vsin v) {
                vs2ps OUT;
                UNITY_SETUP_INSTANCE_ID(v);

                float t = UNITY_ACCESS_INSTANCED_PROP(_AnimTex_T_arr, _AnimTex_T);
                t = clamp(t, 0, _AnimTex_AnimEnd.x);
                OUT.vertex.xyz = AnimTexVertexPos(v.vid, t);
                OUT.normal = AnimTexNormal(v.vid, t);

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
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM
            #pragma multi_compile _ BILINEAR_OFF
            #pragma multi_compile_instancing
            #pragma multi_compile_shadowcaster
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "VertexAnimationTexture.hlsl"

            struct vsin {
                uint vid: SV_VertexID;
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct vs2ps {
                V2F_SHADOW_CASTER;
            };
            
            sampler2D _MainTex;
            float4 _Color;
            
            vs2ps vert(vsin v) {
                UNITY_SETUP_INSTANCE_ID(v);
                float t = UNITY_ACCESS_INSTANCED_PROP(_AnimTex_T_arr, _AnimTex_T);
                t = clamp(t, 0, _AnimTex_AnimEnd.x);
                v.vertex.xyz = AnimTexVertexPos(v.vid, t);
                v.normal = AnimTexNormal(v.vid, t);
                
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
