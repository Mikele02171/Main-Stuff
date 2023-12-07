
def main():
    x = get_date()
    if '/' in x:
        m,d,y = x.strip().split("/")
        d = int(d)
        y = int(y)
        if m in ['1','2','3','4','5','6','7','8','9','10','11','12']:
            m = int(m)
            if 1<=d<=9 and 1<=m<=9:
                print(f"{y}-0{m}-0{d}")
            elif 1<=d<=9 and 9<=m<=12:
                print(f"{y}-{m}-0{d}")
            elif 10<=d<=31 and 1<=m<=9:
                print(f"{y}-0{m}-{d}")
            else:
                x = get_date()
        else:
            x = get_date()

    elif ',' in x:
        m,d,y = x.split(" ")
        y = int(y)
        if m in ["January","February","March","April","May","June","July","August","September","October","November","December"]:
            m = str(m)
            d = int(d.replace(',',' '))
            months = {"January":"01","February":"02","March":"03","April":"04","May":"05","June":"06","July":"07","August":"08","September":"09","October":"10","November":"11","December":"12"}
            if 1<=d<=9:
                print(f"{y}-{months[m]}-0{d}")
            elif 10<=d<=31:
                print(f"{y}-{months[m]}-{d}")
            else:
                x = get_date()
        else:
            x = get_date()


    else:
        x = get_date()


def get_date():
    while True:
        try:
            date = input("Date: ")
            return date
        except (ValueError, ZeroDivisionError):
            pass

main()
