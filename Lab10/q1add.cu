#include<stdio.h>
#include<stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void Replace_Matrix_Elements(int *A, int *B)
{
	int rowid = threadIdx.x;
	int colid = threadIdx.y;
	int M = blockDim.x;
	int N = blockDim.y;
	int rowsum = 0, colsum = 0, sum;

	for(int i=0; i<N; i++)
		rowsum += A[rowid * N + i];

	for(int i=0; i<M; i++)
		colsum += A[i * N + colid];

	sum = rowsum + colsum;

	B[rowid * N + colid] = sum;
}

int main()
{
	int M, N;
	int size;

	printf("Enter the number of rows: ");
	scanf("%d", &M);
	printf("Enter the number of columns: ");
	scanf("%d", &N);
	size = M * N * sizeof(int);

	int *A = (int*)malloc(size);
	int *B = (int*)malloc(size);

	printf("Enter the elements of A: ");
	for(int i=0; i<(M*N); i++)
		scanf("%d", &A[i]);

	int *d_A, *d_B;

	cudaMalloc((void**)&d_A, size);
	cudaMalloc((void**)&d_B, size);
	cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);

	dim3 dimGrid(1, 1, 1);
	dim3 dimBlock(M, N, 1);
	
	Replace_Matrix_Elements<<<dimGrid, dimBlock>>>(d_A, d_B);

	cudaMemcpy(B, d_B, size, cudaMemcpyDeviceToHost);

	printf("RESULTS:\n");
	printf("Resultant Matrix:\n");
	for(int i=0; i<(M*N); i++)
	{
		if(i % N == 0)
			printf("\n");
		printf("%d ", B[i]);
	}
	printf("\n");

	cudaFree(d_A);
	cudaFree(d_B);
	free(A);
	free(B);

	return 0;
}