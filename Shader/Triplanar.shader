Shader "Custom/Triplanar" {
	Properties{
	_Texture1("Tri Texture TopBottom", 2D) = "black" {}
	_Texture2("Tri Texture LeftRight", 2D) = "red" {} 
	_Texture3("Tri Texture FrontBack", 2D) = "red" {}
	_TriTexScale("Scale", Range(0.001,1.0)) = 0.1
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }

		CGPROGRAM
#pragma surface surf Standard

	sampler2D _Texture1;
	sampler2D _Texture2;
	sampler2D _Texture3;
	float _TriTexScale;

	struct Input {
		float2 uv_MainTex;
		float3 worldNormal;
		float3 worldPos;
		INTERNAL_DATA
	};

	void surf(Input IN, inout SurfaceOutputStandard o) {

		fixed4 col1 = tex2D(_Texture2, IN.worldPos.yz * _TriTexScale);
		fixed4 col2 = tex2D(_Texture1, IN.worldPos.xz * _TriTexScale);
		fixed4 col3 = tex2D(_Texture3, IN.worldPos.xy * _TriTexScale);

		float3 vec = abs(IN.worldNormal);
		vec /= vec.x + vec.y + vec.z + 0.001f;
		fixed4 col = vec.x * col1 + vec.y * col2 + vec.z * col3;

		o.Albedo = col;
		o.Emission = col;
	}

	ENDCG
	}
		FallBack "Diffuse"
}