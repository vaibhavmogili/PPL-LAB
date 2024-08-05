#include<stdio.h>
#include<stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__constant__ int d_kernel[3];
__constant__ int d_A[30];
__constant__ int d_width;
__constant__ int d_mask_width;

__global__ void Constant_Convolution(int *B)
{
	int tid = threadIdx.x;
	int start = tid - (d_mask_width / 2);
	int sum = 0;

	for(int i=0; i<d_mask_width; i++)
		if(start + i >= 0 && start + i < d_width)
			sum += d_A[start + i] * d_kernel[i];
	B[tid] = sum;
}

int main()
{
	int width, mask_width;

	printf("Enter the width of input array: ");
	scanf("%d", &width);
	printf("Enter the width of the mask: ");
	scanf("%d", &mask_width);

	int *A = (int*)malloc(width * sizeof(int));
	int *B = (int*)malloc(width * sizeof(int));
	int *h_kernel = (int*)malloc(mask_width * sizeof(int));

	printf("Enter the input array elements: ");
	for(int i=0; i<width; i++)
		scanf("%d", &A[i]);

	printf("Enter the mask elements: ");
	for(int i=0; i<mask_width; i++)
		scanf("%d", &h_kernel[i]);

	int *d_B;
	cudaMalloc((void**)&d_B, width * sizeof(int));

	cudaMemcpyToSymbol(d_kernel, h_kernel, mask_width * sizeof(int));
	cudaMemcpyToSymbol(d_A, A, width * sizeof(int));
	cudaMemcpyToSymbol(d_width, &width, sizeof(int));
	cudaMemcpyToSymbol(d_mask_width, &mask_width, sizeof(int));

	Constant_Convolution<<<1, width>>>(d_B);

	cudaMemcpy(B, d_B, width * sizeof(int), cudaMemcpyDeviceToHost);

	printf("RESULTS:\n");
	printf("Output Array : ");
	for(int i=0; i<width; i++)
		printf("%d ", B[i]);
	printf("\n");

	cudaFree(d_B);
	free(A);
	free(B);
	free(h_kernel);

	return 0;
}