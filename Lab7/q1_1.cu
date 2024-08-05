#include<stdio.h>
#include<stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void add(int *a, int *b, int *c)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	c[idx] = a[idx] + b[idx];
}

int main()
{
	int N;

	printf("Enter the value of N: ");
	scanf("%d", &N);

	int *A = (int*)malloc(N*sizeof(int));
	int *B = (int*)malloc(N*sizeof(int));
	int *C = (int*)malloc(N*sizeof(int));

	printf("Enter the elements of A: ");
	for(int i=0; i<N; i++)
		scanf("%d", &A[i]);

	printf("Enter the elements of B: ");
	for(int i=0; i<N; i++)
		scanf("%d", &B[i]);

	int *d_A, *d_B, *d_C;			// Device buffers
	int size = N * sizeof(int);

	// Allocate memory to device buffers
	cudaMalloc((void**)&d_A, size);
	cudaMalloc((void**)&d_B, size);
	cudaMalloc((void**)&d_C, size);

	// Copy data to device buffers
	cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, B, size, cudaMemcpyHostToDevice);

	// First parameter is number of blocks, whereas second parameter is number of threads per block
	add<<<N,1>>>(d_A, d_B, d_C);

	// Copy results back to host
	cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);

	printf("RESULTS:\n");
	printf("Resultant Array: ");
	for(int i=0; i<N; i++)
		printf("%d ", C[i]);
	printf("\n");

	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);

	return 0;
}