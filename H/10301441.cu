#include <bits/stdc++.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 1024

__global__ void dev_prefixsum_block(int n, int64_t* A, int64_t* S, int64_t* B) {
    int b = blockIdx.x;
    int base = blockIdx.x*blockDim.x;
    int t = threadIdx.x;
    int tid = base + t;

    __shared__ int64_t temp[BLOCK_SIZE];
    if(tid < n) temp[t] = A[tid];
    else temp[t] = 0;
    
    __syncthreads();   

    for(int i = 1; i < BLOCK_SIZE; i <<= 1) {
        if((t + 1) % (i << 1) == 0) {
            temp[t] += temp[t - i];
        }
        __syncthreads();
    }

    if(t == BLOCK_SIZE - 1) {
        B[b] = temp[t];
        temp[t] = 0;
    }
    __syncthreads();

    for(int i = BLOCK_SIZE / 2; i > 0; i >>= 1) {   
        if((t + 1) % (i << 1) == 0) {
            int64_t tmp = temp[t];
            temp[t] += temp[t - i];
            temp[t - i] = tmp;
        }
        __syncthreads();
    }

    if(tid < n) {
        S[tid] = A[tid] + temp[t];
    }

}

__global__ void dev_prefixsum_ends(int block_num, int64_t* B) {
    int tid = threadIdx.x + blockIdx.x*blockDim.x;
    if (tid >= 1) return;

    for(int i = 1; i < block_num; i++) B[i] += B[i - 1];
}

__global__ void dev_add_prefixsum_to_block(int n, int64_t* S, int64_t* B) {
    int b = blockIdx.x;
    int tid = threadIdx.x + blockIdx.x*blockDim.x;
    if (tid >= n) return;
    if(b == 0) return;

    S[tid] += B[b - 1];
}

void prefixsum(int n, int64_t* A, int64_t* S) {

    int block_num = (n + BLOCK_SIZE - 1) / BLOCK_SIZE;  //ceil

    int64_t *B;
    cudaMalloc(&B, block_num*sizeof(int64_t));
    
    dev_prefixsum_block <<<block_num, BLOCK_SIZE>>> (n, A, S, B);
    cudaDeviceSynchronize();

    dev_prefixsum_ends <<<1, 1>>> (block_num, B);
    cudaDeviceSynchronize();

    dev_add_prefixsum_to_block <<<block_num, BLOCK_SIZE>>> (n, S, B);
    cudaDeviceSynchronize();

    cudaFree(B);
}