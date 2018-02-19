Shader "Unlit/NormalMap"
{
	Properties
	{
        _HeightMap("Height Map", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
            #include "NoiseSimplex.cginc"
			#include "UnityCG.cginc"
            #include "UnityCustomRenderTexture.cginc"
            
			#pragma vertex InitCustomRenderTextureVertexShader
			#pragma fragment frag
            #pragma target 3.0

			sampler2D _NormalMap;
            sampler2D _HeightMap;
            float4 _HeightMap_TexelSize;

			fixed4 frag (v2f_init_customrendertexture IN) : COLOR
			{
                float2 uv = IN.texcoord.xy;
                float2 x = float2(_HeightMap_TexelSize.x, 0);
                float2 y = float2(0, _HeightMap_TexelSize.y);

                // Sobel filter: https://en.wikipedia.org/wiki/Sobel_operator
                // [h1] [h2] [h3]
                // [h4] [h5] [h6]   (h5 is unused)
                // [h7] [h8] [h9]

                float h1 = tex2D(_HeightMap, uv - x - y);
                float h2 = tex2D(_HeightMap, uv     - y);
                float h3 = tex2D(_HeightMap, uv + x - y);
                float h4 = tex2D(_HeightMap, uv - x    );
                float h6 = tex2D(_HeightMap, uv + x    );
                float h7 = tex2D(_HeightMap, uv - x + y);
                float h8 = tex2D(_HeightMap, uv     + y);
                float h9 = tex2D(_HeightMap, uv + x + y);

                float4 c = float4(1, 1, 1, 1);

                c.x = h9 - h7 + 2 * (h6 - h4) + h3 - h1;
                c.z = h7 - h1 + 2 * (h8 - h2) + h9 - h3;
                c.xyz = -normalize(c.xyz);

                //float3 vx = float3(eps, ydx, 0);
                //float3 vy = float3(0, ydx, eps);

                c * tex2D(_NormalMap, IN.texcoord.xy);
                return c;
			}
			ENDCG
		}
	}
}
