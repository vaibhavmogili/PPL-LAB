#include<stdio.h>
#include<stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void Generate_STR(char *A, int *B, int *idx, char *res)
{
	int rowid = threadIdx.x;
	int colid = threadIdx.y;
	int N = blockDim.y;

	char ch = A[rowid * N + colid];
	int n = B[rowid * N + colid];
	int start = idx[rowid * N + colid];

	for(int i=0; i<n; i++)
		res[start+i] = ch;
}

int main()
{
	int M, N;

	printf("Enter the number of rows: ");
	scanf("%d", &M);
	printf("Enter the number of columns: ");
	scanf("%d", &N);

	char *A = (char*)malloc(M * N * sizeof(char));
	int *B = (int*)malloc(M * N * sizeof(int));

	printf("Enter the characters of A: ");
	for(int i=0; i<(M*N); i++)
		scanf(" %c", &A[i]);

	printf("Enter the numbers of B: ");
	for(int i=0; i<(M*N); i++)
		scanf("%d", &B[i]);

	int size = 0;
	for(int i=0; i<(M*N); i++)
		size += B[i];
	char *res = (char*)malloc(size * sizeof(char));

	int *idx = (int*)malloc(M * N * sizeof(int));
	idx[0] = 0;

	for(int i=1; i<(M*N); i++)
		idx[i] = idx[i-1] + B[i-1];

	char *d_A;
	int *d_B, *d_idx;
	char *d_res;

	cudaMalloc((void**)&d_A, M * N * sizeof(char));
	cudaMalloc((void**)&d_B, M * N * sizeof(int));	
	cudaMalloc((void**)&d_idx, M * N * sizeof(int));
	cudaMalloc((void**)&d_res, size * sizeof(char));

	cudaMemcpy(d_A, A, M * N * sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, B, M * N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_idx, idx, M * N * sizeof(int), cudaMemcpyHostToDevice);

	dim3 dimGrid(1, 1, 1);
	dim3 dimBlock(M, N, 1);

	Generate_STR<<<dimGrid, dimBlock>>>(d_A, d_B, d_idx, d_res);

	cudaMemcpy(res, d_res, size * sizeof(char), cudaMemcpyDeviceToHost);

	printf("RESULTS:\n");
	printf("STR : ");
	for(int i=0; i<size; i++)
		printf("%c", res[i]);
	printf("\n");

	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_idx);
	cudaFree(d_res);
	free(A);
	free(B);
	free(idx);
	free(res);

	return 0;
}