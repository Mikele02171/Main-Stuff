x = 50
while True:
    print("Amount Due: " + str(x))
    y = int(input("Insert Coin: "))
    if y in [5,10,25]:
        x -= y
        if x <= 0:
            print("Change Owed: " + str(-1*x))
            break
        else:
            print("Amount Due: " + str(x))

    else:
        print()




