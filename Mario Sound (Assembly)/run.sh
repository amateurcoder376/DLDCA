# Assemble the waveform generator
nasm -f elf64 -o wave.o wave.asm

# Compile and link with PortAudio
gcc -no-pie -o mario mario.c wave.o -lportaudio -lm

# Run
./mario
