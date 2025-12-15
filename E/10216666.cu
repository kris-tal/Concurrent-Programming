#include <bits/stdc++.h>
#include <cuda_runtime.h>

typedef long long ll;

__global__ void check(const ll *A, int n, int *ans) {
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    if (tid >= n) return;

    ll target = -A[tid];
    int p = 0;
    int q = n - 1;

    while (p < q) {
        ll sum = A[p] + A[q];
        if (sum == target) {
            atomicExch(ans, true);
            return;
        }
        else if (sum < target) p++;
        else q--;
    }
}


int main() {
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(nullptr);
    int q;
    std::cin >> q;

    while(q--) {
        int n;
        std::cin >> n;

        std::vector<ll> A(n);

        for(int i = 0; i < n; i++) {
            std::cin >> A[i];
        }

        std::sort(A.begin(), A.end());

        ll *dev_A;
        cudaMalloc(&dev_A, n * sizeof(ll));
        cudaMemcpy(dev_A, A.data(), n * sizeof(ll), cudaMemcpyHostToDevice);

        int ans = false;
        int *dev_ans;
        cudaMalloc(&dev_ans, sizeof(int));
        cudaMemcpy(dev_ans, &ans, sizeof(int), cudaMemcpyHostToDevice);


        check<<<(127 + n) / 128, 128>>>(dev_A, n, dev_ans);
        cudaDeviceSynchronize();

        cudaMemcpy(&ans, dev_ans, sizeof(int), cudaMemcpyDeviceToHost);


        if(ans) std::cout << "YES\n";
        else std::cout << "NO\n";

        cudaFree(dev_A);
        cudaFree(dev_ans);
    }

    return 0;
}