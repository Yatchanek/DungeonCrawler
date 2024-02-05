shader_type canvas_item;

uniform vec4 flash_color : source_color;
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec3 new_color = mix(color.rgb, flash_color.rgb, flash_modifier);
	
	COLOR.rgb = new_color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
