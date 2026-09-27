#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define NS   2000
#define FS   8000.0f
#define F0   440.0f

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

int main(){
    int n;
    float input, output;
    FILE *out_f;

    out_f = fopen("archivo5.txt", "w");

    for(n = 0; n < NS; n++){
        input  = sin(2.0 * M_PI * F0 * n / FS);
        output = input;
        fprintf(out_f, "\n % 10f % 10f % 10f", (float)n/FS, input, output);
    }

    fclose(out_f);
    return 0;
}
