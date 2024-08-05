__kernel void odd_even(__global int *A)
{
	int tid = get_global_id(0);
	int N = get_global_size(0);

	if(tid % 2 == 1 && tid + 1 < N)
	{
		if(A[tid] > A[tid+1])
		{
			int temp = A[tid];
			A[tid] = A[tid+1];
			A[tid+1] = temp;
		}
	}
}

__kernel void even_odd(__global int *A)
{
	int tid = get_global_id(0);
	int N = get_global_size(0);

	if(tid % 2 == 0 && tid + 1 < N)
	{
		if(A[tid] > A[tid+1])
		{
			int temp = A[tid];
			A[tid] = A[tid+1];
			A[tid+1] = temp;
		}
	}
}