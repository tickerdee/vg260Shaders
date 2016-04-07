Shader "ZShaders/flat" {
	Properties{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (0,0,0,0)
		_Blend("Tex 2 Color Blend", Range(0,1)) = 0
	}
	
	SubShader{
	
		Pass{
			Tags { "LightMode" = "ForwardBase"}
			
			CGPROGRAM
			
			#pragma vertex vert 
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			uniform float4 _LightColor0;
			
			sampler2D _MainTex;
			float4 _Color;
			float _Blend;
			float4 _MainTex_ST;
			
			//Passed in from Unity
			struct appdata{
				float4 vert : POSITION; //Vertex Position in model view
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};
			
			//Our structure for passing information in between vertex shader and fragment shader
			struct v2f{
				float4 vert : SV_POSITION; //Out calculated position in world
				float4 col : COLOR;
				float2 uv : TEXCOORD0;
			};
			
			// Important part of vertex shader is to turn appdata vert which is model view into projection view
			v2f vert(appdata v){
				v2f output;
				
				output.vert = mul(UNITY_MATRIX_MVP, v.vert);
				output.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				float4 wsl = _WorldSpaceLightPos0;
				
				float4 dr = _LightColor0 * dot(v.normal, _WorldSpaceLightPos0);
				
				output.col = dr;
				
				//normalDirection = normal of vert
				//light direction
				//diffuseReflection = _LightColor * dot(normalDirection, lightDirection);
				// take the dot of the pixel normal and light direction
				
				//dot(light idrection, normal)
				// normalise
				// _world2Object
				// _worldSpaceLightPos0
				// _LightColor0
				
				return output;
			}
			
			fixed4 frag(v2f i) : COLOR{
				
				//float4 texColor = tex2D(_MainTex, i.uv);
				float4 texColor = float4(0,0,0,0);
				
				texColor = tex2D(_MainTex, i.uv);
				
				texColor += i.col;
				
				texColor += _Color * _Blend;
				
				return texColor;
			}
			
			ENDCG
		}
	}//Sub Shader1
	// comment out during development
	//Fallback "diffuse"
}//Shader End