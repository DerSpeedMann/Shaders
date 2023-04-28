
Shader "Unlit/BillboardShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags {
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
            }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // User-specified uniforms            
            uniform sampler2D _MainTex;        
            fixed4 _Color;
            float4 _MainTex_ST;

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP

             struct vertexInput {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 tex : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct vertexOutput {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR;
                float2 tex : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            vertexOutput vert (vertexInput v)
            {
                float3 scale = float3(
                    length(unity_ObjectToWorld._m00_m10_m20),
                    length(unity_ObjectToWorld._m01_m11_m21),
                    length(unity_ObjectToWorld._m02_m12_m22)
                );


                vertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.worldPosition = v.vertex;
                
                o.pos = mul(UNITY_MATRIX_P, 
                    mul(UNITY_MATRIX_MV, float4(0.0, 0.0, 0.0, 1.0))
                    + float4(v.vertex.x, v.vertex.y, 0.0, 0.0)
                    * float4(scale.x, scale.y, 1.0, 1.0));
                o.tex = TRANSFORM_TEX(v.tex, _MainTex);
                o.color = v.color * _Color;
                return o;
            }

            fixed4 frag (vertexOutput IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.tex)) * IN.color;

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif
                return color;//tex2D(_MainTex, float2(input.tex.xy));   
            }
            ENDCG
        }
    }
}
