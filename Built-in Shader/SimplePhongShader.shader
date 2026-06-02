Shader "Unlit/SimplePhongShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}

        _Ambient ("Ambient", Range(0, 1)) = 0.2
        _Diffuse ("Diffuse", Range(0, 1)) = 0.5
        _Specular ("Specular", Range(0, 1)) = 0.9

        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
    }
    SubShader
    {  
        Tags { "RenderType"="Opaque" }
        Tags { "LightMode"="ForwardBase"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "UnityShaderVariables.cginc"

            struct inputData //Data sent to Vertex Shader 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct outputData //Data sent to Fragment Shader from Vertex Shader
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;               
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            float4 _Color;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            half _Ambient;
            half _Diffuse;
            half _Specular;

            half _Smoothness;

            outputData vert (inputData input)
            {
                outputData output;
                output.worldPos = mul(unity_ObjectToWorld, input.normal);
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.normal = UnityObjectToWorldNormal(input.normal);
                return output;
            }

            fixed4 frag (outputData output) : SV_Target
            {
                output.normal = normalize(output.normal);

                fixed4 textureColor = tex2D(_MainTex, output.uv) * _Color;
                half4 effectColor = textureColor * _LightColor0;

                half4 ambient = _Ambient * effectColor;
                half4 diffuse;
                half4 specular;

                half lightDotNormal = dot(_WorldSpaceLightPos0.xyz, output.normal);

                if (lightDotNormal <= 0) 
                {
                    diffuse = half4(0, 0, 0, 0);
                    specular = diffuse;
                } else 
                {
                    diffuse = _Diffuse * effectColor * lightDotNormal;
                }

                half3 reflectVector = reflect(-_WorldSpaceLightPos0, output.normal);
                half reflect_Dot_Normal = dot(reflectVector, output.normal);

                if (reflect_Dot_Normal <= 0) 
                {
                    specular = half4(0, 0, 0, 0);
                } else 
                {
                    //Smoothing the object's surface by the _Smoothness component.
                    half factor = pow(reflect_Dot_Normal, _Smoothness * 10);
                    specular = factor * _Specular * _LightColor0;
                }
                
                return ambient + diffuse + specular; //Phong Reflection = ambient + diffuse + specular
            }
            ENDCG
        }
    }
}