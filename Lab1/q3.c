#include<stdio.h>
#include "mpi.h"

int main(int argc, char *argv[])
{
	int rank, size;
	int n1 = 6, n2 = 3;
	float ans;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	switch(rank)
	{
		case 0:
			ans = n1 + n2;
			printf("Process rank %d of total %d processes: %d+%d=%.2f\n", rank, size, n1, n2, ans);
			break;
		case 1:
			ans = n1 - n2;
			printf("Process rank %d of total %d processes: %d-%d=%.2f\n", rank, size, n1, n2, ans);
			break;
		case 2:
			ans = n1 * n2;
			printf("Process rank %d of total %d processes: %d*%d=%.2f\n", rank, size, n1, n2, ans);
			break;
		case 3:
			ans = n1 / n2;
			printf("Process rank %d of total %d processes: %d/%d=%.2f\n", rank, size, n1, n2, ans);
			break;
	}

	MPI_Finalize();

	return 0;
}