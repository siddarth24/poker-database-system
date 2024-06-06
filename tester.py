for val in range(1, 14):
    for suite in ['D', 'C', 'H', 'S']:
        print("INSERT INTO Card (value, suite) VALUES(" + str(val) + ", '" + suite + "');")