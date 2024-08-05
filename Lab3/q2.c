#include<stdio.h>
#include "mpi.h"

float Average(int arr[], int len)
{
	float sum = 0;
	for(int i=0; i<len; i++)
		sum += arr[i];
	float avg = sum / len;
	return avg;
}

int main(int argc, char *argv[])
{
	int rank, size, M, buf[10];
	float psum = 0;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	int arr[size];
	float averages[size];

	if(rank == 0)
	{
		printf("Enter the value of M: ");
		scanf("%d", &M);
		int len = size * M;

		printf("Enter %d elements: ", len);
		for(int i=0; i<len; i++)
			scanf("%d", &arr[i]);
	}

	MPI_Bcast(&M, 1, MPI_INT, 0,  MPI_COMM_WORLD);
	MPI_Scatter(arr, M, MPI_INT, buf, M, MPI_INT, 0, MPI_COMM_WORLD);

	float avg = Average(buf, M);

	MPI_Gather(&avg, 1, MPI_INT, averages, 1, MPI_INT, 0, MPI_COMM_WORLD);

	if(rank == 0)
	{
		printf("Individual Averages:\n");
		for(int i=0; i<size; i++)
		{
			printf("Process %d: %.2f\n", i, averages[i]);
			psum += averages[i];
		}
		printf("Final Average: %.2f\n", psum/size);
		
	}

	MPI_Finalize();

	return 0;
}