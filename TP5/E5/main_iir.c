#include <stdio.h>

#include "filter.h"
#include "signal.h"

#define NS 4000
#define FS 8000
#define PI 3.1415926


int main()
{
	long n;
	float iir_input;
	float wn[NUM_SECTIONS][2] = {0.0};
	int section;
	float out_wn;
	float yn;

	FILE *iir_out_f;
	iir_out_f = fopen("iir_out.txt", "w");
	
	for (n = 0; n < NS; n++)
	{
		iir_input = signal[n];
			
	    for (section = 0; section < NUM_SECTIONS; section++)
	    {
		    out_wn = iir_input - a[section][0] * wn[section][0]
			    - a[section][1] * wn[section][1];
		    yn = b[section][0] * out_wn + b[section][1] * wn[section][0]
			    + b[section][2] * wn[section][1];
		    wn[section][1] = wn[section][0];
		    wn[section][0] = out_wn;
		    iir_input = yn;
	    }
		
		fprintf(iir_out_f, "\n %f %15.15f", (float)n/FS, yn);
	}

	fclose(iir_out_f);

	return 0;
}
