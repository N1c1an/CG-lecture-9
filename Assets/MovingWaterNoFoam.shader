Shader "Custom/MovingWaterNoFoam"
{
	Properties {
		_MainTex ("Diffuse", 2D) = "white" {}
		_Tint("Color Tint", Color) = (1,1,1,1)
		_Freq("Frequency", Range (0,5)) = 3
		_Speed("Speed",Range(0,100)) = 10
		_Amp("Amplitude", Range(0,1)) = 0.5
		_ScrollX ("Scroll X", Range(-5, 5)) = 1
		_ScrollY ("Scroll Y", Range(-5, 5)) = 1
		_myBump ("Bump Texture", 2D) = "bump" {}
		_mySlider ("Bump Amount", Range(0,10)) = 1
		}

		SubShader {
			CGPROGRAM
			#pragma surface surf Lambert vertex:vert
			
			sampler2D _MainTex;
			sampler2D _myBump;
			half _mySlider;

			struct Input {
				float2 uv_MainTex;
				float3 vertColor;
				};

				float4 _Tint;
				float _Freq;
				float _Speed;
				float _Amp;
				float _ScrollX;	
				float _ScrollY;
				
				struct appdata {
					float4 vertex: POSITION;
					float3 normal: NORMAL;
					float4 tangent: TANGENT;
					float4 texcoord: TEXCOORD0;
					float4 texcoord1: TEXCOORD1;
					float4 texcoord2: TEXCOORD2;
					};
					void vert (inout appdata v, out Input o) {
						UNITY_INITIALIZE_OUTPUT(Input,o);
						float t = _Time * _Speed;
						float waveHeight = sin(t + v.vertex.x * _Freq) * _Amp + sin(t*2 + v.vertex.x * _Freq*2) * _Amp;
						v.vertex.y = v.vertex.y + waveHeight;
						v.normal = normalize (float3(v.normal.x + waveHeight, v.normal.y, v.normal.z));
						o.vertColor = waveHeight + 2;
						}

						void surf (Input IN, inout SurfaceOutput o) {
							_ScrollX *= _Time;	
							_ScrollY *= _Time;
							float2 newuv = IN.uv_MainTex + float2 (_ScrollX, _ScrollY);
							float4 c = tex2D(_MainTex, newuv);
							float3 water = (tex2D (_MainTex, IN.uv_MainTex + float2(_ScrollX, _ScrollY))).rgb;
							//o.Albedo = c * IN.vertColor.rgb;
							o.Albedo += tex2D (_MainTex, newuv);
							//o.Normal = UnpackNormal(tex2D(_myBump, newuv));
							//o.Normal *= float3(_mySlider,_mySlider,1);
							float3 bnormal = UnpackNormal(tex2D(_myBump, newuv));
							bnormal *= float3(_mySlider,_mySlider,1);
							o.Normal += bnormal;
							}
							ENDCG
			}
			Fallback "Diffuse"
}
