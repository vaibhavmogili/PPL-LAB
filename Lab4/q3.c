#include<stdio.h>
#include "mpi.h"

void ErrorHandler(int error_code)
{
	if(error_code != MPI_SUCCESS)
	{
		char error_string[100];
		int len_error_string, error_class;
		MPI_Error_class(error_code, &error_class);
		MPI_Error_string(error_code, error_string, &len_error_string);
		printf("Error Class: %d\nError String: %s\n", error_class, error_string);
	}	
}

int main(int argc, char *argv[])
{
	int rank, size, error_code;
	int mat[3][3], ele, count=0, ans;

	MPI_Init(&argc, &argv);
	MPI_Errhandler_set(MPI_COMM_WORLD, MPI_ERRORS_RETURN);
	error_code = MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	ErrorHandler(error_code);
	error_code = MPI_Comm_size(MPI_COMM_WORLD, &size);
	ErrorHandler(error_code);

	if(rank == 0)
	{
		printf("Enter the matrix elements: ");
		for(int i=0; i<3; i++)
			for(int j=0; j<3; j++)
				scanf("%d", &mat[i][j]);
		printf("The entered matrix:\n");
		for(int i=0; i<3; i++)
		{
			for(int j=0; j<3; j++)
				printf("%d ", mat[i][j]);
			printf("\n");
		}
		printf("Enter the element to find: ");
		scanf("%d", &ele);
	}

	MPI_Bcast(&ele, 1, MPI_INT, 0, MPI_COMM_WORLD);
	for(int i=0; i<3; i++)
		MPI_Bcast(mat[i], 3, MPI_INT, 0, MPI_COMM_WORLD);

	for(int i=0; i<3; i++)
		if(mat[rank][i] == ele)
			count++;

	MPI_Reduce(&count, &ans, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);

	if(rank == 0)
		printf("Element %d found %d times in the matrix!\n", ele, ans);

	MPI_Finalize();

	return 0;
}