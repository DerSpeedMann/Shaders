Shader "Framework/WindAffected" 
{
	Properties 
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex ("Albedo", 2D) = "white" {}
		_Cutoff("Cutoff", float) = 0.5
	}

	SubShader 
	{
		Tags 
		{ 
			"RenderType" = "Opaque"
			"DisableBatching" = "True"
		}

		Cull Off
		LOD 200
		
		CGPROGRAM
			 
		#pragma surface surf StandardSpecular addshadow vertex:vert alphatest:_Cutoff
		#pragma target 3.0
		#include "UnityCG.cginc"
		
		#ifndef PI
		#define PI 3.14159265359f
		#endif 

		sampler2D _MainTex;
		fixed4 _Color;

		struct appdata
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
			float4 texcoord1 : TEXCOORD1;
			float4 texcoord2 : TEXCOORD2;
			float4 color : COLOR;
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		struct Input 
		{
			float2 uv_MainTex;
			float3 color;
		};
		inline float4 RotateAroundXInRadians(float4 vertex, float alpha) {
			float sina, cosa;
			sincos(alpha, sina, cosa);
			float2x2 m = float2x2(cosa, -sina, sina, cosa); 
			return float4(mul(m, vertex.yz), vertex.xw).yzxw;
		}
		inline float4 RotateAroundYInRadians (float4 vertex, float alpha){
            float sina, cosa;
            sincos(alpha, sina, cosa);
            float2x2 m = float2x2(cosa, sina, -sina, cosa);
            return float4(mul(m, vertex.xz), vertex.yw).xzyw;
        }
		inline float4 RotateAroundZInRadians (float4 vertex, float alpha){
            float sina, cosa;
            sincos(alpha, sina, cosa);
            float2x2 m = float2x2(cosa, -sina, sina, cosa);
            return float4(mul(m, vertex.xy), vertex.zw).xyzw;
        }
		inline float4 RotateAroundYInDegrees (float4 vertex, float degrees){
            float alpha = degrees * UNITY_PI / 180.0;
            float sina, cosa;
            sincos(alpha, sina, cosa);
            float2x2 m = float2x2(cosa, -sina, sina, cosa);
            return float4(mul(m, vertex.xz), vertex.yw).xzyw;
        }

		inline float3 getRotation(){
			float3 R = float3(
			atan2(unity_WorldToObject[2].y,unity_WorldToObject[2].z) * -1.0,
			atan2(unity_WorldToObject[2].x,unity_WorldToObject[2].z),
			atan2(unity_WorldToObject[2].y,unity_WorldToObject[2].x)
			);
			return R < 0 ? 2 * PI - abs(R) : R;
		}
		inline float getXRotation(){
			return atan2(unity_ObjectToWorld[2].y,unity_ObjectToWorld[2].z);
		}
		inline float getYRotation(){
			return atan2(unity_ObjectToWorld[2].x,unity_ObjectToWorld[2].z);
		}
		inline float getZRotation(){
			return atan2(unity_ObjectToWorld[0].y,unity_ObjectToWorld[0].x);
		}
		inline float4x4 getXRotationMatrix(float alpha){
			float sina, cosa;
			sincos(alpha, sina, cosa);
			return float4x4(1, 0,    0,     0,
							0, cosa, sina, 0,
							0, -sina, cosa,  0,
							0, 0,    0,     1);
		}
		inline float4x4 getYRotationMatrix(float alpha){
			float sina, cosa;
			sincos(alpha, sina, cosa);
			return float4x4(cosa, 0, -sina, 0,
							0, 	  1, 0,     0,
							sina, 0, cosa,  0,
							0,    0, 0,     1);
		}
		inline float4x4 getZRotationMatrix(float alpha){
			float sina, cosa;
			sincos(alpha, sina, cosa);
			return float4x4(cosa, -sina, 0, 0,
							sina, cosa,  0, 0,
							0,    0,     1, 0,
							0,    0,     0, 1);
		}
		void vert(inout appdata IN, out Input OUT)
		{
			UNITY_INITIALIZE_OUTPUT(Input, OUT);

		#ifdef GRASS_WIND_ON
			//float windInfluence = IN.color.r;
			//float4 worldPos = mul(unity_ObjectToWorld, IN.vertex);
			//windAnimation(worldPos, windInfluence);
			//IN.vertex = mul(unity_WorldToObject, worldPos);
		#endif
			float windInfluence = IN.color.r;
			//OUT.wind = windInfluence;
			float PiHalf = PI/2;
			float PiQuat = PiHalf/2;
			
			
			
			float4x4 compensatedMatrix = unity_ObjectToWorld + getXRotationMatrix(PiHalf);
			// rotate by angle and windInfluence
			//float rotZ = atan2(compensatedMatrix[0].y, compensatedMatrix[0].x)*2;
			float3 objWorldForward = unity_ObjectToWorld._m02_m12_m22;
			float rotZ = getZRotation();
			float rotX = getXRotation();
			float rotY = getYRotation();

			// fix 180 resulting in -180
			if (rotZ < 0) {
				rotZ += PI * 2;
			}
			if (rotX < 0) {
				rotX += PI * 2;
			}
			// TODO: check y rotation not correct
			if (rotY >= PiHalf && rotY <= 3*PiHalf) {
				rotY += PiHalf;
			}
			//	rotY += PI * 2;
			//}

			// multiplication order y x z to undo
			IN.vertex = mul(getYRotationMatrix(-rotY), IN.vertex);
			IN.vertex = mul(getXRotationMatrix(rotX), IN.vertex);
			IN.vertex = mul(getZRotationMatrix(rotZ), IN.vertex);
			
			// set debug colors
			if(rotY < PiHalf){
				OUT.color = float3(255,0,0);
			}else if(rotY > PiHalf){
				OUT.color = float3(0,255,0);
			}else if(rotY == PiHalf){
				OUT.color = float3(0,0,255);
			}else{
				OUT.color = float3(0,0,0);
			}

			/*
			if(rotY % PI == 0){
				rotY = rotY*2;
			}else{
				rotY = rotY*2+PI;
			}
			*/
			//IN.vertex = mul(getZRotationMatrix(rotZ), IN.vertex);

			//compensatedMatrix = compensatedMatrix + getZRotationMatrix(rotZ);
			//rotY = atan2(compensatedMatrix[2].x,compensatedMatrix[2].z);
			//rotY = rotY*2+PI;
			//IN.vertex = mul(getYRotationMatrix(rotY), IN.vertex);
			
			
			
			
			//IN.vertex = mul(getXRotationMatrix(PiHalf), IN.vertex);
			
			
			//IN.vertex = mul(getXRotationMatrix(PiHalf), IN.vertex);
			
			
			/*
			if(rotY % PI == 0){
				rotY = rotY*2;
			}else{
				rotY = rotY*2+PI;
			}
			IN.vertex = RotateAroundYInRadians(IN.vertex, rotY);
			IN.vertex = RotateAroundZInRadians(IN.vertex, rotZ*2 + rotY);
			*/
		}

		void surf(Input IN, inout SurfaceOutputStandardSpecular OUT)
		{
			OUT.Albedo = IN.color;
			OUT.Alpha = 1;
			OUT.Specular = 0.0;

			//fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			//OUT.Albedo = c.rgb;
			//OUT.Alpha = c.a;
			//OUT.Specular = 0.0;
		}

		ENDCG
	}

	FallBack "Standard"
}
