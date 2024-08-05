#include<stdio.h>
#include "mpi.h"

int isPrime(int n)
{
	if(n == 0 || n == 1)
		return 0;
	for(int i=2; i<=n/2; i++)
		if(n % i == 0)
			return 0;
	return 1;
}

int main(int argc, char *argv[])
{
	int rank, size;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	if(rank == 0)
	{
		printf("Process rank %d of total %d processes: ", rank, size);
		for(int i=0; i<=50; i++)
			if(isPrime(i))
				printf("%d ", i);
		printf("\n");
	}
	else
	{
		printf("Process rank %d of total %d processes: ", rank, size);
		for(int i=51; i<=100; i++)
			if(isPrime(i))
				printf("%d ", i);
		printf("\n");
	}

	MPI_Finalize();

	return 0;
}