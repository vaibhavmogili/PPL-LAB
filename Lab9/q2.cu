#include<stdio.h>
#include<stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__void matrix_mult_rowwise(int *A, int *B, int *res, int wa, int wb)
{
	int rowidA = threadIdx.x;

	int sum;

	for(int colidB = 0; colidB < wb; colidB++)
	{
		sum = 0;
		for(int k=0; k<wa; k++)
			sum += A[rowidA * wa + k] * B[k * wb + colidB];
		res[rowidA * wb + colidB] = sum;
	}
}

__global__ void matrix_mult_colwise(int *A, int *B, int *res, int wa, int ha)
{
	int colidB = threadIdx.x;
	int sum;
	int wb = blockDim.x;

	for(int rowidA = 0; rowidA < ha; rowidA++)
	{
		sum = 0;
		for(int k=0; k<wa; k++)
			sum += A[rowidA * wa + k] * B[k * wb + colidB];
		res[rowidA * wb + colidB] = sum;
	}
}

__global__ void matrix_mult_elementwise(int *A, int *B, int *res, int wa)
{
	int rowidA = threadIdx.x;
	int colidB = threadIdx.y;
	int sum = 0;
	int wb = blockDim.y;

	for(int k=0; k<wa; k++)
		sum += A[rowidA * wa + k] * B[k * wb + colidB];
	res[rowidA * wb + colidB] = sum;
}

int main()
{
	int r1, c1, r2, c2;

	printf("Enter the dimensions of M1: ");
	scanf("%d %d", &r1, &c1);
	printf("Enter the dimensions of M2: ");
	scanf("%d &d", &r2, &c2);

	if(c1 != r2)
	{
		printf("Invalid Dimensions!\n");
		exit(1);
	}

	int sizeM1 = r1 * c1 * sizeof(int);
	int sizeM2 = r2 * c2 * sizeof(int);
	int sizeRes = r1 * c2 * sizeof(int);

	int *M1 = (int*)malloc(sizeM1);
	int *M2 = (int*)malloc(sizeM2);
	int *res = (int*)malloc(sizeRes);

	printf("Enter the elements of M1: ");
	for(int i=0; i<(r1 * c1); i++)
		scanf("%d", M1[i]);

	printf("Enter the elements of M2: ");
	for(int i=0; i<(r2 * c2); i++)
		scanf("%d", M2[i]);

	int *d_M1, *d_M2, *d_res;

	cudaMalloc((void**)&d_M1, sizeM1);
	cudaMalloc((void**)&d_M2, sizeM2);
	cudaMalloc((void**)&d_res, sizeRes);

	cudaMemcpy(d_M1, M1, sizeM1, cudaMemcpyHostToDevice);
	cudaMemcpy(d_M2, M2, sizeM2, cudaMemcpyHostToDevice);

	matrix_mult_rowwise<<<1, r1>>>(d_M1, d_M2, d_res, c1, c2);
	// matrix_mult_colwise<<<1, c2>>>(d_M1, d_M2, d_res, c1, r1);
	// matrix_mult_elementwise<<<1, (r1, c2)>>>(d_M1, d_M2, d_res, c1);

	cudaMemcpy(res, d_res, sizeRes, cudaMemcpyDeviceToHost);

	printf("RESULTS:\n");
	printf("Resultant Matrix:\n");
	for(int i=0; i<(r1*c2); i++)
	{
		if(i % c2 == 0)
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