__kernel void selection_sort(__global int *A, __global int *B)
{
	int tid = get_global_id(0);
	int N = get_global_size(0);
	int data = A[tid];
	int pos = 0;

	for(int i=0; i<N; i++)
		if(A[i] < data || (A[i] == data && i < tid))
			pos++;
	B[pos] = data;
}