// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/WaterShader" {
    Properties {
        _Tess ("Tessellation", Range(1,32)) = 4
        _Color("Color", color) = (1,1,1,0)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0
        _Amp1("Amplitudes", Vector) = (1,1,1,1)
        _Amp2("Amplitudes", Vector) = (1,1,1,1)
        _Freq1("Frequencies", Vector) = (1,1,1,1)
        _Freq2("Frequencies", Vector) = (1,1,1,1)
        _Speed1("Wave Speed", Vector) = (1,1,1,1)
        _Speed2("Wave Speed", Vector) = (1,1,1,1)
        _TranslucentParams("Translucency Parameters", Vector) = (0,0,0,0)
        _SpecularParams("Specular Parameters", Vector) = (0,0,0,0)
        _HeightMap ("Height Map", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "white" {}
    }
    SubShader {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 300

        CGPROGRAM
        #pragma surface surf StandardTranslucent vertex:vert tessellate:tessDistance
        #pragma target 4.6

        #include "Tessellation.cginc"
        #include "UnityPBSLighting.cginc"
        
        sampler2D _MainTex;
        sampler2D _HeightMap;
        sampler2D _NormalMap;

        struct Input {
            float2 uv_MainTex;
        };

        struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float4 _Amp1;
        float4 _Amp2;
        float4 _Freq1;
        float4 _Freq2;
        float4 _Speed1;
        float4 _Speed2;
        float4 _TranslucentParams;
        float4 _SpecularParams;
        float _Tess;

        // Reference: https://www.alanzucconi.com/2017/08/30/fast-subsurface-scattering-2/
        inline fixed4 LightingStandardTranslucent(SurfaceOutputStandard s, fixed3 viewDir, UnityGI gi)
        {
            fixed4 pbr = LightingStandard(s, viewDir, gi);
            float3 L = gi.light.dir;
            float3 V = viewDir;
            float3 N = s.Normal;

            // Translucency
            float3 H = normalize(L + N * _TranslucentParams.x);
            float I = pow(saturate(dot(V, -H)), _TranslucentParams.y) * _TranslucentParams.z;

            // Specular
            H = normalize(L + V);
            float spec = pow(max(0, dot(N, H)), _SpecularParams.x) * _SpecularParams.y;

            // Final add
            pbr.rgb = pbr.rgb + gi.light.color * I + _LightColor0.rgb * spec;
            return pbr;
        }

        void LightingStandardTranslucent_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
        {
            LightingStandard_GI(s, data, gi);
        }

        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }

        float4 tessDistance(appdata v0, appdata v1, appdata v2) {
            return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, 10, 70, _Tess);
        }

        void vert(inout appdata v)
        {
            float2 uv = v.texcoord;

            v.vertex.y = tex2Dlod(_HeightMap, float4(uv.xy, 0, 0)).r;
            v.normal = tex2Dlod(_NormalMap, float4(uv.xy, 0, 0)).rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
