#include<stdio.h>
#include<stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void SpVM_CSR(int no_rows, int *data, int *col_idx, int *row_ptr, int *X, int *Y)
{
	int row = threadIdx.x;

	if(row < no_rows)
	{
		int dot = 0;
		int row_start = row_ptr[row];
		int row_end = row_ptr[row+1];
		for(int i=row_start; i<row_end; i++)
			dot += data[i] * X[col_idx[i]];
		Y[row] += dot;
	}
}

int main()
{
	int r, c;

	printf("Enter the number of rows: ");
	scanf("%d", &r);
	printf("Enter the number of columns: ");
	scanf("%d", &c);

	int **A = (int**)malloc(r * sizeof(int*));
	for(int i=0; i<r; i++)
		A[i] = (int*)malloc(c * sizeof(int));

	printf("Enter the matrix elements:\n");
	for(int i=0; i<r; i++)
		for(int j=0; j<c; j++)
			scanf("%d", &A[i][j]);

	int *X = (int*)malloc(c * sizeof(int));
	int *Y = (int*)malloc(r * sizeof(int));

	printf("Enter the elements of vector X: ");
	for(int i=0; i<c; i++)
		scanf("%d", &X[i]);

	int data[20], col_idx[20], row_ptr[20];
	int count = 0, temp;
	row_ptr[0] = 0;
	int i;

	for(i=0; i<r; i++)
	{
		temp = 0;
		for(int j=0; j<c; j++)
		{
			if(A[i][j] != 0)
			{
				temp++;
				data[count] = A[i][j];
				col_idx[count] = j;
				count++;
			}
		}
		row_ptr[i+1] = row_ptr[i] + temp;
	}

	int *d_data, *d_row_ptr, *d_col_idx, *d_X, *d_Y;

	cudaMalloc((void**)&d_data, count * sizeof(int));
	cudaMalloc((void**)&d_col_idx, count * sizeof(int));
	cudaMalloc((void**)&d_row_ptr, (r + 1) * sizeof(int));
	cudaMalloc((void**)&d_X, c * sizeof(int));
	cudaMalloc((void**)&d_Y, r * sizeof(int));

	cudaMemcpy(d_data, data, count * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_col_idx, col_idx, count * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_row_ptr, row_ptr, (r + 1) * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_X, X, c * sizeof(int), cudaMemcpyHostToDevice);

	SpVM_CSR<<<1, r>>>(r, d_data, d_col_idx, d_row_ptr, d_X, d_Y);

	cudaMemcpy(Y, d_Y, r * sizeof(int), cudaMemcpyDeviceToHost);

	printf("RESULTS:\n");
	printf("Y : ");
	for(int j=0; j<r; j++)
		printf("%d ", Y[j]);
	printf("\n");

	cudaFree(d_data);
	cudaFree(d_col_idx);
	cudaFree(d_row_ptr);
	cudaFree(d_X);
	cudaFree(d_Y);
	free(A);

	return 0;
}