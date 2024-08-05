#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "mpi.h"

int CountNonVowels(char str[], int len)
{
	int count=0;
	for(int i=0; i<len; i++)
		if(str[i] == 'a' || str[i] == 'A' || str[i] == 'e' || str[i] == 'E' || str[i] == 'i' || str[i] == 'I' || str[i] == 'o' || str[i] == 'O' || str[i] == 'u' || str[i] == 'U')
			count++;			
	return len-count;
}

int main(int argc, char *argv[])
{
	int rank, size, len, chunk;
	char str[30], buf[30];

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	int nonvowelcounts[size];

	if(rank == 0)
	{
		printf("Enter a string: ");
		scanf("%s", str);

		len = strlen(str);

		if(len % size != 0)
		{
			printf("String length not divisible by %d!\n", size);
			exit(0);
		}
	}

	MPI_Bcast(&len, 1, MPI_INT, 0, MPI_COMM_WORLD);
	chunk = (len / size);
	MPI_Scatter(str, chunk, MPI_CHAR, buf, chunk, MPI_CHAR, 0, MPI_COMM_WORLD);

	int nonvowels = CountNonVowels(buf, chunk);

	MPI_Gather(&nonvowels, 1, MPI_INT, nonvowelcounts, 1, MPI_INT, 0, MPI_COMM_WORLD);

	if(rank == 0)
	{
		int psum=0;
		printf("Count of Non-Vowels:\n");
		for(int i=0; i<size; i++)
		{
			printf("Process %d: %d\n", i, nonvowelcounts[i]);
			psum += nonvowelcounts[i];
		}
		printf("Total Number of Non-Vowels: %d\n", psum);
	}

	MPI_Finalize();

	return 0;
}