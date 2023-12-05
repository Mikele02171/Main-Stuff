string = input("camelCase: ")
#Convert string to List
list1 = list(string)

#We want to append a new list
new_list = []

for i in list1:
    #For every index if it has capital letters
    if i.isupper():
        #use string concatenation
        i = "_" + i.lower()
    #then add i into the new list 
    new_list.append(i)

print(''.join(new_list))
