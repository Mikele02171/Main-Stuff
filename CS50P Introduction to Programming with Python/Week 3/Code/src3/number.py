#Exception Example 1
#try:
#    x = int(input("What's x? "))

#Print if you raise a ValueError
#except ValueError:
#    print("x is not an integer")

#Print if you raise a NameError
#else:
#    print(f"x is {x}")

#Exception Example 2 (Approach 1)
#We will be stuck in the loop forever, until we input an integer.

#while True:
#    try:
#        x = int(input("What's x? "))
#    except ValueError:
#        print("x is not an integer")
#    else:
#        print(f"x is {x}")
#        break

#Exception Example 2 (Approach 2)
#while True:
#    try:
#        x = int(input("What's x? "))
#        break
#    except ValueError:
#        print("x is not an integer")
#print(f"x is {x}")

#Exception Example 2 (Approach 3)
#def main():
#    x = get_int()
#    print(f"x is {x}")

#def get_int():
#    while True:
#        try:
#            return int(input("What's x? "))
#        except ValueError:
#            pass
#main()

#Exception Example 2 (Approach 3)
def main():
    x = get_int("What's x? ")
    print(f"x is {x}")

def get_int(prompt):
    while True:
        try:
            return int(input(prompt))
        except ValueError:
            pass
main()
