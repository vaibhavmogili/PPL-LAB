#include<stdio.h>
#include<stdlib.h>
#include<CL/cl.h>

#define MAX_SOURCE_SIZE (0x100000)

int main()
{
	int LIST_SIZE;

	printf("Enter the number of elements (even): ");
	scanf("%d", &LIST_SIZE);

	int *A = (int*)malloc(LIST_SIZE * sizeof(int));

	printf("Enter the numbers: ");
	for(int i=0; i<LIST_SIZE; i++)
		scanf("%d", &A[i]);

	FILE *fp;
	char * source_str;
	size_t source_size;

	fp = fopen("swappingCLKernel.cl", "r");

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
	cl_command_queue command_queue = clCreateCommandQueue(context, device_id, NULL, &status);

	// Create memory buffers for A
	cl_mem bufA = clCreateBuffer(context, CL_MEM_READ_WRITE, LIST_SIZE*sizeof(int), NULL, &status);

	// Copy arrays A to the device buffer
	status = clEnqueueWriteBuffer(command_queue, bufA, CL_TRUE, 0, LIST_SIZE*sizeof(int), A, 0, NULL, NULL);

	// Create a program from the kernel source
	cl_program program = clCreateProgramWithSource(context, 1, (const char**)&source_str, (const size_t*)&source_size, &status);

	// Build the program
	status = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);

	// Create the OpenCL kernel object
	cl_kernel kernel = clCreateKernel(program, "swapping_adjacent", &status);

	// Set the arguments of the kernel
	status = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void*)&bufA);

	// Execute the OpenCL kernel on the array
	size_t global_item_size = LIST_SIZE;
	size_t local_item_size = 1;

	// Execute the kernel on the device
	cl_event event;
	status = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL, &global_item_size, &local_item_size, 0, NULL, NULL);

	status = clFinish(command_queue);

	// Read the memory buffer B on the device to the local variable A
	status = clEnqueueReadBuffer(command_queue, bufA, CL_TRUE, 0, LIST_SIZE*sizeof(int), A, 0, NULL, NULL);

	printf("The modified array is:\n");
	for(int i=0; i<LIST_SIZE; i++)
		printf("%d ", bufA[i])
	printf("\n");

	// Clean up
	status = clFlush(command_queue);
	status = clReleaseKernel(kernel);
	status = clReleaseProgram(program);
	status = clReleaseMemObject(bufA);
	status = clReleaseCommandQueue(command_queue);
	status = clReleaseContext(context);

	free(A);
	return 0;
}