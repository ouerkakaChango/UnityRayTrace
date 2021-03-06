using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpecialTexGenerator : MonoBehaviour
{
    public Texture2D outTex;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void CreateShiftTex()
    {
        outTex = new Texture2D(256, 256, TextureFormat.RGBA32,false);
        Color[] colors = new Color[256 * 256];
        for (int j = 0; j < 256; j++)
        {
            for (int i = 0; i < 256; i++)
            {
                float rand = Random.Range(0.0f, 1.0f);
                colors[i + 256 * j].r = rand;
                colors[i + 256 * j].g = 0;
                colors[i + 256 * j].b = 0;
                colors[i + 256 * j].a = 1;
            }
        }

        for (int j = 0; j < 256; j++)
        {
            for (int i = 0; i < 256; i++)
            {
                int uvx = i - 37;
                int uvy = j - 17;
                uvx = uvx >= 0 ? uvx : (256 + uvx);
                uvy = uvy >= 0 ? uvy : (256 + uvy);
                colors[i + 256 * j].g = colors[uvx + 256 * uvy].r;
            }
        }
        outTex.SetPixels(colors);
        outTex.Apply();
    }
}
