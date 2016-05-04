//https://www.shadertoy.com/view/4sdXDX

Shader "Custom/ST_SmoothVoroniContours" {
	Properties {
		_Color ("Color", Color) = (0,0,0,0)
		
		_Color1 ("Color1", Color) = (1, 0, .1,1)
		_Color2 ("Color2", Color) = (.64, 0, .1,1)
		_Color3 ("Color3", Color) = (0, 0, 0, 0)
		
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		
		_MovementType("MovementType", Range(0.0, 2)) = 0
		
		_Smoothness("Smoothness", Range(0.0, 720)) = 360
		
		_LowEndFrac("LowEndFrac", Range(0.0, 82)) = 41
		_HighEndFrac("HighEndFrac", Range(83, 578)) = 289
		
		_XDensity("XSeed", Range(0, 4194304)) = 2097152
		_YDensity("YSeed", Range(0, 524288)) = 262144
		
		_Outline("Outline", Range(.01, 10)) = 1
		
		_OuterSpread("OuterSpread", Range(.5, 10)) = 1
		
		_OuterExponent("OuterExponent", Range(.25, 5)) = .5
		
		_OuterFrquency("OuterFrquency", Range(1, 30)) = 12
		
		_DENSITY("DENSITY", Range(1, 30)) = 6
		
		_DistortionMarkerSize("DistortionMarkerSize", Range(1, 60)) = 4
		_RingFrequency("RingFrequency", Range(.01, 3)) = .34
	}
	SubShader {
		Pass{
			Tags { "RenderType"="Opaque" }
			LOD 200
			
			CGPROGRAM
			
			#pragma vertex vert 
			#pragma fragment frag
			
			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0
			
			struct appdata{
				float4 vert : POSITION; //Vertex Position in model view
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};
			
			struct v2f{
				float4 vert : SV_POSITION; //Out calculated position in world
				float4 col : COLOR;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			fixed4 _Color;
			fixed4 _Color1;
			fixed4 _Color2;
			fixed4 _Color3;
			
			float _MovementType;
			
			float _Smoothness;
			float _LowEndFrac;
			float _HighEndFrac;
			
			float _XDensity;
			float _YDensity;
			
			float _Outline;
			
			float _OuterSpread;
			float _OuterExponent;
			
			float _OuterFrquency;
			
			float _DENSITY;
			float _DistortionMarkerSize;
			float _RingFrequency;
			
			//CUSTOM FUNCTIONS
				float2 hash22(float2 p) {
		    
				    // Faster, but probaly doesn't disperse things as nicely as other methods.
				    float n = sin(dot(p, float2(_LowEndFrac, _HighEndFrac)));
				    p = frac(float2(_XDensity, _YDensity)*n);
				    
				    if(_MovementType <= 0.5)
				    	return cos(p*6.283 + _Time)*.5;
				    if(_MovementType > 0.5 && _MovementType < 1.5)
				    	return abs(frac(p+ _Time*.25)-.5)*2. - .5; // Snooker.
				    //if(_MovementType==2)
				    return abs(cos(p*6.283 + _Time))*.5; // Bounce.
				}
				
				float smoothVoronoi(float2 p, float falloff) {

				    float2 ip = floor(p); p -= ip;
					
					float d = 1, res = 0.0;
					
					for(int i = -1; i <= 2; i++) {
						for(int j = -1; j <= 2; j++) {
				            
							float2 b = float2(i, j);
				            
							float2 v = b - p + hash22(ip + b);
				            
							d = max(dot(v,v), 1e-4);
							
							res += _Outline/pow( d, falloff );
						}
					}

					return pow( _OuterSpread/res, _OuterExponent/falloff );
				}
			
				float func2D(float2 p){

				    
				    float d = smoothVoronoi(p*2., 4.)*.66 + smoothVoronoi(p*_DENSITY, _DistortionMarkerSize)*_RingFrequency;
				    
				    return sqrt(d);
				    
				}
				
				float smoothFract(float x, float sf){
				 
				    x = frac(x); return min(x, x*(1.-x)*sf);
				    
				}
			
			//COLORING FUNCTIONS
			v2f vert(appdata v){
				v2f output;
				
				output.vert = mul(UNITY_MATRIX_MVP, v.vert);
				//output.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				output.uv = v.uv;
				
				return output;
			}
				
			fixed4 frag(v2f i) : COLOR{
				
				float2 uv = i.uv;
				
				float2 e = float2(0.001, 0);
				
				float f = func2D(uv);
				
				float g = length( float2(f - func2D(uv-e.xy), f - func2D(uv-e.yx)) )/(e.x);
				g = 1./max(g, 0.001);
				
				float freq = _OuterFrquency;
				//float smoothFactor = iResolution.y*0.0125;
				float smoothFactor = _Smoothness*0.0125;
				
				float c = clamp(cos(f*freq*3.14159*2.)*g*smoothFactor, 0., 1.);
				
				// Coloring.
			    //
			    // Convert "c" above to the greyscale and green colors.
			    fixed3 col = c;
			    col += _Color;
			    
			    fixed3 col2 = fixed3(c*_Color2.x, c, c*c*_Color2.z);
			    col2 += _Color3;
				
				col = lerp(col, col2, -uv.y + clamp(cos(f*freq*3.14159)*2., 0., 1.0));
				
				f = f*freq;
				
				if(f>8.5 && f<9.5) 
					col *= fixed3(_Color1.x, _Color1.y, _Color1.z);
				
				fixed4 texColor = fixed4( sqrt(clamp(col, 0., 1.)), 1.0 );
				//texColor = tex2D(_MainTex, i.uv);
				//texColor += _Color;
				
				return texColor;
			}
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
