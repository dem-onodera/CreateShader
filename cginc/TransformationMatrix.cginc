			float4x4 Translate(float3 t) {
				return float4x4(
					1,0,0,t.x,
					0,1,0,t.y,
					0,0,1,t.z,
					0,0,0,1
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
