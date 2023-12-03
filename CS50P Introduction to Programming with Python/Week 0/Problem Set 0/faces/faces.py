
def main():
    x = emoji(input(" "))

    print(x)

def emoji(e):
    #return emoji
    e = e.replace(":)","🙂")
    e = e.replace(":(","🙁")
    e = e.replace(":|","😐")
    return e

main()

