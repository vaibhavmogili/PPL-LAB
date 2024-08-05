#include<stdio.h>
#include<stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void replace_matrix_elements(int *A, int *res, int N)
{
	int i = threadIdx.x;
	int j = threadIdx.y;
	int num = A[i * N + j];
	int ans;

	if(i == j)
		ans = 0;
	else if(i < j)
	{
		ans = 0;
		int dig;

		while(num > 0)
		{
			dig = num % 10;
			num /= 10;
			ans += dig;
		}
	}
	else
	{
		ans = 1;
		for(int i=1; i<=num; i++)
			ans *= i;
	}
	res[i * N + j] = ans;
}

int main()
{
	int N;
	int size;

	printf("Enter the value of N: ");
	scanf("%d", &N);
	size = N * N * sizeof(int);

	int *A = (int*)malloc(size);
	int *res = (int*)malloc(size);

	printf("Enter the matrix elements: ");
	for(int i=0; i<(N * N); i++)
		scanf("%d", &A[i]);

	int *d_A, *d_res;

	cudaMalloc((void**)&d_A, size);
	cudaMalloc((void**)&d_res, size);

	cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);

	replace_matrix_elements<<<1, (N, N)>>>(d_A, d_res, N);

	cudaMemcpy(res, d_res, size, cudaMemcpyDeviceToHost);

	printf("RESULTS:\n");
	printf("Resultant Matrix:\n");
	for(int i=0; i<(N*N); i++)
	{
		if(i % N == 0)
			printf("\n");
		printf("%d ", res[i]);
	}

	cudaFree(d_A);
	cudaFree(d_res);
	free(A);
	free(res);

	return 0;
}