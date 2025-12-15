#include <iostream>
#include <vector>
#include <thread>

const int THREADS = 16;
const int N = 4000;

short A[N * N];
short Bt[N * N];
int C[N * N]{};

void multiply(int n, int p, int q) {
    for (int i = p; i < q; i++) {
        for (int j = 0; j < n; j++) {
            for (int k = 0; k < n; k++) {
                C[i * n + j] += (int)A[i * n + k] * (int)Bt[j * n + k];
            }
        }
    }
}

int main() {
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(nullptr);
    int n;

    std::cin >> n;

    int b = n / THREADS;
    int r = n % THREADS;

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

    std::vector<std::thread> workers;
    workers.reserve(THREADS);

    int p = 0;
    for (int t = 0; t < THREADS; t++) {
        int q = p + b + (t < r ? 1 : 0);
        if (p >= q) break;

        workers.emplace_back(multiply, n, p, q);
        p = q;
    }

    for (auto& w : workers) {
        w.join();
    }

    for(int i = 0; i < n; i++) {
        for(int j = 0; j < n; j++) {
            std::cout << C[i * n + j] << " ";
        }
        std::cout << "\n";
    }

    return 0;
}