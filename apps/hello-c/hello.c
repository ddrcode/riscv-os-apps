#include "stdlib.h"

int main() {
    char* msg = "Running C program";
    syscall((u32)msg, 0, 0, 0, 0, 22);
    return 3;
}
