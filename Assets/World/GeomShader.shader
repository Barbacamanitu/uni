Shader "Voxel/VoxelGeometry"
{
	Properties
	{
		[Header(Shading)]
		_Color("Color", Color) = (1,1,1,1)
	}

		CGINCLUDE
#include "UnityCG.cginc"
#include "Lighting.cginc"



			// Simple noise function, sourced from http://answers.unity.com/answers/624136/view.html
			// Extended discussion on this function can be found at the following link:
			// https://forum.unity.com/threads/am-i-over-complicating-this-random-function.454887/#post-2949326
			// Returns a number in the 0...1 range.
			float rand(float3 co) {
			return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
		}

		// Construct a rotation matrix that rotates around the provided axis, sourced from:
		// https://gist.github.com/keijiro/ee439d5e7388f3aafc5296005c8c3f33
		float3x3 AngleAxis3x3(float angle, float3 axis) {
			float c, s;
			sincos(angle, s, c);

			float t = 1 - c;
			float x = axis.x;
			float y = axis.y;
			float z = axis.z;

			return float3x3(
				t * x * x + c, t * x * y - s * z, t * x * z + s * y,
				t * x * y + s * z, t * y * y + c, t * y * z - s * x,
				t * x * z - s * y, t * y * z + s * x, t * z * z + c
				);
		}

		float4 _Color;

		float4 vert(float4 vertex : POSITION) : SV_POSITION{
			return vertex;
		}

		struct geometryOutput
		{
			float4 pos : SV_POSITION;
			float3  normal : NORMAL;
			float3 diffuse : TEXCOORD1;
		};

		float3 calcDiffuse(geometryOutput o) {
			float3 normalDirection = o.normal;
			float3 viewDirection = normalize(_WorldSpaceCameraPos
				- o.pos);
			float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);


			float3 ambientLighting =
				UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
			float attenuation = 1.0f;
			float3 diffuseReflection =
				attenuation * _LightColor0.rgb * _Color.rgb
				* max(0.0, dot(normalDirection, lightDirection));
			return diffuseReflection;
		}

		

		[maxvertexcount(24)]
		void geo(triangle float4 IN[3] : SV_POSITION, inout TriangleStream<geometryOutput> triStream)
		{
			geometryOutput o;
			float3 p = IN[0].xyz;

			//Top Face
			o.normal = float3(0, 1, 0);
			o.pos = UnityObjectToClipPos(p + float3(-0.5,0.5,-0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(0.5, 0.5, -0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(-0.5, 0.5, 0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);

			
			o.pos = UnityObjectToClipPos(p + float3(0.5, 0.5, 0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);
			triStream.RestartStrip();

			//Posz
			//Back face
			o.normal = float3(0, 0, 1);
			o.pos = UnityObjectToClipPos(p + float3(-0.5, 0.5, 0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);


			o.pos = UnityObjectToClipPos(p + float3(0.5, 0.5, 0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(-0.5, -0.5, 0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(0.5, -0.5, 0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);
			triStream.RestartStrip();


			//Bottom face
			o.normal = float3(0, -1, 0);

			o.pos = UnityObjectToClipPos(p + float3(-0.5, -0.5, 0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(0.5, -0.5, 0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(-0.5, -0.5, -0.5));
			o.diffuse = calcDiffuse(o); 
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(0.5, -0.5, -0.5));
			o.diffuse = calcDiffuse(o); 
			triStream.Append(o);
			triStream.RestartStrip();

			//Front face
			o.normal = float3(0, 0, -1);
			o.pos = UnityObjectToClipPos(p + float3(-0.5, -0.5, -0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(0.5, -0.5, -0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(-0.5, 0.5, -0.5));
			o.diffuse = calcDiffuse(o); 
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(0.5, 0.5, -0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);
			triStream.RestartStrip();

			//Right Side
			o.normal = float3(-1, 0, 0);
			o.pos = UnityObjectToClipPos(p + float3(0.5, 0.5, -0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(0.5, 0.5, 0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(0.5, -0.5, -0.5));
			o.diffuse = calcDiffuse(o); 
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(0.5, -0.5, 0.5));
			o.diffuse = calcDiffuse(o); 
			triStream.Append(o);

			triStream.RestartStrip();
			//Left Side
			o.normal = float3(1, 0, 0);
			o.pos = UnityObjectToClipPos(p + float3(-0.5, 0.5, -0.5));
			o.diffuse = calcDiffuse(o);
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(-0.5, 0.5, 0.5));
			o.diffuse = calcDiffuse(o); 
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(-0.5, -0.5, -0.5));
			o.diffuse = calcDiffuse(o); 
			triStream.Append(o);

			o.pos = UnityObjectToClipPos(p + float3(-0.5, -0.5, 0.5));
			o.diffuse = calcDiffuse(o); 
			triStream.Append(o);
			
		}

		ENDCG

			SubShader
		{
			Cull Off

			Pass
			{
				Tags
				{
					"RenderType" = "Opaque"
					"LightMode" = "ForwardBase"
				}

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma geometry geo
				#pragma target 4.6


				float4 frag(geometryOutput IN) : COLOR
				{
					


					return float4(IN.diffuse,1.0f);
				}

				ENDCG
			}
		}
}