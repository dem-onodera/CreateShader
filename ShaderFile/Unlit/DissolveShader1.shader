//https://www.youtube.com/watch?v=ki0LObpYG3I&t=74s
Shader "SmyCustom/DissolveShader1"
{
	Properties
	{
		_DissolveAmount("Dissolve Amount",Range(0,1)) = 0.5
		_NoiseScale("Noise Scale",Float) = 0
		_Color("Color",Color) = (1,1,1,1)
		[HDR]_EmissiveColor("Emissive Color",Color) = (1,1,1,1)
		_BorderSize("Border Size",Range(-30,1)) = 1
	}
		SubShader
	{
		Tags { "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float _DissolveAmount;
			float _NoiseScale;
			float4 _EmissiveColor;
			float _BorderSize;

			//sampler2D _MainTex;
			//float4 _MainTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//Dissolveをするノイズを生成。Scaleで面積を増やす
				float n = noise(float3(i.uv*_NoiseScale,0));
				n += _DissolveAmount;

				float c = clamp(n, 0, 1);
				//Emissive
				float r = remap(c, 0, 1, _BorderSize, 1);
				float emission = clamp(r, 0, 1);
				fixed4 e_col = emission * _EmissiveColor;
				//ディソブルテクスチャ
				fixed4 n_col = fixed4(n, n, n, 1);
				//ShaderGraph:AlphaClipThreshold
				n_col.a = step(0.9, n)*(1-step(1,1-_DissolveAmount));
				return n_col * e_col;
			}
			ENDCG
		}
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

			float _DissolveAmount;
			float _NoiseScale;
			float4 _Color;
			float4 _EmissiveColor;
			float _BorderSize;

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				//Dissolveをするノイズを生成。Scaleで面積を増やす
				float n = noise(float3(i.uv*_NoiseScale,0));
				n += _DissolveAmount;

				float c = clamp(n, 0, 1);
				fixed4 n_col = fixed4(n, n, n, 1);
				//ShaderGraph:AlphaClipThreshold
				n_col.a = step(1, n);
                return n_col*_Color;
            }
            ENDCG
        }
    }
}
