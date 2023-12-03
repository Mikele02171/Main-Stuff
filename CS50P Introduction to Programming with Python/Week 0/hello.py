
#Ways to say hello to the user.
#name = input("What's your name? ")

#Method 1
#String concatenation
#print("Hello " + x)

#Method 2
#f-strings
#print(f'Hello {x}')

#Print Hello x input, using sep
#print("Hello ",x,sep=",")

#Escape Characters using " inside the string
#print("Hello,\"World\"")
#In terminal type python hello.py to compilie.


#remove whitespace in string
#x = x.strip()

#Capitalize the user name (only the very first letter from x-string)
#x=x.capitalize()

#Title, Capitalizes initials only
#x = x.title()

#Combine strip and title functions together
#x = x.strip().title()

#print(f'Hello, {x}')

#Defining functions for hello
#Using def (short for define, using def to define your function)
#inside hello function (hello()) are arguments

#def hello(to="world"):
#    print("Hello,",to)
#hello()
#name = input("What's your name? ")
#hello(name)
def main():
    name = input("What's your name? ")
    hello(name)

def hello(to="world"):
    print("Hello,",to)

main()
