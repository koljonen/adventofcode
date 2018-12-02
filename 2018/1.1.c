#include <stdio.h>

int main() {
    int change = 0;
    int frequency = 0;
    while(scanf("%i", &change) != EOF) {
        frequency += change;
    }
    printf("The answer is %i\n", frequency);
}
