#include<stdio.h>
#include<stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void convolution_1D_mask(int *N, int *M, int *P, int mask_width, int width)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int Pval = 0;
	int N_start_point = idx - (mask_width / 2);

	for(int j=0; j<mask_width; j++)
		if(N_start_point + j >= 0 && N_start_point + j < width)
			Pval += N[N_start_point + j] * M[j];
	P[idx] = Pval;
}

int main()
{
	int width, mask_width;
	int d_width, d_mask_width;

	printf("Enter the width of the input array N: ");
	scanf("%d", &width);
	printf("Enter the width of the mask M: ");
	scanf("%d", &mask_width);

	int *N = (int*)malloc(width*sizeof(int));
	int *P = (int*)malloc(width*sizeof(int));
	int *M = (int*)malloc(mask_width*sizeof(int));
	int *d_N, *d_P, *d_M;

	printf("Enter the elements of N: ");
	for(int i=0; i<width; i++)
		scanf("%d", &N[i]);

	printf("Enter the elements of M: ");
	for(int i=0; i<mask_width; i++)
		scanf("%d", &M[i]);

	cudaMalloc((void**)&d_N, width*sizeof(int));
	cudaMalloc((void**)&d_P, width*sizeof(int));
	cudaMalloc((void**)&d_M, mask_width*sizeof(int));
	cudaMalloc((void**)&d_width, sizeof(int));
	cudaMalloc((void**)&d_mask_width, sizeof(int));

	cudaMemcpy(d_N, N, width*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_P, P, width*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_M, M, mask_width*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_width, width, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_mask_width, mask_width, sizeof(int), cudaMemcpyHostToDevice);

	convolution_1D_mask<<<1, width>>>(d_N, d_M, d_P, d_mask_width, d_width);

	cudaMemcpy(P, d_P, width*sizeof(int), cudaMemcpyDeviceToHost);

	printf("The output array P is: ");
	for(int i=0; i<width; i++)
		printf("%d ", P[i]);
	printf("\n");

	cudaFree(d_N);
	cudaFree(d_P);
	cudaFree(d_M);

	return 0;
}