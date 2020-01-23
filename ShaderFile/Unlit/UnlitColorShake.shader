Shader"SmyCustom/UnlitColorShake"{
	Properties{
		_MainTex("Texture",2D)="white"{}
		_Color("Color",Color)=(1,1,1,1)
		_Amplitude("Amplitude",Float)=1.0
		_RimPower("RimPower",Range(0.1,10.0))=3.0
	}
	SubShader{
		Tags{"RenderType"="Transparent" "Queue"="Transparent"}
	    Blend One One
		Cull Back
		ZWrite Off
		
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"UnityCG.cginc"
			#include"cginc/Noise.cginc"

			sampler2D _MainTex;
			fixed4 _Color;
			float _Amplitude;
			half _RimPower;

			struct appdata {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float2 uv:TEXCOORD0;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				float3 normal:NORMAL;
				float2 uv:TEXCOORD0;
				float3 viewDir:TEXCOORD1;
			};

			v2f vert(appdata v) {
				v2f o;
				//頂点方向にランダムに動かす
				v.vertex.xyz += v.normal*_Amplitude*noise(v.vertex.xyz*_Time.y);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.uv = v.uv;
				//視線ベクトル
				o.viewDir = WorldSpaceViewDir(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) :SV_Target{
				float3 N=normalize(i.normal);             //法線ベクトル
				float3 V = normalize(i.viewDir);          //視線ベクトル
				float rim = 1.0f - saturate(dot(V, N));   //内積
				fixed4 rimColor = pow(rim, _RimPower);	  //リムライトの色を決める
				i.uv += float2(_Time.x, 0);
				fixed4 tex = tex2D(_MainTex,i.uv);
				fixed4 color = tex * rimColor*_Color;
				return color;
			}
			ENDCG
		}
	}
}