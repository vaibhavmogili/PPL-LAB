#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void Generate_RS(char *S, char *RS, int *idx, int len)
{
	int tid = threadIdx.x;
	for(int i=0; i<len; i++)
		RS[idx[tid]+i] = S[i];
}

int main()
{
	char S[100], RS[100];
	int idx[100];
	int len;

	printf("Enter a word: ")
	scanf("%s", S);
	len = strlen(S);

	idx[0] = 0;
	for(int i=1; i<len; i++)
		idx[i] = idx[i-1] + len - i + 1;

	char *d_S, *d_RS;
	int *d_idx;

	cudaMalloc((void**)&d_S, len*sizeof(char));
	cudaMalloc((void**))&d_RS, (len*len)*sizeof(char));
	cudaMalloc((void**)&d_idx, len*sizeof(int));

	cudaMemcpy(d_S, S, len*sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_RS, RS, (len*len)*sizeof(char), cudaMemcpyHostToDevice);

	Generate_RS<<<1, len>>>(d_S, d_RS, d_idx, len);

	cudaMemcpy(RS, d_RS, (len*len)*sizeof(char), cudaMemcpyDeviceToHost);

	printf("RS: %s\n", RS);

	cudaFree(d_S);
	cudaFree(d_RS);
	cudaFree(d_idx);

	return 0;
}		