#include <iostream>
#include <thread>
#include <vector>
#include <mutex>
#include <condition_variable>

typedef long long ll;

const int THREADS = 16;
const int N = 2000;
ll D[N][N];

std::mutex m;
std::condition_variable cv;
int n_t = 0;

void floyd_warshall(int p, int q, int n, int all_t) {
    for(int k = 0; k < n; k++) {
        for(int i = p; i < q; i++) {
            for(int j = 0; j < n; j++) {
                D[i][j] = std::min(D[i][j], D[i][k] + D[k][j]);
            }
        }

        std::unique_lock lk(m);
        n_t++;
        if(n_t < all_t * (k + 1)) cv.wait(lk, [&]{ return n_t >= all_t * (k + 1); });
        else cv.notify_all();
    }
}

int main() {
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(nullptr);
    int n;
    std::cin >> n;

    int b = n / THREADS;
    int r = n % THREADS;

    int all_t = std::min(THREADS, n);

    for(int i = 0; i < n; i++) {
        for(int j = 0; j < n; j++) {
            std::cin >> D[i][j];
        }
    }

    std::vector<std::thread> threads;
    threads.reserve(all_t);

    int p = 0;
    for (int t = 0; t < all_t; t++) {
        int q = p + b + (t < r ? 1 : 0);

        threads.emplace_back(floyd_warshall, p, q, n, all_t);
        p = q;
    }

    for (auto& t : threads) {
        t.join();
    }


    for(int i = 0; i < n; i++) {
        for(int j = 0; j < n; j++) {
            std::cout << D[i][j] << " ";
        }
        std::cout << "\n";
    }

    return 0;
}