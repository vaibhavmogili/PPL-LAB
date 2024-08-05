__kernel void copy_string(__global char *S, __global char *res, int len)
{
	int tid = get_global_id(0);

	for(int i=0; i<len; i++)
		res[tid * len + i] = S[i];
}