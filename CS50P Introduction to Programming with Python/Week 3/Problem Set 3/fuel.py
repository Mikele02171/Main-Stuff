
def main():
    x = get_fraction()
    if x == 0.99 or x == 1:
        print("F")
    elif x==0 or x== 0.01:
        print("E")
    elif x>= 1:
        get_fraction()
    else:
        print(f"{x*100:.0f}%")

def get_fraction():
    while True:
        try:
            frac_int = input("What's x? ")
            a,b = frac_int.split("/")
            a = int(a)
            b = int(b)
            fraction = float(a/b)
            return fraction
        except (ValueError, ZeroDivisionError):
            pass

main()
