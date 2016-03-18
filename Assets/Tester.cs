using UnityEngine;

[ExecuteInEditMode]
public class Tester : MonoBehaviour
{
    [SerializeField, Range(0, 2)]
    int _gradientType;

    [SerializeField, Range(0.25f, 4)]
    float _bufferScale = 1;

    [SerializeField, Range(1, 1000)]
    float _amplify = 100;

    [SerializeField]
    Shader _shader;

    Material _material;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material == null) {
            _material = new Material(_shader);
            _material.hideFlags = HideFlags.DontSave;
        }

        _material.SetFloat("_Amplify", _amplify);

        _material.shaderKeywords = null;

        if (_gradientType == 0)
            _material.EnableKeyword("_GRADIENT1");
        else if (_gradientType == 1)
            _material.EnableKeyword("_GRADIENT2");
        else
            _material.EnableKeyword("_GRADIENT3");

        var tw = (int)(source.width  * _bufferScale);
        var th = (int)(source.height * _bufferScale);

        var rtHDR  = RenderTexture.GetTemporary(tw, th, 0, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear);
        var rtRGBM = RenderTexture.GetTemporary(tw, th, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        var rtRGBD = RenderTexture.GetTemporary(tw, th, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);

        Graphics.Blit(null, rtHDR,  _material, 0);
        Graphics.Blit(null, rtRGBM, _material, 1);
        Graphics.Blit(null, rtRGBD, _material, 2);

        _material.SetTexture("_HDRTex", rtHDR);
        _material.SetTexture("_RGBMTex", rtRGBM);
        _material.SetTexture("_RGBDTex", rtRGBD);
        Graphics.Blit(null, destination, _material, 3);

        RenderTexture.ReleaseTemporary(rtHDR);
        RenderTexture.ReleaseTemporary(rtRGBM);
        RenderTexture.ReleaseTemporary(rtRGBD);
    }
}
