// waves.glsl

const int OCTAVES = 4;
const float MAX_DISPLACEMENT = 0.10; 
const float MAX_DIP = 0.35; 

const float WARP_STRENGTH = 1.2; 

const mat2 rot = mat2(-0.737, -0.675, 
                       0.675, -0.737);

float getWaveHeight(vec3 world_pos, float time) {
    float total_wave = 0.0;
    float max_possible_height = 0.0; 

    float amplitude = 1.0;
    float frequency = 0.3; 
    float speed = 0.6; 

    vec2 p = world_pos.xz;
    
    vec2 derivative_sum = vec2(0.0);

    for (int i = 0; i < OCTAVES; i++) {
        float phase = (p.x + p.y) * frequency + time * speed;
        float current_wave = sin(phase);

        total_wave += current_wave * amplitude;
        max_possible_height += amplitude;

        float slope = cos(phase) * frequency * amplitude;
        
        derivative_sum += vec2(slope, slope);
        p -= derivative_sum * WARP_STRENGTH; 
        // --------------------------

        amplitude *= 0.5;   
        frequency *= 2.0;   
        speed *= 1.15;       

        p = rot * p;
    }

    float raw_normalized = total_wave / max_possible_height;
    float t = raw_normalized * 0.5 + 0.5;

    return mix(-MAX_DIP, MAX_DISPLACEMENT, t);
}