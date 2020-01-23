Shader"SmyCustom/Speqular"{
	Properties{
		_LightValue("Light Value",Range(0,2))=1
		_BaseColor("BaseColor",Color)=(1,1,1,1)
		_SpeqularValue("Speqular Value",Range(0,2))=1
		_SpeqularColor("Speqular Color",Color)=(1,1,1,1)
		_SpeqularIndex("Speqular Index",Range(1,100))=2
	}
	SubShader{
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"UnityCG.cginc"

		    float _LightValue;
			fixed4 _BaseColor;
			float _SpeqularValue;
			fixed4 _SpeqularColor;
			float _SpeqularIndex;

			struct appdata {
				float4 pos:POSITION;
				float3 normal:NORMAL;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				float3 normal:NORMAL;
				float3 view:TEXCOORD1;
			};

			v2f vert(appdata v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.pos);            //頂点の位置を取得
				o.normal = UnityObjectToWorldNormal(v.normal);  //法線ベクトルの取得
				o.view = WorldSpaceViewDir(v.pos);              //視線ベクトルの取得
				return o;
			}

			//フォン鏡面反射
			fixed4 frag(v2f i) :SV_Target{
				float3 N = normalize(i.normal);                  //法線ベクトル
				float3 L = normalize(_WorldSpaceLightPos0.xyz);  //ライトのベクトル
				float3 E = normalize(i.view);                    //視線ベクトル

				//反射ベクトル
				fixed3 R = -E + 2 * (dot(N, E)*N);
				//環境色
				fixed4 Am = _LightValue * _BaseColor;      
				//Lambert
				fixed4 La = (_LightValue / 2.0f)*_BaseColor*max(0, dot(N, L));        
				//スペキュラー
				fixed4 Sp = _SpeqularValue * _SpeqularColor* pow(max(0,dot(L, R)), _SpeqularIndex);
				//合成
				fixed4 I = Am + La + Sp;
				return I;
			}
			ENDCG
		}
	}
}