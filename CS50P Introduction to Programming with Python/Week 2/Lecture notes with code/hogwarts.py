#LISTS
#students = ["Hermione","Harry","Ron"]

#Index at 0, location 1 from students list to retrieve "Hermione"
#students[0]

#print(students[0])

#Index at 1, location 2 from students list to retrieve "Harry"
#students[1]

#print(students[1])

#Index at 2, location 3 from students list to retrieve "Ron"
#students[2]

#print(students[2])

#NOTE can replace student _ or s, but the main goal to make the person understand your code
#Method 1:
#for student in students:
#    print(student)

#method 2
#for i in range(len(students)):
#    print(i + 1,students[i])
#    #index + 1 , element

#DICTIONARIES
#students = ["Hermione","Harry","Ron","Draco"]
#houses = ["Gryffindor","Gryffindor","Gryffindor","Slytherin"]

#Dictionary, readable
#students = {"Hermione":"Gryffindor","Harry":"Gryffindor","Ron":"Gryffindor","Draco": "Slytherin"}

#print(students)
#NOTE: Use students["Herminone"], indexing the key to retrieve the assoicated value, in this case "Gryffindor".

#for student in students:
 #   print(student,students[student],sep = ", ")

#List of dictionaries
students = [{"name":"Hermione","house":"Gryffindor","patronus":"Otter"},
{"name":"Harry","house":"Gryffindor","patronus":"Stag"},
{"name":"Ron","house":"Gryffindor","patronus":"Jack Russell terrier"},
{"name":"Draco","house":"Slytherin","patronus":None}]

#Where None is a special keyword.
for student in students:
        print(student["name"],student["house"],student["patronus"],sep=", ")



