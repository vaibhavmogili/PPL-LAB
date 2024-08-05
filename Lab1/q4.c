#include<stdio.h>
#include<string.h>
#include "mpi.h"

int main(int argc, char *argv[])
{
	int rank, size;
	char str[] = "SauRaBh";

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	if(str[rank] >= 'A' && str[rank] <= 'Z')
		str[rank] += 32;
	else
		str[rank] -= 32;

	printf("Process rank %d of total %d processes: %s\n", rank, size, str);

	MPI_Finalize();

	return 0;
}