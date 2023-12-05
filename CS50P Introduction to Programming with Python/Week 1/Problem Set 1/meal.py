def main():
    t = input("What time is it? ")
    if 7<=convert(t)<=8:
        print("breakfast time")
    elif 12<=convert(t)<=13:
        print("lunch time")
    elif 18<=convert(t)<=19:
        print("dinner time")
    else:
        print("")




def convert(time):
    hours,minutes= time.split(":")
    h = int(hours)
    m = int(minutes)
    result = h + m/60
    return result



if __name__ == "__main__":
    main()
