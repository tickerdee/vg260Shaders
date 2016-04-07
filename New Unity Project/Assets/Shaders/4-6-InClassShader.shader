Shader "Unlit/4-6-InClassShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			
			// A structure for our vertex data. this includes vertex position and uc coord
			struct appdata
			{
				float4 vertex : POSITION;//The position of the vertex in local space (model space)
				//The UV coordinate for that vertex. Mesh being rendered must have at least one 
				//texture coordinate. The third and fourth floats in the vector represent a 3rd 
				//UV dimension and a scale factor, and are rarely if ever used.
				float2 uv : TEXCOORD0;
			};
			
			//v2f is vertex / fragment shader
			struct v2f
			{
				//First texture coordinate, or UV.
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				//The position of the vertex after being transformed into projection space.
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
			 	
				float4 col = tex2Dlod(_MainTex, float4(v.uv.xy,0,0));
				
				o.vertex.y -= col.x * 1.5f;
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);				
				return col;
			}
			ENDCG
		}
	}
}
