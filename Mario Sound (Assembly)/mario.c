#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <portaudio.h>

#define SAMPLE_RATE 44100
#define AMPLITUDE 30000

extern void generate_wave(int16_t *buffer, int64_t frames, int64_t frequency);

// Generate a square wave 
/* 
void generate_wave(int16_t *buffer, int frames, int frequency){
    if (frequency == 0) { 
        for (int i = 0; i < frames; i++) buffer[i] = 0; 
        return; } 
    int halfPeriod = SAMPLE_RATE / (2 * frequency); 
    int counter = halfPeriod; int16_t sample = AMPLITUDE; 
    for (int i = 0; i < frames; i++) { 
        buffer[i] = sample; 
        counter--; 
        if (counter <= 0) { 
        sample = -sample; 
        counter = halfPeriod; } } 
    }

*/

// Note structure
typedef struct {
    int freq;
    float duration;
} Note;

// Mario overworld theme (simplified)
Note mario_theme[] = {
    {659,0.125},{659,0.125},{0,0.125},{659,0.125},{0,0.125},{523,0.125},{659,0.125},{0,0.125},
    {784,0.125},{0,0.25},{392,0.25},
    {523,0.25},{392,0.125},{330,0.25},{440,0.125},{494,0.125},{466,0.125},{440,0.125},{392,0.125},{659,0.125},{784,0.125},{880,0.25},
    {698,0.25},{784,0.125},{659,0.125},{523,0.125},{587,0.125},{494,0.125},{523,0.125},{0,0.125},
    {392,0.125},{330,0.125},{440,0.125},{494,0.25},{466,0.125},{440,0.125},{392,0.125},{659,0.125},{784,0.125},{880,0.25},
    {698,0.25},{784,0.125},{659,0.125},{523,0.125},{587,0.125},{494,0.125}
};

int main() {
    PaStream *stream;
    PaError err;

    // Initialize PortAudio
    if ((err = Pa_Initialize()) != paNoError) {
        fprintf(stderr, "PortAudio error: %s\n", Pa_GetErrorText(err));
        return 1;
    }

    if ((err = Pa_OpenDefaultStream(&stream,0,1,paInt16,SAMPLE_RATE,256,NULL,NULL)) != paNoError) {
        fprintf(stderr, "PortAudio error: %s\n", Pa_GetErrorText(err));
        Pa_Terminate();
        return 1;
    }

    if ((err = Pa_StartStream(stream)) != paNoError) {
        fprintf(stderr, "PortAudio error: %s\n", Pa_GetErrorText(err));
        Pa_Terminate();
        return 1;
    }

    // Find the maximum number of frames needed
    int maxFrames = 0;
    int totalNotes = sizeof(mario_theme)/sizeof(Note);
    for(int i=0;i<totalNotes;i++){
        int frames = (int)(mario_theme[i].duration * SAMPLE_RATE);
        if(frames > maxFrames) maxFrames = frames;
    }

    // Allocate a single reusable buffer
    int16_t *buffer = malloc(sizeof(int16_t) * maxFrames);
    if(!buffer){ perror("malloc"); exit(1); }

    // Play all notes
    for(int n=0;n<totalNotes;n++){
        Note note = mario_theme[n];
        int frames = (int)(note.duration * SAMPLE_RATE);
        generate_wave(buffer, frames, note.freq);
        err = Pa_WriteStream(stream, buffer, frames);
        if(err != paNoError) fprintf(stderr,"PortAudio write error: %s\n",Pa_GetErrorText(err));
    }

    free(buffer);
    Pa_StopStream(stream);
    Pa_CloseStream(stream);
    Pa_Terminate();
    return 0;
}
