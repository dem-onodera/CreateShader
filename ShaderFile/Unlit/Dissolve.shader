Shader"SmyCustom/Dissolve"{
	Properties{
		_MainTex("Texture",2D)="white"{}
		_DissolveTex("DissolveTex",2D)="white"{}
		_Smooth("Smooth",Range(0,1)) = 0
	}
	SubShader{
		Tags{"RenderType"="Transparent" "Queue"="Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha

		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _DissolveTex;
			float _Smooth;

			struct appdata {
				float4 vertex:POSITION;
				float4 normal:NORMAL;
				float2 uv:TEXCOORD0;
			};

			struct v2f {
				float4 position:POSITION;
				float3 normal:NORMAL;
				float2 uv:TEXCOORD0;
			};

			v2f vert(appdata v){
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldDir(v.normal);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) :SV_Target{
				float r = tex2D(_DissolveTex,i.uv).r;
				float alpha = smoothstep(0, r, _Smooth);
				fixed4 col = tex2D(_MainTex, i.uv);
				col.a = alpha;
				return col;
			}
			ENDCG
		}
	}
}