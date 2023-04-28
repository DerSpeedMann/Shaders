Shader "Unlit/Skinns" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Details ("Details", 2D) = "black" {}
        _Mask ("Mask", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct MeshData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            sampler2D _Details;
            sampler2D _Mask;

            
            Interpolators vert (MeshData v) {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target {
                float4 maintex = tex2D( _MainTex, i.uv ); 
                float4 details = tex2D( _Details, i.uv );
                float pattern = tex2D( _Mask, i.uv ).x;

                float4 finalColor = lerp( details, maintex, pattern );

                return finalColor;
            }
            ENDCG
        }
    }
}
