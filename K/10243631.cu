#include <bits/stdc++.h>
#include <cuda_runtime.h>
#include "moderngpu/transform.hxx"
#include "moderngpu/context.hxx"
#include "moderngpu/memory.hxx"

int main() {
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(nullptr);

    int q;
    std::cin >> q;

    while(q--) {
        std::string s_A;
        std::string s_B;

        std::cin >> s_A >> s_B;

        int n_A = s_A.length() + 1;
        int n_B = s_B.length() + 1;

        if(n_A < n_B) {
            std::swap(s_A, s_B);
            std::swap(n_A, n_B);
        }

        std::vector<char> A;
        A.reserve(n_A);
        A.push_back('#');
        A.insert(A.end(), s_A.begin(), s_A.end());

        std::vector<char> B;
        B.reserve(n_B);
        B.push_back('!');
        B.insert(B.end(), s_B.begin(), s_B.end());
    
        mgpu::standard_context_t context(false);

        mgpu::mem_t<char> mdev_A = mgpu::to_mem(A, context);
        mgpu::mem_t<char> mdev_B = mgpu::to_mem(B, context);
        char *dev_A = mdev_A.data();
        char *dev_B = mdev_B.data();

        std::vector<int> ans(n_B, 0);      

        mgpu::mem_t<int> mdev_pprev_dp = mgpu::to_mem(ans, context);
        mgpu::mem_t<int> mdev_prev_dp = mgpu::to_mem(ans, context);
        mgpu::mem_t<int> mdev_dp(n_B, context);
        int *dev_pprev_dp = mdev_pprev_dp.data();
        int *dev_prev_dp = mdev_prev_dp.data();
        int *dev_dp = mdev_dp.data();
        
        int diag_size = 2;
        int offset = n_B - 2;
        int end_offset = 0;

        int start_A = 0;
        bool padding = true;

        for(int i = 2; i < n_A + n_B - 1; i++) {
            offset = std::max(offset - 1, 0);
            if(i >= n_B) start_A++;

            if(i < n_B) diag_size++;
            else if(i >= n_A) {
                diag_size--;
                padding = false;
                end_offset++;
            }

            int n = diag_size;

            mgpu::transform([=] MGPU_DEVICE(int index) {
                if(dev_A[index + start_A] == dev_B[n - 1 - index + end_offset]) dev_dp[index + offset] = dev_pprev_dp[index + offset + 1] + 1;
                else dev_dp[index + offset] = max(dev_prev_dp[index + offset], dev_prev_dp[index + offset + 1]);
            }, diag_size - padding, context);

            std::swap(mdev_pprev_dp, mdev_prev_dp);
            std::swap(mdev_prev_dp, mdev_dp);

            dev_pprev_dp = mdev_pprev_dp.data();
            dev_prev_dp = mdev_prev_dp.data();
            dev_dp = mdev_dp.data();
        }
        context.synchronize();

        ans = mgpu::from_mem(mdev_prev_dp);
        std::cout << ans[0] << "\n";

    }

    return 0;
}