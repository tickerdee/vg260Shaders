Shader "Custom/4-6-ShaderInClass" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows
		#pragma vertex vert fragment frag
		
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
		
		sampler2D _MainTex;
		
		// A structure for our vertex data. this includes vertex position and uc coord
		struct appdata
		{
			float4 vertex : POSITION //The position of the vertex in local space (model space)
			
			//The UV coordinate for that vertex. Mesh being rendered must have at least one 
			//texture coordinate. The third and fourth floats in the vector represent a 3rd 
			//UV dimension and a scale factor, and are rarely if ever used.
			float2 uv : TEXCOORD0 
		};
		
		//v2f is vertex / fragment shader
		struct v2f
        {
        	//First texture coordinate, or UV.
            float2 uv : TEXCOORD0;
            //The position of the vertex after being transformed into projection space.
            float4 vertex : SV_POSITION;
        };
		
		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
