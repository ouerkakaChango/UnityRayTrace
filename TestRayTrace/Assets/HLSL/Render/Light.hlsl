float dis2(float3 p1, float3 p2)
{
	float3 d = p1 - p2;
	return dot(d, d);
}

float3 GetAttenuationed(float3 lightColor, float3 pos, float3 lightPos)
{
	float ldis2 = dis2(pos, lightPos);
	float attenuation = 1.0;
	//attenuation = 1 / ldis2;
	//attenuation = saturate(attenuation);
	//???
	//attenuation = 1;
	//����ѧԭ�� atten ���� 1/dis2
	//1.��ֹ����̫����ʱ������ˣ�˥��������Ҫһ����Сֵ
	//2.���Ե���˥���ٶȣ����ұ�֤[0,1]
	float d2min = 0.001;
	float d2max = 20000;
	if (ldis2 > d2min)
	{
		attenuation = (d2max - ldis2) / (d2max - d2min);
	}
	attenuation = saturate(attenuation);

	return attenuation * lightColor;
}

float rgbSum(float3 color)
{
	return color.r + color.g + color.b;
}