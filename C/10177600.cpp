#include <iostream>
#include <vector>
#include <omp.h>

const int N = 4000;

short A[N * N];
short Bt[N * N];
int C[N * N]{};

void multiply(int n) {
    #pragma omp parallel for
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            for (int k = 0; k < n; k++) {
                C[i * n + j] += (int)A[i * n + k] * Bt[j * n + k];
            }
        }
    }
}

int main() {
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(nullptr);
    int n;

    std::cin >> n;

    for(int i = 0; i < n; i++) {
        for(int j = 0; j < n; j++) {
            std::cin >> A[i * n + j];
        }
    }

    for(int i = 0; i < n; i++) {
        for(int j = 0; j < n; j++) {
            std::cin >> Bt[j * n + i];
        }
    }

    multiply(n);
    
    for(int i = 0; i < n; i++) {
        for(int j = 0; j < n; j++) {
            std::cout << C[i * n + j] << " ";
        }
        std::cout << "\n";
    }

    return 0;
}