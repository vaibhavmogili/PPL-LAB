#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<CL/cl.h>

#define MAX_SOURCE_SIZE (0x100000)

int main()
{
	int len, N;

	printf("Enter the number of elements: ");
	scanf("%d", &len);
	int *A = (int*)malloc(len * sizeof(int));
	int *B = (int*)malloc(len * sizeof(int));

	printf("Enter the elements: ");
	for(int i=0; i<len; i++)
		scanf("%d", &A[i]);

	FILE *fp;
	char * source_str;
	size_t source_size;

	fp = fopen("selectionSortCLKernel.cl", "r");

	if(!fp)
	{
		printf("Cannot open kernel file!\n");
		exit(1);
	}

	source_str = (char*)malloc(MAX_SOURCE_SIZE);
	source_size = fread(source_str, 1, MAX_SOURCE_SIZE, fp);

	fclose(fp);

	// Get platform and device information
	cl_int status;
	cl_platform_id platform_id = NULL;
	cl_device_id device_id = NULL;
	cl_uint ret_num_devices;
	cl_uint ret_num_platforms;

	status = clGetPlatformIDs(1, &platform_id, &ret_num_platforms);
	status = clGetDeviceIDs(platform_id, CL_DEVICE_TYPE_GPU, 1, &device_id, &ret_num_devices);

	// Create an OpenCL context
	cl_context context = clCreateContext(NULL, 1, &device_id, NULL, NULL, &status);

	// Create a command queue
	cl_command_queue command_queue = clCreateCommandQueue(context, device_id, 0, &status);

	// Create memory buffers for each of bufA and bufB
	cl_mem bufA = clCreateBuffer(context, CL_MEM_READ_ONLY, len*sizeof(int), NULL, &status);
	cl_mem bufB = clCreateBuffer(context, CL_MEM_WRITE_ONLY, len*sizeof(int), NULL, &status);

	// Copy arrays S to its respective buffer
	status = clEnqueueWriteBuffer(command_queue, bufA, CL_TRUE, 0, len*sizeof(int), A, 0, NULL, NULL);
	status = clEnqueueWriteBuffer(command_queue, bufB, CL_TRUE, 0, len*sizeof(int), B, 0, NULL, NULL);

	// Create a program from the kernel source
	cl_program program = clCreateProgramWithSource(context, 1, (const char**)&source_str, (const size_t*)&source_size, &status);

	// Build the program
	status = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);

	// Create the OpenCL kernel object
	cl_kernel kernel = clCreateKernel(program, "selection_sort", &status);

	// Set the arguments of the kernel
	status = clSetKernelArg(kernel, 0, sizeof(cl_mem), &bufA);
	status = clSetKernelArg(kernel, 1, sizeof(cl_mem), &bufB);

	// Execute the OpenCL kernel on the array
	size_t global_work_size = len;
	size_t local_item_size = 1;

	// Execute the kernel on the device
	cl_event event;
	status = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL, &global_work_size, &local_item_size, 0, NULL, NULL);

	status = clFinish(command_queue);

	// Read the memory buffer B on the device to the local variable bufB
	status = clEnqueueReadBuffer(command_queue, bufB, CL_TRUE, 0, len*sizeof(int), B, 0, NULL, NULL);

	printf("RESULTS:\n");
	printf("Sorted Array: ");
	for(int i=0; i<len; i++)
		printf("%d ", B[i]);
	printf("\n");

	// Clean up
	status = clFlush(command_queue);
	status = clReleaseKernel(kernel);
	status = clReleaseProgram(program);
	status = clReleaseMemObject(bufA);
	status = clReleaseMemObject(bufB);
	status = clReleaseCommandQueue(command_queue);
	status = clReleaseContext(context);

	free(A);
	free(B);
	return 0;
}