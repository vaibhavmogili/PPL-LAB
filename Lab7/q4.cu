#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void sin_rad(float *A, float *B)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	float val = A[idx];
	float res = sin(val);
	B[idx] = res;
}

int main()
{
	int N;

	printf("Enter the number of elements: ");
	scanf("%d", &N);

	float *A = (float*)malloc(N*sizeof(float));
	float *d_A, *d_B;

	printf("Enter the array elements: ");
	for(int i=0; i<N; i++)
		scanf("%f", &A[i]);

	cudaMalloc((void**)&d_A, N*sizeof(float));
	cudaMalloc((void**)&d_B, N*sizeof(float));

	cudaMemcpy(d_A, A, N*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, B, N*sizeof(float), cudaMemcpyHostToDevice);

	sin_rad<<<1, N>>>(d_A, d_B);

	cudaMemcpy(B, d_B, N*sizeof(float), cudaMemcpyDeviceToHost);

	printf("The output array is: ");
	for(int i=0; i<N; i++)
		printf("%.3f ", B[i]);
	printf("\n");

	cudaFree(d_A);
	cudaFree(d_B);

	return 0;
}