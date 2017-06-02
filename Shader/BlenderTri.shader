Shader "Custom/BlenderTri" {
	Properties{

		_ObjectZ("Object Front Z",Range(0,100)) = 0
		_ObjectDepth("Object Depth",Range(0,10)) =2
		_ObjectRot("Object Rotation",Range(0,360)) = 0
		_TriTexTB_Alb_A("Tri Texture TopBottom", 2D) = "white" {}
		_TriTexLR_Alb_A("Tri Texture LeftRight", 2D) = "red" {}
		_TriTexFB_Alb_A("Tri Texture FrontBack", 2D) = "green" {}
		/*
		_TriTexTB_Alb_B("Tri Texture TopBottom", 2D) = "white" {}
		_TriTexLR_Alb_B("Tri Texture LeftRight", 2D) = "red" {}
		_TriTexFB_Alb_B("Tri Texture FrontBack", 2D) = "green" {}
		*/
		_TriTexScale("Tri Tex Scale", Range(0.001,1.0)) = 0.1

		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo 1 (RGB)", 2D) = "white" {}
		_SecondTex("Albedo 2 (RGB)", 2D) = "white" {}
		
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		
		_NormalMap("Normal Map", 2D) = "white"{}
		_NormalVal("Normal Value",Range(0.0,22.0))=1.0

		_OcclusionMap("Occlusio Map", 2D) = "white"{}
		_OcclusionVal("Occlusio Value",Range(0.0,1.0)) = 1.0

		//---------------------------
		_DissolveMap("Dissolve Shape", 2D) = "white"{}
		_DissolveVal("Dissolve Value", Range(0.01, 1.0)) = 1.0
			//_LineWidth("Line Width", Range(0.0, 0.2)) = 0.1
			//_LineColor("Line Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Tolerance("Tolerance", Range(0.0001,1.0)) = 0.1

		_ClipWorldY("Cutoff World Y",Range(0.0,16.0)) = 1.0
	}


		SubShader{

			Tags{ "RenderType" = "Opaque" }
			Blend SrcAlpha OneMinusSrcAlpha
			// Cull Off  // two sided
			//LOD 200
			//	Lighting On
			//	Specular On
			//	SeparateSpecular On
			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			//  the :fade parameter allows to fade out specular hightlights & reflections as well, makes it completly transparent
			#pragma surface surf Standard fullforwardshadows
			#pragma shader_feature _NORMALMAP

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0
			#include "UnityCG.cginc"

			//tri
			sampler2D _TriTexTB_Alb_A; sampler2D _TriTexLR_Alb_A; sampler2D _TriTexFB_Alb_A;
			float _TriTexScale;
			float _ObjectDepth; float _ObjectZ; float _ObjectRotation;
			sampler2D _MainTex;
			sampler2D _NormalMap; sampler2D _DissolveMap; sampler2D _OcclusionMap;
			sampler2D _SecondTex;
			float _NormalVal; float _OcclusionVal; 
			float4 _LineColor; float _DissolveVal; float _ClipWorldY; float _Tolerance;

			struct Input {
				float2 uv_MainTex;
				float2 uv_NormalMap;
				half2 uv_DissolveMap;
				float3 worldNormal;
				float3 worldPos;
			
				INTERNAL_DATA
			};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling

		
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			
			// TRIPLANAR
			float3 wp = IN.worldPos;
			fixed4 col1 = tex2D(_TriTexLR_Alb_A, IN.worldPos.yz * _TriTexScale);
			fixed4 col2 = tex2D(_TriTexTB_Alb_A, IN.worldPos.xz * _TriTexScale);
			fixed4 col3 = tex2D(_TriTexFB_Alb_A, IN.worldPos.xy * _TriTexScale);
			/*
			fixed4 nrm1 = tex2D(_NormalMap, IN.worldPos.yz * _TriTexScale);
			fixed4 nrm2 = tex2D(_NormalMap, IN.worldPos.xz * _TriTexScale);
			fixed4 nrm3 = tex2D(_NormalMap, IN.worldPos.xy * _TriTexScale);
			*/
			float3 vec = abs(IN.worldNormal);
			//float3 sqAbsNormalDir = vec*vec;
			vec /= vec.x + vec.y + vec.z + 0.001f;
			fixed4 colA = vec.x * col1 + vec.y * col2 + vec.z * col3;
			//fixed4 nrmA = vec.x * nrm1 + vec.y * nrm2 + vec.z * nrm3;
			//float3 normalLocal = sqAbsNormalDir.x * nrm1 + sqAbsNormalDir.y * nrm2 + sqAbsNormalDir.z * nrm3;
		//	TANGENT_SPACE_ROTATION; // is a unitdefine the defines "rotation"
			//	float3 normalDirection = normalize(mul(normalLocal, rotation)); // Perturbed normals
	
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed4 c2 = tex2D(_SecondTex, IN.uv_MainTex) * _Color;
		

			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
	
			o.Alpha = c.a;
		//	fixed4 normal = tex2D(_NormalMap, IN.worldPos.xy * _TriTexScale);
			
			
			
			half4 dissolve = tex2D(_DissolveMap, IN.uv_DissolveMap); 
			//half4 clear = half4(0.0,0.0,0.0,0.0);
			//int isClear = int(dissolve.r - (_DissolveVal + _LineWidth) + 0.99);
			float t = _Tolerance;
			float al = dissolve.r -( _DissolveVal+t)+1.0;
			//clip(_ClipWorldY - IN.worldPos.y);
			
			al=clamp(al, 1.0-t, 1.0);
			al = (al-1.0+t) / t;
			al = clamp(al, 0.0, 1.0);
			//int isAtLeastLine = int(dissolve.r - (_DissolveVal)+0.99);
			//half4 altCol = lerp(_LineColor, clear, isClear);
			float depthFade = (_ObjectDepth - clamp(0, _ObjectDepth, (_ObjectZ - IN.worldPos.z))) / _ObjectDepth;
			o.Albedo = lerp(colA.rgb, c2.rgb, al) *depthFade;
			//o.Alpha = al;// lerp(1.0, 0.0, al);
			//o.Alpha = 0.0;
			//o.Normal = UnpackScaleNormal(nrmA, _NormalVal);// UnityObjectToWorldNormal(normal.xyz) *_NormalVal;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
