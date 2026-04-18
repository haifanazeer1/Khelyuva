import pandas as pd
import random
import os;
# ─────────────────────────────
# LOAD DATASET (ONLY ONCE)
# ─────────────────────────────
BASE_DIR = os.path.dirname(__file__)
df = pd.read_csv(os.path.join(BASE_DIR, "food.csv"))


# ─────────────────────────────
# BMR CALCULATION
# ─────────────────────────────
def calculate_bmr(weight, height, age, gender="female"):
    if gender.lower() == "female":
        return (10 * weight) + (6.25 * height) - (5 * age) - 161
    else:
        return (10 * weight) + (6.25 * height) - (5 * age) + 5


# ─────────────────────────────
# ACTIVITY MULTIPLIER
# ─────────────────────────────
def get_activity_multiplier(activity_level):
    mapping = {
        "lightly_active": 1.375,
        "moderately_active": 1.55,
        "very_active": 1.725,
        "sedentary": 1.2
    }
    return mapping.get(activity_level.lower(), 1.2)


# ─────────────────────────────
# BMI
# ─────────────────────────────
def calculate_bmi(weight, height):
    height_m = height / 100
    return weight / (height_m ** 2)


def get_bmi_category(bmi):
    if bmi < 18.5:
        return "Underweight"
    elif bmi < 24.9:
        return "Normal weight"
    elif bmi < 29.9:
        return "Overweight"
    else:
        return "Obese"


# ─────────────────────────────
# MACROS
# ─────────────────────────────
def calculate_macros(calories, weight, goal):
    protein = weight * (2 if goal == "gain" else 1.6)
    protein_cal = protein * 4

    fat_cal = calories * 0.25
    fat = fat_cal / 9

    carbs_cal = calories - (protein_cal + fat_cal)
    carbs = carbs_cal / 4

    return {
        "protein": round(protein),
        "carbs": round(carbs),
        "fat": round(fat)
    }


# ─────────────────────────────
# GOAL MAPPING
# ─────────────────────────────
def map_goal(goal):
    goal = goal.lower()

    if "loss" in goal:
        return "loss"
    elif "gain" in goal:
        return "gain"
    else:
        return "maintain"
    
def classify_food(row):
    name = row["Food_items"].lower()

    # ❌ Junk / desserts
    junk_keywords = [
        "icecream", "chocolate", "doughnut", "cake", "brownie",
        "fries", "pizza", "burger", "nachos"
    ]
    if any(word in name for word in junk_keywords):
        return "avoid"

    # 🍳 Breakfast-friendly items
    breakfast_keywords = [
        "milk", "banana", "oats", "bread", "egg", "fruit",
        "yogurt", "corn flakes", "poha", "idli", "dosa"
    ]
    if any(word in name for word in breakfast_keywords):
        return "breakfast"

    # 🍗 Main dishes
    if row["Proteins"] > 10 or any(word in name for word in [
        "rice", "chicken", "fish", "paneer", "dal", "meat"
    ]):
        return "main"

    # 🥗 Side dishes
    return "side"


# ─────────────────────────────
# AI-STYLE MEAL GENERATION
# ─────────────────────────────
def generate_meal_plan(goal, target_calories):
    df_copy = df.copy()

    df_copy["category"] = df_copy.apply(classify_food, axis=1)

    df_clean = df_copy[df_copy["category"] != "avoid"]

    if goal == "loss":
        df_clean = df_clean[df_clean["Calories"] < 400]
    elif goal == "gain":
        df_clean = df_clean[df_clean["Calories"] > 80]

    breakfast_items = df_clean[df_clean["Breakfast"] == 1]
    lunch_items = df_clean[df_clean["Lunch"] == 1]
    dinner_items = df_clean[df_clean["Dinner"] == 1]

    # 🔥 Breakfast
    def build_breakfast(items):
        breakfast_main = items[items["category"] == "breakfast"]
        sides = items[items["category"] == "side"]

        main_food = None
        side_food = None

        if not breakfast_main.empty:
            main_food = breakfast_main.sample(1)["Food_items"].values[0]

        if not sides.empty:
            side_food = sides.sample(1)["Food_items"].values[0]

        if main_food and side_food:
            return f"{main_food} + {side_food}"
        elif main_food:
            return main_food
        else:
            return "Oats + Fruit"

    # 🔥 Lunch/Dinner
    def build_meal(items):
        high_protein = items[items["Proteins"] >= 8]

        mains = items[items["category"] == "main"]
        sides = items[items["category"] == "side"]

        main_food = None
        side_food = None

        if not high_protein.empty:
            main_food = high_protein.sample(1)["Food_items"].values[0]
        elif not mains.empty:
            main_food = mains.sample(1)["Food_items"].values[0]

        if not sides.empty:
            side_food = sides.sample(1)["Food_items"].values[0]

        if main_food and side_food:
            return f"{main_food} + {side_food}"
        elif main_food:
            return main_food
        elif side_food:
            return side_food
        else:
            return "Balanced meal"

    # 🔥 THIS PART WAS MISSING
    breakfast = build_breakfast(breakfast_items)
    lunch = build_meal(lunch_items)
    dinner = build_meal(dinner_items)

    return {
        "breakfast": breakfast,
        "lunch": lunch,
        "dinner": dinner
    }


# ─────────────────────────────
# MAIN FUNCTION (API USES THIS)
# ─────────────────────────────
def recommend_diet(age, weight, height, fitness_goal, activity_level):
    # 1. BMR
    bmr = calculate_bmr(weight, height, age)

    # 2. Activity
    multiplier = get_activity_multiplier(activity_level)
    maintenance = bmr * multiplier

    # 3. Goal
    goal = map_goal(fitness_goal)

    if goal == "loss":
        target_calories = maintenance - 400
    elif goal == "gain":
        target_calories = maintenance + 400
    else:
        target_calories = maintenance

    # Safety limit
    if target_calories < 1200:
        target_calories = 1200

    # 4. BMI
    bmi = calculate_bmi(weight, height)
    bmi_category = get_bmi_category(bmi)

    # 5. Macros
    macros = calculate_macros(target_calories, weight, goal)

    # 6. AI Meals
    
    meals = generate_meal_plan(goal, target_calories)
  
    return {
        "target_calories": round(target_calories),
        "bmi": round(bmi, 2),
        "bmi_category": bmi_category,
        "macros": macros,
        "meals": meals
    }