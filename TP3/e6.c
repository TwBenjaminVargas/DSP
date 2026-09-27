#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define NS 2000
#define FS 8000.0f

int main(){
    int n;
    float input, output;
    FILE *out_f;

    srand(time(NULL));

    out_f = fopen("archivo6.txt", "w");

    for(n = 0; n < NS; n++){
        input  = 2.0f * ((float)rand() / RAND_MAX) - 1.0f;
        output = input;
        fprintf(out_f, "\n % 10f % 10f % 10f", (float)n/FS, input, output);
    }

    fclose(out_f);
    return 0;
}
