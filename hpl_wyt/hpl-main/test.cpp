#include <bits/stdc++.h>
#include <mpi.h>
#include <unistd.h>

using namespace std;

int main(int argc, char** argv) {
    int size, rank;
	MPI_Init(&argc, &argv);
	cout << "hello" << endl;
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	cout << rank << endl;
    MPI_Finalize();
	return 0;
}
