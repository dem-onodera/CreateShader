//https://www.youtube.com/watch?v=E_Hl10Awyjc
Shader "SmyCustom/RefractiveShader"
{
	Properties
	{
		_NoiseScale("Noise Scale",Float) = 0.5
		_NoiseSpeed("Noise Speed",Float) = 0.5
		_NoiseOffset("Noise Offset",Vector) = (0,0,1,1)
		_RefrectionStrength("refrection Strength",Float) = 1
		[HDR]_EmissionColor("Emission Color",Color) = (1,1,1,1)
		_RimPower("Rim Power",Float) = 3
	}
		SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha

		GrabPass {"_GrabPassTexture"}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include"../cginc/SmyMethod.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal:NORMAL;
				float3 worldPos:TEXCOORD1;
				float4 screenPos:TEXCOORD2;
			};

			float _NoiseScale;
			float _RefrectionStrength;
			float _NoiseSpeed;
			float2 _NoiseOffset;
			sampler2D _GrabPassTexture;
			float4 _EmissionColor;
			float _RimPower;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;
				o.uv = v.uv;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//Rim
				float3 N = normalize(i.normal);
				float3 L = normalize(i.worldPos.xyz - _WorldSpaceCameraPos.xyz);
				float d = 1 - abs(dot(N, L));
				d = pow(d, _RimPower);

				float sp1 = _NoiseSpeed * _Time.w;
				float sp2 = sp1 * _NoiseOffset.x;
				float sp3 = sp1 * _NoiseOffset.y;

				fixed2 noiseUV = i.uv + fixed2(sp2, sp3);

				fixed n = noise(float3(noiseUV*_NoiseScale,0));
				n = n - 0.5;
				n *= _RefrectionStrength;

				fixed4 uv = i.screenPos + n;

				fixed4 col = tex2Dproj(_GrabPassTexture,uv);
				fixed4 alpha = col + fixed4(1,1,1,d);
				col.xyz = _EmissionColor.xyz;
				col.a = alpha.a;
				return col;
			}
			ENDCG
		}
	}
}
