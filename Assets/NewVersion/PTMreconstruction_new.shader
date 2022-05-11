Shader "Custom/PTMreconstruction_new"
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
            };

            fixed4 _Color0;

            v2f vertexFunc(appdata IN) {
                v2f OUT;
                OUT.position = UnityObjectToClipPos(IN.vertex);
                OUT.uv = IN.uv;
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

            #define BASIS_COUNT 6

            float4 evaluatePTM(half4 weights[BASIS_COUNT], float3 lightDirection)
            {
                fixed4 pixelColor = fixed4(0, 0, 0, 1);

                float u = lightDirection.x;
                float v = lightDirection.y;
                float w = lightDirection.z;
                float row[BASIS_COUNT];
                row[0] = 1.0f;
                row[1] = length(float2(u, v)); // u; // TODO: TEMP fix until tangent space problems are fixed
                row[2] = length(float2(u, v)); // v;
                row[3] = w;
                row[4] = v * u;
                row[5] = u * u + v * v;

                pixelColor = pixelColor + weights[0] * row[0];
                pixelColor = abs(pixelColor + weights[1] * row[1]); // TODO remove abs() when tangent space problems are fixed
                pixelColor = abs(pixelColor + weights[2] * row[2]);
                pixelColor = pixelColor + weights[3] * row[3];
                pixelColor = pixelColor + weights[4] * row[4];
                pixelColor = pixelColor + weights[5] * row[5];

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

                float3 lightDir0 = mul(IN.tbn, normalize(_WorldSpaceLightPos0.xyz)); // TBN is row-major, i.e. already transposed.
                //float3 lightDir1 = mul(IN.tbn, normalize(_WorldSpaceLightPos1.xyz)); // TBN is row-major, i.e. already transposed.
                
                return fixed4(evaluatePTM(color, lightDir0.xyz).rgb * _LightColor0.rgb * smoothstep(0, 0.25, lightDir0.z), 1);
                    //+ fixed4(evaluatePTM(color, lightDir1.xyz), 1) * _LightColor1 * smoothstep(0, 0.25, lightDir1.z);
            }

            ENDCG
        }
    }
}
