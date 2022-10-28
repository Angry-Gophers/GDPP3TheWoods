AV HAIR
[explanations are similar for each renderpipeline]
- Standard Render Pipeline
- Universal Render Pipeline
- High Definition Render Pipeline

CREATOR OF THIS SHADER:
Discord: AlexViktor#1715

_________________________________________________________________________________


EXPLANATION OF ALL PROPERTIES:
Cull Mode [culling means hiding the respective face of the mesh]
	OFF = Double Sided
	Front = only the backface is being rendered
	Back = only the front face is being rendered
Blend Mode
	Opaque = solid mesh without any transparency or cutout
	Alpha Test = makes use of the Texture Alpha channel to cutout meshes
Mask Clip Value
	alpha output is being subtracted by clip value
Opacity Mask Multiplier
	multiplies the alpha channel
Smoothness [unity default: 0.5]
	sets the reflection intensity/range, depends on your normals
Metallic [unity default: 0]
	exponent to define a intensified and darker color
AO Intensity [unity default 0]
	occludes the amount of your ambient/baked lighting

Color
	Color is being multiplied with the Albedo to define a new texture color
Albedo (RGB)
	This is your Main Diffuse Texture
Albedo Desaturate
	lerps between Albedo*Color and Albedograyscale*Color
	[i had to use max(R,max(G,B) to get a consistant result when using the hair anisotropics, therefore i reused it for desaturation] [to optimize a little bit more, i made an own implementation of max(R,max(G,B), its not linear, but works in most cases, i call it fastmax]
Albedo Remapper
	adds the selected amount to the albedo, to define a new texture color
Albedo Max
	remaps the albedo to a new max-value
Emission
	depending on your post-processing, this can have a good effect to bring in some glow/shine
	you can imagine this value acting as a UNLIT shader
	[glows in darkness]

Normal
	Normal Map 
Normal Intensity
	sets the Normal intensity
Normal Mode
	Normal = uses default Normal input
	Normal Create = generates a normal by offsetting the Albedo [works pretty well on hair]
Normal Create Offset
	changes the offset value

Thickness Map
	basically a mask, to mask out the effect [returns 1 as default]
SSS Color
	defines color of SubSurface Scattering
SSS Distortion
	normal dependent scatter [approximation, works reasonably well]
SSS Power
	higher values for a slim rim
SSS Intensity
	multiplies the effect by given amount

Hair Blend
	property to set overall highlight intensity [0 = disabled]
Hair Gloss
	sets smoothness on hair whereever noise is applied
Noise Frequency
	changes the frequency of the noise
Noise Spread
	widens the noise on higher values
[same info for 'Secondary Highlight' properties]
Highlight Color
	sets the highlight color
Highlight Position
	value offsets the position of the highlight
Highlight Exponent
	changes power of the highlight
Highlight Intensity
	changes intensity of the highlight

Hair Variation
	blends between default and variation
Hair Variation Color
	color of the hairblend
Hair Variation Position
	sets the position of the color blend
Hair Variation Hardness
	full hardness is on 0.5