#include<stdio.h>
#include<stdlib.h>
#include<CL/cl.h>

#define MAX_SOURCE_SIZE (0x100000)

int main()
{
	int LIST_SIZE;

	printf("Enter the number of elements: ");
	scanf("%d", &LIST_SIZE);

	int *A = (int*)malloc(LIST_SIZE * sizeof(int));
	int *B = (int*)malloc(LIST_SIZE * sizeof(int));

	printf("Enter the binary numbers: ");
	for(int i=0; i<LIST_SIZE; i++)
		scanf("%d", &A[i]);

	FILE *fp;
	char * source_str;
	size_t source_size;

	fp = fopen("decimalCLKernel.cl", "r");

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

	// Create memory buffers for each of A and B
	cl_mem bufA = clCreateBuffer(context, CL_MEM_READ_ONLY, LIST_SIZE*sizeof(int), NULL, &status);
	cl_mem bufB = clCreateBuffer(context, CL_MEM_WRITE_ONLY, LIST_SIZE*sizeof(int), NULL, &status);

	// Copy arrays A and B to their respective buffers
	status = clEnqueueWriteBuffer(command_queue, bufA, CL_TRUE, 0, LIST_SIZE*sizeof(int), A, 0, NULL, NULL);

	// Create a program from the kernel source
	cl_program program = clCreateProgramWithSource(context, 1, (const char**)&source_str, (const size_t*)&source_size, &status);

	// Build the program
	status = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);

	// Create the OpenCL kernel object
	cl_kernel kernel = clCreateKernel(program, "bin_to_dec", &status);

	// Set the arguments of the kernel
	status = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void*)&bufA);
	status = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void*)&bufB);

	// Execute the OpenCL kernel on the array
	size_t global_item_size = LIST_SIZE;
	size_t local_item_size = 1;

	// Execute the kernel on the device
	cl_event event;
	status = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL, &global_item_size, &local_item_size, 0, NULL, NULL);

	status = clFinish(command_queue);

	// Read the memory buffer B on the device to the local variable B
	status = clEnqueueReadBuffer(command_queue, bufB, CL_TRUE, 0, LIST_SIZE*sizeof(int), B, 0, NULL, NULL);

	printf("RESULTS:\n");
	for(int i=0; i<LIST_SIZE; i++)
		printf("Decimal value of %d is %d\n", A[i], B[i]);

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