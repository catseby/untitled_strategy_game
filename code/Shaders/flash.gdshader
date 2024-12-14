shader_type spatial;
render_mode unshaded, depth_draw_never;

uniform vec4 flash_color : source_color = vec4(1.0,1.0,1.0,1.0);
uniform float flash_speed = 40.0;
uniform float flash_duration = 1.0;
instance uniform bool active = false;

void fragment() {
	if (active) {
		float alpha = TIME;
		ALBEDO = flash_color.rgb;
		ALPHA = round((sin(TIME * flash_speed) + 1.0) / 2.0);
	}
	else {
		ALPHA = 0.0;
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
