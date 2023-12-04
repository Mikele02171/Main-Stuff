z = input("The answer to the Great Question of Life, the Universe and Everything? ")
z = z.strip() #Must note strip removes all whitespace in strings
match z:
    case "forty-two" | "forty two" |"Forty Two" |"42" |"Forty-Two"| "FoRty TwO"|" 42"|"42 "| " 42 ":
        print("Yes")
    case _:
        print("No")


