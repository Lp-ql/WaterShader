Shader "Custom/WaterShader" {
    Properties{
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0
        _Amp("Amplitudes", Vector) = (1,1,1,1)
        _Freq("Frequencies", Vector) = (1,1,1,1)
        _Speed("Wave Speed", Vector) = (1,1,1,1)
    }
    SubShader{
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf StandardTranslucent fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        #include "noiseSimplex.cginc"
        #include "UnityPBSLighting.cginc"

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float4 _Freq;
        float4 _Amp;
        float4 _Speed;

        inline fixed4 LightingStandardTranslucent(SurfaceOutputStandard s, fixed3 viewDir, UnityGI gi)
        {
            fixed4 pbr = LightingStandard(s, viewDir, gi);


            return pbr;
        }

        void LightingStandardTranslucent_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
        {
            LightingStandard_GI(s, data, gi);
        }

        void surf(Input IN, inout SurfaceOutputStandard o) {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }

        inline float wave(float2 v) {
            float2 t = float2(_Time.x, _Time.x);

            float y1 = snoise(_Freq.x * v + _Speed.x * t) * _Amp.x;
            float y2 = snoise(_Freq.y * v + _Speed.y * t) * _Amp.y;
            float y3 = snoise(_Freq.z * v + _Speed.z * t) * _Amp.z;
            float y4 = snoise(_Freq.w * v + _Speed.w * t) * _Amp.w;

            return y1 + y2 + y3 + y4;
        }

        void vert(inout appdata_full v) {
            float y = wave(v.vertex.xz);
            const float eps = 0.0001;

            float ydx = wave(v.vertex.xz + float2(eps, 0)) - y;
            float ydz = wave(v.vertex.xz + float2(0, eps)) - y;

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
