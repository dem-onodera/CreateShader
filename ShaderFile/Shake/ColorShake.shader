Shader"SmyCustom/ColorShake"{
	Properties{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_Amplitude("Amplitude", float) = 1.0
		_RimPower("RimPower", Range(0.1, 10.0)) = 3.0
	}
	SubShader{
			Tags{"RenderType"="Transparent" "Queue"="Transparent"}
			Blend One One
			ZWrite Off

			CGPROGRAM
			#pragma surface surf Lambert vertex:vert
			#pragma target 3.0
			#include"cginc/Noise.cginc"

			sampler2D _MainTex;
			float _Amplitude;
			float4 _Color;
			half _RimPower;

			struct Input {
				float2 uv_MainTex;
				float3 viewDir;
			};

			void vert(inout appdata_full v) {
				v.vertex.xyz += v.normal*_Amplitude*noise(v.vertex.xyz*_Time.y);
			}
			void surf(Input IN, inout SurfaceOutput o)
			{
				float rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
				float3 rimColor = pow(rim, _RimPower);
				IN.uv_MainTex += float2(_Time.x, 0);
				o.Emission = tex2D(_MainTex, IN.uv_MainTex).rgb * rimColor * _Color;
			}
			ENDCG
	}
	Fallback "Diffuse"
}