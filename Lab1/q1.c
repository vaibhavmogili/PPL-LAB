#include<stdio.h>
#include<math.h>
#include "mpi.h"

int main(int argc, char *argv[])
{
	int rank, size, x=2;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	printf("Process rank %d of total %d processes: %d^%d=%.2f\n", rank, size, x, rank, pow(x, rank));

	MPI_Finalize();

	return 0;
}