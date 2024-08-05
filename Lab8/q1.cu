#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void Count_Word_Occurrences(char *str, char *word, int str_len, int word_len, int count)
{
	int tid = threadIdx.x;

	while(tid < str_len)
	{
		int i = 0;
		while(i < word_len && str[tid+i] == word[i])
			i++;

		if(i == word_len)
		{
			atomicAdd(count, 1);
			tid += word_len;
		}
		else
			tid++;
	}
}

int main()
{
	char str[100], word[100];
	int str_len, word_len;

	printf("Enter a string: ");
	gets(str);
	str_len = strlen(str);

	printf("Enter a word: ");
	scanf("%s", word);
	word_len = strlen(word);

	char *d_str, *d_word;
	int *d_count, count;

	cudaMalloc((void**)&d_str, str_len*sizeof(char));
	cudaMalloc((void**)&d_word, word_len*sizeof(char));
	cudaMalloc((void**)&d_count, sizeof(int));

	cudaMemcpy(d_str, str, str_len*sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_word, word, word_len*sizeof(char), cudaMemcpyHostToDevice);
	cudaMemset(d_count, 0, sizeof(int));

	Count_Word_Occurrences<<<1, 1>>>(d_str, d_word, str_len, word_len, d_count);

	cudaMemcpy(count, d_count, sizeof(int), cudaMemcpyDeviceToHost);

	printf("Number of Occurrences: %d\n", count);

	cudaFree(d_str);
	cudaFree(d_word);
	cudaFree(d_count);

	return 0;
}