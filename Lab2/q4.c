#include<stdio.h>
#include "mpi.h"

int main(int argc, char *argv[])
{
	int rank, size, n;
	MPI_Status status;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	if(rank == 0)
	{
		printf("Enter a number: ");
		scanf("%d", &n);

		MPI_Ssend(&n, 1, MPI_INT, 1, 1, MPI_COMM_WORLD);
		MPI_Recv(&n, 1, MPI_INT, size-1, 1, MPI_COMM_WORLD, &status);
		printf("Process %d of total %d processes: %d\n", rank, size, n);
	}
	else
	{
		MPI_Recv(&n, 1, MPI_INT, rank-1, 1, MPI_COMM_WORLD, &status);
		printf("Process %d of total %d processes: %d\n", rank, size, n);
		n++;
		if(rank != size-1)
			MPI_Ssend(&n, 1, MPI_INT, rank+1, 1, MPI_COMM_WORLD);
		else
			MPI_Ssend(&n, 1, MPI_INT, 0, 1, MPI_COMM_WORLD);
	}

	MPI_Finalize();

	return 0;
}