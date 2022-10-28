// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AV/URP/Hair"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Int) = 0
		[Enum(Opaque,0,Alpha Test,1)]_BlendMode("Blend Mode", Int) = 1
		_MaskClipValue("Mask Clip Value", Range( 0.15 , 0.85)) = 0.5
		_OpacityMaskMultiplier("Opacity Mask Multiplier", Float) = 4
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_AOIntensity("AO Intensity", Range( 0 , 1)) = 0
		[HDR][Header(Main)]_Color("Color", Color) = (1,1,1,0)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_AlbedoDesaturate("Albedo Desaturate", Range( 0 , 1)) = 0
		_AlbedoRemapper("Albedo Remapper", Range( -2 , 2)) = 0
		_AlbedoMax("Albedo Max", Range( 0 , 2)) = 1
		_Emission("Emission", Range( 0 , 10)) = 0
		[Normal][Header(Normal)]_BumpMap("Normal", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Range( 0 , 10)) = 1
		[Enum(Normal,0,Normal Create,1)]_NormalMode("Normal Mode", Int) = 0
		_NormalCreateOffset("Normal Create Offset", Range( 0 , 0.5)) = 0.35
		[Header(SubSurface Scattering)]_ThicknessMap("Thickness Map", 2D) = "white" {}
		[HDR]_SSSColor("SSS Color", Color) = (1,1,1,1)
		_SSSDistortion("SSS Distortion", Range( 0 , 2.5)) = 1
		_SSSPower("SSS Power", Range( 0 , 10)) = 1
		_SSSIntensity("SSS Intensity", Range( 0 , 5)) = 0
		[Header(Hair Anisotropic)]_HairBlend("Hair Blend", Range( 0 , 1)) = 0
		_HairGloss("Hair Gloss", Range( 0 , 1)) = 0
		_NoiseFrequency("Noise Frequency", Range( 0 , 100)) = 80
		_NoiseSpread("Noise Spread", Range( 0 , 2)) = 0.5
		[HDR]_HighlightColor("Highlight Color", Color) = (1,1,1,0)
		_HighlightPosition("Highlight Position", Range( -1 , 3)) = 0
		_HighlightExponent("Highlight Exponent", Range( 0 , 10)) = 9
		_HighlightIntensity("Highlight Intensity", Range( 0 , 3)) = 0.5
		[HDR]_SecondaryHighlightColor("Secondary Highlight Color", Color) = (1,1,1,0)
		_SecondaryHighlightPosition("Secondary Highlight Position", Range( -1 , 3)) = 0
		_SecondaryHighlightExponent("Secondary Highlight Exponent", Range( 0 , 10)) = 7
		_SecondaryHighlightIntensity("Secondary Highlight Intensity", Range( 0 , 3)) = 1.5
		[Header(Hair Variation)]_HairVariationBlend("Hair Variation Blend", Range( 0 , 1)) = 0
		[HDR]_HairVariationColor("Hair Variation Color", Color) = (1,0,0,0)
		_HairVariationPosition("Hair Variation Position", Range( -0.5 , 0.5)) = 0
		_HairVariationHardness("Hair Variation Hardness", Range( 0 , 1)) = 0.3
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		Cull [_CullMode]
		HLSLINCLUDE
		#pragma target 2.0

		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend Off
			ZWrite On
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70301

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _HighlightColor;
			float4 _BumpMap_ST;
			float4 _SSSColor;
			float4 _ThicknessMap_ST;
			float4 _HairVariationColor;
			float4 _SecondaryHighlightColor;
			float4 _MainTex_ST;
			float4 _Color;
			float _Smoothness;
			float _HairGloss;
			float _Metallic;
			float _Emission;
			float _SecondaryHighlightExponent;
			float _AOIntensity;
			float _OpacityMaskMultiplier;
			float _SSSIntensity;
			float _SSSPower;
			float _SSSDistortion;
			float _HairBlend;
			float _SecondaryHighlightIntensity;
			int _CullMode;
			float _HighlightExponent;
			float _HighlightIntensity;
			int _BlendMode;
			float _HighlightPosition;
			float _NoiseSpread;
			int _NormalMode;
			float _NormalCreateOffset;
			float _NormalIntensity;
			float _NoiseFrequency;
			float _HairVariationBlend;
			float _HairVariationPosition;
			float _HairVariationHardness;
			float _AlbedoMax;
			float _AlbedoRemapper;
			float _AlbedoDesaturate;
			float _SecondaryHighlightPosition;
			float _MaskClipValue;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _ThicknessMap;


			inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }
			inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }
			inline float valueNoise (float2 uv)
			{
				float2 i = floor(uv);
				float2 f = frac( uv );
				f = f* f * (3.0 - 2.0 * f);
				uv = abs( frac(uv) - 0.5);
				float2 c0 = i + float2( 0.0, 0.0 );
				float2 c1 = i + float2( 1.0, 0.0 );
				float2 c2 = i + float2( 0.0, 1.0 );
				float2 c3 = i + float2( 1.0, 1.0 );
				float r0 = noise_randomValue( c0 );
				float r1 = noise_randomValue( c1 );
				float r2 = noise_randomValue( c2 );
				float r3 = noise_randomValue( c3 );
				float bottomOfGrid = noise_interpolate( r0, r1, f.x );
				float topOfGrid = noise_interpolate( r2, r3, f.x );
				float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
				return t;
			}
			
			float SimpleNoise(float2 UV)
			{
				float t = 0.0;
				float freq = pow( 2.0, float( 0 ) );
				float amp = pow( 0.5, float( 3 - 0 ) );
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(1));
				amp = pow(0.5, float(3-1));
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(2));
				amp = pow(0.5, float(3-2));
				t += valueNoise( UV/freq )*amp;
				return t;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				o.clipPos = positionCS;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				o.screenPos = ComputeScreenPos(positionCS);
				#endif
				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord1 = v.texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN , half ase_vface : VFACE ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 WorldNormal = normalize( IN.tSpace0.xyz );
				float3 WorldTangent = IN.tSpace1.xyz;
				float3 WorldBiTangent = IN.tSpace2.xyz;
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif
	
				#if SHADER_HINT_NICE_QUALITY
					WorldViewDirection = SafeNormalize( WorldViewDirection );
				#endif

				float2 uv_MainTex = IN.ase_texcoord7.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode4 = tex2D( _MainTex, uv_MainTex );
				float temp_output_5_0_g130 = tex2DNode4.r;
				float temp_output_5_0_g131 = ( temp_output_5_0_g130 + ( tex2DNode4.g * ( 1.0 - temp_output_5_0_g130 ) ) );
				float temp_output_1492_0 = ( temp_output_5_0_g131 + ( tex2DNode4.b * ( 1.0 - temp_output_5_0_g131 ) ) );
				float3 temp_cast_0 = (temp_output_1492_0).xxx;
				float3 lerpResult1446 = lerp( (tex2DNode4).rgb , temp_cast_0 , _AlbedoDesaturate);
				float temp_output_7_0_g153 = _AlbedoRemapper;
				float3 temp_output_16_0_g151 = _Color.rgb;
				float temp_output_12_0_g151 = ( 1.0 - _HairVariationHardness );
				float temp_output_14_0_g151 = ( frac( ( float4(IN.ase_texcoord7.xy,0,0).xy.y * 2.0 ) ) + _HairVariationPosition );
				float smoothstepResult2_g151 = smoothstep( _HairVariationHardness , temp_output_12_0_g151 , temp_output_14_0_g151);
				float3 lerpResult6_g151 = lerp( (_HairVariationColor).rgb , temp_output_16_0_g151 , smoothstepResult2_g151);
				float3 lerpResult9_g151 = lerp( temp_output_16_0_g151 , lerpResult6_g151 , _HairVariationBlend);
				float3 temp_output_1302_0 = ( ( ( lerpResult1446 * ( ( _AlbedoRemapper + _AlbedoMax ) - temp_output_7_0_g153 ) ) + temp_output_7_0_g153 ) * lerpResult9_g151 );
				float3 normalizedWorldNormal = normalize( WorldNormal );
				float3 T77_g155 = cross( WorldTangent , normalizedWorldNormal );
				float2 appendResult5_g155 = (float2(( float4(IN.ase_texcoord7.xy,0,0).xy.x * _NoiseFrequency ) , float4(IN.ase_texcoord7.xy,0,0).xy.y));
				float simpleNoise6_g155 = SimpleNoise( appendResult5_g155*10.0 );
				simpleNoise6_g155 = simpleNoise6_g155*2 - 1;
				float smoothstepResult7_g155 = smoothstep( -0.3 , 0.6 , simpleNoise6_g155);
				float hairnoise79_g155 = smoothstepResult7_g155;
				float3 appendResult7_g139 = (float3(1.0 , 1.0 , ase_vface));
				float2 uv_BumpMap = float4(IN.ase_texcoord7.xy,0,0).xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				float2 uv0_MainTex = float4(IN.ase_texcoord7.xy,0,0).xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 temp_output_2_0_g99 = uv0_MainTex;
				float2 break6_g99 = temp_output_2_0_g99;
				float temp_output_25_0_g99 = ( pow( _NormalCreateOffset , 3.0 ) * 0.1 );
				float2 appendResult8_g99 = (float2(( break6_g99.x + temp_output_25_0_g99 ) , break6_g99.y));
				float4 tex2DNode11_g99 = tex2D( _MainTex, appendResult8_g99 );
				float4 tex2DNode14_g99 = tex2D( _MainTex, temp_output_2_0_g99 );
				float temp_output_4_0_g99 = _NormalIntensity;
				float3 appendResult13_g99 = (float3(1.0 , 0.0 , ( ( max( max( tex2DNode11_g99.r , tex2DNode11_g99.g ) , tex2DNode11_g99.b ) - max( max( tex2DNode14_g99.r , tex2DNode14_g99.g ) , tex2DNode14_g99.b ) ) * temp_output_4_0_g99 )));
				float2 appendResult9_g99 = (float2(break6_g99.x , ( break6_g99.y + temp_output_25_0_g99 )));
				float4 tex2DNode12_g99 = tex2D( _MainTex, appendResult9_g99 );
				float3 appendResult16_g99 = (float3(0.0 , 1.0 , ( ( max( max( tex2DNode12_g99.r , tex2DNode12_g99.g ) , tex2DNode12_g99.b ) - max( max( tex2DNode14_g99.r , tex2DNode14_g99.g ) , tex2DNode14_g99.b ) ) * temp_output_4_0_g99 )));
				float3 normalizeResult22_g99 = normalize( cross( appendResult13_g99 , appendResult16_g99 ) );
				float3 lerpResult1337 = lerp( UnpackNormalScale( tex2D( _BumpMap, uv_BumpMap ), _NormalIntensity ) , normalizeResult22_g99 , (float)_NormalMode);
				float2 _Vector0 = float2(-1,1);
				float3 temp_cast_3 = (_Vector0.x).xxx;
				float3 temp_cast_4 = (_Vector0.y).xxx;
				float3 clampResult1339 = clamp( lerpResult1337 , temp_cast_3 , temp_cast_4 );
				float3 temp_output_5_0_g139 = clampResult1339;
				float3 normal1334 = ( appendResult7_g139 * temp_output_5_0_g139 );
				float3 temp_output_83_0_g155 = normal1334;
				float3 normal107_g155 = temp_output_83_0_g155;
				float NoiseFX78_g155 = ( hairnoise79_g155 * temp_output_1492_0 * ( (normal107_g155).y + _NoiseSpread ) * _NoiseSpread );
				float3 appendResult22_g155 = (float3(SafeNormalize(_MainLightPosition.xyz).x , ( NoiseFX78_g155 + SafeNormalize(_MainLightPosition.xyz).y + _HighlightPosition ) , SafeNormalize(_MainLightPosition.xyz).z));
				float3 normalizeResult29_g155 = normalize( ( appendResult22_g155 + WorldViewDirection ) );
				float3 HL130_g155 = normalizeResult29_g155;
				float dotResult36_g155 = dot( T77_g155 , HL130_g155 );
				float sinTHL147_g155 = sqrt( ( 1.0 - ( dotResult36_g155 * dotResult36_g155 ) ) );
				float3 temp_output_65_0_g155 = ( (_HighlightColor).rgb * pow( sinTHL147_g155 , exp2( _HighlightExponent ) ) * _HighlightIntensity );
				float3 appendResult20_g155 = (float3(SafeNormalize(_MainLightPosition.xyz).x , ( NoiseFX78_g155 + SafeNormalize(_MainLightPosition.xyz).y + _SecondaryHighlightPosition ) , SafeNormalize(_MainLightPosition.xyz).z));
				float3 normalizeResult28_g155 = normalize( ( appendResult20_g155 + WorldViewDirection ) );
				float3 HL231_g155 = normalizeResult28_g155;
				float dotResult37_g155 = dot( T77_g155 , HL231_g155 );
				float sinTHL246_g155 = sqrt( ( 1.0 - ( dotResult37_g155 * dotResult37_g155 ) ) );
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal73_g155 = temp_output_83_0_g155;
				float3 worldNormal73_g155 = normalize( float3(dot(tanToWorld0,tanNormal73_g155), dot(tanToWorld1,tanNormal73_g155), dot(tanToWorld2,tanNormal73_g155)) );
				float dotResult76_g155 = dot( SafeNormalize(_MainLightPosition.xyz) , worldNormal73_g155 );
				float smoothstepResult62_g155 = smoothstep( -1.0 , 0.0 , dotResult36_g155);
				float dirAtten64_g155 = smoothstepResult62_g155;
				float3 normalizeResult1505 = normalize( temp_output_1302_0 );
				float3 tanNormal24_g154 = normal1334;
				float3 worldNormal24_g154 = normalize( float3(dot(tanToWorld0,tanNormal24_g154), dot(tanToWorld1,tanNormal24_g154), dot(tanToWorld2,tanNormal24_g154)) );
				float dotResult20_g154 = dot( WorldViewDirection , -( SafeNormalize(_MainLightPosition.xyz) + ( worldNormal24_g154 * _SSSDistortion ) ) );
				float temp_output_22_0_g154 = pow( saturate( dotResult20_g154 ) , _SSSPower );
				float2 uv_ThicknessMap = float4(IN.ase_texcoord7.xy,0,0).xy * _ThicknessMap_ST.xy + _ThicknessMap_ST.zw;
				float3 temp_output_1111_0 = saturate( ( temp_output_1302_0 + saturate( ( ( temp_output_65_0_g155 + ( (_SecondaryHighlightColor).rgb * pow( sinTHL246_g155 , exp2( _SecondaryHighlightExponent ) ) * _SecondaryHighlightIntensity ) ) * ( dotResult76_g155 * dotResult76_g155 * dotResult76_g155 ) * dirAtten64_g155 * _HairBlend ) ) + ( normalizeResult1505 * ( temp_output_22_0_g154 * _SSSIntensity * (_SSSColor).rgb * (tex2D( _ThicknessMap, uv_ThicknessMap )).rgb ) ) ) );
				
				float3 emission945 = ( temp_output_1111_0 * _Emission );
				
				float temp_output_5_0_g156 = ( saturate( ( hairnoise79_g155 + _HairGloss ) ) * _HairGloss );
				
				float opacitymask1462 = ( 1.0 - ( ( 1.0 - saturate( ( tex2DNode4.a * _OpacityMaskMultiplier ) ) ) * _BlendMode ) );
				
				float3 Albedo = temp_output_1111_0;
				float3 Normal = normal1334;
				float3 Emission = emission945;
				float3 Specular = 0.5;
				float Metallic = _Metallic;
				float Smoothness = ( temp_output_5_0_g156 + ( _Smoothness * ( 1.0 - temp_output_5_0_g156 ) ) );
				float Occlusion = ( 1.0 - _AOIntensity );
				float Alpha = opacitymask1462;
				float AlphaClipThreshold = _MaskClipValue;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					inputData.normalWS = normalize(TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal )));
				#else
					#if !SHADER_HINT_NICE_QUALITY
						inputData.normalWS = WorldNormal;
					#else
						inputData.normalWS = normalize( WorldNormal );
					#endif
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS );
				#ifdef _ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif
				half4 color = UniversalFragmentPBR(
					inputData, 
					Albedo, 
					Metallic, 
					Specular, 
					Smoothness, 
					Occlusion, 
					Emission, 
					Alpha);

				#ifdef _TRANSMISSION_ASE
				{
					float shadow = _TransmissionShadow;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += Albedo * mainTransmission;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += Albedo * transmission;
						}
					#endif
				}
				#endif

				#ifdef _TRANSLUCENCY_ASE
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );

					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += Albedo * mainTranslucency * strength;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += Albedo * translucency * strength;
						}
					#endif
				}
				#endif

				#ifdef _REFRACTION_ASE
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, WorldNormal ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif
				
				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70301

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _HighlightColor;
			float4 _BumpMap_ST;
			float4 _SSSColor;
			float4 _ThicknessMap_ST;
			float4 _HairVariationColor;
			float4 _SecondaryHighlightColor;
			float4 _MainTex_ST;
			float4 _Color;
			float _Smoothness;
			float _HairGloss;
			float _Metallic;
			float _Emission;
			float _SecondaryHighlightExponent;
			float _AOIntensity;
			float _OpacityMaskMultiplier;
			float _SSSIntensity;
			float _SSSPower;
			float _SSSDistortion;
			float _HairBlend;
			float _SecondaryHighlightIntensity;
			int _CullMode;
			float _HighlightExponent;
			float _HighlightIntensity;
			int _BlendMode;
			float _HighlightPosition;
			float _NoiseSpread;
			int _NormalMode;
			float _NormalCreateOffset;
			float _NormalIntensity;
			float _NoiseFrequency;
			float _HairVariationBlend;
			float _HairVariationPosition;
			float _HairVariationHardness;
			float _AlbedoMax;
			float _AlbedoRemapper;
			float _AlbedoDesaturate;
			float _SecondaryHighlightPosition;
			float _MaskClipValue;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;


			
			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );
				
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode4 = tex2D( _MainTex, uv_MainTex );
				float opacitymask1462 = ( 1.0 - ( ( 1.0 - saturate( ( tex2DNode4.a * _OpacityMaskMultiplier ) ) ) * _BlendMode ) );
				
				float Alpha = opacitymask1462;
				float AlphaClipThreshold = _MaskClipValue;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70301

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _HighlightColor;
			float4 _BumpMap_ST;
			float4 _SSSColor;
			float4 _ThicknessMap_ST;
			float4 _HairVariationColor;
			float4 _SecondaryHighlightColor;
			float4 _MainTex_ST;
			float4 _Color;
			float _Smoothness;
			float _HairGloss;
			float _Metallic;
			float _Emission;
			float _SecondaryHighlightExponent;
			float _AOIntensity;
			float _OpacityMaskMultiplier;
			float _SSSIntensity;
			float _SSSPower;
			float _SSSDistortion;
			float _HairBlend;
			float _SecondaryHighlightIntensity;
			int _CullMode;
			float _HighlightExponent;
			float _HighlightIntensity;
			int _BlendMode;
			float _HighlightPosition;
			float _NoiseSpread;
			int _NormalMode;
			float _NormalCreateOffset;
			float _NormalIntensity;
			float _NoiseFrequency;
			float _HairVariationBlend;
			float _HairVariationPosition;
			float _HairVariationHardness;
			float _AlbedoMax;
			float _AlbedoRemapper;
			float _AlbedoDesaturate;
			float _SecondaryHighlightPosition;
			float _MaskClipValue;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode4 = tex2D( _MainTex, uv_MainTex );
				float opacitymask1462 = ( 1.0 - ( ( 1.0 - saturate( ( tex2DNode4.a * _OpacityMaskMultiplier ) ) ) * _BlendMode ) );
				
				float Alpha = opacitymask1462;
				float AlphaClipThreshold = _MaskClipValue;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70301

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _HighlightColor;
			float4 _BumpMap_ST;
			float4 _SSSColor;
			float4 _ThicknessMap_ST;
			float4 _HairVariationColor;
			float4 _SecondaryHighlightColor;
			float4 _MainTex_ST;
			float4 _Color;
			float _Smoothness;
			float _HairGloss;
			float _Metallic;
			float _Emission;
			float _SecondaryHighlightExponent;
			float _AOIntensity;
			float _OpacityMaskMultiplier;
			float _SSSIntensity;
			float _SSSPower;
			float _SSSDistortion;
			float _HairBlend;
			float _SecondaryHighlightIntensity;
			int _CullMode;
			float _HighlightExponent;
			float _HighlightIntensity;
			int _BlendMode;
			float _HighlightPosition;
			float _NoiseSpread;
			int _NormalMode;
			float _NormalCreateOffset;
			float _NormalIntensity;
			float _NoiseFrequency;
			float _HairVariationBlend;
			float _HairVariationPosition;
			float _HairVariationHardness;
			float _AlbedoMax;
			float _AlbedoRemapper;
			float _AlbedoDesaturate;
			float _SecondaryHighlightPosition;
			float _MaskClipValue;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _ThicknessMap;


			inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }
			inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }
			inline float valueNoise (float2 uv)
			{
				float2 i = floor(uv);
				float2 f = frac( uv );
				f = f* f * (3.0 - 2.0 * f);
				uv = abs( frac(uv) - 0.5);
				float2 c0 = i + float2( 0.0, 0.0 );
				float2 c1 = i + float2( 1.0, 0.0 );
				float2 c2 = i + float2( 0.0, 1.0 );
				float2 c3 = i + float2( 1.0, 1.0 );
				float r0 = noise_randomValue( c0 );
				float r1 = noise_randomValue( c1 );
				float r2 = noise_randomValue( c2 );
				float r3 = noise_randomValue( c3 );
				float bottomOfGrid = noise_interpolate( r0, r1, f.x );
				float topOfGrid = noise_interpolate( r2, r3, f.x );
				float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
				return t;
			}
			
			float SimpleNoise(float2 UV)
			{
				float t = 0.0;
				float freq = pow( 2.0, float( 0 ) );
				float amp = pow( 0.5, float( 3 - 0 ) );
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(1));
				amp = pow(0.5, float(3-1));
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(2));
				amp = pow(0.5, float(3-2));
				t += valueNoise( UV/freq )*amp;
				return t;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN , half ase_vface : VFACE ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode4 = tex2D( _MainTex, uv_MainTex );
				float temp_output_5_0_g130 = tex2DNode4.r;
				float temp_output_5_0_g131 = ( temp_output_5_0_g130 + ( tex2DNode4.g * ( 1.0 - temp_output_5_0_g130 ) ) );
				float temp_output_1492_0 = ( temp_output_5_0_g131 + ( tex2DNode4.b * ( 1.0 - temp_output_5_0_g131 ) ) );
				float3 temp_cast_0 = (temp_output_1492_0).xxx;
				float3 lerpResult1446 = lerp( (tex2DNode4).rgb , temp_cast_0 , _AlbedoDesaturate);
				float temp_output_7_0_g153 = _AlbedoRemapper;
				float3 temp_output_16_0_g151 = _Color.rgb;
				float temp_output_12_0_g151 = ( 1.0 - _HairVariationHardness );
				float temp_output_14_0_g151 = ( frac( ( float4(IN.ase_texcoord2.xy,0,0).xy.y * 2.0 ) ) + _HairVariationPosition );
				float smoothstepResult2_g151 = smoothstep( _HairVariationHardness , temp_output_12_0_g151 , temp_output_14_0_g151);
				float3 lerpResult6_g151 = lerp( (_HairVariationColor).rgb , temp_output_16_0_g151 , smoothstepResult2_g151);
				float3 lerpResult9_g151 = lerp( temp_output_16_0_g151 , lerpResult6_g151 , _HairVariationBlend);
				float3 temp_output_1302_0 = ( ( ( lerpResult1446 * ( ( _AlbedoRemapper + _AlbedoMax ) - temp_output_7_0_g153 ) ) + temp_output_7_0_g153 ) * lerpResult9_g151 );
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float3 T77_g155 = cross( ase_worldTangent , normalizedWorldNormal );
				float2 appendResult5_g155 = (float2(( float4(IN.ase_texcoord2.xy,0,0).xy.x * _NoiseFrequency ) , float4(IN.ase_texcoord2.xy,0,0).xy.y));
				float simpleNoise6_g155 = SimpleNoise( appendResult5_g155*10.0 );
				simpleNoise6_g155 = simpleNoise6_g155*2 - 1;
				float smoothstepResult7_g155 = smoothstep( -0.3 , 0.6 , simpleNoise6_g155);
				float hairnoise79_g155 = smoothstepResult7_g155;
				float3 appendResult7_g139 = (float3(1.0 , 1.0 , ase_vface));
				float2 uv_BumpMap = float4(IN.ase_texcoord2.xy,0,0).xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				float2 uv0_MainTex = float4(IN.ase_texcoord2.xy,0,0).xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 temp_output_2_0_g99 = uv0_MainTex;
				float2 break6_g99 = temp_output_2_0_g99;
				float temp_output_25_0_g99 = ( pow( _NormalCreateOffset , 3.0 ) * 0.1 );
				float2 appendResult8_g99 = (float2(( break6_g99.x + temp_output_25_0_g99 ) , break6_g99.y));
				float4 tex2DNode11_g99 = tex2D( _MainTex, appendResult8_g99 );
				float4 tex2DNode14_g99 = tex2D( _MainTex, temp_output_2_0_g99 );
				float temp_output_4_0_g99 = _NormalIntensity;
				float3 appendResult13_g99 = (float3(1.0 , 0.0 , ( ( max( max( tex2DNode11_g99.r , tex2DNode11_g99.g ) , tex2DNode11_g99.b ) - max( max( tex2DNode14_g99.r , tex2DNode14_g99.g ) , tex2DNode14_g99.b ) ) * temp_output_4_0_g99 )));
				float2 appendResult9_g99 = (float2(break6_g99.x , ( break6_g99.y + temp_output_25_0_g99 )));
				float4 tex2DNode12_g99 = tex2D( _MainTex, appendResult9_g99 );
				float3 appendResult16_g99 = (float3(0.0 , 1.0 , ( ( max( max( tex2DNode12_g99.r , tex2DNode12_g99.g ) , tex2DNode12_g99.b ) - max( max( tex2DNode14_g99.r , tex2DNode14_g99.g ) , tex2DNode14_g99.b ) ) * temp_output_4_0_g99 )));
				float3 normalizeResult22_g99 = normalize( cross( appendResult13_g99 , appendResult16_g99 ) );
				float3 lerpResult1337 = lerp( UnpackNormalScale( tex2D( _BumpMap, uv_BumpMap ), _NormalIntensity ) , normalizeResult22_g99 , (float)_NormalMode);
				float2 _Vector0 = float2(-1,1);
				float3 temp_cast_3 = (_Vector0.x).xxx;
				float3 temp_cast_4 = (_Vector0.y).xxx;
				float3 clampResult1339 = clamp( lerpResult1337 , temp_cast_3 , temp_cast_4 );
				float3 temp_output_5_0_g139 = clampResult1339;
				float3 normal1334 = ( appendResult7_g139 * temp_output_5_0_g139 );
				float3 temp_output_83_0_g155 = normal1334;
				float3 normal107_g155 = temp_output_83_0_g155;
				float NoiseFX78_g155 = ( hairnoise79_g155 * temp_output_1492_0 * ( (normal107_g155).y + _NoiseSpread ) * _NoiseSpread );
				float3 appendResult22_g155 = (float3(SafeNormalize(_MainLightPosition.xyz).x , ( NoiseFX78_g155 + SafeNormalize(_MainLightPosition.xyz).y + _HighlightPosition ) , SafeNormalize(_MainLightPosition.xyz).z));
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 normalizeResult29_g155 = normalize( ( appendResult22_g155 + ase_worldViewDir ) );
				float3 HL130_g155 = normalizeResult29_g155;
				float dotResult36_g155 = dot( T77_g155 , HL130_g155 );
				float sinTHL147_g155 = sqrt( ( 1.0 - ( dotResult36_g155 * dotResult36_g155 ) ) );
				float3 temp_output_65_0_g155 = ( (_HighlightColor).rgb * pow( sinTHL147_g155 , exp2( _HighlightExponent ) ) * _HighlightIntensity );
				float3 appendResult20_g155 = (float3(SafeNormalize(_MainLightPosition.xyz).x , ( NoiseFX78_g155 + SafeNormalize(_MainLightPosition.xyz).y + _SecondaryHighlightPosition ) , SafeNormalize(_MainLightPosition.xyz).z));
				float3 normalizeResult28_g155 = normalize( ( appendResult20_g155 + ase_worldViewDir ) );
				float3 HL231_g155 = normalizeResult28_g155;
				float dotResult37_g155 = dot( T77_g155 , HL231_g155 );
				float sinTHL246_g155 = sqrt( ( 1.0 - ( dotResult37_g155 * dotResult37_g155 ) ) );
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal73_g155 = temp_output_83_0_g155;
				float3 worldNormal73_g155 = normalize( float3(dot(tanToWorld0,tanNormal73_g155), dot(tanToWorld1,tanNormal73_g155), dot(tanToWorld2,tanNormal73_g155)) );
				float dotResult76_g155 = dot( SafeNormalize(_MainLightPosition.xyz) , worldNormal73_g155 );
				float smoothstepResult62_g155 = smoothstep( -1.0 , 0.0 , dotResult36_g155);
				float dirAtten64_g155 = smoothstepResult62_g155;
				float3 normalizeResult1505 = normalize( temp_output_1302_0 );
				float3 tanNormal24_g154 = normal1334;
				float3 worldNormal24_g154 = normalize( float3(dot(tanToWorld0,tanNormal24_g154), dot(tanToWorld1,tanNormal24_g154), dot(tanToWorld2,tanNormal24_g154)) );
				float dotResult20_g154 = dot( ase_worldViewDir , -( SafeNormalize(_MainLightPosition.xyz) + ( worldNormal24_g154 * _SSSDistortion ) ) );
				float temp_output_22_0_g154 = pow( saturate( dotResult20_g154 ) , _SSSPower );
				float2 uv_ThicknessMap = float4(IN.ase_texcoord2.xy,0,0).xy * _ThicknessMap_ST.xy + _ThicknessMap_ST.zw;
				float3 temp_output_1111_0 = saturate( ( temp_output_1302_0 + saturate( ( ( temp_output_65_0_g155 + ( (_SecondaryHighlightColor).rgb * pow( sinTHL246_g155 , exp2( _SecondaryHighlightExponent ) ) * _SecondaryHighlightIntensity ) ) * ( dotResult76_g155 * dotResult76_g155 * dotResult76_g155 ) * dirAtten64_g155 * _HairBlend ) ) + ( normalizeResult1505 * ( temp_output_22_0_g154 * _SSSIntensity * (_SSSColor).rgb * (tex2D( _ThicknessMap, uv_ThicknessMap )).rgb ) ) ) );
				
				float3 emission945 = ( temp_output_1111_0 * _Emission );
				
				float opacitymask1462 = ( 1.0 - ( ( 1.0 - saturate( ( tex2DNode4.a * _OpacityMaskMultiplier ) ) ) * _BlendMode ) );
				
				
				float3 Albedo = temp_output_1111_0;
				float3 Emission = emission945;
				float Alpha = opacitymask1462;
				float AlphaClipThreshold = _MaskClipValue;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = Albedo;
				metaInput.Emission = Emission;
				
				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend Off
			ZWrite On
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70301

			#pragma enable_d3d11_debug_symbols
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _HighlightColor;
			float4 _BumpMap_ST;
			float4 _SSSColor;
			float4 _ThicknessMap_ST;
			float4 _HairVariationColor;
			float4 _SecondaryHighlightColor;
			float4 _MainTex_ST;
			float4 _Color;
			float _Smoothness;
			float _HairGloss;
			float _Metallic;
			float _Emission;
			float _SecondaryHighlightExponent;
			float _AOIntensity;
			float _OpacityMaskMultiplier;
			float _SSSIntensity;
			float _SSSPower;
			float _SSSDistortion;
			float _HairBlend;
			float _SecondaryHighlightIntensity;
			int _CullMode;
			float _HighlightExponent;
			float _HighlightIntensity;
			int _BlendMode;
			float _HighlightPosition;
			float _NoiseSpread;
			int _NormalMode;
			float _NormalCreateOffset;
			float _NormalIntensity;
			float _NoiseFrequency;
			float _HairVariationBlend;
			float _HairVariationPosition;
			float _HairVariationHardness;
			float _AlbedoMax;
			float _AlbedoRemapper;
			float _AlbedoDesaturate;
			float _SecondaryHighlightPosition;
			float _MaskClipValue;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _ThicknessMap;


			inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }
			inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }
			inline float valueNoise (float2 uv)
			{
				float2 i = floor(uv);
				float2 f = frac( uv );
				f = f* f * (3.0 - 2.0 * f);
				uv = abs( frac(uv) - 0.5);
				float2 c0 = i + float2( 0.0, 0.0 );
				float2 c1 = i + float2( 1.0, 0.0 );
				float2 c2 = i + float2( 0.0, 1.0 );
				float2 c3 = i + float2( 1.0, 1.0 );
				float r0 = noise_randomValue( c0 );
				float r1 = noise_randomValue( c1 );
				float r2 = noise_randomValue( c2 );
				float r3 = noise_randomValue( c3 );
				float bottomOfGrid = noise_interpolate( r0, r1, f.x );
				float topOfGrid = noise_interpolate( r2, r3, f.x );
				float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
				return t;
			}
			
			float SimpleNoise(float2 UV)
			{
				float t = 0.0;
				float freq = pow( 2.0, float( 0 ) );
				float amp = pow( 0.5, float( 3 - 0 ) );
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(1));
				amp = pow(0.5, float(3-1));
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(2));
				amp = pow(0.5, float(3-2));
				t += valueNoise( UV/freq )*amp;
				return t;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN , half ase_vface : VFACE ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode4 = tex2D( _MainTex, uv_MainTex );
				float temp_output_5_0_g130 = tex2DNode4.r;
				float temp_output_5_0_g131 = ( temp_output_5_0_g130 + ( tex2DNode4.g * ( 1.0 - temp_output_5_0_g130 ) ) );
				float temp_output_1492_0 = ( temp_output_5_0_g131 + ( tex2DNode4.b * ( 1.0 - temp_output_5_0_g131 ) ) );
				float3 temp_cast_0 = (temp_output_1492_0).xxx;
				float3 lerpResult1446 = lerp( (tex2DNode4).rgb , temp_cast_0 , _AlbedoDesaturate);
				float temp_output_7_0_g153 = _AlbedoRemapper;
				float3 temp_output_16_0_g151 = _Color.rgb;
				float temp_output_12_0_g151 = ( 1.0 - _HairVariationHardness );
				float temp_output_14_0_g151 = ( frac( ( float4(IN.ase_texcoord2.xy,0,0).xy.y * 2.0 ) ) + _HairVariationPosition );
				float smoothstepResult2_g151 = smoothstep( _HairVariationHardness , temp_output_12_0_g151 , temp_output_14_0_g151);
				float3 lerpResult6_g151 = lerp( (_HairVariationColor).rgb , temp_output_16_0_g151 , smoothstepResult2_g151);
				float3 lerpResult9_g151 = lerp( temp_output_16_0_g151 , lerpResult6_g151 , _HairVariationBlend);
				float3 temp_output_1302_0 = ( ( ( lerpResult1446 * ( ( _AlbedoRemapper + _AlbedoMax ) - temp_output_7_0_g153 ) ) + temp_output_7_0_g153 ) * lerpResult9_g151 );
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float3 T77_g155 = cross( ase_worldTangent , normalizedWorldNormal );
				float2 appendResult5_g155 = (float2(( float4(IN.ase_texcoord2.xy,0,0).xy.x * _NoiseFrequency ) , float4(IN.ase_texcoord2.xy,0,0).xy.y));
				float simpleNoise6_g155 = SimpleNoise( appendResult5_g155*10.0 );
				simpleNoise6_g155 = simpleNoise6_g155*2 - 1;
				float smoothstepResult7_g155 = smoothstep( -0.3 , 0.6 , simpleNoise6_g155);
				float hairnoise79_g155 = smoothstepResult7_g155;
				float3 appendResult7_g139 = (float3(1.0 , 1.0 , ase_vface));
				float2 uv_BumpMap = float4(IN.ase_texcoord2.xy,0,0).xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				float2 uv0_MainTex = float4(IN.ase_texcoord2.xy,0,0).xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 temp_output_2_0_g99 = uv0_MainTex;
				float2 break6_g99 = temp_output_2_0_g99;
				float temp_output_25_0_g99 = ( pow( _NormalCreateOffset , 3.0 ) * 0.1 );
				float2 appendResult8_g99 = (float2(( break6_g99.x + temp_output_25_0_g99 ) , break6_g99.y));
				float4 tex2DNode11_g99 = tex2D( _MainTex, appendResult8_g99 );
				float4 tex2DNode14_g99 = tex2D( _MainTex, temp_output_2_0_g99 );
				float temp_output_4_0_g99 = _NormalIntensity;
				float3 appendResult13_g99 = (float3(1.0 , 0.0 , ( ( max( max( tex2DNode11_g99.r , tex2DNode11_g99.g ) , tex2DNode11_g99.b ) - max( max( tex2DNode14_g99.r , tex2DNode14_g99.g ) , tex2DNode14_g99.b ) ) * temp_output_4_0_g99 )));
				float2 appendResult9_g99 = (float2(break6_g99.x , ( break6_g99.y + temp_output_25_0_g99 )));
				float4 tex2DNode12_g99 = tex2D( _MainTex, appendResult9_g99 );
				float3 appendResult16_g99 = (float3(0.0 , 1.0 , ( ( max( max( tex2DNode12_g99.r , tex2DNode12_g99.g ) , tex2DNode12_g99.b ) - max( max( tex2DNode14_g99.r , tex2DNode14_g99.g ) , tex2DNode14_g99.b ) ) * temp_output_4_0_g99 )));
				float3 normalizeResult22_g99 = normalize( cross( appendResult13_g99 , appendResult16_g99 ) );
				float3 lerpResult1337 = lerp( UnpackNormalScale( tex2D( _BumpMap, uv_BumpMap ), _NormalIntensity ) , normalizeResult22_g99 , (float)_NormalMode);
				float2 _Vector0 = float2(-1,1);
				float3 temp_cast_3 = (_Vector0.x).xxx;
				float3 temp_cast_4 = (_Vector0.y).xxx;
				float3 clampResult1339 = clamp( lerpResult1337 , temp_cast_3 , temp_cast_4 );
				float3 temp_output_5_0_g139 = clampResult1339;
				float3 normal1334 = ( appendResult7_g139 * temp_output_5_0_g139 );
				float3 temp_output_83_0_g155 = normal1334;
				float3 normal107_g155 = temp_output_83_0_g155;
				float NoiseFX78_g155 = ( hairnoise79_g155 * temp_output_1492_0 * ( (normal107_g155).y + _NoiseSpread ) * _NoiseSpread );
				float3 appendResult22_g155 = (float3(SafeNormalize(_MainLightPosition.xyz).x , ( NoiseFX78_g155 + SafeNormalize(_MainLightPosition.xyz).y + _HighlightPosition ) , SafeNormalize(_MainLightPosition.xyz).z));
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 normalizeResult29_g155 = normalize( ( appendResult22_g155 + ase_worldViewDir ) );
				float3 HL130_g155 = normalizeResult29_g155;
				float dotResult36_g155 = dot( T77_g155 , HL130_g155 );
				float sinTHL147_g155 = sqrt( ( 1.0 - ( dotResult36_g155 * dotResult36_g155 ) ) );
				float3 temp_output_65_0_g155 = ( (_HighlightColor).rgb * pow( sinTHL147_g155 , exp2( _HighlightExponent ) ) * _HighlightIntensity );
				float3 appendResult20_g155 = (float3(SafeNormalize(_MainLightPosition.xyz).x , ( NoiseFX78_g155 + SafeNormalize(_MainLightPosition.xyz).y + _SecondaryHighlightPosition ) , SafeNormalize(_MainLightPosition.xyz).z));
				float3 normalizeResult28_g155 = normalize( ( appendResult20_g155 + ase_worldViewDir ) );
				float3 HL231_g155 = normalizeResult28_g155;
				float dotResult37_g155 = dot( T77_g155 , HL231_g155 );
				float sinTHL246_g155 = sqrt( ( 1.0 - ( dotResult37_g155 * dotResult37_g155 ) ) );
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal73_g155 = temp_output_83_0_g155;
				float3 worldNormal73_g155 = normalize( float3(dot(tanToWorld0,tanNormal73_g155), dot(tanToWorld1,tanNormal73_g155), dot(tanToWorld2,tanNormal73_g155)) );
				float dotResult76_g155 = dot( SafeNormalize(_MainLightPosition.xyz) , worldNormal73_g155 );
				float smoothstepResult62_g155 = smoothstep( -1.0 , 0.0 , dotResult36_g155);
				float dirAtten64_g155 = smoothstepResult62_g155;
				float3 normalizeResult1505 = normalize( temp_output_1302_0 );
				float3 tanNormal24_g154 = normal1334;
				float3 worldNormal24_g154 = normalize( float3(dot(tanToWorld0,tanNormal24_g154), dot(tanToWorld1,tanNormal24_g154), dot(tanToWorld2,tanNormal24_g154)) );
				float dotResult20_g154 = dot( ase_worldViewDir , -( SafeNormalize(_MainLightPosition.xyz) + ( worldNormal24_g154 * _SSSDistortion ) ) );
				float temp_output_22_0_g154 = pow( saturate( dotResult20_g154 ) , _SSSPower );
				float2 uv_ThicknessMap = float4(IN.ase_texcoord2.xy,0,0).xy * _ThicknessMap_ST.xy + _ThicknessMap_ST.zw;
				float3 temp_output_1111_0 = saturate( ( temp_output_1302_0 + saturate( ( ( temp_output_65_0_g155 + ( (_SecondaryHighlightColor).rgb * pow( sinTHL246_g155 , exp2( _SecondaryHighlightExponent ) ) * _SecondaryHighlightIntensity ) ) * ( dotResult76_g155 * dotResult76_g155 * dotResult76_g155 ) * dirAtten64_g155 * _HairBlend ) ) + ( normalizeResult1505 * ( temp_output_22_0_g154 * _SSSIntensity * (_SSSColor).rgb * (tex2D( _ThicknessMap, uv_ThicknessMap )).rgb ) ) ) );
				
				float opacitymask1462 = ( 1.0 - ( ( 1.0 - saturate( ( tex2DNode4.a * _OpacityMaskMultiplier ) ) ) * _BlendMode ) );
				
				
				float3 Albedo = temp_output_1111_0;
				float Alpha = opacitymask1462;
				float AlphaClipThreshold = _MaskClipValue;

				half4 color = half4( Albedo, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}
		
	}
	/*ase_lod*/
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18200
306.5;540;1057;364;-1487.703;560.8678;3.388723;True;False
Node;AmplifyShaderEditor.CommentaryNode;1433;984.4292,184.7701;Inherit;False;1526.717;495.5953;;10;1334;1339;1337;1497;1475;857;1338;1329;859;1507;Normal;0,0,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;859;1034.429,498.2578;Inherit;False;Property;_NormalIntensity;Normal Intensity;14;0;Create;True;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1329;1034.665,420.2349;Inherit;False;Property;_NormalCreateOffset;Normal Create Offset;16;0;Create;True;0;0;False;0;False;0.35;0.35;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;1336;987.3409,-381.4098;Inherit;True;Property;_MainTex;Albedo (RGB);8;0;Create;False;0;0;False;0;False;None;38e1b44b53d74b141aad5e83ea42b916;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;1475;1356.052,434.2139;Inherit;False;Normal Create Optimized;-1;;99;411559a2966304e449b2eb4e03bac6eb;3,27,4,28,4,29,4;4;1;SAMPLER2D;0;False;2;FLOAT2;0,0;False;3;FLOAT;0.5;False;4;FLOAT;2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;1338;1430.534,576.9716;Inherit;False;Property;_NormalMode;Normal Mode;15;1;[Enum];Create;True;2;Normal;0;Normal Create;1;0;False;0;False;0;0;0;1;INT;0
Node;AmplifyShaderEditor.SamplerNode;857;1331.014,234.77;Inherit;True;Property;_BumpMap;Normal;13;1;[Normal];Create;False;0;0;False;1;Header(Normal);False;-1;None;e041849ee1925fa438dfa3ad631eb277;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;1301.142,-381.1319;Inherit;True;Property;_asdasd;asdasd;8;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;1491;1616.412,-309.6826;Inherit;False;FastMax;-1;;130;57e8a203d681a7d44943a7a02b635b77;0;2;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1337;1670.954,410.3343;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;1497;1676.118,284.0506;Inherit;False;Constant;_Vector0;Vector 0;23;0;Create;True;0;0;False;0;False;-1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;1096;1382.079,26.84278;Inherit;False;Property;_OpacityMaskMultiplier;Opacity Mask Multiplier;3;0;Create;True;0;0;False;0;False;4;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1492;1764.785,-309.6826;Inherit;False;FastMax;-1;;131;57e8a203d681a7d44943a7a02b635b77;0;2;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1443;1642.995,-213.1946;Inherit;False;Property;_AlbedoDesaturate;Albedo Desaturate;9;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;1339;1856.05,410.6479;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,0,0;False;2;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1456;1642.711,-62.5883;Inherit;False;Property;_AlbedoMax;Albedo Max;11;0;Create;True;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;738;1616.935,-381.1902;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1450;1642.848,-136.9773;Inherit;False;Property;_AlbedoRemapper;Albedo Remapper;10;0;Create;True;0;0;False;0;False;0;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;186;1877.644,-557.7852;Float;False;Property;_Color;Color;7;1;[HDR];Create;True;0;0;False;1;Header(Main);False;1,1,1,0;0.254717,0.1161984,0.0276344,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1093;1644.344,10.04201;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1507;2015.801,409.8917;Inherit;False;Normal Backface Fix;-1;;139;8834765e3b1a8da42974a77986950055;1,8,0;1;5;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;1446;1946.361,-375.1903;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1457;1939.146,-133.2298;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1489;2131.541,-553.6588;Inherit;False;Hair Color Blend;36;;151;427db5f0aa0a67449b5f348fef3b315e;2,20,1,33,1;1;16;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1449;2133.024,-375.9359;Inherit;False;Remap From 0-1;-1;;153;a39cd2f60dbc1ab48bc6321a2d59e3f6;0;3;6;FLOAT3;0,0,0;False;7;FLOAT;0;False;8;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;1496;1782.448,9.114454;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1334;2268.147,404.5546;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1143;2068.437,-224.496;Inherit;False;1334;normal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;1458;1934.905,8.697037;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;1431;1927.546,80.11235;Inherit;False;Property;_BlendMode;Blend Mode;1;1;[Enum];Create;True;2;Opaque;0;Alpha Test;1;0;False;0;False;1;1;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1302;2361.754,-376.1107;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1459;2098.904,8.697037;Inherit;False;2;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1502;2258.003,-219.4318;Inherit;False;Subsurface Scattering;17;;154;09bb372d14c0a924aaabeb999018a72f;2,110,0,167,0;2;45;FLOAT3;0,0,1;False;104;FLOAT3;0,0,0;False;1;FLOAT3;100
Node;AmplifyShaderEditor.NormalizeNode;1505;2343.847,-287.3391;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1487;1808.326,-658.8912;Inherit;False;1334;normal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;1460;2243.905,7.697037;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1504;2506.733,-287.369;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1503;2001.507,-653.6028;Inherit;False;Hair Anisotropic;23;;155;6c96809a9a8977f47a16a4e0f4fbf5fb;1,81,1;2;83;FLOAT3;0,0,1;False;82;FLOAT;1;False;2;FLOAT3;0;FLOAT;93
Node;AmplifyShaderEditor.RegisterLocalVarNode;1462;2411.205,2.75108;Inherit;False;opacitymask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1327;2663.069,-377.5301;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1012;2973.425,-378.4218;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1084;2662.477,-254.8813;Inherit;False;Property;_Emission;Emission;12;0;Create;True;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;945;3136,-384;Inherit;False;emission;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1085;2569.005,99.94745;Inherit;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;False;0;False;0.5;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1463;2817.11,248.4445;Inherit;False;1462;opacitymask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1307;2132.128,-469.4288;Inherit;False;maintexRGBmax;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1092;2731.781,3.303111;Inherit;False;Property;_Metallic;Metallic;5;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;946;2824.893,-73.6375;Inherit;False;945;emission;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;875;2826.347,-146.8406;Inherit;False;1334;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;1111;2804.501,-377.7237;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;1516;3136,-144;Inherit;False;Property;_CullMode;Cull Mode;0;1;[Enum];Create;True;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;1;INT;0
Node;AmplifyShaderEditor.FunctionNode;1495;2860.134,81.14105;Inherit;False;FastMax;-1;;156;57e8a203d681a7d44943a7a02b635b77;0;2;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1097;2729.747,326.2532;Inherit;False;Property;_MaskClipValue;Mask Clip Value;2;0;Create;True;0;0;True;0;False;0.5;0.5;0.15;0.85;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;897;2568.595,168.4935;Inherit;False;Property;_AOIntensity;AO Intensity;6;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1464;2859.769,172.9008;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1511;3136,-64;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;AV/URP/Hair;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;16;False;False;False;False;False;False;False;False;False;True;2;True;1516;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;0;5;False;-1;10;False;-1;0;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;0;False;-1;True;0;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;33;Workflow;1;Surface;1;  Refraction Model;0;  Blend;0;Two Sided;0;Transmission;0;  Transmission Shadow;1,False,-1;Translucency;0;  Translucency Strength;2.3,False,-1;  Normal Distortion;1,False,-1;  Scattering;1,False,-1;  Direct;1,False,-1;  Ambient;0.193,False,-1;  Shadow;0,False,-1;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;1;Built-in Fog;1;Meta Pass;1;Override Baked GI;0;Extra Pre Pass;0;DOTS Instancing;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;6;False;True;True;True;True;True;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1512;3136,-64;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1515;3136,-64;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;0;5;False;-1;10;False;-1;0;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;True;0;False;-1;True;0;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1510;3136,-64;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1513;3136,-64;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1514;3136,-64;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;1475;1;1336;0
WireConnection;1475;3;1329;0
WireConnection;1475;4;859;0
WireConnection;857;5;859;0
WireConnection;4;0;1336;0
WireConnection;1491;5;4;1
WireConnection;1491;6;4;2
WireConnection;1337;0;857;0
WireConnection;1337;1;1475;0
WireConnection;1337;2;1338;0
WireConnection;1492;5;1491;0
WireConnection;1492;6;4;3
WireConnection;1339;0;1337;0
WireConnection;1339;1;1497;1
WireConnection;1339;2;1497;2
WireConnection;738;0;4;0
WireConnection;1093;0;4;4
WireConnection;1093;1;1096;0
WireConnection;1507;5;1339;0
WireConnection;1446;0;738;0
WireConnection;1446;1;1492;0
WireConnection;1446;2;1443;0
WireConnection;1457;0;1450;0
WireConnection;1457;1;1456;0
WireConnection;1489;16;186;0
WireConnection;1449;6;1446;0
WireConnection;1449;7;1450;0
WireConnection;1449;8;1457;0
WireConnection;1496;0;1093;0
WireConnection;1334;0;1507;0
WireConnection;1458;0;1496;0
WireConnection;1302;0;1449;0
WireConnection;1302;1;1489;0
WireConnection;1459;0;1458;0
WireConnection;1459;1;1431;0
WireConnection;1502;45;1143;0
WireConnection;1505;0;1302;0
WireConnection;1460;0;1459;0
WireConnection;1504;0;1505;0
WireConnection;1504;1;1502;100
WireConnection;1503;83;1487;0
WireConnection;1503;82;1492;0
WireConnection;1462;0;1460;0
WireConnection;1327;0;1302;0
WireConnection;1327;1;1503;0
WireConnection;1327;2;1504;0
WireConnection;1012;0;1111;0
WireConnection;1012;1;1084;0
WireConnection;945;0;1012;0
WireConnection;1307;0;1492;0
WireConnection;1111;0;1327;0
WireConnection;1495;5;1503;93
WireConnection;1495;6;1085;0
WireConnection;1464;0;897;0
WireConnection;1511;0;1111;0
WireConnection;1511;1;875;0
WireConnection;1511;2;946;0
WireConnection;1511;3;1092;0
WireConnection;1511;4;1495;0
WireConnection;1511;5;1464;0
WireConnection;1511;6;1463;0
WireConnection;1511;7;1097;0
ASEEND*/
//CHKSM=76896A06D6C0DDCA380DBA2D854AB9084523BFAC