#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<CL/cl.h>

#define MAX_SOURCE_SIZE (0x100000)

int main()
{
	int len, N;

	printf("Enter the length of the string: ");
	scanf("%d", &len);
	char *S = (char*)malloc(len * sizeof(char));

	printf("Enter the string: ");
	scanf("%s", S);

	printf("Enter the value of N: ");
	scanf("%d", &N);
	int size = N * len * sizeof(char);
	char *res = (char*)malloc(size * sizeof(char));

	FILE *fp;
	char * source_str;
	size_t source_size;

	fp = fopen("copyStringCLKernel.cl", "r");

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

	// Create memory buffers for each of S and bufres
	cl_mem bufS = clCreateBuffer(context, CL_MEM_READ_ONLY, len*sizeof(char), NULL, &status);
	cl_mem bufres = clCreateBuffer(context, CL_MEM_WRITE_ONLY, size, NULL, &status);

	// Copy arrays S to its respective buffer
	status = clEnqueueWriteBuffer(command_queue, bufS, CL_TRUE, 0, len*sizeof(char), S, 0, NULL, NULL);

	// Create a program from the kernel source
	cl_program program = clCreateProgramWithSource(context, 1, (const char**)&source_str, (const size_t*)&source_size, &status);

	// Build the program
	status = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);

	// Create the OpenCL kernel object
	cl_kernel kernel = clCreateKernel(program, "copy_string", &status);

	// Set the arguments of the kernel
	status = clSetKernelArg(kernel, 0, sizeof(cl_mem), &bufS);
	status = clSetKernelArg(kernel, 1, sizeof(cl_mem), &bufres);
	status = clSetKernelArg(kernel, 2, sizeof(int), &len);

	// Execute the OpenCL kernel on the array
	size_t global_work_size = N;
	size_t local_item_size = 1;

	// Execute the kernel on the device
	cl_event event;
	status = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL, &global_work_size, &local_item_size, 0, NULL, NULL);

	status = clFinish(command_queue);

	// Read the memory buffer bufres on the device to the local variable res
	status = clEnqueueReadBuffer(command_queue, bufres, CL_TRUE, 0, size, res, 0, NULL, NULL);

	printf("RESULTS:\n");
	printf("Resultant String: %s\n", res);

	// Clean up
	status = clFlush(command_queue);
	status = clReleaseKernel(kernel);
	status = clReleaseProgram(program);
	status = clReleaseMemObject(bufS);
	status = clReleaseMemObject(bufres);
	status = clReleaseCommandQueue(command_queue);
	status = clReleaseContext(context);

	free(S);
	free(res);
	return 0;
}