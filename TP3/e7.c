#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "test_signal.h"

#define NS     2000
#define FS     8000.0f
#define NH     5           /* longitud del filtro h */

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

/* filtro: media movil de 5 coeficientes */
float h[NH] = {0.2f, 0.2f, 0.2f, 0.2f, 0.2f};

int main(){
    int n, k;
    float y;
    FILE *out_f;

    out_f = fopen("archivo7.txt", "w");

    for(n = 0; n < NS; n++){
        y = 0.0f;
        for(k = 0; k < NH; k++){
            if(n - k >= 0){
                y += h[k] * test_signal[n - k];
            }
        }
        fprintf(out_f, "\n % 10f % 10f % 10f",
                (float)n/FS, test_signal[n], y);
    }

    fclose(out_f);
    return 0;
}
