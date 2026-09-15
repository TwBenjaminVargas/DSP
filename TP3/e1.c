#include <stdio.h>
#include <stdlib.h>
#include "test_signal.h"

#define NS 2000
#define FS 8000


int main(){
	int n;
	float input, output;
	FILE *out_f;
	
	out_f = fopen("archivo1.txt", "w");
	
	for(n=0;n<NS;n++){
		input = test_signal[n];
		
		output = input;
		
		fprintf(out_f,"\n % 10f % 10f % 10f", (float)n/FS, input, output);
	}

	fclose(out_f);
	
	return 0;
}
