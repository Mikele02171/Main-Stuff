#ADDITION

#x = int(input("What is x?"))
#y = int(input("what is y?"))

#if you do not int() for x and y, you end up concatenating strings.
#z = x + y
#print(z)

#Example
#a = float(input("What is a?"))
#b = float(input("What is b?"))
#c = a+b
#c=round(c)
#print(f"{c:,}")

#What is a? 999
#What is b? 1
1,000

#DIVISION
#a = float(input("What is a?"))
#b = float(input("What is b?"))
#c = round(a/b,2)

#Using f-string, to compute how many digits you want to print out
#print(f"{c: .2f}")

#Define function for squaring integers
def main():
    a = int(input("What is a? "))
    print("x sqaured is", square(a))

def square(n):
    #return n x n
    #return pow(n,2)
    return n**2

main()
