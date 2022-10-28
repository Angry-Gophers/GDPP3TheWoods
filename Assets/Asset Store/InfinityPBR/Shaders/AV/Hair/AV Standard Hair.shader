// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AV/Standard/Hair"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)][Header(Global Properties)]_CullMode("Cull Mode", Int) = 0
		[Enum(Opaque,0,Alpha Test,1)]_BlendMode("Blend Mode", Int) = 0
		_MaskClipValue("Mask Clip Value", Range( 0.15 , 0.85)) = 0.5
		[Toggle(_)]_AlphaToCoverage("Alpha To Coverage", Int) = 0
		_OpacityMaskMultiplier("Opacity Mask Multiplier", Float) = 1
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
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull [_CullMode]
		Blend SrcAlpha OneMinusSrcAlpha
		
		AlphaToMask [_AlphaToCoverage]
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			half ASEVFace : VFACE;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
		};

		uniform int _CullMode;
		uniform int _AlphaToCoverage;
		uniform float _MaskClipValue;
		uniform float _NormalIntensity;
		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _NormalCreateOffset;
		uniform int _NormalMode;
		uniform float _AlbedoDesaturate;
		uniform float _AlbedoRemapper;
		uniform float _AlbedoMax;
		uniform float4 _Color;
		uniform float4 _HairVariationColor;
		uniform float _HairVariationHardness;
		uniform float _HairVariationPosition;
		uniform float _HairVariationBlend;
		uniform float4 _HighlightColor;
		uniform float _NoiseFrequency;
		uniform float _NoiseSpread;
		uniform float _HighlightPosition;
		uniform float _HighlightExponent;
		uniform float _HighlightIntensity;
		uniform float4 _SecondaryHighlightColor;
		uniform float _SecondaryHighlightPosition;
		uniform float _SecondaryHighlightExponent;
		uniform float _SecondaryHighlightIntensity;
		uniform float _HairBlend;
		uniform float _SSSDistortion;
		uniform float _SSSPower;
		uniform float _SSSIntensity;
		uniform float4 _SSSColor;
		uniform sampler2D _ThicknessMap;
		uniform float4 _ThicknessMap_ST;
		uniform float _Emission;
		uniform float _Metallic;
		uniform float _HairGloss;
		uniform float _Smoothness;
		uniform float _AOIntensity;
		uniform float _OpacityMaskMultiplier;
		uniform int _BlendMode;


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


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 appendResult7_g139 = (float3(1.0 , 1.0 , i.ASEVFace));
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float2 uv0_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
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
			float3 lerpResult1337 = lerp( UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap ), _NormalIntensity ) , normalizeResult22_g99 , (float)_NormalMode);
			float2 _Vector0 = float2(-1,1);
			float3 temp_cast_1 = (_Vector0.x).xxx;
			float3 temp_cast_2 = (_Vector0.y).xxx;
			float3 clampResult1339 = clamp( lerpResult1337 , temp_cast_1 , temp_cast_2 );
			float3 temp_output_5_0_g139 = clampResult1339;
			float3 normal1334 = ( appendResult7_g139 * temp_output_5_0_g139 );
			o.Normal = normal1334;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode4 = tex2D( _MainTex, uv_MainTex );
			float temp_output_5_0_g130 = tex2DNode4.r;
			float temp_output_5_0_g131 = ( temp_output_5_0_g130 + ( tex2DNode4.g * ( 1.0 - temp_output_5_0_g130 ) ) );
			float temp_output_1492_0 = ( temp_output_5_0_g131 + ( tex2DNode4.b * ( 1.0 - temp_output_5_0_g131 ) ) );
			float3 temp_cast_3 = (temp_output_1492_0).xxx;
			float3 lerpResult1446 = lerp( (tex2DNode4).rgb , temp_cast_3 , _AlbedoDesaturate);
			float temp_output_7_0_g160 = _AlbedoRemapper;
			float3 temp_output_16_0_g161 = _Color.rgb;
			float temp_output_12_0_g161 = ( 1.0 - _HairVariationHardness );
			float temp_output_14_0_g161 = ( frac( ( i.uv_texcoord.y * 2.0 ) ) + _HairVariationPosition );
			float smoothstepResult2_g161 = smoothstep( _HairVariationHardness , temp_output_12_0_g161 , temp_output_14_0_g161);
			float3 lerpResult6_g161 = lerp( (_HairVariationColor).rgb , temp_output_16_0_g161 , smoothstepResult2_g161);
			float3 lerpResult9_g161 = lerp( temp_output_16_0_g161 , lerpResult6_g161 , _HairVariationBlend);
			float3 temp_output_1302_0 = ( ( ( lerpResult1446 * ( ( _AlbedoRemapper + _AlbedoMax ) - temp_output_7_0_g160 ) ) + temp_output_7_0_g160 ) * lerpResult9_g161 );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 T77_g165 = cross( ase_worldTangent , ase_normWorldNormal );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float2 appendResult5_g165 = (float2(( i.uv_texcoord.x * _NoiseFrequency ) , i.uv_texcoord.y));
			float simpleNoise6_g165 = SimpleNoise( appendResult5_g165*10.0 );
			simpleNoise6_g165 = simpleNoise6_g165*2 - 1;
			float smoothstepResult7_g165 = smoothstep( -0.3 , 0.6 , simpleNoise6_g165);
			float hairnoise79_g165 = smoothstepResult7_g165;
			float3 temp_output_83_0_g165 = normal1334;
			float3 normal107_g165 = temp_output_83_0_g165;
			float NoiseFX78_g165 = ( hairnoise79_g165 * temp_output_1492_0 * ( (normal107_g165).y + _NoiseSpread ) * _NoiseSpread );
			float3 appendResult22_g165 = (float3(ase_worldlightDir.x , ( NoiseFX78_g165 + ase_worldlightDir.y + _HighlightPosition ) , ase_worldlightDir.z));
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult29_g165 = normalize( ( appendResult22_g165 + ase_worldViewDir ) );
			float3 HL130_g165 = normalizeResult29_g165;
			float dotResult36_g165 = dot( T77_g165 , HL130_g165 );
			float sinTHL147_g165 = sqrt( ( 1.0 - ( dotResult36_g165 * dotResult36_g165 ) ) );
			float3 temp_output_65_0_g165 = ( (_HighlightColor).rgb * pow( sinTHL147_g165 , exp2( _HighlightExponent ) ) * _HighlightIntensity );
			float3 appendResult20_g165 = (float3(ase_worldlightDir.x , ( NoiseFX78_g165 + ase_worldlightDir.y + _SecondaryHighlightPosition ) , ase_worldlightDir.z));
			float3 normalizeResult28_g165 = normalize( ( appendResult20_g165 + ase_worldViewDir ) );
			float3 HL231_g165 = normalizeResult28_g165;
			float dotResult37_g165 = dot( T77_g165 , HL231_g165 );
			float sinTHL246_g165 = sqrt( ( 1.0 - ( dotResult37_g165 * dotResult37_g165 ) ) );
			float dotResult76_g165 = dot( ase_worldlightDir , normalize( (WorldNormalVector( i , temp_output_83_0_g165 )) ) );
			float smoothstepResult62_g165 = smoothstep( -1.0 , 0.0 , dotResult36_g165);
			float dirAtten64_g165 = smoothstepResult62_g165;
			float3 normalizeResult1505 = normalize( temp_output_1302_0 );
			float dotResult20_g164 = dot( ase_worldViewDir , -( ase_worldlightDir + ( normalize( (WorldNormalVector( i , normal1334 )) ) * _SSSDistortion ) ) );
			float temp_output_22_0_g164 = pow( saturate( dotResult20_g164 ) , _SSSPower );
			float2 uv_ThicknessMap = i.uv_texcoord * _ThicknessMap_ST.xy + _ThicknessMap_ST.zw;
			float3 temp_output_1111_0 = saturate( ( temp_output_1302_0 + saturate( ( ( temp_output_65_0_g165 + ( (_SecondaryHighlightColor).rgb * pow( sinTHL246_g165 , exp2( _SecondaryHighlightExponent ) ) * _SecondaryHighlightIntensity ) ) * ( dotResult76_g165 * dotResult76_g165 * dotResult76_g165 ) * dirAtten64_g165 * _HairBlend ) ) + ( normalizeResult1505 * ( temp_output_22_0_g164 * _SSSIntensity * (_SSSColor).rgb * (tex2D( _ThicknessMap, uv_ThicknessMap )).rgb ) ) ) );
			o.Albedo = temp_output_1111_0;
			float3 emission945 = ( temp_output_1111_0 * _Emission );
			o.Emission = emission945;
			o.Metallic = _Metallic;
			float temp_output_5_0_g166 = ( saturate( ( hairnoise79_g165 + _HairGloss ) ) * _HairGloss );
			o.Smoothness = ( temp_output_5_0_g166 + ( _Smoothness * ( 1.0 - temp_output_5_0_g166 ) ) );
			o.Occlusion = ( 1.0 - _AOIntensity );
			o.Alpha = 1;
			float opacitymask1462 = ( 1.0 - ( ( 1.0 - saturate( ( tex2DNode4.a * _OpacityMaskMultiplier ) ) ) * _BlendMode ) );
			clip( opacitymask1462 - _MaskClipValue );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18104
361;548;1040;373;321.7769;757.0496;3.645986;True;False
Node;AmplifyShaderEditor.CommentaryNode;1433;984.4292,184.7701;Inherit;False;1526.717;495.5953;;10;1334;1339;1337;1497;1475;857;1338;1329;859;1507;Normal;0,0,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;1336;987.3409,-381.4098;Inherit;True;Property;_MainTex;Albedo (RGB);9;0;Create;False;0;0;False;0;False;None;38e1b44b53d74b141aad5e83ea42b916;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;859;1034.429,498.2578;Inherit;False;Property;_NormalIntensity;Normal Intensity;15;0;Create;True;0;0;False;0;False;1;0.6;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1329;1034.665,420.2349;Inherit;False;Property;_NormalCreateOffset;Normal Create Offset;17;0;Create;True;0;0;False;0;False;0.35;0.35;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;1301.142,-381.1319;Inherit;True;Property;_asdasd;asdasd;8;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;857;1331.014,234.77;Inherit;True;Property;_BumpMap;Normal;14;1;[Normal];Create;False;0;0;False;1;Header(Normal);False;-1;None;e041849ee1925fa438dfa3ad631eb277;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;1338;1443.534,577.9716;Inherit;False;Property;_NormalMode;Normal Mode;16;1;[Enum];Create;True;2;Normal;0;Normal Create;1;0;False;0;False;0;0;0;1;INT;0
Node;AmplifyShaderEditor.FunctionNode;1475;1356.052,434.2139;Inherit;False;Normal Create Optimized;-1;;99;2eac668477391da4384a613fcf9b1f74;3,27,4,28,4,29,4;4;1;SAMPLER2D;0;False;2;FLOAT2;0,0;False;3;FLOAT;0.5;False;4;FLOAT;2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;1497;1671.118,284.0506;Inherit;False;Constant;_Vector0;Vector 0;23;0;Create;True;0;0;False;0;False;-1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FunctionNode;1491;1616.412,-309.6826;Inherit;False;FastMax;-1;;130;77893a230aa5d4a43b6f6510820a4d66;0;2;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1337;1670.954,410.3343;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1492;1764.785,-309.6826;Inherit;False;FastMax;-1;;131;77893a230aa5d4a43b6f6510820a4d66;0;2;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1443;1642.995,-213.1946;Inherit;False;Property;_AlbedoDesaturate;Albedo Desaturate;10;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1450;1642.848,-136.9773;Inherit;False;Property;_AlbedoRemapper;Albedo Remapper;11;0;Create;True;0;0;False;0;False;0;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;738;1616.935,-381.1902;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;1339;1856.05,410.6479;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,0,0;False;2;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1456;1642.711,-62.5883;Inherit;False;Property;_AlbedoMax;Albedo Max;12;0;Create;True;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;186;1877.644,-557.7852;Float;False;Property;_Color;Color;8;1;[HDR];Create;True;0;0;False;1;Header(Main);False;1,1,1,0;0.254717,0.1161984,0.0276344,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;1457;1939.146,-133.2298;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1507;2015.801,409.8917;Inherit;False;Normal Backface Fix;-1;;139;5042132a257410b4b8b94f9551566a01;1,8,0;1;5;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;1446;1946.361,-375.1903;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1334;2268.147,404.5546;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1514;2131.541,-553.6588;Inherit;False;Hair Color Blend;37;;161;2668a07de1b8779428ae358f75c4816c;3,20,1,29,2,33,2;1;16;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1449;2133.024,-375.9359;Inherit;False;Remap From 0-1;-1;;160;5454cc39823be5644b26279791046fff;0;3;6;FLOAT3;0,0,0;False;7;FLOAT;0;False;8;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1302;2361.754,-376.1107;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1096;1382.079,27.84278;Inherit;False;Property;_OpacityMaskMultiplier;Opacity Mask Multiplier;4;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1143;2068.437,-224.496;Inherit;False;1334;normal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1487;1808.326,-658.8912;Inherit;False;1334;normal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1093;1644.344,10.04201;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;1505;2343.847,-287.3391;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1502;2258.003,-219.4318;Inherit;False;Subsurface Scattering;18;;164;5fc3947ab881fac449027203ace33981;2,110,0,167,0;2;45;FLOAT3;0,0,1;False;104;FLOAT3;0,0,0;False;1;FLOAT3;100
Node;AmplifyShaderEditor.FunctionNode;1503;2001.507,-653.6028;Inherit;False;Hair Anisotropic;24;;165;938004f063eefba4ab5538c4c89e1e18;1,81,1;2;83;FLOAT3;0,0,1;False;82;FLOAT;1;False;2;FLOAT3;0;FLOAT;93
Node;AmplifyShaderEditor.SaturateNode;1496;1782.448,9.114454;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1504;2506.733,-287.369;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1327;2663.069,-377.5301;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;1431;1927.546,80.11235;Inherit;False;Property;_BlendMode;Blend Mode;1;1;[Enum];Create;True;2;Opaque;0;Alpha Test;1;0;False;0;False;0;1;0;1;INT;0
Node;AmplifyShaderEditor.OneMinusNode;1458;1934.905,8.697037;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1459;2098.904,8.697037;Inherit;False;2;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1084;2662.477,-254.8813;Inherit;False;Property;_Emission;Emission;13;0;Create;True;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1111;2804.501,-377.7237;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1012;2973.425,-378.4218;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;1460;2243.905,7.697037;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;945;3136,-384;Inherit;False;emission;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;897;2568.595,168.4935;Inherit;False;Property;_AOIntensity;AO Intensity;7;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1085;2569.005,99.94745;Inherit;False;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;False;0;False;0.5;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1462;2411.205,2.75108;Inherit;False;opacitymask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;875;2826.347,-146.8406;Inherit;False;1334;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1463;2817.11,248.4445;Inherit;False;1462;opacitymask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;852;3136,-144;Inherit;False;Property;_CullMode;Cull Mode;0;1;[Enum];Create;True;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;1;Header(Global Properties);False;0;0;0;1;INT;0
Node;AmplifyShaderEditor.FunctionNode;1495;2860.134,81.14105;Inherit;False;FastMax;-1;;166;77893a230aa5d4a43b6f6510820a4d66;0;2;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1092;2731.781,3.303111;Inherit;False;Property;_Metallic;Metallic;6;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;946;2824.893,-73.6375;Inherit;False;945;emission;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1097;3136,-224;Inherit;False;Property;_MaskClipValue;Mask Clip Value;2;0;Create;True;0;0;True;0;False;0.5;0.5;0.15;0.85;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1464;2859.769,172.9008;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;1508;3136,-304;Inherit;False;Property;_AlphaToCoverage;Alpha To Coverage;3;0;Create;True;0;1;;True;1;Toggle(_);False;0;0;0;1;INT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1307;2132.128,-469.4288;Inherit;False;maintexRGBmax;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3136,-64;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;AV/Standard/Hair;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;True;0;0;True;852;-1;0;True;1097;0;0;0;False;0.1;False;-1;0;True;1508;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;1509;3353.064,-287.2827;Inherit;False;217.2517;100;works only with MSAA;0;;1,1,1,1;0;0
WireConnection;4;0;1336;0
WireConnection;857;5;859;0
WireConnection;1475;1;1336;0
WireConnection;1475;3;1329;0
WireConnection;1475;4;859;0
WireConnection;1491;5;4;1
WireConnection;1491;6;4;2
WireConnection;1337;0;857;0
WireConnection;1337;1;1475;0
WireConnection;1337;2;1338;0
WireConnection;1492;5;1491;0
WireConnection;1492;6;4;3
WireConnection;738;0;4;0
WireConnection;1339;0;1337;0
WireConnection;1339;1;1497;1
WireConnection;1339;2;1497;2
WireConnection;1457;0;1450;0
WireConnection;1457;1;1456;0
WireConnection;1507;5;1339;0
WireConnection;1446;0;738;0
WireConnection;1446;1;1492;0
WireConnection;1446;2;1443;0
WireConnection;1334;0;1507;0
WireConnection;1514;16;186;0
WireConnection;1449;6;1446;0
WireConnection;1449;7;1450;0
WireConnection;1449;8;1457;0
WireConnection;1302;0;1449;0
WireConnection;1302;1;1514;0
WireConnection;1093;0;4;4
WireConnection;1093;1;1096;0
WireConnection;1505;0;1302;0
WireConnection;1502;45;1143;0
WireConnection;1503;83;1487;0
WireConnection;1503;82;1492;0
WireConnection;1496;0;1093;0
WireConnection;1504;0;1505;0
WireConnection;1504;1;1502;100
WireConnection;1327;0;1302;0
WireConnection;1327;1;1503;0
WireConnection;1327;2;1504;0
WireConnection;1458;0;1496;0
WireConnection;1459;0;1458;0
WireConnection;1459;1;1431;0
WireConnection;1111;0;1327;0
WireConnection;1012;0;1111;0
WireConnection;1012;1;1084;0
WireConnection;1460;0;1459;0
WireConnection;945;0;1012;0
WireConnection;1462;0;1460;0
WireConnection;1495;5;1503;93
WireConnection;1495;6;1085;0
WireConnection;1464;0;897;0
WireConnection;1307;0;1492;0
WireConnection;0;0;1111;0
WireConnection;0;1;875;0
WireConnection;0;2;946;0
WireConnection;0;3;1092;0
WireConnection;0;4;1495;0
WireConnection;0;5;1464;0
WireConnection;0;10;1463;0
ASEEND*/
//CHKSM=DE83C603F1F7AAF5A04E372DDAADD7C16F6DA81A