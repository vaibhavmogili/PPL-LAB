__kernel void bin_to_dec(__global int *A, __global int *B)
{
	int tid = get_global_id(0);
	int n = A[tid];
	int pow = 1;
	int temp, sum = 0;

	while(n != 0)
	{
		temp = n % 10;
		n /= 10;
		sum += temp * pow;
		pow *= 2;
	}
	B[tid] = sum;
}