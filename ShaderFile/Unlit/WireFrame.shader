Shader"SmyCustom/WireFrame"{
	Properties{
		_MainColor("Main Color",Color)=(1,1,1,1)
		[HDR]
		_WireColor("WireFrame Color",Color)=(1,1,1,1)
		_LineWidth("Line Width",Range(0,1))=0.1
		_ParcelSize("ParcelSize",Range(0,10))=1
		[Toggle]
		_MoveFlag("Move Flag",Float)=1
	}
	SubShader{
		Tags{"Queue"="Transparent" "RenderType"="Transparent"}
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed4 _MainColor;
			fixed4 _WireColor;
			float _LineWidth;
			float _ParcelSize;
			float _MoveFlag;

			struct appdata {
				float4 vertex:POSITION;
			};

			struct v2f {
				float4 position: SV_POSITION;
				float3 worldPos:TEXCOORD0;
			};

			v2f vert(appdata v) {
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}

			//返す数値はstepなので0 or 1
			//左辺:ラインの長さの二倍 右辺:引数の数値/ラインの感覚に長さを足す
			half CulcWireFrameNum(float pos) {
				return step(_LineWidth * 2, frac(pos / _ParcelSize) + _LineWidth);
			}

			fixed4 frag(v2f i) :SV_Target{
				i.worldPos.z += _Time.y*_MoveFlag;
				//ワイヤー数値を計算(frac()で小数部分を取得 = マス目が取れる)
				half val1 = CulcWireFrameNum(i.worldPos.x);
				half val2 = CulcWireFrameNum(i.worldPos.y);
				half val3 = CulcWireFrameNum(i.worldPos.z);
				fixed val = 1 - (val1*val2*val3);
				//メインの色とワイヤーの色を補完する
				fixed4 col = lerp(_MainColor, _WireColor, val);
				return col;
			}
			ENDCG
		}
	}
}