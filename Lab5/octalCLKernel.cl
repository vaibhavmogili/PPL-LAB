__kernel void octal_transform(__global int * A, __global int *B)
{
	int tid = get_global_id(0);

	int octalDigits[100];
	int octalNumber = 0, i = 1;
	int quotient = A[tid];

	while(quotient != 0)
	{
		octalDigits[i++] = quotient % 8;
		quotient = quotient / 8;
	}

	for(int j=i-1; j>0; j--)
		octalNumber = octalNumber*10 + octalDigits[j];
	B[tid] = octalNumber;
}
