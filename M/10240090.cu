#include <bits/stdc++.h>
using namespace std;

__global__ void compute(int n, long long *a, long long *b) {
    int primes[30] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29,
                  31, 37, 41, 43, 47, 53, 59, 61, 67, 71,
                  73, 79, 83, 89, 97, 101, 103, 107, 109, 113};

    int tid = threadIdx.x + blockIdx.x*blockDim.x;
    if (tid >= n) return;
    b[tid] = 0;
    long long num = a[tid];

    for (int i = 0; i < 30; i++) {
        int p = primes[i];
        if (num % p == 0) {
            b[tid] = p;
            return;
        }
    }


    for(long long j = 115; j * j <= num; j+=2){
        if(num % j == 0) {
            b[tid] = j;
            return;
        }
    }

    b[tid] = num;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);
    int n;
    
    std::cin >> n;
    vector<long long> a(n);
    vector<long long> b(n);

    for(int i = 0; i < n; i++) {
        std::cin >> a[i];
    }

    long long *dev_a, *dev_b;
    cudaMalloc(&dev_a, n*sizeof(long long));
    cudaMalloc(&dev_b, n*sizeof(long long));
    cudaMemcpy(dev_a, a.data(), n*sizeof(long long), cudaMemcpyHostToDevice);

    compute <<<(127+n)/128, 128>>> (n, dev_a, dev_b);
    cudaDeviceSynchronize();
    cudaMemcpy(b.data(), dev_b, n*sizeof(long long), cudaMemcpyDeviceToHost);
    cudaDeviceSynchronize();
    for(int i = 0; i < n; ++i){
        cout << b[i] << '\n';
    }

   return 0;
}