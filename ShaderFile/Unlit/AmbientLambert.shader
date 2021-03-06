﻿Shader "SmyCustom/AmbientLambert"{
	Properties{
		_BaseColor("Base Color",Color) = (1,1,1,1)
		_LightValue("Light Value",Range(0,2)) = 0
	}
		SubShader{
			Pass{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include"UnityCG.cginc"

				float _LightValue;
				fixed4 _BaseColor;

				struct appdata {
					float4 pos:POSITION;
					float3 normal:NORMAL;
				};

				struct v2f {
					float4 pos:SV_POSITION;
					float3 normal:NORMAL;
				};

				v2f vert(appdata v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.pos);
					o.normal = UnityObjectToWorldNormal(v.normal);
					return o;
				}

				//ランバート+環境色
				fixed4 frag(v2f i) :SV_Target{
					float3 N = normalize(i.normal);//法線ベクトル
					float3 L = normalize(_WorldSpaceLightPos0.xyz);//ライトの入射ベクトル

					fixed4 I = _LightValue * _BaseColor;//環境色
					//環境色+Lambert = 黒い部分が少なくなる
					fixed4 col = I + (_LightValue / 2.0f)*_BaseColor*max(0,dot(N, L));

					return col;
				}
				ENDCG
			}
	}
}
