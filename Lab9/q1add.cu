#include<stdio.h>
#include<stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void replace_matrix_elements(int *A, int *res)
{
	int rows = blockDim.x;
	int cols = blockDim.y;
	int row = threadIdx.x;
	int col = threadIdx.y;

	int idx = row * cols + col;
	int sum = 0;

	if(A[idx] % 2 == 0)
		for(int i=0; i<cols; i++)
			sum += A[row * cols + i];
	else
		for(int i=0; i<rows; i++)
			sum += A[i * cols + col];
	res[idx] = sum;
}

int main()
{
	int M, N;
	int size;

	printf("Enter the value of M: ");
	scanf("%d", &M);
	printf("Enter the value of N: ");
	scanf("%d", &N);
	size = M * N * sizeof(int);

	int *A = (int*)malloc(size);
	int *res = (int*)malloc(size);

	printf("Enter the elements of matrix A: ");
	for(int i=0; i<(M*N); i++)
		scanf("%d", &A[i]);

	int *d_A, *d_res;

	cudaMalloc((void**)&d_A, size);
	cudaMalloc((void**)&d_res, size);

	cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);

	replace_matrix_elements<<<1, (M, N)>>>(d_A, d_res);

	cudaMemcpy(res, d_res, size, cudaMemcpyDeviceToHost);

	printf("RESULTS:\n");
	printf("Resultant Matrix:\n");
	for(int i=0; i<(M*N); i++)
	{
		if(i % M == 0)
			printf("\n");
		printf("%d ", res[i]);
	}

	cudaFree(d_A);
	cudaFree(d_res);
	free(A);
	free(res);

	return 0;
}