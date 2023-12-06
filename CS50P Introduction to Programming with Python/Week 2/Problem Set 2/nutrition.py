Nutrition = {"apple":130,"Apple":130,
             "avocado":50,"Avocado":50,
             "banana":110,"Banana":110,
             "cantaloupe":50,"Cantaloupe":50,
             "grapefruit":60,"Grapefruit":60,
             "grapes":90, "Grapes":90,
             "honeydew melon":50,"Honeydew Melon":50,
             "kiwifruit":90,"Kiwifruit":90,
             "lemon":15,"Lemon":15,
             "lime":20,"Lime":20,
             "nectarine":60,"Nectarine":60,
             "orange":80,"Orange":80,
             "peach":60,"Peach":60,
             "pear":100,"Pear":100,
             "pineapple":50,"Pineapple":50,
             "plums":70,"Plums":70,
             "strawberries":50,"Strawberries":50,
             "sweet cherries":100,"Sweet Cherries":100,
             "tangerine":50,"Tangerine":50,
             "watermelon":80,"Watermelon":80}

item = input("Item: ")
if item in Nutrition.keys():
    print("Calories: " + str(Nutrition[item]))
