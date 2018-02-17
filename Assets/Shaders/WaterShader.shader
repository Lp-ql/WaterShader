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
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 300
            
        CGPROGRAM
        #pragma surface surf StandardTranslucent vertex:vert tessellate:tessDistance
        #pragma target 4.6

        #include "NoiseSimplex.cginc"
        #include "Tessellation.cginc"
        #include "UnityPBSLighting.cginc"
        
        sampler2D _MainTex;

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

            // Translucency
            float3 L = gi.light.dir;
            float3 V = viewDir;
            float3 N = s.Normal;

            float3 H = normalize(L + N * _TranslucentParams.x);
            float I = pow(saturate(dot(V, -H)), _TranslucentParams.y) * _TranslucentParams.z;

            // Specular
            H = normalize(L + V);
            float spec = pow(max(0, dot(s.Normal, H)), _SpecularParams.x) * _SpecularParams.y;

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

        inline float wave(float2 v) {
            float2 t = float2(_Time.x, _Time.x);

            float y1 =      snoise(_Freq1.x * v + _Speed1.x * t)  * _Amp1.x;
            float y2 = -abs(snoise(_Freq1.y * v + _Speed1.y * t)) * _Amp1.y;
            float y3 =      snoise(_Freq1.z * v + _Speed1.z * t)  * _Amp1.z;
            float y4 =      snoise(_Freq1.w * v + _Speed1.w * t)  * _Amp1.w;
            float y5 =      snoise(_Freq2.x * v + _Speed2.x * t)  * _Amp2.x;
            float y6 =      snoise(_Freq2.y * v + _Speed2.y * t)  * _Amp2.y;
            float y7 =      snoise(_Freq2.z * v + _Speed2.z * t)  * _Amp2.z;
            float y8 =      snoise(_Freq2.w * v + _Speed2.w * t)  * _Amp2.w;

            return y1 + y2 + y3 + y4 + y5 + y6 + y7 + y8;
        }

        void vert(inout appdata v)
        {
            float3 vertex = mul(unity_ObjectToWorld, v.vertex).xyz;

            float y = wave(vertex.xz);
            const float eps = 0.0001;

            float ydx = wave(vertex.xz + float2(eps, 0)) - y;
            float ydz = wave(vertex.xz + float2(0, eps)) - y;

            float3 vx = float3(eps, ydx, 0);
            float3 vy = float3(0, ydx, eps);
            float3 normal = normalize(cross(vx, vy));

            v.vertex.y = y;
            v.normal = normal;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
