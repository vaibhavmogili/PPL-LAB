#include<stdio.h>
#include<stdlib.h>
#include "mpi.h"
#define BUFFER_SIZE 100

int main(int argc, char *argv[])
{
	int rank, size, n, bsize;
	int num[100], *buf;
	MPI_Status status;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	if(rank == 0)
	{
		printf("Enter %d elements: ", size-1);
		for(int i=0; i<size-1; i++)
			scanf("%d", &num[i]);

		bsize = MPI_BSEND_OVERHEAD + size;
		buf = (int*)malloc(bsize);
		MPI_Buffer_attach(buf, bsize);

		for(int i=0; i<size-1; i++)
			MPI_Bsend(&num[i], 1, MPI_INT, i+1, i+1, MPI_COMM_WORLD);
		MPI_Buffer_detach(&buf, &size);
	}
	else
	{
		MPI_Recv(&n, 1, MPI_INT, 0, rank, MPI_COMM_WORLD, &status);
		if(rank%2==0)
			n = n * n;
		else
			n = n * n * n;
		printf("Process %d of total %d processes: %d\n", rank, size, n);
	}

	MPI_Finalize();

	return 0;
}