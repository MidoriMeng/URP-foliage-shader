#ifndef MAINLIGHT_INCLUDED
#define MAINLIGHT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl"
// #pragma multi_compile_fog
void GetFogIntensity_float(float fogFactor, out float fogIntensity)
{
    fogIntensity = ComputeFogIntensity(fogFactor);
    // #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
    // #if defined(FOG_EXP)
    // // factor = exp(-density*z)
    // // fogFactor = density*z compute at vertex
    // fogIntensity = saturate(exp2(-fogFactor));
    // #elif defined(FOG_EXP2)
    // // factor = exp(-(density*z)^2)
    // // fogFactor = density*z compute at vertex
    // fogIntensity = saturate(exp2(-fogFactor * fogFactor));
    // #elif defined(FOG_LINEAR)
    // fogIntensity = fogFactor;
    // #endif
    // #endif
}

void GetMainLightData_float(float3 WorldPos, out float3 direction, out float3 color, out float shadowAttenuation)
{
#ifdef SHADERGRAPH_PREVIEW
    // In Shader Graph Preview we will assume a default light direction and white color
    direction = float3(-0.3, -0.8, 0.6);
    color = float3(1, 1, 1);
    shadowAttenuation = 1.0;
#else

    // Universal Render Pipeline
    #if defined(UNIVERSAL_LIGHTING_INCLUDED)
    
        // GetMainLight defined in Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl
        Light mainLight = GetMainLight();
        direction = mainLight.direction;
        color = mainLight.color;
        shadowAttenuation = mainLight.shadowAttenuation;

        // float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
        // or if you want shadow cascades :
        float cascadeIndex = ComputeCascadeIndex(WorldPos);
        float4 shadowCoord = mul(_MainLightWorldToShadow[cascadeIndex], float4(WorldPos, 1.0));
     
        ShadowSamplingData shadowSamplingData = GetMainLightShadowSamplingData();
        float shadowStrength = GetMainLightShadowStrength();
        shadowAttenuation = SampleShadowmap(shadowCoord, TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_MainLightShadowmapTexture), shadowSamplingData, shadowStrength, false);
    
    #elif defined(HD_LIGHTING_INCLUDED) 
        // ToDo: make it work for HDRP (check define above)
        // Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightDefinition.cs.hlsl
        // if (_DirectionalLightCount > 0)
        // {
        //     DirectionalLightData light = _DirectionalLightDatas[0];
        //     lightDir = -light.forward.xyz;
        //     color = light.color;
        //     ......
        
    #endif

#endif
}

#endif