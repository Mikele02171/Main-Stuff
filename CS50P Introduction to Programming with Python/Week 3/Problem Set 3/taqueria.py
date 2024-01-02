
import sys
food = {"Baja Taco": 4.25,"baja taco": 4.25,
             "Burrito": 7.50,"burrito": 7.50,
             "Bowl": 8.50,"bowl": 8.50,
             "Nachos": 11.00,"nachos": 11.00,
             "Quesadilla": 8.50,"quesadilla": 8.50,
             "Super Burrito": 8.50,"super burrito": 8.50,
             "Super Quesadilla": 9.50,"super quesadilla": 9.50,
             "Taco": 3.00,"taco": 3.00,
             "Tortilla Salad": 8.00,"tortilla salad": 8.00}


total = 0
while True:
      try:
        item = input("Item: ").title()
        #Check if the item is in food
        if item in food:
            total += food[item]
            formatted_total = "${:.2f}".format(total)
            print(f"Total: {formatted_total} ")
      except EOFError:
          sys.exit()

