using UnityEngine;

[ExecuteInEditMode]
public class Tester : MonoBehaviour
{
    public enum Encoding { None, RGBM, RGBD }

    [SerializeField]
    Encoding _encoding;

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

        if (_encoding == Encoding.RGBM)
            _material.EnableKeyword("_RGBM");
        else if (_encoding == Encoding.RGBD)
            _material.EnableKeyword("_RGBD");
        else
        {
            Graphics.Blit(null, destination, _material, 1);
            return;
        }

        var tw = (int)(source.width  * _bufferScale);
        var th = (int)(source.height * _bufferScale);

        var rtLDR = RenderTexture.GetTemporary(tw, th, 0, RenderTextureFormat.Default);
        var rtHDR = RenderTexture.GetTemporary(tw, th, 0, RenderTextureFormat.DefaultHDR);

        Graphics.Blit(null, rtLDR, _material, 0);
        Graphics.Blit(null, rtHDR, _material, 1);

        _material.SetTexture("_RefTex", rtHDR);
        Graphics.Blit(rtLDR, destination, _material, 2);

        RenderTexture.ReleaseTemporary(rtLDR);
        RenderTexture.ReleaseTemporary(rtHDR);
    }
}
