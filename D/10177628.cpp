#include <iostream>
#include <vector>
#include <omp.h>

const int N = 2000;
int D[N][N];

void floyd_warshall(int n) {
    for(int k = 0; k < n; k++) {
        #pragma omp parallel for
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                D[i][j] = std::min(D[i][j], D[i][k] + D[k][j]);
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
            std::cin >> D[i][j];
        }
    }

    floyd_warshall(n);

    for(int i = 0; i < n; i++) {
        for(int j = 0; j < n; j++) {
            std::cout << D[i][j] << " ";
        }
        std::cout << "\n";
    }

    return 0;
}