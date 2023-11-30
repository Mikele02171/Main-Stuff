#include <stdio.h>
#include "cs50.h"

/* This is how to program a n x n # grid */
int main(void)
{
    // Get size of grid
    int n;
    do
    {
        n = get_int("Size: ");
    } 
    while(n<1);
    
    // Print grid of n x n bricks 
    for(int i =0; i<n;i++)
    {
        for (int j = 0; j<n;j++)
        {
            printf("#");
        }
        printf("\n");

    }

}