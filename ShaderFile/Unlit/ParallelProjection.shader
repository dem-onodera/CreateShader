Shader"SmyCustom/ParallelProjection"{
	Properties{
		_MainTex("Texture",2D)="white"{}
		_Rotate("Rotate",Vector)=(0,0,0,0)
	}
	SubShader{
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"UnityCG.cginc"
			#include"cginc/TransformationMatrix.cginc"


			sampler2D _MainTex;
			float4 _Rotate;

			struct appdata {
				float4 vertex:POSITION;
				float2 uv:TEXCOORD0;
			};

			struct v2f {
				float4 position:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			v2f vert(appdata v) {
				v2f o;
				v.vertex = mul(RotateZ(_Rotate.z), v.vertex);
				v.vertex = mul(RotateX(_Rotate.x), v.vertex);
				v.vertex = mul(RotateY(_Rotate.y), v.vertex);

				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = v.vertex.xy;
				return o;
			}

			fixed4 frag(v2f i) :SV_Target{
				//なぜかずれる・・・ので、補正値を加える(真ん中に寄せる)
				i.uv+=float2(0.5f,0.5f);
				fixed4 col = tex2D(_MainTex,i.uv);
				return col;
			}
			ENDCG
		}
	}
}