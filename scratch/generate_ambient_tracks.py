import wave
import struct
import math
import random
import os

sample_rate = 44100
duration = 18.0  # 18-second smooth seamless loop
total_samples = int(sample_rate * duration)

output_dir = "/Users/betopia/development/projects/picstools/assets/audio"
os.makedirs(output_dir, exist_ok=True)

def write_wav(filename, samples_l, samples_r):
    filepath = os.path.join(output_dir, filename)
    with wave.open(filepath, 'w') as wav:
        wav.setnchannels(2)
        wav.setsampwidth(2)
        wav.setframerate(sample_rate)
        
        # Normalize
        max_val = max(max(abs(s) for s in samples_l), max(abs(s) for s in samples_r))
        if max_val == 0:
            max_val = 1
        scale = 0.85 * 32767 / max_val
        
        frames = bytearray()
        for i in range(len(samples_l)):
            # Apply loop crossfade at boundaries (0.5s fade in/out match)
            fade_len = int(sample_rate * 0.5)
            envelope = 1.0
            if i < fade_len:
                envelope = 0.5 - 0.5 * math.cos(math.pi * i / fade_len)
            elif i > len(samples_l) - fade_len:
                envelope = 0.5 + 0.5 * math.cos(math.pi * (i - (len(samples_l) - fade_len)) / fade_len)
            
            l = int(samples_l[i] * scale * envelope)
            r = int(samples_r[i] * scale * envelope)
            l = max(-32767, min(32767, l))
            r = max(-32767, min(32767, r))
            frames.extend(struct.pack('<hh', l, r))
        wav.writeframes(frames)
    print(f"Generated {filepath} ({os.path.getsize(filepath)} bytes)")

# 1. Deep Focus (Warm C Major 7th / F Major 7th meditative piano & pad progression)
def gen_deep_focus():
    samples_l = [0.0] * total_samples
    samples_r = [0.0] * total_samples
    # Chords: Cmaj7 (C3, E3, G3, B3), Fmaj7 (F3, A3, C4, E4), Am7 (A3, C4, E4, G4), Gsus4 (G3, C4, D4, G4)
    chords = [
        [130.81, 164.81, 196.00, 246.94],  # Cmaj7
        [174.61, 220.00, 261.63, 329.63],  # Fmaj7
        [110.00, 164.81, 220.00, 261.63],  # Am7
        [196.00, 261.63, 293.66, 392.00],  # Gsus4
    ]
    chord_dur = duration / len(chords)
    
    for ci, chord in enumerate(chords):
        c_start = int(ci * chord_dur * sample_rate)
        c_end = int((ci + 1) * chord_dur * sample_rate)
        c_samples = c_end - c_start
        for i in range(c_samples):
            idx = c_start + i
            if idx >= total_samples: break
            t = i / sample_rate
            # Smooth Bell/Pad envelope for chord
            env = math.sin(math.pi * i / c_samples) ** 1.5
            val_l = 0.0
            val_r = 0.0
            for note_i, freq in enumerate(chord):
                # Sine + Warm Overtones
                w = 2 * math.pi * freq * (idx / sample_rate)
                lfo = 1.0 + 0.15 * math.sin(2 * math.pi * 0.25 * (idx / sample_rate) + note_i)
                tone = (math.sin(w) + 0.35 * math.sin(2 * w) + 0.12 * math.sin(3 * w)) * lfo
                pan = 0.3 + 0.4 * (note_i / len(chord))
                val_l += tone * (1.0 - pan)
                val_r += tone * pan
            samples_l[idx] += val_l * env * 0.4
            samples_r[idx] += val_r * env * 0.4
    
    # Add warm sub bass & soft air
    for i in range(total_samples):
        t = i / sample_rate
        sub = math.sin(2 * math.pi * 65.41 * t) * (1.0 + 0.1 * math.sin(2 * math.pi * 0.1 * t))
        noise = (random.random() - 0.5) * 0.015
        samples_l[i] += sub * 0.15 + noise
        samples_r[i] += sub * 0.15 + noise
        
    write_wav("deep_focus.mp3", samples_l, samples_r)

# 2. Cozy Rain (Rain textures + Lo-Fi gentle electric piano chords)
def gen_cozy_rain():
    samples_l = [0.0] * total_samples
    samples_r = [0.0] * total_samples
    
    # Soft filtered rain pink noise
    b0_l, b1_l, b2_l = 0.0, 0.0, 0.0
    b0_r, b1_r, b2_r = 0.0, 0.0, 0.0
    for i in range(total_samples):
        white_l = random.random() * 2 - 1
        white_r = random.random() * 2 - 1
        # Pink noise filter approximation
        b0_l = 0.99765 * b0_l + white_l * 0.0990460
        b1_l = 0.96300 * b1_l + white_l * 0.2965164
        b2_l = 0.57000 * b2_l + white_l * 1.0526913
        rain_l = (b0_l + b1_l + b2_l + white_l * 0.1848) * 0.04
        
        b0_r = 0.99765 * b0_r + white_r * 0.0990460
        b1_r = 0.96300 * b1_r + white_r * 0.2965164
        b2_r = 0.57000 * b2_r + white_r * 1.0526913
        rain_r = (b0_r + b1_r + b2_r + white_r * 0.1848) * 0.04
        
        samples_l[i] += rain_l
        samples_r[i] += rain_r
    
    # Lo-Fi Rhodes chords (Dmaj7, Bm7, Gmaj7, A7)
    chords = [
        [146.83, 185.00, 220.00, 277.18],  # Dmaj7
        [123.47, 146.83, 185.00, 220.00],  # Bm7
        [98.00, 146.83, 196.00, 246.94],   # Gmaj7
        [110.00, 164.81, 220.00, 277.18],  # A7
    ]
    chord_dur = duration / len(chords)
    for ci, chord in enumerate(chords):
        c_start = int(ci * chord_dur * sample_rate)
        c_end = int((ci + 1) * chord_dur * sample_rate)
        for i in range(c_end - c_start):
            idx = c_start + i
            if idx >= total_samples: break
            t = (c_start + i) / sample_rate
            env = math.exp(-3.0 * i / (c_end - c_start)) * 0.8 + 0.2 * math.sin(math.pi * i / (c_end - c_start))
            for note_i, freq in enumerate(chord):
                tremolo = 1.0 + 0.2 * math.sin(2 * math.pi * 4.5 * t)
                tone = math.sin(2 * math.pi * freq * t) * tremolo
                samples_l[idx] += tone * env * 0.18
                samples_r[idx] += tone * env * 0.18
                
    write_wav("cozy_rain.mp3", samples_l, samples_r)

# 3. Cosmic Glow (Lush evolving ambient synth soundscape)
def gen_cosmic_glow():
    samples_l = [0.0] * total_samples
    samples_r = [0.0] * total_samples
    
    # Ethereal drones: Eb minor / Ab Major celestial harmony
    frequencies = [77.78, 116.54, 155.56, 233.08, 311.13, 466.16, 622.25]
    for fi, freq in enumerate(frequencies):
        lfo_rate = 0.08 + fi * 0.03
        phase_offset = fi * 1.2
        for i in range(total_samples):
            t = i / sample_rate
            mod = 0.5 + 0.5 * math.sin(2 * math.pi * lfo_rate * t + phase_offset)
            tone = math.sin(2 * math.pi * freq * t + 0.2 * math.sin(2 * math.pi * 0.5 * t))
            shimmer = 0.2 * math.sin(2 * math.pi * (freq * 2.002) * t)
            
            pan = 0.5 + 0.4 * math.sin(2 * math.pi * 0.15 * t + fi)
            samples_l[i] += (tone + shimmer) * mod * (1.0 - pan) * 0.18
            samples_r[i] += (tone + shimmer) * mod * pan * 0.18
            
    write_wav("cosmic_glow.mp3", samples_l, samples_r)

# 4. Nature Serenity (Gentle forest breeze, water flow & acoustic chimes)
def gen_nature_serenity():
    samples_l = [0.0] * total_samples
    samples_r = [0.0] * total_samples
    
    # Gentle stream water modulation
    for i in range(total_samples):
        t = i / sample_rate
        breeze = 0.5 + 0.5 * math.sin(2 * math.pi * 0.12 * t)
        flow = (random.random() * 2 - 1) * 0.02 * breeze
        samples_l[i] += flow
        samples_r[i] += flow
        
    # Pentatonic Chimes (G Major Pentatonic: G4, A4, B4, D5, E5)
    chimes = [392.00, 440.00, 493.88, 587.33, 659.25, 783.99]
    chime_times = [1.0, 3.5, 6.0, 8.5, 11.0, 13.5, 16.0]
    for ci, ct in enumerate(chime_times):
        freq = chimes[ci % len(chimes)]
        start_idx = int(ct * sample_rate)
        dur_samples = int(4.0 * sample_rate)
        for i in range(dur_samples):
            idx = (start_idx + i) % total_samples
            env = math.exp(-3.5 * i / dur_samples)
            t = (start_idx + i) / sample_rate
            chime = (math.sin(2 * math.pi * freq * t) + 0.3 * math.sin(2 * math.pi * freq * 2.76 * t)) * env
            pan = 0.2 + 0.6 * ((ci * 3) % 7 / 7.0)
            samples_l[idx] += chime * (1.0 - pan) * 0.22
            samples_r[idx] += chime * pan * 0.22
            
    write_wav("nature_serenity.mp3", samples_l, samples_r)

gen_deep_focus()
gen_cozy_rain()
gen_cosmic_glow()
gen_nature_serenity()
print("All relaxing ambient tracks successfully created!")
