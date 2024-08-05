// 1D Convolution Constant Memory

#include<stdio.h>
#include<stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#define K 3

__constant__ int d_kernel[K];

__global__ void Convolution_1D(int *A, int *B)
{
	int tid = threadIdx.x;
	int width = blockDim.x;
	int start_point = tid - (K / 2);
	int sum = 0;

	for(int i=0; i<K; i++)
		if(start_point + i >= 0 && start_point + i < width)
			sum += A[start_point + i] * d_kernel[i];
	B[tid] = sum;
}

int main()
{
	int width;

	printf("Enter width of input array: ");
	scanf("%d", &width);

	int *A = (int*)malloc(width * sizeof(int));
	int *B = (int*)malloc(width * sizeof(int));

	printf("Enter the input array elements: ");
	for(int i=0; i<width; i++)
		scanf("%d", &A[i]);

	int h_kernel[K] = {1, 2, 3};

	int *d_A, *d_B;

	cudaMalloc((void**)&d_A, width * sizeof(int));
	cudaMalloc((void**)&d_B, width * sizeof(int));
	
	cudaMemcpy(d_A, A, width * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpyToSymbol(d_kernel, h_kernel, K * sizeof(int));

	Convolution_1D<<<1, width>>>(d_A, d_B);

	cudaMemcpy(B, d_B, width * sizeof(int), cudaMemcpyDeviceToHost);

	printf("RESULTS:\n");
	printf("Output Array: ");
	for(int i=0; i<width; i++)
		printf("%d ", B[i]);
	printf("\n");

	cudaFree(d_A);
	cudaFree(d_B);
	free(A);
	free(B);

	return 0;
}