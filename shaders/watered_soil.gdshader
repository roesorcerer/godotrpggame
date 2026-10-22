shader_type canvas_item;

// Draws only the dirt part of dirt.png tiles, darkened, so the watered
// overlay doesn't tint the grass baked into the tile corners.
uniform vec4 tint : source_color = vec4(0.62, 0.52, 0.5, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	// Grass pixels are green-dominant; dirt and its outline are not.
	if (tex.g > tex.r) {
		discard;
	}
	COLOR = vec4(tex.rgb * tint.rgb, tex.a);
}
