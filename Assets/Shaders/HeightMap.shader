Shader "Unlit/HeightMap"
{
	Properties
	{
        _HeightMap("Height Map", 2D) = "white" {}
        _Offset ("Position", Vector) = (0,0,0,0)
        _Amp1("Amplitudes", Vector) = (1,1,1,1)
        _Amp2("Amplitudes", Vector) = (1,1,1,1)
        _Freq1("Frequencies", Vector) = (1,1,1,1)
        _Freq2("Frequencies", Vector) = (1,1,1,1)
        _Speed1("Wave Speed", Vector) = (1,1,1,1)
        _Speed2("Wave Speed", Vector) = (1,1,1,1)
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

			sampler2D _HeightMap;
            float4 _Offset;
            float4 _Amp1;
            float4 _Amp2;
            float4 _Freq1;
            float4 _Freq2;
            float4 _Speed1;
            float4 _Speed2;

            inline float wave(float2 v) {
                float2 t1 = _Offset.xy;
                float2 t2 = _Offset.zw;

                float y1 =      snoise(_Freq1.x * v + _Speed1.x * t1)  * _Amp1.x;
                float y2 = -abs(snoise(_Freq1.y * v + _Speed1.y * t1)) * _Amp1.y;
                float y3 =      snoise(_Freq1.z * v + _Speed1.z * t1)  * _Amp1.z;
                float y4 =      snoise(_Freq1.w * v + _Speed1.w * t1)  * _Amp1.w;
                float y5 =      snoise(_Freq2.x * v + _Speed2.x * t2) * _Amp2.x;
                float y6 =      snoise(_Freq2.y * v + _Speed2.y * t2)  * _Amp2.y;
                float y7 =      snoise(_Freq2.z * v + _Speed2.z * t2)  * _Amp2.z;
                float y8 =      snoise(_Freq2.w * v + _Speed2.w * t2)  * _Amp2.w;

                return y1 + y2 + y3 + y4 + y5 + y6 + y7 + y8;
            }

			fixed4 frag (v2f_init_customrendertexture IN) : COLOR
			{
                float2 v = IN.texcoord.xy;
                float height = wave(v);
                float4 c = float4(height, 0, 0, 1);
                c * tex2D(_HeightMap, IN.texcoord.xy);
                return c;
			}
			ENDCG
		}
	}
}
