interpreter = input("Expression: ")
x,y,z = interpreter.split(" ")
#Initalise the values as integers not strings

if y == '+':
    result = int(x)+int(z)
    print(f"{result:.1f}")
elif y == "-":
    result = int(x) - int(z)
    print(f"{result:.1f}")
elif y == "/":
    result = int(x)/int(z)
    print(f"{result:.1f}")
elif y == "*":
    result = int(x)*int(z)
    print(f"{result:.1f}")
else:
    print("None")


