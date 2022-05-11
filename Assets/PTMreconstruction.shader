Shader "Custom/PTMreconstruction"
{
    Properties{
        _Weight0("Weight0", 2D) = "" {}
        _Weight1("Weight1", 2D) = "" {}
        _Weight2("Weight2", 2D) = "" {}
        _Weight3("Weight3", 2D) = "" {}
        _Weight4("Weight4", 2D) = "" {}
        _Weight5("Weight5", 2D) = "" {}

    }
    SubShader{
        Pass{
            CGPROGRAM

            #pragma vertex vertexFunc
            #pragma fragment fragmentFunc
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            struct appdata {
                float4 vertex:POSITION;
                float2 uv:TEXCOORD0;
            };

            struct v2f {
                float4 position:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            fixed4 _Color0;

            v2f vertexFunc(appdata IN) {
                v2f OUT;
                OUT.position = UnityObjectToClipPos(IN.vertex);
                OUT.uv = IN.uv;

                return OUT;
            }
            sampler2D  _Weight0;
            sampler2D  _Weight1;
            sampler2D  _Weight2;
            sampler2D  _Weight3;
            sampler2D  _Weight4;
            sampler2D  _Weight5;

            fixed4 fragmentFunc(v2f IN) :SV_Target
            {
                const int BASIS_COUNT = 6;
                fixed4 pixelColor = fixed4(0,0,0,1);
                float3 lightDirection = mul(unity_WorldToObject, float4(normalize(_WorldSpaceLightPos0.xyz), 0)).xyz;
                float u = lightDirection.x;
                float v = lightDirection.y;
                float w = lightDirection.z;
                float row[BASIS_COUNT];

                row[0] = 1.0f;
                row[1] = u;
                row[2] = v;
                row[3] = w;
                row[4] = u * u;
                row[5] = u * v;

                half4 color0 = 2*tex2D(_Weight0, IN.uv)-1;
                pixelColor = pixelColor + color0 * row[0];

                half4 color1 = 2 * tex2D(_Weight1, IN.uv)-1;
                pixelColor = pixelColor + color1 * row[1];

                half4 color2 = 2*tex2D(_Weight2, IN.uv)-1;
                pixelColor= pixelColor + color2 * row[2];

                half4 color3 = 2*tex2D(_Weight3, IN.uv)-1;
                pixelColor = pixelColor + color3 * row[3];

                half4 color4 = 2*tex2D(_Weight4, IN.uv)-1;
                pixelColor = pixelColor + color4 * row[4];

                half4 color5 = 2*tex2D(_Weight5, IN.uv)-1;
                pixelColor = pixelColor + color5 * row[5];
                


                return fixed4(pixelColor.xyz, 1) * _LightColor0;
            }

            ENDCG
        }
    }
}
