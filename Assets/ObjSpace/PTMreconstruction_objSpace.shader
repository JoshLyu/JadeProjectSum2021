Shader "Custom/PTMreconstruction_objSpace"
{
    Properties{
        _Weight0("Weight0", 2D) = "" {}
        _Weight1("Weight1", 2D) = "" {}
        _Weight2("Weight2", 2D) = "" {}
        _Weight3("Weight3", 2D) = "" {}
        _Weight4("Weight4", 2D) = "" {}
        _Weight5("Weight5", 2D) = "" {}
        _Weight6("Weight6", 2D) = "" {}
        _Weight7("Weight7", 2D) = "" {}
        _Weight8("Weight8", 2D) = "" {}
        _Weight9("Weight9", 2D) = "" {}

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
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float2 uv:TEXCOORD0;
            };

            struct v2f {
                float4 position:SV_POSITION;
                float2 uv:TEXCOORD0;
                float3x3 tbn:TEXCOORD1;
                float3 normal:TEXCOORD4;
            };

            fixed4 _Color0;

            v2f vertexFunc(appdata IN) {
                v2f OUT;
                OUT.position = UnityObjectToClipPos(IN.vertex);
                OUT.uv = IN.uv;
                OUT.normal = IN.normal;
                float3 worldNormal = UnityObjectToWorldNormal(IN.normal);
                float3 worldTangent = UnityObjectToWorldDir(IN.tangent);
                float3 worldBitangent = cross(worldNormal, worldTangent);
                OUT.tbn = float3x3(worldTangent, worldBitangent, worldNormal); // Row-major

                return OUT;
            }
            sampler2D  _Weight0;
            sampler2D  _Weight1;
            sampler2D  _Weight2;
            sampler2D  _Weight3;
            sampler2D  _Weight4;
            sampler2D  _Weight5;
            sampler2D  _Weight6;
            sampler2D  _Weight7;
            sampler2D  _Weight8;
            sampler2D  _Weight9;

            #define BASIS_COUNT 10

            float4 evaluatePTM(half4 weights[BASIS_COUNT], float3 lightDirection)
            {
                fixed4 pixelColor = fixed4(0, 0, 0, 1);

                float u = lightDirection.x;
                float v = lightDirection.y;
                float w = lightDirection.z;
                float row[BASIS_COUNT];
                row[0] = 1.0f;
                row[1] = u; 
                row[2] = v;
                row[3] = w;
                row[4] = u * u;
                row[5] = v * v;
                row[6] = w * w;
                row[7] = u * v;
                row[8] = u * w;
                row[9] = v * w;

                pixelColor = pixelColor + weights[0] * row[0];
                pixelColor = pixelColor + weights[1] * row[1];
                pixelColor = pixelColor + weights[2] * row[2];
                pixelColor = pixelColor + weights[3] * row[3];
                //pixelColor = pixelColor + weights[4] * row[4];
                //pixelColor = pixelColor + weights[5] * row[5];
                //pixelColor = pixelColor + weights[6] * row[6];
                //pixelColor = pixelColor + weights[7] * row[7];
                //pixelColor = pixelColor + weights[8] * row[8];
                //pixelColor = pixelColor + weights[9] * row[9];
                return pixelColor;
            }

            fixed4 fragmentFunc(v2f IN) :SV_Target {
                half4 color[BASIS_COUNT];
                color[0] = 2 * tex2D(_Weight0, IN.uv) - 1;
                color[1] = 2 * tex2D(_Weight1, IN.uv) - 1;
                color[2] = 2 * tex2D(_Weight2, IN.uv) - 1;
                color[3] = 2 * tex2D(_Weight3, IN.uv) - 1;
                color[4] = 2 * tex2D(_Weight4, IN.uv) - 1;
                color[5] = 2 * tex2D(_Weight5, IN.uv) - 1;
                color[6] = 2 * tex2D(_Weight6, IN.uv) - 1;
                color[7] = 2 * tex2D(_Weight7, IN.uv) - 1;
                color[8] = 2 * tex2D(_Weight8, IN.uv) - 1;
                color[9] = 2 * tex2D(_Weight9, IN.uv) - 1;

                float3 lightDir0 = normalize(_WorldSpaceLightPos0.xyz); 
                
                float3 ptm = evaluatePTM(color, lightDir0.xyz).rgb;

                float3 normalPTM = normalize(float3(color[1].g, color[2].g, color[3].g));

                return fixed4(IN.normal * 0.5 + 0.5, 1);//fixed4(dot(lightDir0, normalize(IN.normal)), dot(lightDir0, normalize(IN.normal)), dot(lightDir0, normalize(IN.normal)), 1);
                    //fixed4(ptm * _LightColor0.rgb /* * smoothstep(0.25, 0.5, dot(lightDir0, normalize(IN.normal)))*/, 1);
                    //+ fixed4(evaluatePTM(color, lightDir1.xyz), 1) * _LightColor1 * smoothstep(0, 0.25, lightDir1.z);
            }

            ENDCG
        }
    }
}
