shader_type spatial;
render_mode cull_front, unshaded;

uniform float outline_width : hint_range(0.0, 0.1) = 0.02;
uniform vec4 outline_color : source_color = vec4(1.0, 0.85, 0.0, 1.0);

void vertex() {
    vec3 normal = normalize(NORMAL);
    VERTEX += normal * outline_width;
}

void fragment() {
    ALBEDO = outline_color.rgb;
}