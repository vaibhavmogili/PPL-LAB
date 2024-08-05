__kernel void swapping_adjacent(__global int *A)
{
	int tid = get_global_id(0);
	int temp;

	if(tid % 2 == 0)
	{
	 	temp = A[tid];
		A[tid] = A[tid+1];
		A[tid+1] = temp;
	}
}