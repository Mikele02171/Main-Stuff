#print("meow")
#print("meow")
#print("meow")


#While loop 1
#i = 3
#while i != 0:
#    print("meow")
#    i -= 1
#Infinite Loop (be careful), use control C to terminal the terminal window
#hence, we use i = i - 1

#While loop 2
#i=1
#while i <= 3:
#    print("meow")
#    i += 1

#While loop 3 (start at i = 0)
#i=0
#while i < 3:
#    print("meow")
#    i += 1

#NOTE: Python does not enable i++ or i--

#For loop, [] is a list
#This may not be an efficient way saying [0,1,2,3,.... etc..]
#for i in [0,1,2]:
#    print("meow")


#For loop
#i = 0 (start value)
#Including 0,1,2 but not 3
#Where range(start,end,step)

#for i in range(3):
 #   print("meow")

#Another meow approach printing 3 times for each line
#print("meow\n"*3)

#print the number of meows Method 1
#while True:
#    n = int(input("What's n? "))
#    if n>0:
#        break #break in the loop
#    else:
 #       continue #continue the loop

#for _ in range(n):
#   print("meow")

#print the number of meows Method 2
def main():
    number = get_number()
    meow(3)

def get_number():
    while True:
        n = int(input("What's n? "))
        if n > 0:
            break
    #must return the value n inside the function
    return n


def meow(n):
    for _ in range(n):
        print("meow")

main()
