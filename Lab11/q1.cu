// Matrix Multiplication 2D Grid 2D Block

#include<stdio.h>
#include<stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void Matrix_Mult(int *A, int *B, int *C, int ra, int ca, int cb)
{
	int r = blockIdx.x * blockDim.x + threadIdx.x;
	int c = blockIdx.y * blockDim.y + threadIdx.y;

	if(r < ra && c < cb)
	{
		int sum = 0;
		for(int k=0; k<ca; k++)	
			sum += A[r * ca + k] * B[k * cb + c];
		C[r * cb + c] = sum;
	}
}

int main()
{
	int ra, ca, rb, cb;

	printf("Enter the dimensions of matrix A: ");
	scanf("%d %d", &ra, &ca);
	printf("Enter the dimensions of matrix B: ");
	scanf("%d %d", &rb, &cb);

	int *A = (int*)malloc((ra * ca) * sizeof(int));
	int *B = (int*)malloc((rb * cb) * sizeof(int));
	int *C = (int*)malloc((ra * cb) * sizeof(int));

	printf("Enter the elements of matrix A: ");
	for(int i=0; i<(ra * ca); i++)
		scanf("%d", &A[i]);

	printf("Enter the elements of matrix B: ");
	for(int i=0; i<(rb * cb); i++)
		scanf("%d", &B[i]);

	int *d_A, *d_B, *d_C;

	cudaMalloc((void**)&d_A, (ra * ca) * sizeof(int));
	cudaMalloc((void**)&d_B, (rb * cb) * sizeof(int));
	cudaMalloc((void**)&d_C, (ra * cb) * sizeof(int));

	cudaMemcpy(d_A, A, (ra * ca) * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, B, (rb * cb) * sizeof(int), cudaMemcpyHostToDevice);

	dim3 dimGrid(ceil(ra / 3.0), ceil(cb / 3.0), 1);
	dim3 dimBlock(3, 3, 1);
	Matrix_Mult<<<dimGrid, dimBlock>>>(d_A, d_B, d_C, ra, ca, cb);

	cudaMemcpy(C, d_C, (ra * cb) * sizeof(int), cudaMemcpyDeviceToHost);

	printf("RESULTS:\n");
	printf("Output Matrix:\n");
	for(int i=0; i<(ra * cb); i++)
	{
		if(i % cb == 0)
			printf("\n");
		printf("%d ", C[i]);
	}

	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
	free(A);
	free(B);
	free(C);

	return 0;
}