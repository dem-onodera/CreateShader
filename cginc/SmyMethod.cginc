#define PI 3.14159265359

//t: 時間 a: 明るさ　b: ぼかし c: 色のスケーリング
//参照:http://iquilezles.org/www/articles/palettes/palettes.htm
float3 colorPalette( float t,  float3 a,  float3 b,  float3 c,float3 d) {
    return a + b * cos(PI*2*(c*t + d));
}

//画面比の取得
float ScreenRatio(){
    return _ScreenParams.x/_ScreenParams.y;
}


//0.0～yの値に収まる数値を返す
float mod(float x, float y) {
	return x - y * floor(x / y);
}


//Twirl:https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/Twirl-Node.html
void Twirl(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
{
	//渦の中心を求める
	float2 delta = UV - Center;
	//渦の動きの強さ＊中心のベクトルの長さをかける
	float angle = Strength * length(delta);
	//アルキメデスの螺旋方程式x = a*cos()  y = a*sin()
	float x = cos(angle) * delta.x - sin(angle) * delta.y;
	float y = sin(angle) * delta.x + cos(angle) * delta.y;
	//uvとして主力する(Centerで真ん中に合わせ、Offsetで調節する)
	Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
}

//valの値がinMin～inMax内の場合、outMin～outMaxの指定された割合に変換して出力する
float remap(float val, float inMin, float inMax, float outMin, float outMax)
{
    return clamp(outMin + (val - inMin) * (outMax - outMin) / (inMax - inMin), outMin, outMax);
}

//入力されたAからBを引く
float Subtract(float A,float B){
    return A-B;
}

//入力されたベクトルAからベクトルBを引く
float2 Subtract(float2 A,float2 B){
    return A-B;
}

//Noise

float rand(float2 co)
{
	return frac(sin(dot(co.xy,float2(12.9898f,78.233)))*43758.5453);
}

float rand(float3 co)
{
	return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 56.787))) * 43758.5453);
}

float noise(float3 pos)
{
    float3 ip = floor(pos);
    float3 fp = smoothstep(0, 1, frac(pos));
    float4 a = float4(
        rand(ip + float3(0, 0, 0)),
        rand(ip + float3(1, 0, 0)),
        rand(ip + float3(0, 1, 0)),
        rand(ip + float3(1, 1, 0)));
    float4 b = float4(
        rand(ip + float3(0, 0, 1)),
        rand(ip + float3(1, 0, 1)),
        rand(ip + float3(0, 1, 1)),
        rand(ip + float3(1, 1, 1)));
    a = lerp(a, b, fp.z);
    a.xy = lerp(a.xy, a.zw, fp.y);
    return lerp(a.x, a.y, fp.x);
}

fixed2 random2(fixed2 st) {
	st = fixed2(dot(st, fixed2(127.1, 311.7)),
		dot(st, fixed2(269.5, 183.3)));
	return -1.0 + 2.0*frac(sin(st)*43758.5453123);
}

float perlinNoise(fixed2 st)
{
	fixed2 p = floor(st);
	fixed2 f = frac(st);
	fixed2 u = f * f*(3.0 - 2.0*f);

	float v00 = random2(p + fixed2(0, 0));
	float v10 = random2(p + fixed2(1, 0));
	float v01 = random2(p + fixed2(0, 1));
	float v11 = random2(p + fixed2(1, 1));

	return lerp(lerp(dot(v00, f - fixed2(0, 0)), dot(v10, f - fixed2(1, 0)), u.x),
		lerp(dot(v01, f - fixed2(0, 1)), dot(v11, f - fixed2(1, 1)), u.x),
		u.y) + 0.5f;
}

fixed4 VolonoiNoise(float2 uv, float scale, float distance) {
	float2 st = uv * scale;//表示するセルの数

	float2 ist = floor(st); //グリッド数
	float2 fst = frac(st);  //小数部分

	float m_dist=distance;//一番近い点

	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			//セルがどのグリッドにいるか
			float2 neighbor = float2(x, y);

			//セルの位置をランダムに決める
			float2 p = random2(ist + neighbor);

			p = 0.5 + 0.5*sin((PI * 2)*p);

			float2 diff = neighbor + p - fst;

			float dist = length(diff);

			m_dist = min(m_dist, dist);
		}
	}
	fixed3 col = m_dist;
	return fixed4(col, 1);
}


//Matrix

float4x4 Translate(float3 t) {
	return float4x4(
		1, 0, 0, t.x,
		0, 1, 0, t.y,
		0, 0, 1, t.z,
		0, 0, 0, 1
		);
}

float4x4 Scale(float3 s) {
	return float4x4(
		s.x, 0, 0, 0,
		0, s.y, 0, 0,
		0, 0, s.z, 0,
		0, 0, 0, 1
		);
}

float4x4 RotateX(float x) {
	float s = sin(radians(x));
	float c = cos(radians(x));
	return float4x4(
		1, 0, 0, 0,
		0, c, -s, 0,
		0, s, c, 0,
		0, 0, 0, 1
		);
}


float4x4 RotateY(float y) {
	float s = sin(radians(y));
	float c = cos(radians(y));
	return float4x4(
		c, 0, s, 0,
		0, 1, 0, 0,
		-s, 0, c, 0,
		0, 0, 0, 1
		);
}


float4x4 RotateZ(float z) {
	float s = sin(radians(z));
	float c = cos(radians(z));
	return float4x4(
		c, -s, 0, 0,
		s, c, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
		);
}