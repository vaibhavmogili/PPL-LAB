__kernel void ones_complement(__global int * A, __global int *B)
{
	int i = get_global_id(0);
	int curr = A[i];
	int res = 0;
	int cnt = 1;
	int temp = 0;
	
	while(curr > 0)
	{
		temp = (curr % 10);
		if(temp == 0)
			res = (1 * cnt) + res;
		else
			res = (0 * cnt) + res;
		curr /= 10;
		cnt *= 10;
	}
	B[i] = res;
}
