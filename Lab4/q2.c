#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<mpi.h>

int main(int argc, char* argv[])
{
	int rank, size;
	float ans;

	MPI_Init(&argc,&argv);

	MPI_Comm_size(MPI_COMM_WORLD, &size);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);


	float val = 1 + ((rank + 0.5)/(size - 1)) * ((rank + 0.5)/(size - 1));
	float final = 4 / (val * (size - 1));

	MPI_Reduce(&final,&ans,1,MPI_FLOAT,MPI_SUM,0,MPI_COMM_WORLD);
	
	if(rank == 0)
		printf("The value of pi is : %.5f\n",ans);

	MPI_Finalize();
}