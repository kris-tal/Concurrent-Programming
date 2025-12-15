#include <bits/stdc++.h>
#include <cuda_runtime.h>
#include <thrust/scan.h>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

__global__ void dev_layer(int k, int n, int *a, int *P0) {
    int tid = threadIdx.x + blockIdx.x*blockDim.x;
    if (tid >= n) return;
    P0[tid] = (1 - ((a[tid] >> k) & 1));
}

__global__ void dev_insert(int k, int n, int *a, int *b, int *P0, int zero_sum) {
    int tid = threadIdx.x + blockIdx.x*blockDim.x;
    if (tid >= n) return;

    if((a[tid] >> k) & 1) {
        b[tid - P0[tid] + zero_sum] = a[tid];
    }
    else {
        b[P0[tid]] = a[tid];
    }
}

void gpusort(int n, int* a) {
    int *dev_a = a;
    int *dev_P0, *dev_b;

    cudaMalloc(&dev_P0, n*sizeof(int));
    cudaMalloc(&dev_b, n*sizeof(int));

    thrust::device_ptr<int> tp0(dev_P0);

    for(int k = 0; k <= 30; k++) {
        //count
        dev_layer <<<(127+n)/128, 128>>> (k, n, dev_a, dev_P0);
        cudaDeviceSynchronize();

        //licze sumy prefix
        thrust::exclusive_scan(tp0, tp0 + n, tp0);

        int last_P0, last_bit;
        cudaMemcpy(&last_P0, dev_P0 + (n - 1), sizeof(int), cudaMemcpyDeviceToHost);
        cudaMemcpy(&last_bit, dev_a + (n - 1), sizeof(int), cudaMemcpyDeviceToHost);
        last_bit = (last_bit >> k) & 1;
        int zero_sum = last_P0 + (last_bit == 0 ? 1 : 0);

        //wstawiam
        dev_insert <<<(127+n)/128, 128>>> (k, n, dev_a, dev_b, dev_P0, zero_sum);
        cudaDeviceSynchronize();

        std::swap(dev_a, dev_b);
    }
    
    //na wszelki wypadek jak nieparzyste iter
    if (dev_a != a) {
        cudaMemcpy(a, dev_a, n * sizeof(int), cudaMemcpyDeviceToDevice);
    }

    
}