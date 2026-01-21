shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform bool overlay = false;

// Scanlines suaves
uniform float scanlines_opacity : hint_range(0.0, 1.0) = 0.15;   // ↓ más sutil
uniform float scanlines_width : hint_range(0.0, 0.5) = 0.35;    // ↑ más ancho = líneas más difusas

// Grille (trama RGB) casi apagada
uniform float grille_opacity : hint_range(0.0, 1.0) = 0.08;     // ↓ muy baja

uniform vec2 resolution = vec2(640.0, 480.0);

uniform bool pixelate = false; // por defecto desactivado

// Roll y distorsión mínimos
uniform bool roll = false;
uniform float roll_speed = 8.0;
uniform float roll_size : hint_range(0.0, 100.0) = 15.0;
uniform float roll_variation : hint_range(0.1, 5.0) = 1.8;
uniform float distort_intensity : hint_range(0.0, 0.2) = 0.015; // ↓ mucho más bajo

// Ruido suave
uniform float noise_opacity : hint_range(0.0, 1.0) = 0.1;       // ↓
uniform float noise_speed = 5.0;

uniform float static_noise_intensity : hint_range(0.0, 1.0) = 0.02; // ↓

// Aberración cromática mínima
uniform float aberration : hint_range(-1.0, 1.0) = 0.008;       // ↓
uniform float brightness = 1.15;                                // ↓ brillo más natural
uniform bool discolor = false;                                  // por defecto desactivado

// Warp suave
uniform float warp_amount : hint_range(0.0, 5.0) = 0.3;         // ↓ curvatura leve
uniform bool clip_warp = false;

// Vignette sutil
uniform float vignette_intensity = 0.25;                        // ↓
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.3;    // ↓


vec2 random(vec2 uv){
    uv = vec2(dot(uv, vec2(127.1,311.7)), dot(uv, vec2(269.5,183.3)));
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix(
        mix(dot(random(uv_index + vec2(0.0,0.0)), uv_fract - vec2(0.0,0.0)),
            dot(random(uv_index + vec2(1.0,0.0)), uv_fract - vec2(1.0,0.0)), blur.x),
        mix(dot(random(uv_index + vec2(0.0,1.0)), uv_fract - vec2(0.0,1.0)),
            dot(random(uv_index + vec2(1.0,1.0)), uv_fract - vec2(1.0,1.0)), blur.x),
        blur.y
    ) * 0.5 + 0.5;
}

vec2 warp(vec2 uv){
    vec2 delta = uv - 0.5;
    float delta2 = dot(delta.xy, delta.xy);
    float delta4 = delta2 * delta2;
    float delta_offset = delta4 * warp_amount * 0.05; // ↓ atenuamos el efecto de warp
    return uv + delta * delta_offset;
}

float border (vec2 uv){
    float radius = max(0.01, 0.08 - warp_amount * 0.01); // suavizamos el borde
    vec2 abs_uv = abs(uv * 2.0 - 1.0) - vec2(1.0, 1.0) + radius;
    float dist = length(max(vec2(0.0), abs_uv)) / radius;
    float square = smoothstep(0.95, 1.0, dist);
    return clamp(1.0 - square, 0.0, 1.0);
}

float vignette(vec2 uv){
    uv *= 1.0 - uv.xy;
    float vignette = uv.x * uv.y * 12.0; // ↓ intensidad base
    return pow(vignette, vignette_intensity * vignette_opacity + 0.1); // evita negro total
}


void fragment()
{
    vec2 uv = overlay ? warp(SCREEN_UV) : warp(UV);
    vec2 text_uv = uv;
    vec2 roll_uv = vec2(0.0);
    float time = roll ? TIME : 0.0;

    if (pixelate){
        text_uv = ceil(uv * resolution) / resolution;
    }

    float roll_line = 0.0;
    if (roll || noise_opacity > 0.0){
        roll_line = smoothstep(0.4, 0.85, sin(uv.y * roll_size - (time * roll_speed)));
        roll_line *= roll_line * smoothstep(0.4, 0.85, sin(uv.y * roll_size * roll_variation - (time * roll_speed * roll_variation)));
        roll_uv = vec2((roll_line * distort_intensity * (1.0 - UV.x)), 0.0);
    }

    vec4 text;
    if (roll){
        text.r = texture(SCREEN_TEXTURE, text_uv + roll_uv * 0.8 + vec2(aberration, 0.0) * 0.5).r;
        text.g = texture(SCREEN_TEXTURE, text_uv + roll_uv * 1.2).g;
        text.b = texture(SCREEN_TEXTURE, text_uv + roll_uv - vec2(aberration, 0.0) * 0.5).b;
        text.a = 1.0;
    } else {
        text.r = texture(SCREEN_TEXTURE, text_uv + vec2(aberration * 0.5, 0.0)).r;
        text.g = texture(SCREEN_TEXTURE, text_uv).g;
        text.b = texture(SCREEN_TEXTURE, text_uv - vec2(aberration * 0.5, 0.0)).b;
        text.a = 1.0;
    }

    float r = text.r;
    float g = text.g;
    float b = text.b;

    uv = warp(UV);

    // Grille muy sutil (solo si se quiere)
    if (grille_opacity > 0.01){
        float freq = resolution.x * 3.14159265 * 0.8; // ↓ frecuencia más baja
        float g_r = smoothstep(0.9, 0.98, abs(sin(uv.x * freq)));
        float g_g = smoothstep(0.9, 0.98, abs(sin(1.05 + uv.x * freq)));
        float g_b = smoothstep(0.9, 0.98, abs(sin(2.1 + uv.x * freq)));
        r = mix(r, r * g_r, grille_opacity);
        g = mix(g, g * g_g, grille_opacity);
        b = mix(b, b * g_b, grille_opacity);
    }

    // Brillo moderado
    vec3 color = vec3(r, g, b) * brightness;
    color = clamp(color, 0.0, 1.0);

    // Scanlines suaves
    if (scanlines_opacity > 0.0){
        float scan = abs(sin(uv.y * resolution.y * 3.14159265));
        float scan_smooth = smoothstep(scanlines_width, scanlines_width + 0.4, scan);
        color = mix(color, color * scan_smooth, scanlines_opacity);
    }

    // Ruido dinámico muy leve
    if (noise_opacity > 0.0){
        float n = noise(uv * vec2(1.0, 150.0) + vec2(0.0, TIME * noise_speed * 0.3));
        n = smoothstep(0.45, 0.55, n);
        color += (n - 0.5) * noise_opacity * 0.3;
    }

    // Ruido estático mínimo
    if (static_noise_intensity > 0.0){
        float static_n = random(floor(uv * resolution * 0.5) + vec2(TIME * 0.1)).x;
        color += (static_n * 0.5 + 0.5) * static_noise_intensity * 0.5;
    }

    // Bordes y viñeta suaves
    float mask = border(uv);
    color *= mask;
    color *= vignette(uv);

    if (clip_warp){
        text.a *= mask;
    }

    // Desaturación opcional (mejor dejarla apagada para nitidez)
    if (discolor){
        float luma = dot(color, vec3(0.299, 0.587, 0.114));
        color = mix(color, vec3(luma), 0.2); // solo 20% de desaturación
    }

    COLOR = vec4(color, text.a);
}