    Shader "Diffuse - Worldspace" {
    Properties {
        _Color ("Main Color", Color) = (1,1,1,1)
        _WallTex ("Base (RGBA)", 2D) = "white" {}
        _Tiling("Tiling", Range(0.1, 10)) = 1
        _AlphaThreshold("Alpha Threshold", Range(0.0, 1.0)) = 0.7
    }
    SubShader {
    Tags {
        "RenderType"="Transparent" // tag to inform the render pipeline of what type this is
        "Queue"="Transparent" // changes the render order
    }
        
    Cull Back
    ZWrite Off
    Blend SrcAlpha OneMinusSrcAlpha
	LOD 200
     
    CGPROGRAM
    #pragma surface surf Standard fullforwardshadows alpha:premul 
    #include "UnityCG.cginc"

    sampler2D _WallTex;
    fixed4 _Color;
    float _Tiling;
    float _AlphaThreshold;

    struct Input
    {
        float3 worldNormal;
        float3 worldPos;
    };
     
    void surf (Input IN, inout SurfaceOutputStandard  o)
    {
        float2 UV;
        fixed4 c;
     
        float3 uvs = IN.worldPos.xyz * _Tiling;
        float3 blending = saturate(abs(IN.worldNormal.xyz) - 0.4); // Change the 0.2 value to adjust blending
        blending = pow(blending, 4.0); // Change the 2.0 value to adjust blending
        blending /= dot(blending, float3(1.0, 1.0, 1.0));
        c = blending.x * tex2D(_WallTex, uvs.yz);
        c = blending.y * tex2D(_WallTex, uvs.xz) + c; // Single MAD
        c = blending.z * tex2D(_WallTex, uvs.xy) + c; // Single MAD
        
        if (c.a > _AlphaThreshold)
        {
            c.a = 1;
        }

        o.Alpha = c.a;
        o.Albedo = c.rgba * _Color;
    }
    ENDCG
    }
     
    Fallback "VertexLit"
    }
     
