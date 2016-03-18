Shader "Unlit/Tester"
{
    Properties
    {
        _MainTex("", 2D) = ""{}
        _RefTex("", 2D) = ""{}
    }

    CGINCLUDE

    #pragma multi_compile _RGBM _RGBD
    #pragma multi_compile _GRADIENT1 _GRADIENT2 _GRADIENT3

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    sampler2D _RefTex;
    float _Amplify;

    static const float kHDRRange = 1;

    float Gradient(float x)
    {
    #if _GRADIENT1
        return x * kHDRRange;
    #endif
    #if _GRADIENT2
        return (sin(x * 30) + 1) / 2;
    #endif
    #if _GRADIENT3
        return fmod(x * 32, kHDRRange);
    #endif
    }

    fixed4 EncodeHDR(float3 rgb)
    {
    #if _RGBM
        rgb *= 1.0 / kHDRRange;
        float m = max(max(rgb.r, rgb.g), max(rgb.b, 1e-6));
        m = ceil(m * 255) / 255;
        return fixed4(rgb / m, m);
    #else
        float m = max(max(rgb.r, rgb.g), max(rgb.b, 1e-6));
        float d = max(kHDRRange / m, 1);
        d = saturate(floor(d) / 255);
        return fixed4(rgb * d * 255 / kHDRRange, d);
    #endif
    }

    float3 DecodeHDR(fixed4 encoded)
    {
    #if _RGBM
        return encoded.rgb * encoded.a * kHDRRange;
    #else
        return encoded.rgb * (kHDRRange / 255) / encoded.a;
    #endif
    }

    fixed4 frag_encode(v2f_img i) : SV_Target
    {
        return EncodeHDR(Gradient(i.uv.x));
    }

    float4 frag_truth(v2f_img i) : SV_Target
    {
        return Gradient(i.uv.x);
    }

    fixed4 frag_compare(v2f_img i) : SV_Target
    {
        fixed encoded = DecodeHDR(tex2D(_MainTex, i.uv)).r;
        float truth = tex2D(_RefTex, i.uv).r;
        return abs(encoded - truth) * _Amplify < i.uv.y;
        //return absyyp(encoded - truth) * _Amplify + 0.5;
    }

    ENDCG

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_encode
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_truth
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_compare
            ENDCG
        }
    }
}
