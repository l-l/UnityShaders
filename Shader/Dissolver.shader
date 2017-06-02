Shader "Custom/Dissolver" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_DissolveMap("Dissolve Shape", 2D) = "white"{}
		_DissolveVal("Dissolve Value", Range(0, 1.0)) = 1.0
			
			_Tolerance("Tolerance", Range(0.0001,1.0))=0.1
	}
	SubShader {
	
			Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		// Cull Off  // two sided
		//LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		//  the :fade parameter allows to fade out specular hightlights & reflections as well, makes it completly transparent
		#pragma surface surf Standard fullforwardshadows alpha:fade 

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _DissolveMap; float _DissolveVal; 
		float _Tolerance;
		struct Input {
			float2 uv_MainTex;
			half2 uv_DissolveMap;
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
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;

			half4 dissolve = tex2D(_DissolveMap, IN.uv_DissolveMap); 
			half4 clear = half4(0.0,0.0,0.0,0.0);
		//	int isClear = int(dissolve.r - (_DissolveVal + _LineWidth) + 0.99);
			float t = _Tolerance;
			float al = dissolve.r -( _DissolveVal+t)+1.0;

			
			al=clamp(al, 1.0-t, 1.0);
			al = (al-1.0+t) / t;
			al = clamp(al, 0.0, 1.0);
			
		
		//	o.Albedo = lerp(o.Albedo, altCol, isAtLeastLine);
			o.Alpha = al;// lerp(1.0, 0.0, al);
			//o.Alpha = 0.0;

		}
		ENDCG
	}
	FallBack "Diffuse"
}
