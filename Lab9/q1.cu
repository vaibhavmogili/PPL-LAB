#include<stdio.h>
#include<stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void matrix_add_rowwise(int *M1, int *M2, int *res, int c)
{
	int tid = blockIdx.x * blockDim.x + threadIdx.x;

	for(int i=0; i<c; i++)
		res[tid * c + i] = M1[tid * c + i] + M2[tid * c + i];
}

__global__ void matrix_add_colwise(int *M1, int *M2, int *res, int r)
{
	int tid = threadIdx.x;
	int c = blockDim.x;
	for(int i=0; i<r; i++)
		res[i * c + tid] = M1[i * c + tid] + M2[i * c + tid];
}

__global__ void matrix_add_elementwise(int *M1, int *M2, int *res)
{
	int tid = threadIdx.x;
	res[tid] = M1[tid] + M2[tid];
}

int main()
{
	int r, c;
	int size;

	printf("Enter the number of rows: ");
	scanf("%d", &r);
	printf("Enter the number of columns: ");
	scanf("%d", &c);
	size = r * c * sizeof(int);

	int *M1 = (int*)malloc(size);
	int *M2 = (int*)malloc(size);
	int *res = (int*)malloc(size);

	printf("Enter the elements of M1: ");
	for(int i=0; i<(r*c); i++)
		scanf("%d", &M1[i]);

	printf("Enter the elements of M2: ");
	for(int i=0; i<(r*c); i++)
		scanf("%d", &M2[i]);

	int *d_M1, *d_M2, *d_res;

	cudaMalloc((void**)&d_M1, size);
	cudaMalloc((void**)&d_M2, size);
	cudaMalloc((void**)&d_res, size);

	cudaMemcpy(d_M1, M1, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_M2, M2, size, cudaMemcpyHostToDevice);

	matrix_add_rowwise<<<1, r>>>(d_M1, d_M2, d_res, c);
	// matrix_add_colwise<<<1, c>>>(d_M1, d_M2, d_res, r);
	// matrix_add_elementwise<<<1, r*c>>>(d_M1, d_M2, d_res);

	cudaMemcpy(res, d_res, size, cudaMemcpyDeviceToHost);

	printf("RESULTS:\n");
	printf("Resultant Matrix:\n");
	for(int i=0; i<(r*c); i++)
	{	
		if(i % c == 0)
			printf("\n");
		printf("%d ", res[i]);
	}

	cudaFree(d_M1);
	cudaFree(d_M2);
	cudaFree(d_res);
	free(M1);
	free(M2);
	free(res);

	return 0;
}