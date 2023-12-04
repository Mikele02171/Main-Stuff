#Comparsion 2
score = int(input("Score: "))
#if score >= 90 and score <= 100:
#    print("Grade: A")

#elif score >= 80 and score < 90:
#    print("Grade: B")

#elif score >= 70 and score < 80:
#    print("Grade: C")

#elif score >= 60 and score < 70:
#    print("Grade: D")

#else:
#    print("Grade: F")

#inside the  if.elif statements you can switch around the score
# 90 <= score
# 80 <= score

#or 90 <= score <= 100 (a lot cleaner)
#Unable to do this in C,C++, Java and other programming languages.

#This makes the code readable
#This is further as we can get (unless we apply a loop)
# NOTE: & is (and)
if score >= 90 & score <= 100:
    print("Grade: A")

elif score >= 80:
    print("Grade: B")

elif score >= 70:
    print("Grade: C")

elif score >= 60:
    print("Grade: D")

else:
    print("Grade: F")

#if on all conditions (BE CAREFUL)
#It will print out
#Score: 95
#Grade: A
#Grade: B
#Grade: C
#Grade: D
#Grade: F


