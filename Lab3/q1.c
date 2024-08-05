#include<stdio.h>
#include "mpi.h"

int Factorial(int n)
{
	if(n == 0 || n == 1)
		return 1;
	return n*Factorial(n-1);
}

int main(int argc, char *argv[])
{
	int rank, size, num, sum=0;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	int arr[size], factorials[size];

	if(rank == 0)
	{
		printf("Enter %d elements: ", size);
		for(int i=0; i<size; i++)
			scanf("%d", &arr[i]);
	}

	MPI_Scatter(arr, 1, MPI_INT, &num, 1, MPI_INT, 0, MPI_COMM_WORLD);

	int fact = Factorial(num);

	MPI_Gather(&fact, 1, MPI_INT, factorials, 1, MPI_INT, 0, MPI_COMM_WORLD);

	if(rank == 0)
	{
		for(int i=0; i<size; i++)
		{
			printf("Factorial of %d: %d\n", arr[i], factorials[i]);
			sum += factorials[i];
		}
		printf("Sum of factorials: %d\n", sum);
	}

	MPI_Finalize();

	return 0;
}