//参考URL：https://www.youtube.com/watch?v=glSsaRpHKos&t=364s
Shader "SmyCustom/FlamesShader"
{
    Properties
    {
		[HDR]_Color("Frame Color",Color)=(1,1,1,1)               //メインとなる炎の色
        _MainTex ("Texture", 2D) = "white" {}                    //Flame用テクスチャ
		_DistortionSpeed("Distortion Speed",Vector)= (0,-0.3,1,1)   //通常ノイズ:スクロールの速度
		_DistortionScale("Distortion Scale",Float)=5            //通常ノイズ:ノイズの大きさ
		_DistortionAmount("Distortion Amount",Range(0,1))=0.1    //通常ノイズ:Lerpの補間
		_DissolveSpeed("Dissolve Speed",Vector)=(-0.1,-0.5,1,1)        //Volonoi:スクロールの速度
		_DissolveScale("Dissolve Scale",Float)=2                 //Volonoi:セルの個数
		_DissolveAmount("Dissolve Amount",Float)=1.2             //Volonoi:累乗用
    }
    SubShader
    {
		Tags { "RenderType" = "Opaque" "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "../cginc/SmyMethod.cginc"

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

            sampler2D _MainTex;
            float4 _MainTex_ST; //Tiling,Offsetを使用するため
			float4 _Color;
			//Noise
			float4 _DistortionSpeed;
			float _DistortionScale;
			float _DistortionAmount;//補正値
			//Volonoi
			float4 _DissolveSpeed;
			float _DissolveScale;
			float _DissolveAmount;


			//ノイズテクスチャのUVを返す
			fixed4 Gradient(float2 uv) {
				float noiseUV = noise(float3(uv, 0));
				return fixed4(noiseUV, noiseUV, noiseUV, 1);
			}

			fixed4 Volonoi(float2 uv, float scale, float distance) {
				return VolonoiNoise(uv, scale, distance);
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float2 gradientScroll = _DistortionSpeed.xy*_Time.y;
				float2 gradientUV = Gradient(i.uv+gradientScroll)*_DistortionScale;

				float2 volonoiScroll = _DissolveSpeed.xy*_Time.y;
				float2 volonoiUV = Volonoi(i.uv+volonoiScroll, _DissolveScale, 5);

				volonoiUV = pow(volonoiUV, _DissolveAmount);
				float2 mix = gradientUV * volonoiUV;
				
				//元のUV座標と求めたノイズUVのlerp
				float2 uv = lerp(i.uv, gradientUV, _DistortionAmount);
				//テクスチャの色とプロパティで指定した色を合わせる
                fixed4 tex = tex2D(_MainTex, uv);

				fixed4 flameCol = tex * fixed4(mix.x, mix.y,mix.x+mix.y, 1);
				
				fixed4 col = flameCol * _Color;
				col.a = flameCol.r;
				return col;
            }
            ENDCG
        }
    }
}
