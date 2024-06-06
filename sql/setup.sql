CREATE DATABASE IF NOT EXISTS poker;
USE poker;


CREATE TABLE IF NOT EXISTS Card(
id INT UNIQUE AUTO_INCREMENT, 
value INT NOT NULL, 
suite CHAR(1) NOT NULL,
PRIMARY KEY (value, suite)
);

CREATE TABLE IF NOT EXISTS Game_Season(
	date DATE PRIMARY KEY,
	season_number INT
);

CREATE TABLE IF NOT EXISTS Game(
	id INT PRIMARY KEY AUTO_INCREMENT,
	date DATE, 
FOREIGN KEY (date) REFERENCES Game_season(date) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Game_Tournament(
	date DATE PRIMARY KEY,
in_tournament BOOLEAN,
tournament_id INT,
FOREIGN KEY (date) REFERENCES Game_season(date) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Matches(
	id INT UNIQUE AUTO_INCREMENT,
	match_number INT NOT NULL,
	game_id INT NOT NULL,
	PRIMARY KEY (match_number, game_id),
	FOREIGN KEY (game_id) REFERENCES Game(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Player_Region(
home_country VARCHAR(127) PRIMARY KEY,
poker_region VARCHAR(127)
);

CREATE TABLE IF NOT EXISTS Player(
	id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(255),
	net_winnings FLOAT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS Player_Country(
	id INT PRIMARY KEY AUTO_INCREMENT,
home_country VARCHAR(127),
FOREIGN KEY (id) REFERENCES Player(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Hole_Cards(
	id INT UNIQUE AUTO_INCREMENT,
	match_id INT,
	player_id INT,
	card1 INT NOT NULL,
	card2 INT NOT NULL,
	PRIMARY KEY (match_id, player_id),
	FOREIGN KEY (match_id) REFERENCES Matches(id) ON DELETE CASCADE,
	FOREIGN KEY (player_id) REFERENCES Player(id) ON DELETE RESTRICT,
	FOREIGN KEY (card1) REFERENCES Card(id) ON DELETE RESTRICT,
	FOREIGN KEY (card2) REFERENCES Card(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Round_Type(
	round_number INT PRIMARY KEY,
	round_type VARCHAR(31) NOT NULL
);

CREATE TABLE IF NOT EXISTS Round (
	id INT UNIQUE AUTO_INCREMENT,
	round_number INT NOT NULL,
	match_id INT NOT NULL,
pot_size FLOAT NOT NULL,
	card1_id INT,
	card2_id INT,
	card3_id INT,
	PRIMARY KEY (round_number, match_id),
FOREIGN KEY (round_number) REFERENCES Round_Type(round_number) ON DELETE RESTRICT,
	FOREIGN KEY (match_id) REFERENCES Matches(id) ON DELETE CASCADE,
	FOREIGN KEY (card1_id) REFERENCES Card(id) ON DELETE RESTRICT,
	FOREIGN KEY (card2_id) REFERENCES Card(id) ON DELETE RESTRICT,
	FOREIGN KEY (card3_id) REFERENCES Card(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Action(
id INT UNIQUE AUTO_INCREMENT,
	action_number INT,
	round_id INT NOT NULL,
	player_id INT NOT NULL,
	action_type VARCHAR(31) NOT NULL,
	amount FLOAT,
	ending_balance FLOAT NOT NULL,
	PRIMARY KEY (action_number, round_id, player_id),
	FOREIGN KEY (round_id) REFERENCES Round(id) ON DELETE CASCADE,
	FOREIGN KEY (player_id) REFERENCES Player(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Buy_in_cash_out(
	id INT UNIQUE AUTO_INCREMENT,
	action_type INT NOT NULL,
	amount FLOAT NOT NULL,
	match_id INT NOT NULL,
	player_id INT NOT NULL,
	PRIMARY KEY (match_id, player_id),
FOREIGN KEY (match_id) REFERENCES Matches(id) ON DELETE RESTRICT,
FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE RESTRICT
);

DELIMITER $$

CREATE TRIGGER trg_after_buyin_cashout
AFTER INSERT ON Buy_in_cash_out
FOR EACH ROW
BEGIN
    IF NEW.action_type = 1 THEN
        UPDATE Player
        SET net_winnings = net_winnings - NEW.amount
        WHERE id = NEW.player_id;
    ELSEIF NEW.action_type = 2 THEN
        UPDATE Player
        SET net_winnings = net_winnings + NEW.amount
        WHERE id = NEW.player_id;
    END IF;
END$$

DELIMITER ;