#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "mpi.h"

int main(int argc, char *argv[])
{
	int rank, size, len, chunk;
	char str1[30], str2[30];

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	char res[2*size];

	if(rank == 0)
	{
		printf("Enter a string: ");
		scanf("%s", str1);
		printf("Enter another string: ");
		scanf("%s", str2);
		len = strlen(str1);
	}

	MPI_Bcast(&len, 1, MPI_INT, 0, MPI_COMM_WORLD);
	char buf[2];
	MPI_Scatter(str1, 1, MPI_CHAR, &buf[0], 1, MPI_CHAR, 0, MPI_COMM_WORLD);
	MPI_Scatter(str2, 1, MPI_CHAR, &buf[1], 1, MPI_CHAR, 0, MPI_COMM_WORLD);
	MPI_Gather(buf, 2, MPI_CHAR, res, 2, MPI_CHAR, 0, MPI_COMM_WORLD);
	res[2*size] = '\0';

	if(rank == 0)
		printf("The final string is %s\n", res);

	MPI_Finalize();

	return 0;
}