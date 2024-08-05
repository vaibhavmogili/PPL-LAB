#include<stdio.h>
#include<string.h>
#include "mpi.h"

int main(int argc, char *argv[])
{
	int rank, len;
	char word[100];
	MPI_Status status;

	MPI_Init(&argc, &argv);

	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	if(rank == 0)
	{
		printf("Enter a word: ");
		scanf("%s", word);
		len = strlen(word);

		MPI_Ssend(&len, 1, MPI_INT, 1, 1, MPI_COMM_WORLD);
		MPI_Ssend(word, len, MPI_CHAR, 1, 2, MPI_COMM_WORLD);
		MPI_Recv(word, len, MPI_CHAR, 1, 3, MPI_COMM_WORLD, &status);
		printf("Received: %s\n", word);
	}
	else
	{
		MPI_Recv(&len, 1, MPI_INT, 0, 1, MPI_COMM_WORLD, &status);
		MPI_Recv(word, len, MPI_CHAR, 0, 2, MPI_COMM_WORLD, &status);
		for(int i=0; i<len; i++)
		{
			if(word[i]>='A' && word[i]<='Z')
				word[i] += 32;
			else
				word[i] -= 32;
		}
		MPI_Ssend(word, len, MPI_CHAR, 0, 3, MPI_COMM_WORLD);
	}

	MPI_Finalize();

	return 0;
}