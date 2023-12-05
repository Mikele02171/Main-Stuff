#Print 3 # for each line
#
#
#

#for _ in range(3):
#    print("#")

#Print n of #'s for each line
#def main():
#    print_column(3)

#def print_column(height):
#    for _ in range(height):
#        print("#")

#main()

#Print n of ?'s in rows

#def main():
#    print_row(4)

#def print_row(width):
#    print("?"*width)
#main()

#Print the square n of # Method 1
#def main():
#    print_square(3)

#def print_square(size):

    #For each row in square
#    for i in range(size):

        #For each brick in row
#        for j in range(size):

            #Print brick (but leaving itself, only prints out the recent output in terminal)
#            print("#",end="")

        #Prints row of bricks for each line
#        print()

#main()

#Print the square n of # Method 2
def main():
    print_square(3)

def print_square(size):

    #For each row in square
    for i in range(size):
        print_row(size)

def print_row(width):
    print("#" * width)

main()

