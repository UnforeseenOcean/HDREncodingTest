Shader "Unlit/Tester"
{
    Properties
    {
        _HDRTex("", 2D) = ""{}
        _RGBMTex("", 2D) = ""{}
        _RGBDTex("", 2D) = ""{}
    }

    CGINCLUDE

    #pragma multi_compile _GRADIENT1 _GRADIENT2 _GRADIENT3

    #include "UnityCG.cginc"

    sampler2D _HDRTex;
    sampler2D _RGBMTex;
    sampler2D _RGBDTex;

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

    fixed4 EncodeRGBM(float3 rgb)
    {
        rgb *= 1.0 / kHDRRange;
        float m = max(max(rgb.r, rgb.g), max(rgb.b, 1e-6));
        m = ceil(m * 255) / 255;
        return fixed4(rgb / m, m);
    }

    fixed4 EncodeRGBD(float3 rgb)
    {
        float m = max(max(rgb.r, rgb.g), max(rgb.b, 1e-6));
        float d = max(kHDRRange / m, 1);
        d = saturate(floor(d) / 255);
        return fixed4(rgb * d * 255 / kHDRRange, d);
    }

    float3 DecodeRGBM(fixed4 encoded)
    {
        return encoded.rgb * encoded.a * kHDRRange;
    }

    float3 DecodeRGBD(fixed4 encoded)
    {
        return encoded.rgb * (kHDRRange / 255) / encoded.a;
    }

    float4 frag_hdr(v2f_img i) : SV_Target
    {
        return Gradient(i.uv.x);
    }

    fixed4 frag_rgbm(v2f_img i) : SV_Target
    {
        return EncodeRGBM((float3)Gradient(i.uv.x));
    }

    fixed4 frag_rgbd(v2f_img i) : SV_Target
    {
        return EncodeRGBD((float3)Gradient(i.uv.x));
    }

    fixed4 frag_result(v2f_img i) : SV_Target
    {
        float x = i.uv.x;
        float y = frac(i.uv.y * 5);
        float row = floor((1 - i.uv.y) * 5);

        //float truth = Gradient(x);
        float truth = tex2D(_HDRTex, i.uv).r;
        float rgbm = DecodeRGBM(tex2D(_RGBMTex, i.uv)).r;
        float rgbd = DecodeRGBD(tex2D(_RGBDTex, i.uv)).r;

        if (y < 0.1) return 0;

        if (row < 1)
        {
            return truth;
        }
        else if (row < 2)
        {
            return rgbm;
        }
        else if (row < 3)
        {
            return abs(rgbm - truth) * _Amplify > y;
        }
        else if (row < 4)
        {
            return rgbd;
        }
        else
        {
            return abs(rgbd - truth) * _Amplify > y;
        }
    }




/*

    fixed4 frag_compare(v2f_img i) : SV_Target
    {
        fixed encoded = DecodeHDR(tex2D(_MainTex, i.uv)).r;
        float truth = tex2D(_RefTex, i.uv).r;
        return abs(encoded - truth) * _Amplify < i.uv.y;
        //return absyyp(encoded - truth) * _Amplify + 0.5;
    }
    */


    ENDCG

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_hdr
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_rgbm
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_rgbd
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_result
            ENDCG
        }
    }
}
