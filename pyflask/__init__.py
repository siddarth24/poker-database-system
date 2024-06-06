import os
from flask import Flask, request, jsonify, Response
from flask_cors import CORS, cross_origin
import mysql.connector
import json

# code referenced from https://flask.palletsprojects.com/en/3.0.x/tutorial/factory/
# def create_app(test_config=None):
#     # create and configure the app
#     app = Flask(__name__, instance_relative_config=True)
#     CORS(app)
#     app.config.from_mapping(
#         SECRET_KEY='dev',
#         DATABASE=os.path.join(app.instance_path, 'flaskr.sqlite'),
#     )

#     if test_config is None:
#         # load the instance config, if it exists, when not testing
#         app.config.from_pyfile('config.py', silent=True)
#     else:
#         # load the test config if passed in
#         app.config.from_mapping(test_config)

#     # ensure the instance folder exists
#     try:
#         os.makedirs(app.instance_path)
#     except OSError:
#         pass

app = Flask(__name__)
CORS(app)

db_config = {
    "user": "poker_admin",
    "password": "poker",
    "host": "localhost",
    "database": "poker",
}

# helper function to get a database connection
def executeQuery(query, variables=None):
    try:
        connector = mysql.connector.connect(**db_config)
        cursor = connector.cursor()
        cursor.execute(query, variables)
        ret = (cursor.fetchall(), cursor.lastrowid)
        connector.commit()
        return ret
    except mysql.connector.Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        connector.close()

# create a new game
@app.route('/api/new_game', methods=['POST'])
@cross_origin()
def new_game():
    # get data from JSON request
    data = request.json
    
    if "season_number" not in data or "date" not in data or "in_tournament" not in data or "tournament_id" not in data:
        return jsonify({"error": "Missing required parameters in request"}), 400
    
    date = data["date"]
    season_number = data["season_number"]
    in_tournament = data["in_tournament"]
    tournament_id = data["tournament_id"]

    # create a new game in the database
    query_game_season = '''
            INSERT INTO Game_Season (date, season_number)
            VALUES (%s, %s)
            ON DUPLICATE KEY UPDATE season_number = VALUES(season_number)
        '''
    variables_game_season = (date, season_number)
    result_game_season = executeQuery(query_game_season, variables_game_season)
    
    if isinstance(result_game_season[0], Response):
        if "error" in result_game_season[0].json:
            return result_game_season[0].json, 500
    
    query_game = '''
            INSERT INTO Game (date)
            VALUES (%s)
        '''
    variables_game = (date,)
    result_game = executeQuery(query_game, variables_game)
    
    if isinstance(result_game[0], Response):
        if "error" in result_game[0].json:
            return result_game[0].json, 500
    else:
        game_id = result_game[1]
        
        query_game_tournament = '''
                    INSERT INTO Game_Tournament (date, in_tournament, tournament_id)
                    VALUES (%s, %s, %s)
                    ON DUPLICATE KEY UPDATE in_tournament = VALUES(in_tournament), tournament_id = VALUES(tournament_id)
                '''
        variables_game_tournament = (date, in_tournament, tournament_id)
        result_game_tournament = executeQuery(query_game_tournament, variables_game_tournament)
        
        if isinstance(result_game_tournament[0], Response):
            if "error" in result_game_tournament[0].json:
                return result_game_tournament[0].json, 500
        else:
            return jsonify({"game_id": game_id}), 201

# deletes the specified game
@app.route('/api/delete_game', methods=['DELETE'])
@cross_origin()
def delete_game():
    data = request.json
    
    if "game_id" not in data:
        return jsonify({"error": "Missing 'game_id' in request"}), 400
    
    game_id = data['game_id']

    # delete the game from the database
    query = "DELETE FROM Game WHERE id = %s"
    variables = (game_id,)
    result = executeQuery(query, variables)
    
    if isinstance(result[0], Response):
        if "error" in result[0].json:
            return result[0].json, 500
    else:
        return jsonify({"game_id": game_id}), 200

# Player(s) buy(s) in to a game, at the most recent round played
@app.route('/api/buy_in', methods=['POST'])
@cross_origin()
def buy_in():
    data = request.json
    
    if "game_id" not in data or "buy_ins" not in data:
        return jsonify({"error": "Missing required parameters in request"}), 400
    
    game_id = data["game_id"]
    buy_ins = data["buy_ins"]
    response_array = []
    
    for buy_in in buy_ins:
        player_id = buy_in["player_id"]
        amount = buy_in["amount"]
        
        query_buy_in = '''
            INSERT INTO Buy_in_cash_out (action_type, amount, match_id, player_id)
            VALUES (%s, %s, (SELECT id FROM Matches WHERE game_id = %s ORDER BY match_number DESC LIMIT 1), %s)
        '''
        variables = (1, amount, game_id, player_id)
        result = executeQuery(query_buy_in, variables)
        
        if isinstance(result[0], Response):
            if "error" in result[0].json:
                return result[0].json, 500
        else:
            query_net_winnings = "SELECT net_winnings FROM Player WHERE id = %s"
            variables_net_winnings = (player_id,)
            result_net_winnings = executeQuery(query_net_winnings, variables_net_winnings)
            if isinstance(result_net_winnings[0], Response):
                if "error" in result_net_winnings[0].json:
                    return result_net_winnings[0].json, 500
            else:
                net_winnings = result_net_winnings[0][0][0]
                response_array.append({
                    "player_id": player_id,
                    "net_winnings": net_winnings
                })
    return jsonify({"buy_ins": response_array}), 201

# Player(s) cash(es) out of a game, at the most recent round played
@app.route('/api/cash_out', methods=['POST'])
@cross_origin()
def cash_out():
    data = request.json
    
    if "game_id" not in data or "cash_outs" not in data:
        return jsonify({"error": "Missing required parameters in request"}), 400
    
    game_id = data["game_id"]
    cash_outs = data["cash_outs"]
    response_array = []
    
    if game_id == "" or cash_outs == []:
        return jsonify({"error": "Parameters are either zero or empty strings/arrays"}), 400
    
    for cash_out in cash_outs:
        player_id = cash_out["player_id"]
        amount = cash_out["amount"]
        
        query_cash_out = '''
            INSERT INTO Buy_in_cash_out (action_type, amount, match_id, player_id)
            VALUES (%s, %s, (SELECT id FROM Matches WHERE game_id = %s ORDER BY match_number DESC LIMIT 1), %s)
        '''
        variables = (2, amount, game_id, player_id)
        result = executeQuery(query_cash_out, variables)
        
        if isinstance(result[0], Response):
            if "error" in result[0].json:
                return result[0].json, 500
        else:
            query_net_winnings = "SELECT net_winnings FROM Player WHERE id = %s"
            variables_net_winnings = (player_id,)
            result_net_winnings = executeQuery(query_net_winnings, variables_net_winnings)
            if isinstance(result_net_winnings[0], Response):
                if "error" in result_net_winnings[0].json:
                    return result_net_winnings[0].json, 500
            else:
                response_array.append({
                    "player_id": player_id,
                    "net_winnings": result_net_winnings[0][0][0]
                })
    return jsonify({"cash_outs": response_array}), 201

# adds a new match to the game
@app.route('/api/add_match', methods=['POST'])
@cross_origin()
def add_match():
    data = request.json
    
    if "game_id" not in data or "hole_cards" not in data:
        return jsonify({"error": "Missing required parameters in request"}), 400
    
    game_id = data["game_id"]
    hole_cards = data["hole_cards"]
    
    if game_id == "" or hole_cards == []:
        return jsonify({"error": "Parameters are either zero or empty strings/arrays"}), 400
    
    for hole_card in hole_cards:
        if "player_id" not in hole_card or "card1_id" not in hole_card or "card2_id" not in hole_card:
            return jsonify({"error": "Missing required parameters in request"}), 400
        
        player_id = hole_card["player_id"]
        card_1 = hole_card["card1_id"]
        card_2 = hole_card["card2_id"]
                
        if player_id == "" or card_1 == "" or card_2 == "":
            return jsonify({"error": "Parameters are either zero or empty strings/arrays"}), 400
        
    # get the most recent match number to increment
    query_match_number = "SELECT MAX(match_number) FROM Matches WHERE game_id = %s"
    variables_match_number = (game_id,)
    result_match_number = executeQuery(query_match_number, variables_match_number)
    if isinstance(result_match_number[0], Response):
        if "error" in result_match_number[0]:
            return result_match_number[0].json, 500
    else:
        match_number = result_match_number[0][0][0] + 1
        query_match = "INSERT INTO Matches (match_number, game_id) VALUES (%s, %s)"
        variables_match = (match_number, game_id)
        result_match = executeQuery(query_match, variables_match)
        if isinstance(result_match[0], Response):
            if "error" in result_match[0]:
                return result_match[0].json, 500
        else:
            match_id = result_match[1]
            
            for hole_card in hole_cards:
                player_id = hole_card["player_id"]
                card_1 = hole_card["card1_id"]
                card_2 = hole_card["card2_id"]
                
                query_hole_cards = '''
                    INSERT INTO Hole_Cards (player_id, match_id, card1, card2)
                    VALUES (%s, %s, %s, %s)
                '''
                variables_hole_cards = (player_id, match_id, card_1, card_2)
                result_hole_cards = executeQuery(query_hole_cards, variables_hole_cards)
                if isinstance(result_hole_cards[0], Response):
                    if "error" in result_hole_cards[0].json:
                        return result_hole_cards[0].json, 500
            
            return jsonify({"match_id": match_id}), 201
    
    
# TODO: deletes the most recently played match from a game
@app.route('/api/delete_match', methods=['DELETE'])
@cross_origin()
def delete_match():
    data = request.json
    if "game_id" not in data:
        return jsonify({"error": "Missing 'game_id' in request"}), 400
    
    game_id = data['game_id']
    if game_id == "":
        return jsonify({"error": "Parameters are either zero or empty strings/arrays"}), 400
    
    query = "DELETE FROM Matches WHERE game_id = %s ORDER BY match_number DESC LIMIT 1"
    variables = (game_id,)
    result = executeQuery(query, variables)
    if isinstance(result[0], Response):
        if "error" in result[0].json:
            return result[0].json, 500
    else:
        return jsonify({"game_id": game_id}), 200

# TODO: adds a new round to the most recently played match in the specified game
@app.route('/api/add_round', methods=['POST'])
@cross_origin()
def add_round():
    data = request.json
    game_id = int(data['game_id'])
    pot_size = int(data['pot_size'])
    card1 = int(data['card1_id']) if 'card1_id' in data else None
    card2 = int(data['card2_id']) if 'card2_id' in data else None
    card3 = int(data['card3_id']) if 'card3_id' in data else None
    actions = data['actions']

    # First, get match and round info
    query = """
    SELECT m.match_number, m.id
    FROM matches m
    WHERE m.game_id = %s
    ORDER BY m.match_number DESC
    LIMIT 1
    """
    args = (game_id,)
    result = executeQuery(query, args)
    match_number, match_id = result[0][0][0], result[0][0][1]

    query = """
    SELECT r.round_number
    FROM round r
    INNER JOIN matches m ON r.match_id = m.id
    WHERE m.id = %s
    ORDER BY r.round_number DESC
    LIMIT 1
    """
    args = (match_id,)
    result = executeQuery(query, args)
    if len(result[0]) > 0:
        round_number = result[0][0][0] + 1
    else:
        round_number = 1
    if round_number > 4:
        return {
            "error": "Most recent match already has 4 rounds"
        }

    # Next, insert round
    query = """
    INSERT INTO round (round_number, match_id, pot_size, card1_id, card2_id, card3_id) VALUES (%s, %s, %s, %s, %s, %s)
    """
    args = (round_number, match_id, pot_size, card1, card2, card3)
    result = executeQuery(query, args)
    round_id = result[1]

    # Finally, add actions
    query = f"""
    INSERT INTO action
        (action_number, round_id, player_id, action_type, amount, ending_balance)
        VALUES {", ".join(["(%s, %s, %s, %s, %s, %s)"] * len(actions))}
    """
    args = [(i, round_id, actions[i]['player_id'], actions[i]['action'], actions[i]['amount'], actions[i]['ending_balance']) for i in range(len(actions))]
    args = tuple([element for tup in args for element in tup])
    result = executeQuery(query, args)

    return {
        "game_id": game_id,
        "match_id": match_id,
        "match_number": match_number,
        "round_number": round_number
    }

# Delete the most recently played round in the given game
@app.route('/api/delete_round', methods=['DELETE'])
@cross_origin()
def delete_round():
    data = request.json
    game_id = int(data['game_id'])

    # First, round info
    query = """
    SELECT r.id, r.round_number, m.id, m.match_number
    FROM round r
    INNER JOIN matches m ON r.match_id = m.id
    WHERE m.game_id = %s
    ORDER BY m.match_number DESC, r.round_number DESC
    LIMIT 1
    """
    args = (game_id,)
    result = executeQuery(query, args)
    round_id = result[0][0][0]
    round_number = result[0][0][1]
    match_id = result[0][0][2]
    match_number = result[0][0][3]

    # Then, delete round
    query = """
    DELETE FROM round WHERE round.id = %s
    """
    args = (round_id,)
    result = executeQuery(query, args)
    
    return {
        "round_id": round_id,
        "round_number": round_number,
        "match_id": match_id,
        "match_number": match_number
    }



# REPLAY API
# Sid does this
# =======================================================================================================
# =======================================================================================================

# list all games that have been played
@app.route('/api/get_games', methods=['POST'])
@cross_origin()
def get_games():
    data = request.json
    offset = int(data.get('offset', 0))
    limit = int(data.get('limit', 9999))
    query = '''
        SELECT g.id AS game_id, g.date, gs.season_number, gt.in_tournament, gt.tournament_id
        FROM Game g
        INNER JOIN Game_Season gs ON g.date = gs.date
        LEFT JOIN Game_Tournament gt ON g.date = gt.date
        LIMIT %s OFFSET %s
    '''
    args = (limit, offset)
    result = executeQuery(query, args)

    if "error" in result[0]: 
        return result

    games_list = [{
        "game_id": game[0],    
        "date": game[1],          
        "season_number": game[2],  
        "in_tournament": game[3],  
        "tournament_id": game[4] if game[3] else None 
    } for game in result[0]]  

    return jsonify(games_list)

# list all matches in a specified game
# list all matches in a specified game
@app.route('/api/get_matches', methods=['POST'])
@cross_origin()
def get_matches():
    data = request.json
    game_id_str = data.get('game_id')
    offset_str = data.get('offset', '0')  
    limit_str = data.get('limit', '999')  

    try:
        game_id = int(game_id_str)
        offset = int(offset_str)
        limit = int(limit_str)
    except (ValueError, TypeError):
        return jsonify({"error": "Invalid input, 'game_id', 'offset', and 'limit' must be integers"}), 400

    query = '''
        SELECT m.id, m.match_number, m.game_id
        FROM Matches m
        WHERE m.game_id = %s
        ORDER BY m.match_number ASC
        LIMIT %s OFFSET %s
    '''
    matches, _ = executeQuery(query, (game_id, limit, offset))

    if isinstance(matches, dict) and "error" in matches:  
        return jsonify(matches), 500

    matches_list = [{
        "match_id": match[0],
        "match_number": match[1],
        "game_id": match[2],
    } for match in matches]

    return jsonify(matches_list)

# list all rounds in a specified match
# if match id is provided, match number and game id are not needed
@app.route('/api/get_rounds', methods=["POST"])
@cross_origin()
def get_rounds():
    data = request.json
    match_id = data.get("match_id", None)
    game_id = data.get("game_id", None)
    match_number = data.get("match_number", None)
    offset = int(data.get("offset", 0))
    limit = int(data.get("limit", 9999))

    if not match_id and (not game_id or not match_number):
        return {
            "error": "Please specify match_id, or both game_id and match_number"
        }
    
    query = "SELECT c.id, c.value, c.suite FROM card c"
    result = executeQuery(query)
    cardMap = {id: {"value": value, "suite": suite} for id, value, suite in result[0]}

    
    if match_id:
        query = """
        SELECT r.round_number, r.card1_id, r.card2_id, r.card3_id, r.pot_size
        FROM round r
        WHERE r.match_id = %s
        ORDER BY r.round_number ASC
        LIMIT %s OFFSET %s
        """
        args = (match_id, limit, offset)
        result = executeQuery(query, args)
    else:
        query = """
        SELECT r.round_number, r.card1_id, r.card2_id, r.card3_id, r.pot_size
        FROM round r
        INNER JOIN matches m ON m.id = r.match_id
        WHERE m.game_id = %s AND m.match_number = %s
        ORDER BY r.round_number ASC
        LIMIT %s OFFSET %s
        """
        args = (game_id, match_number, limit, offset)
        result = executeQuery(query, args)
    
    ret = [{
        "round_number": row[0],
        "community_cards": [
            {
                "id": row[1],
                "value": cardMap[row[1]]["value"] if row[1] else None,
                "suite": cardMap[row[1]]["suite"] if row[1] else None,
            },
            {
                "id": row[2],
                "value": cardMap[row[2]]["value"] if row[2] else None,
                "suite": cardMap[row[2]]["suite"] if row[2] else None,
            },
            {
                "id": row[3],
                "value": cardMap[row[3]]["value"] if row[3] else None,
                "suite": cardMap[row[3]]["suite"] if row[3] else None,
            },
        ],
        "pot_size": row[4]
    } for row in result[0]]

    return ret

# list all games in which the specified player played in
@app.route('/api/get_player_games', methods=['POST'])
@cross_origin()
def get_player_games():
    data = request.json
    player_id_str = data.get('player_id') 
    offset_str = data.get('offset', '0')  
    limit_str = data.get('limit', '10')  

    try:
        player_id = int(player_id_str)
        offset = int(offset_str)
        limit = int(limit_str)
    except (ValueError, TypeError):
        return jsonify({"error": "Invalid 'player_id', 'offset', or 'limit', must be integers"}), 400

    query = '''
        SELECT DISTINCT g.id AS game_id, g.date, gs.season_number, gt.in_tournament, gt.tournament_id
        FROM Game g
        JOIN Matches m ON g.id = m.game_id
        LEFT JOIN Hole_Cards hc ON m.id = hc.match_id
        JOIN Game_Season gs ON g.date = gs.date
        LEFT JOIN Game_Tournament gt ON g.date = gt.date
        WHERE hc.player_id = %s
        ORDER BY g.date ASC
        LIMIT %s OFFSET %s
    '''
    games, _ = executeQuery(query, (player_id, limit, offset))

    if isinstance(games, dict) and "error" in games:
        return jsonify(games), 500


    games_list = [{
        "game_id": game[0],
        "date": game[1],
        "season_number": game[2],
        "in_tournament": game[3],
        "tournament_id": game[4]
    } for game in games]

    return jsonify(games_list)


# ADMIN API
# MATTHEW DOES THIS
# =======================================================================================================
# =======================================================================================================

# Create new player
@app.route('/api/new_player', methods=['POST'])
@cross_origin()
def create_player():
    data = request.json
    name = data['name']
    home_country = data['home_country']
    region = data['region']
    net_winnings = data['net_winnings']

    query = "INSERT INTO player (name, net_winnings) VALUES (%s, %s)"
    args = (name, net_winnings)
    res = executeQuery(query, args)
    player_id = res[1]

    query = "INSERT INTO player_country (id, home_country) VALUES (%s, %s)"
    args = (player_id, home_country)
    executeQuery(query, args)

    query = "INSERT INTO player_region (id, region) VALUES (%s, %s)"
    args = (player_id, region)
    executeQuery(query, args)
    
    return {
        "player_id": player_id
    }

# delete player
@app.route('/api/delete_player', methods=['POST'])
@cross_origin()
def delete_player():
    data = request.json
    player_id = data['player_id']

    query = "DELETE FROM player WHERE id=%s"
    args = (player_id,)
    executeQuery(query, args)
    
    return {
        "player_id": player_id
    }

# edit the specified player info
@app.route('/api/edit_player', methods=['PUT'])
@cross_origin()
def edit_player():
    data = request.json
    player_id = data.get('player_id', None)
    name = data.get('name', None)
    home_country = data.get('home_country', None)
    region = data.get('region', None)
    net_winnings = data.get('net_winnings', None)
    
    if (name and net_winnings):
        query = "UPDATE player SET name=%s, net_winnings=%s WHERE id=%s"
        args = (name, net_winnings, player_id)
        executeQuery(query, args)
    elif (name and not net_winnings):
        query = "UPDATE player SET name=%s WHERE id=%s"
        args = (name, player_id)
        executeQuery(query, args)
    elif (not name and net_winnings):
        query = "UPDATE player SET net_winnings=%s WHERE id=%s"
        args = (net_winnings, player_id)
        executeQuery(query, args)
    
    if (home_country):
        query = "UPDATE player_country SET country=%s WHERE id=%s"
        args = (home_country, player_id)
        executeQuery(query, args)
    
    if (region):
        query = "UPDATE player_region SET region=%s WHERE id=%s"
        args = (region, player_id)
        executeQuery(query, args)
    
    return {
        "player_id": player_id
    }

# get a summary of players activity
@app.route('/api/players_summary', methods=['POST'])
@cross_origin()
def players_summary(player_id=0, start_date="", end_date=""):
    data = request.json
    player_id = data['player_id']
    start_date = data.get('start_date', '0001-01-01')
    end_date = data.get('end_date', '9999-12-30')

    # List of game_ids that this player played
    query = """
    SELECT
        game.id AS game_id,
        COUNT(action.id) AS 'n_of_actions',
        SUM(action.action_type = 'fold') AS 'n_of_folds',
        SUM(action.action_type = 'check') AS 'n_of_checks',
        SUM(action.action_type = 'call') AS 'n_of_call',
        SUM(action.action_type = 'raise') AS 'n_of_raises',
        AVG(CASE WHEN action.action_type = 'raise' THEN action.amount END) AS 'avg_raise_size'
    FROM game
    INNER JOIN matches ON game.id = matches.game_id
    INNER JOIN round ON round.match_id = matches.id
    INNER JOIN action ON action.round_id = round.id
    INNER JOIN buy_in_cash_out ON buy_in_cash_out.match_id = matches.id
    WHERE
        buy_in_cash_out.player_id = %s AND
        game.date >= %s AND
        game.date <= %s
    GROUP BY game.id;
    """
    args = (player_id, start_date, end_date)
    results = executeQuery(query, args)
    ret = [{
        "game_id": val[0],
        "n_of_actions": val[1],
        "n_of_folds": val[2],
        "n_of_checks": val[3],
        "n_of_calls": val[4],
        "n_of_raises": val[5],
        "avg_raise_size": val[6]
    } for val in results[0]]

    return ret

# get players that played in all specified games
@app.route('/api/get_players_in_games', methods=['POST'])
@cross_origin()
def get_players_in_games():
    data = request.json
    game_ids = data['game_ids']

    query = f"""
    SELECT DISTINCT p.id, p.name, pc.home_country, pr.poker_region, p.net_winnings
    FROM player p
    INNER JOIN player_country pc ON pc.id = p.id
    INNER JOIN player_region pr ON pc.home_country = pr.home_country
    WHERE NOT EXISTS (
        (
            SELECT game.id
            FROM game
            WHERE game.id IN ({', '.join(['%s'] * len(game_ids))})
        )
        EXCEPT
        (
            SELECT game.id
            FROM buy_in_cash_out bico
            INNER JOIN matches ON matches.id = bico.match_id
            INNER JOIN game ON matches.game_id = game.id
            WHERE bico.player_id = p.id AND
                game.id IN ({', '.join(['%s'] * len(game_ids))})
        )
    );
    """
    args = tuple([int(x) for x in game_ids * 2])
    result = executeQuery(query, args)
    ret = [{
        "player_id": row[0],
        "name": row[1],
        "home_country": row[2],
        "region": row[3],
        "net_winnings": row[4],
    } for row in result[0]]
    return ret

# get summary statistics for all games played in a season
@app.route('/api/season_summary', methods=['POST'])
@cross_origin()
def season_summary():
    data = request.json
    min_players = data.get('min_players', 0)
    min_games = data.get('min_games', 0)
    min_avg_pot_size = data.get('min_avg_pot_size', 0)
    min_max_pot_size = data.get('min_max_pot_size', 0)
    seasons = data.get('seasons', [])
    if not seasons or (len(seasons) == 1 and len(seasons[0]) == 0):
        seasons = []

    query = f"""
        SELECT
            gs.season_number AS season_number, 
            COUNT(g.id) AS n_games,
            AVG(r.pot_size) AS avg_pot_size,
            MAX(r.pot_size) AS max_pot_size
        FROM Game g
        INNER JOIN game_season gs ON g.date = gs.date
        INNER JOIN matches m ON m.game_id = g.id
        INNER JOIN round r ON r.match_id = m.id
        INNER JOIN buy_in_cash_out bico ON bico.match_id = m.id
        {"WHERE gs.season_number IN (%s)" if seasons else "WHERE gs.season_number NOT IN (%s)"}
        GROUP BY gs.season_number
        HAVING COUNT(bico.player_id) > %s AND
            COUNT(g.id) > %s AND
            AVG(r.pot_size) > %s AND
            MAX(r.pot_size) > %s
    """
    args = (', '.join(seasons), 
        min_players, 
        min_games, 
        min_avg_pot_size, 
        min_max_pot_size
    )
    result = executeQuery(query, args)
    ret = [{
        "season_number": row[0],
        "n_games": row[1],
        "players": [423, 432, 543, 654],
        "avg_pot_size": round(row[2], 2),
        "max_pot_size": round(row[3], 2),
    } for row in result[0]]
    return ret
