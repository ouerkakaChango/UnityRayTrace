#ifndef PBR_IBL_HLSL
#define PBR_IBL_HLSL

#include "../PBR/PBRCommonDef.hlsl"
Texture2D<float4> LUT_BRDF;

float3 GetEnvIrradiance_equirectangular(Texture2D envTex, float3 dir, bool unityDir)
{
	dir = normalize(dir);

	float2 uv = EquirectangularToUV(dir, unityDir);
	uint envTexW, envTexH;
	envTex.GetDimensions(envTexW, envTexH);
	return envTex[uv*float2(envTexW, envTexH)].rgb;
}

SamplerState my_point_repeat_sampler;
float3 GetEnvIrradiance_equirectangular(Texture2D envTex, float3 dir, float mip, bool unityDir)
{
	dir = normalize(dir);
	float2 uv = EquirectangularToUV(dir, unityDir);
	return envTex.SampleLevel(my_point_repeat_sampler, uv, mip).rgb;
}

float3 IBLBakeSpecMip(Texture2DArray envSpecTex2DArr, float3 dir, float texInx, bool unityDir)
{
	dir = normalize(dir);
	float2 uv = EquirectangularToUV(dir, unityDir);
	return envSpecTex2DArr.SampleLevel(my_point_repeat_sampler, float3(uv, texInx), 0).rgb;
}

float3 IBLBakeSpecMipByRoughness(Texture2DArray envSpecTex2DArr, float3 dir, float roughness, bool unityDir)
{
	uint Width;
	uint Height;
	uint Elements;
	envSpecTex2DArr.GetDimensions(Width, Height, Elements);

	float inx = roughness * Elements;
	float fpart = frac(inx);
	if (NearZero(fpart))
	{
		return IBLBakeSpecMip(envSpecTex2DArr, dir, inx, unityDir);
	}
	else if (equal(roughness, 1.0f))
	{
		return IBLBakeSpecMip(envSpecTex2DArr, dir, Elements-1, unityDir);
	}
	else
	{
		int inx1 = floor(inx);
		int inx2 = ceil(inx);
		float3 re1 = IBLBakeSpecMip(envSpecTex2DArr, dir, inx1, unityDir);
		float3 re2 = IBLBakeSpecMip(envSpecTex2DArr, dir, inx2, unityDir);
		return lerp(re1, re2, inx);
	}
}

//https://learnopengl-cn.github.io/07%20PBR/03%20IBL/02%20Specular%20IBL/
//https://matheowis.github.io/HDRI-to-CubeMap/

SamplerState my_point_clamp_sampler;
SamplerState _LinearClamp;
float3 PBR_IBL(Texture2DArray envSpecTex2DArr, Texture2D brdfLUT, Material_PBR param, float3 N, float3 V)
{
	uint Width;
	uint Height;
	uint Elements;
	envSpecTex2DArr.GetDimensions(Width, Height, Elements);

	//???
	float ao = 1;

	float3 F0 = 0.04;
	F0 = lerp(F0, param.albedo, param.metallic);

	//diffuse
	float3 kS = fresnelSchlickRoughness(max(dot(N, V), 0.0), F0, param.roughness);
	float3 kD = 1.0 - kS;
	float3 irradiance = IBLBakeSpecMip(envSpecTex2DArr, N, Elements-1, true);
	float3 indirect_diffuse = (kD * irradiance * param.albedo) * ao;

	//spec
	float3 R = reflect(-V, N);
	float3 prefilteredColor;
	//Unity_ComputeShader��û����cubemap�����Դ��ľ��mip����
	//���Լ���texArr����Ԥ���ֵ�5��ͼ�Ž�ȥ��	
	prefilteredColor = IBLBakeSpecMipByRoughness(envSpecTex2DArr, R, param.roughness, true);

	float2 envBRDF_UV = 0;
	envBRDF_UV.x = max(dot(N, V),0);
	envBRDF_UV.y = param.roughness;
	
	float2 envBRDF = brdfLUT.SampleLevel(my_point_clamp_sampler, envBRDF_UV, 0).rg;
	float3 indirect_specular = prefilteredColor * (kS * envBRDF.x + envBRDF.y) * ao;

	return indirect_diffuse + indirect_specular;
}

float3 PBR_IBL(Texture2DArray envSpecTex2DArr, Material_PBR param, float3 N, float3 V)
{
	return PBR_IBL(envSpecTex2DArr, LUT_BRDF, param, N, V);
}
#endif