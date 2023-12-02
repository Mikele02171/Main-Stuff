#include <stdio.h>
#include "cs50.h"
// Computing the scores N (how many times) then compute the average.
float average(int length,int array[]);
const int N = 3;

int main(void)
{
     
    int scores[N];
    for (int i = 0; i<N;i++)
    {
        scores[i] = get_int("Score: ");
    }

    printf("Average: %f\n", average(N,scores));
}

float average(int legnth,int array[])
{
    int sum = 0;
    for (int i = 0; i<N;i++)
    {
        sum += array[i];
    }
    return sum/(float) N;
}