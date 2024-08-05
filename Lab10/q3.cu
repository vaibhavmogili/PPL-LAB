#include<stdio.h>
#include<stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void Replace_Matrix_Elements(int *A, int *B)
{
	int rowid = threadIdx.x;
	int colid = threadIdx.y;
	int rows = blockDim.x;
	int cols = blockDim.y;
	int binary = 0, base = 1;
	int res = 0, cnt = 1;
	int temp, elem = A[rowid * cols + colid];;

	if(rowid == 0 || colid == 0 || rowid == (cols-1) || colid == (rows-1))
		res = elem;
	else
	{
		while(elem > 0)
		{
			binary += (elem % 2) * base;
			elem /= 2;
			base *= 10;
		}

		while(binary > 0)
		{
			temp = binary % 10;
			if(temp == 0)
				res = (1 * cnt) + res;
			else
				res = (0 * cnt) + res;
			binary /= 10;
			cnt *= 10;
		}
	}
	B[rowid * cols + colid] = res;
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