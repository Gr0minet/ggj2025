shader_type spatial;
render_mode depth_draw_always;

uniform sampler2D main_noise_sampler : hint_normal;
uniform sampler2D caustic_sampler : hint_normal, filter_linear;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_ROUGHNESS_TEXTURE : hint_normal_roughness_texture, repeat_disable, filter_nearest;

uniform vec3 water_color : source_color = vec3(1.0);
uniform vec3 water_depth_color : source_color = vec3(1.0);

uniform float water_edge_distance = 0.1;
uniform float water_depth_distance = 0.3;

uniform float water_texture_scale = 20.0;

varying vec2 base_offset;

float get_noise(vec2 offset){
  return texture(main_noise_sampler, offset).x;
}

void vertex(){
  base_offset = (UV * 0.5) + TIME * 0.01;
  float h = 1.0;//get_noise(base_offset) * 0.1;
  //VERTEX.y += h;
  vec3 normal = normalize(vec3(
    h - get_noise(base_offset + vec2(0.8, 0.0)),
    8.0,
    h - get_noise(base_offset + vec2(0.0, 0.8))
  ));
  NORMAL = normal;
}

float fresnel(vec3 normal, vec3 view, float power){
  return pow(1.0 - clamp(dot(normal, view), 0.0, 1.0), power);
}

void fragment() {
  float caustic_1 = texture(caustic_sampler, UV * water_texture_scale + TIME * 0.05).x;
  float final_caustic = caustic_1 * (1.0 - fresnel(NORMAL, VIEW, 1.0)) * 0.25;

  float depth_tex = textureLod(DEPTH_TEXTURE,SCREEN_UV,0.0).r;
  vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV*2.0-1.0,depth_tex,1.0);
  world_pos.xyz /= world_pos.w;

    vec3 screen_normal = texture(NORMAL_ROUGHNESS_TEXTURE, SCREEN_UV).xyz;
    screen_normal = screen_normal * 2.0 - 1.0;

  float water_edge = world_pos.z + water_edge_distance;
  float water_edge_mask = clamp(1.0 - smoothstep(water_edge, water_edge + (caustic_1 * 0.5), VERTEX.z),0.0,1.0);
  float water_depth_mask = clamp(1.0 - smoothstep(world_pos.z, world_pos.z + water_depth_distance, VERTEX.z),0.0,1.0);

  vec3 screen_texture = texture(SCREEN_TEXTURE, SCREEN_UV, 2.0).rgb;
  vec3 final_water_color = mix(water_color, screen_texture * water_depth_color, water_depth_mask * 0.75);

  // check if the pixel is inside the bathtub or not
  // camera position: from the Camera3D node in your scene
  vec4 camera_position = vec4(0.0, 2.832, 0.885, 1.0);
  camera_position = VIEW_MATRIX * camera_position;

  // check if the pixel is inside the bathtub or not
  //bool inside = dot(screen_normal, camera_position.xyz - world_pos.xyz) > 0.0;
  //// make sure we have a object behind the water
  //bool valid = depth_tex > 0.0;
//
  //// if we're outside the bathtub, discard the pixel
  //if (!valid || !inside) {
    //discard;
  //}

   ROUGHNESS = 0.95;
  SPECULAR = 0.5;
  ALBEDO.rgb = final_water_color;
  ALBEDO += clamp(water_edge_mask + final_caustic, 0.0, 1.0);
  ALBEDO.r = clamp(water_edge_mask, 0.0, 1.0);

  // debug view
  // ALBEDO = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), float(inside && valid));
}