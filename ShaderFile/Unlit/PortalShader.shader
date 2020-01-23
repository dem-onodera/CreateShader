//ワープホール:https://www.youtube.com/watch?v=w0znZIuvQ2I
Shader "SmyCustom/PortalShader"
{
    Properties
    {
		_MaskTex("Mask Texture",2D)="white"{}
		_TwirlAmount("Twirl Amount",Float)=9
		_TwirlSpeed("Twirl Speed",Float)=3
		_VolonoiScale("Scale",Float)=3
		_VolonoiDistance("Distance",Range(0,1))=1
		[HDR]_EmissionColor("Emission Color",Color)=(1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Opaque"="Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off

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

			sampler2D _MaskTex;
			float4 _MaskTex_ST;
			float _TwirlAmount;
			float _TwirlSpeed;
			float _VolonoiScale;
			float _VolonoiDistance;
			float4 _EmissionColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv =TRANSFORM_TEX(v.uv,_MaskTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed2 s = _Time.w*_TwirlSpeed;
				fixed4 twirl;
				Twirl(i.uv, float2(0.5, 0.5), _TwirlAmount, s, twirl.xy);
				//Twirlの結果をUV座標として手渡す(ShaderGraph内ではEmission扱い)
				fixed4 vol = VolonoiNoise(i.uv+twirl.xy, _VolonoiScale, _VolonoiDistance);
				//Emission
				fixed4 emissiveCol = vol * _EmissionColor;
				fixed4 tex = tex2D(_MaskTex, i.uv*_MaskTex_ST.xy + _MaskTex_ST.zw);
				emissiveCol.a = emissiveCol.r;
                return emissiveCol*tex;
            }
            ENDCG
        }
    }
}
