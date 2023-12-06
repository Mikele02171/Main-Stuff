string  = input("Input: ")
ls = list(string)

new_list = []
for i in ls:
    if i in ["a","e","i","o","u","A","E","I","O","U"]:
        i = i.replace(i," ").strip()
    new_list.append(i)

print(''.join(new_list))

