#x = int(input("What's is x? "))

#if x%2 ==0:
#    print("Even")

#else:
#    print("Odd")

def main():
    x = int(input("What's x? "))
    if is_even(x):
        print("Even")
    else:
        print("Odd")

def is_even(n):
    if n % 2 == 0:
        return True
    else:
        return False
    #Comment everything in def is_even()
    #and type the following, and it still works
    #return True if n%2 == 0 else False

#Must call main() to start calling the function main
main()
