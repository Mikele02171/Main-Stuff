#include<stdio.h>
#include "cs50.h"

int main(void)
{
    //char c1 = 'H';
    //char c2 = 'I';
    //char c3 = '!';
    //string s = "HI!";
    //string t  = "BYE!";

    string words[2];
    words[0]="HI!";
    words[1]="BYE!";

    //Convert message into a new sequence of numbers 
    printf("%c%c%c\n",words[0][0],words[0][1],words[0][2]);
    printf("%c%c%c%c\n",words[1][0],words[1][1],words[1][2],words[1][3]);
}