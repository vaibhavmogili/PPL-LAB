#include<stdio.h>
#include<stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void Replace_Matrix_Elements(int *A, int N)
{
	int row = threadIdx.x;

	for(int i=0; i<N; i++)
	{
		int elem = A[row * N + i];
		int temp = elem;
		for(int j=0; j<row; j++)
			elem *= temp;
		A[row * N + i] = elem;
	}
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

	printf("Enter the elements of A: ");
	for(int i=0; i<(M*N); i++)
		scanf("%d", &A[i]);

	int *d_A;

	cudaMalloc((void**)&d_A, size);
	cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);

	Replace_Matrix_Elements<<<1, M>>>(d_A, N);

	cudaMemcpy(A, d_A, size, cudaMemcpyDeviceToHost);

	printf("RESULTS:\n");
	printf("Resultant Matrix:\n");
	for(int i=0; i<(M*N); i++)
	{
		if(i % N == 0)
			printf("\n");
		printf("%d ", A[i]);
	}
	printf("\n");

	cudaFree(d_A);
	free(A);

	return 0;
}