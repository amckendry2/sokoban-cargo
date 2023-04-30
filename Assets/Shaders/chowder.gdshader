shader_type canvas_item;

uniform vec2 aspect_ratio = vec2(1.0f, 1.0f);

// Which color you want to change
uniform vec4 u_color_key : hint_color;

uniform sampler2D background_texture : hint_black;

uniform float scale = 2.0;
uniform vec2 move_dir = vec2(1.0f,-1.0f);
uniform float move_speed = 1.0f;

void fragment() {
    vec4 col = texture(TEXTURE, UV);
	col = col * col.a;
    vec4 d4 = abs(col - u_color_key);
    float d = max(max(d4.r, d4.g), d4.b);
	
    if(d < 0.02) {
      vec2 uv = vec2(SCREEN_UV.x, SCREEN_UV.y * aspect_ratio.x/aspect_ratio.y);
      col = texture(background_texture, fract(1.0f - uv * vec2(scale,scale) + TIME * move_dir * move_speed/100.0f));
    }
    COLOR = col;
}