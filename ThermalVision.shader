Shader "MM/ThermalOryVision"
{
    Properties
    {
        _HotMask ("Hot Mask", 2D) = "white" {} //Colorless Hot sources mask
		_DepthMask ("Depth Mask", 2D) = "white" {} //Colorless Depth mask
		//_RenderTex ("Colorful Render Texture", 2D) = "black" {}
		_Intensity ("Visibility Range", Float) = 1
		_HotColIntensity ("Hot Sources Color Intensity", Range(0, 1)) = 0.8
		_HotCol ("Hot Sources Color", Color) = (1, 0, 0, 1) //Hot Sources Color
		_ColdCol ("Cold Sources Color", Color) = (1, 1, 1, 1) //Cold Sources Color
		_InterfaceMask ("Interface Mask", 2D) = "white" {} //Interface Colorless mask
		_InterfaceTex ("Interface Texture", 2D) = "white" {} //Interface Colorful Texture
    }
	
    SubShader
    {
		Tags { "RenderType" = "Opaque" }
		
        CGPROGRAM
			#pragma surface surf Lambert
			//#pragma target 3.5
			#include "UnityCG.cginc"

			sampler2D _HotMask, _DepthMask, _InterfaceMask, _InterfaceTex; //_RenderTex
			fixed3 _HotCol, _ColdCol;
			float _Intensity, _HotColIntensity;

			struct Input
			{
				half2 uv_HotMask, uv_DepthMask, uv_RenderTex, uv_InterfaceMask, uv_InterfaceTex; //uv_RenderTex
			};
			
			void surf(Input IN, inout SurfaceOutput o)
			{
				fixed3 hotmask = tex2D(_HotMask, IN.uv_HotMask);
				fixed3 depthmask = tex2D(_DepthMask, IN.uv_DepthMask);
				fixed3 interfacemask = tex2D(_InterfaceMask, IN.uv_InterfaceMask);
				hotmask = (hotmask.r + hotmask.g + hotmask.b)/3;
				depthmask = (depthmask.r + depthmask.g + depthmask.b)/3;

				if(hotmask.r != depthmask.r) hotmask.r = 0;
				depthmask.r -= hotmask.r; //Now depthmask is "coldmask"
				
				//if(hotmask.r != 0) hotmask.r = 1; if(depthmask.r != 0) depthmask.r = 1; //Final thermal mask
				if(hotmask.r != 0) hotmask.r = _HotColIntensity;
				depthmask.r *= _Intensity;
				
				o.Albedo = _HotCol * hotmask.r + _ColdCol * depthmask.r; //Thermal mask painted in hot and cold colors
				
				o.Albedo = o.Albedo * interfacemask.r + tex2D(_InterfaceTex, IN.uv_InterfaceTex);

				o.Emission = o.Albedo;
			}
		ENDCG
    }
	
	Fallback "Diffuse" //the shader was written by КОТЯРА. he's noob in writting shaders. call discord КОТЯРА 7702. he's good man
}
