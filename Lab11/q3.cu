// Tiled Matrix Multiplication 2D Grid 2D Block

#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
#include<device_launch_parameters.h>

#define BLOCK_WIDTH 2
#define TILE_WIDTH 2
#define WIDTH 4

__global__ void Tiled_Matrix_Mult(int *A, int *B, int *C)
{
	__shared__ int As[TILE_WIDTH][TILE_WIDTH];
	__shared__ int Bs[TILE_WIDTH][TILE_WIDTH];

	int tx = threadIdx.x;
	int ty = threadIdx.y;
	int row = blockIdx.y * TILE_WIDTH + ty;
	int col = blockIdx.x * TILE_WIDTH + tx;
	int res = 0;

	for(int t = 0; t < WIDTH / TILE_WIDTH; t++)
	{
		As[ty][tx] = A[row * WIDTH + t * TILE_WIDTH + tx];
		Bs[ty][tx] = B[(t * TILE_WIDTH + ty) * WIDTH + col];
		__syncthreads();

		for(int k=0; k<TILE_WIDTH; k++)
			res += As[ty][k] * Bs[k][tx];

		__syncthreads();
	}
	C[row * WIDTH + col] = res;
}

int main()
{
	int *A = (int*)malloc((WIDTH * WIDTH) * sizeof(int));
	int *B = (int*)malloc((WIDTH * WIDTH) * sizeof(int));
	int *C = (int*)malloc((WIDTH * WIDTH) * sizeof(int));

	printf("Enter the elements of A: ");
	for(int i=0; i<(WIDTH * WIDTH); i++)
		scanf("%d", &A[i]);

	printf("Enter the elements of B: ");
	for(int i=0; i<(WIDTH * WIDTH); i++)
		scanf("%d", &B[i]);

	int *d_A, *d_B, *d_C;

	cudaMalloc((void**)&d_A, (WIDTH * WIDTH) * sizeof(int));
	cudaMalloc((void**)&d_B, (WIDTH * WIDTH) * sizeof(int));
	cudaMalloc((void**)&d_C, (WIDTH * WIDTH) * sizeof(int));

	cudaMemcpy(d_A, A, (WIDTH * WIDTH) * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, B, (WIDTH * WIDTH) * sizeof(int), cudaMemcpyHostToDevice);

	dim3 dimBlock(BLOCK_WIDTH, BLOCK_WIDTH, 1);
	dim3 dimGrid(ceil(WIDTH / BLOCK_WIDTH), ceil(WIDTH / BLOCK_WIDTH), 1);

	Tiled_Matrix_Mult<<<dimGrid, dimBlock>>>(d_A, d_B, d_C);

	cudaMemcpy(C, d_C, (WIDTH * WIDTH) * sizeof(int), cudaMemcpyDeviceToHost);

	printf("Output Matrix:\n");
	for(int i=0; i<(WIDTH * WIDTH); i++)
	{
		if(i % WIDTH == 0)
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