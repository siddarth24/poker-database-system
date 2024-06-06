-- This script will wipe and re-set up the poker database with sample date

-- First, wipe the database
-- ========================================================================================
-- ========================================================================================
USE poker;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE Card;
DROP TABLE Game_Season;
DROP TABLE Game;
DROP TABLE Game_Tournament;
DROP TABLE Matches;
DROP TABLE Player_Region;
DROP TABLE Player;
DROP TABLE Player_Country;
DROP TABLE Hole_Cards;
DROP TABLE Round_Type;
DROP TABLE Round;
DROP TABLE Action;
DROP TABLE Buy_in_cash_out;
SET FOREIGN_KEY_CHECKS = 1;



-- Then, create tables
-- ========================================================================================
-- ========================================================================================
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





-- Finally, insert sample data
-- ========================================================================================
-- ========================================================================================
-- #region Create cards
INSERT INTO Card (value, suite) VALUES
(1, 'D'),
(1, 'C'),
(1, 'H'),
(1, 'S'),
(2, 'D'),
(2, 'C'),
(2, 'H'),
(2, 'S'),
(3, 'D'),
(3, 'C'),
(3, 'H'),
(3, 'S'),
(4, 'D'),
(4, 'C'),
(4, 'H'),
(4, 'S'),
(5, 'D'),
(5, 'C'),
(5, 'H'),
(5, 'S'),
(6, 'D'),
(6, 'C'),
(6, 'H'),
(6, 'S'),
(7, 'D'),
(7, 'C'),
(7, 'H'),
(7, 'S'),
(8, 'D'),
(8, 'C'),
(8, 'H'),
(8, 'S'),
(9, 'D'),
(9, 'C'),
(9, 'H'),
(9, 'S'),
(10, 'D'),
(10, 'C'),
(10, 'H'),
(10, 'S'),
(11, 'D'),
(11, 'C'),
(11, 'H'),
(11, 'S'),
(12, 'D'),
(12, 'C'),
(12, 'H'),
(12, 'S'),
(13, 'D'),
(13, 'C'),
(13, 'H'),
(13, 'S');
-- #endregion

-- #region Create Games
INSERT INTO Game_Season (date, season_number) VALUES
('2023-01-01', 23),
('2023-02-02', 23),
('2023-03-03', 23),
('2023-04-04', 23),
('2023-05-05', 23),
('2023-06-06', 23),
('2023-07-07', 24),
('2023-08-08', 24);

INSERT INTO Game(date) VALUES
('2023-01-01'),
('2023-02-02'),
('2023-03-03'),
('2023-04-04'),
('2023-05-05'),
('2023-06-06'),
('2023-07-07'),
('2023-08-08');

INSERT INTO Game_Tournament(date, in_tournament, tournament_id) VALUES
('2023-01-01', true, 101),
('2023-02-02', false, null),
('2023-03-03', true, 103),
('2023-04-04', true, 104),
('2023-05-05', false, null),
('2023-06-06', true, 105),
('2023-07-07', false, null),
('2023-08-08', true, 106);

-- Inserts for Matches
INSERT INTO Matches (match_number, game_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2),
(5, 3),
(6, 3),
(7, 4),
(8, 4),
(9, 5),
(10, 5),
(11, 6),
(12, 6),
(13, 7),
(14, 7),
(15, 8),
(16, 8);

-- Inserts for Player_Region
INSERT INTO Player_Region (home_country, poker_region) VALUES
('USA', 'North America'),
('Canada', 'North America'),
('France', 'Europe'),
('Germany', 'Europe'),
('Brazil', 'South America'),
('Italy', 'Europe'),
('Spain', 'Europe'),
('Mexico', 'North America'),
('Japan', 'Asia'),
('Australia', 'Oceania');

-- Inserts for Player
INSERT INTO Player (name, net_winnings) VALUES
('John Doe', 0.00),
('Jane Smith', 0.00),
('Pierre Dupont', 0.00),
('Max Mustermann', 0.00),
('Ana Souza', 0.00),
('Giovanni Rossi', 0.00),
('Carlos Hernandez', 0.00),
('Takumi Tanaka', 0.00),
('Isabella Brown', 0.00),
('Alejandro Martinez', 0.00);

-- Inserts for Player_Country
INSERT INTO Player_Country (id, home_country) VALUES
(1, 'USA'),
(2, 'Canada'),
(3, 'France'),
(4, 'Germany'),
(5, 'Brazil'),
(6, 'Italy'),
(7, 'Spain'),
(8, 'Mexico'),
(9, 'Japan'),
(10, 'Australia');

-- Inserts for Hole_Cards
INSERT INTO Hole_Cards (match_id, player_id, card1, card2) VALUES
-- Match 1
(1, 1, 1, 14),
(1, 2, 28, 41),
(1, 3, 4, 17),
(1, 4, 31, 44),
(1, 5, 7, 20),

-- Match 2
(2, 6, 2, 15),
(2, 7, 29, 42),
(2, 8, 5, 18),
(2, 9, 32, 45),
(2, 10, 8, 21),

-- Match 3 
(3, 1, 3, 16),
(3, 2, 30, 43),
(3, 3, 6, 19),
(3, 4, 33, 46),
(3, 5, 9, 22),
(3, 6, 34, 47),

-- Match 4 
(4, 7, 10, 23),
(4, 8, 35, 48),
(4, 9, 12, 25),
(4, 10, 49, 2),
(4, 1, 13, 26),

-- Match 5
(5, 3, 1, 13),   
(5, 4, 2, 14),   
(5, 5, 3, 15),  
(5, 6, 4, 16),   
(5, 7, 5, 17),  

-- Match 6
(6, 8, 6, 18),  
(6, 9, 7, 19),   
(6, 10, 8, 20),  
(6, 1, 9, 21),   
(6, 2, 10, 22),

-- Match 7 
(7, 8, 23, 37),  
(7, 9, 24, 38),  
(7, 10, 25, 39), 
(7, 1, 26, 40),  
(7, 2, 27, 41), 

-- Match 8 
(8, 3, 28, 42),  
(8, 4, 29, 43),  
(8, 5, 30, 44),  
(8, 6, 31, 45), 
(8, 7, 32, 46),  
(8, 8, 33, 47),

-- Match 9 
(9, 9, 34, 48), 
(9, 10, 35, 49), 
(9, 1, 36, 50),  
(9, 2, 11, 25),  
(9, 3, 12, 26),

-- Match 10 
(10, 4, 13, 27), 
(10, 5, 14, 28), 
(10, 6, 15, 29), 
(10, 7, 16, 30), 
(10, 8, 17, 31), 
(10, 9, 18, 32),

-- Match 11
(11, 10, 19, 33),
(11, 1, 20, 34),  
(11, 2, 21, 35),  
(11, 3, 22, 36),  
(11, 4, 23, 37),

-- Match 12 
(12, 5, 24, 38), 
(12, 6, 25, 39),  
(12, 7, 26, 40), 
(12, 8, 27, 41),  
(12, 9, 28, 42),  
(12, 10, 29, 43),

-- Match 13 
(13, 1, 30, 44),  
(13, 2, 31, 45), 
(13, 3, 32, 46),  
(13, 4, 33, 47),
(13, 5, 34, 48),

-- Match 14 
(14, 6, 35, 49),  
(14, 7, 36, 50), 
(14, 8, 37, 51),  
(14, 9, 38, 52),  
(14, 10, 1, 14), 
(14, 1, 2, 15),

-- Match 15 
(15, 2, 3, 16),
(15, 3, 4, 17),   
(15, 4, 5, 18), 
(15, 5, 6, 19),   
(15, 6, 7, 20),

-- Match 16 
(16, 7, 8, 21),   
(16, 8, 9, 22),   
(16, 9, 10, 23), 
(16, 10, 11, 24), 
(16, 1, 12, 25),  
(16, 2, 13, 26);  

-- Inserts for Round_Type
INSERT INTO Round_Type (round_number, round_type) VALUES
(1, 'Pre-flop'),
(2, 'Flop'),
(3, 'Turn'),
(4, 'River');

-- Inserts for Rounds
INSERT INTO Round (round_number, match_id, pot_size, card1_id, card2_id, card3_id) VALUES
-- Match 1 Rounds
(1, 1, 300.00, 12, 7, 33), (2, 1, 600.00, 21, 1, 52), (3, 1, 900.00, 45, 11, 23), 

-- Match 2 Rounds
(1, 2, 200.00, 3, 28, 17), (2, 2, 400.00, 19, 20, 6), (3, 2, 600.00, 9, 15, 31), (4, 2, 800.00, 42, 37, 5),

-- Match 3 Rounds
(1, 3, 500.00, 8, 46, 29), (2, 3, 900.00, 10, 48, 2), (3, 3, 1300.00, 24, 35, 50), (4, 3, 1700.00, 14, 22, 41),

-- Match 4 Rounds
(1, 4, 350.00, 18, 4, 34), (2, 4, 650.00, 26, 38, 13), (3, 4, 950.00, 47, 30, 44),

-- Match 5 Rounds
(1, 5, 250.00, 17, 34, 39), (2, 5, 450.00, 28, 14, 35), (3, 5, 650.00, 49, 47, 45), (4, 5, 850.00, 13, 46, 20),

-- Match 6 Rounds
(1, 6, 550.00, 26, 43, 42), (2, 6, 850.00, 24, 29, 34), (3, 6, 1150.00, 29, 8, 16), (4, 6, 1450.00, 15, 5, 22),

-- Match 7 Rounds
(1, 7, 300.00, 2, 38, 36), (2, 7, 600.00, 15, 38, 1), (3, 7, 900.00, 5, 46, 41), (4, 7, 1200.00, 4, 15, 5),

-- Match 8 Rounds
(1, 8, 400.00, 3, 22, 5), (2, 8, 700.00, 33, 16, 18), (3, 8, 1000.00, 43, 32, 14), (4, 8, 1300.00, 35, 9, 47),

-- Match 9 Rounds
(1, 9, 500.00, 37, 31, 16), (2, 9, 800.00, 51, 31, 52), (3, 9, 1100.00, 27, 13, 7), (4, 9, 1400.00, 7, 43, 28),

-- Match 10 Rounds
(1, 10, 350.00, 23, 28, 27), (2, 10, 650.00, 30, 47, 4), (3, 10, 950.00, 44, 42, 7), (4, 10, 1250.00, 4, 26, 47),

-- Match 11 Rounds
(1, 11, 450.00, 22, 52, 7), (2, 11, 750.00, 16, 13, 35), (3, 11, 1050.00, 29, 9, 28), (4, 11, 1350.00, 12, 18, 30),

-- Match 12 Rounds
(1, 12, 300.00, 16, 5, 29), (2, 12, 600.00, 52, 36, 7), (3, 12, 900.00, 4, 42, 35), (4, 12, 1200.00, 1, 6, 49),

-- Match 13 Rounds
(1, 13, 500.00, 16, 11, 27), (2, 13, 850.00, 32, 31, 14), (3, 13, 1200.00, 26, 4, 11), (4, 13, 1550.00, 25, 1, 17),

-- Match 14 Rounds
(1, 14, 350.00, 51, 30, 19), (2, 14, 650.00, 28, 45, 47), (3, 14, 950.00, 51, 36, 43), (4, 14, 1250.00, 46, 32, 10),

-- Match 15 Rounds
(1, 15, 250.00, 13, 19, 14), (2, 15, 550.00, 4, 38, 48), (3, 15, 850.00, 35, 4, 48), (4, 15, 1150.00, 21, 4, 38),

-- Match 16 Rounds
(1, 16, 450.00, 31, 33, 34), (2, 16, 750.00, 11, 4, 33), (3, 16, 1050.00, 6, 12, 5), (4, 16, 1350.00, 39, 5, 44);

-- Inserts for Actions
INSERT INTO Action (action_number, round_id, player_id, action_type, amount, ending_balance) VALUES
-- Match 1
-- Pre-flop
(1, 1, 1, 'Call', 50, 450),  
(2, 1, 2, 'Raise', 100, 900), 
(3, 1, 3, 'Fold', 0, 1500), 
(4, 1, 4, 'Call', 100, 600),  
(5, 1, 5, 'Call', 100, 400),  
-- Flop
(1, 2, 1, 'Check', 0, 450), 
(2, 2, 2, 'Bet', 200, 700),  
(3, 2, 4, 'Fold', 0, 600),  
(4, 2, 5, 'Call', 200, 200),  
-- Turn
(1, 3, 1, 'Check', 0, 450),  
(2, 3, 2, 'Bet', 300, 400), 
(3, 3, 5, 'Fold', 0, 200),  

-- Match 2
-- Pre-flop
(1, 4, 6, 'Raise', 100, 900),  
(2, 4, 7, 'Call', 100, 900),  
(3, 4, 8, 'Fold', 0, 1000),  
(4, 4, 9, 'Call', 100, 900),  
(5, 4, 10, 'Call', 100, 900),  
-- Flop
(1, 5, 6, 'Check', 0, 900),  
(2, 5, 7, 'Bet', 200, 700),  
(3, 5, 9, 'Call', 200, 700), 
(4, 5, 10, 'Fold', 0, 900),  
-- Turn
(1, 6, 6, 'Check', 0, 900),  
(2, 6, 7, 'Check', 0, 700),  
(3, 6, 9, 'Check', 0, 700),  
-- River
(1, 7, 6, 'Bet', 300, 600),  
(2, 7, 7, 'Fold', 0, 700),  
(3, 7, 9, 'Call', 300, 400),  

-- Match 3
-- Pre-flop
(1, 8, 1, 'Call', 50, 450), 
(2, 8, 2, 'Raise', 150, 850), 
(3, 8, 3, 'Call', 150, 850),  
(4, 8, 4, 'Fold', 0, 1000),   
(5, 8, 5, 'Call', 150, 350), 
(6, 8, 6, 'Fold', 0, 1000),  
-- Flop
(1, 9, 1, 'Check', 0, 450),  
(2, 9, 2, 'Bet', 200, 650),  
(3, 9, 3, 'Fold', 0, 850),   
(4, 9, 5, 'Call', 200, 150),
-- Turn
(1, 10, 1, 'Bet', 150, 300), 
(2, 10, 2, 'Call', 150, 500),  
(3, 10, 5, 'Fold', 0, 150),  
-- River
(1, 11, 1, 'Check', 0, 300),  
(2, 11, 2, 'Check', 0, 500), 

-- Match 4
-- Pre-flop
(1, 12, 7, 'Raise', 100, 900), 
(2, 12, 8, 'Call', 100, 900),  
(3, 12, 9, 'Fold', 0, 1000),  
(4, 12, 10, 'Call', 100, 900), 
(5, 12, 1, 'Call', 100, 400),  
-- Flop
(1, 13, 7, 'Check', 0, 900),   
(2, 13, 8, 'Bet', 200, 700),   
(3, 13, 10, 'Fold', 0, 900),   
(4, 13, 1, 'Call', 200, 200),  
-- Turn
(1, 14, 7, 'Bet', 300, 600),   
(2, 14, 8, 'Fold', 0, 700),

-- Match 5
-- Pre-flop
(1, 15, 3, 'Raise', 100, 400),
(2, 15, 4, 'Call', 100, 400),
(3, 15, 5, 'Fold', 0, 1500),
(4, 15, 6, 'Call', 100, 400),
(5, 15, 7, 'Call', 100, 400),
-- Flop
(1, 16, 3, 'Bet', 200, 200),
(2, 16, 4, 'Fold', 0, 400),
(3, 16, 6, 'Call', 200, 200),
(4, 16, 7, 'Call', 200, 200),
-- Turn
(1, 17, 3, 'Check', 0, 200),
(2, 17, 6, 'Check', 0, 200),
(3, 17, 7, 'Bet', 100, 100),
(4, 17, 3, 'Fold', 0, 200),
(5, 17, 6, 'Call', 100, 100),
-- River
(1, 18, 6, 'Check', 0, 100),
(2, 18, 7, 'Check', 0, 100),

-- Match 6
-- Pre-flop
(1, 19, 8, 'Call', 50, 950),
(2, 19, 9, 'Raise', 150, 850),
(3, 19, 10, 'Call', 150, 850),
(4, 19, 1, 'Fold', 0, 450),
(5, 19, 2, 'Call', 150, 850),
-- Flop
(1, 20, 8, 'Check', 0, 950),
(2, 20, 9, 'Bet', 200, 650),
(3, 20, 10, 'Call', 200, 650),
(4, 20, 2, 'Fold', 0, 850),
-- Turn
(1, 21, 8, 'Fold', 0, 950),
(2, 21, 9, 'Bet', 300, 350),
(3, 21, 10, 'Call', 300, 350),
-- River
(1, 22, 9, 'Check', 0, 350),
(2, 22, 10, 'Bet', 350, 0),
(3, 22, 9, 'Call', 350, 0),

-- Match 7
-- Pre-flop
(1, 23, 8, 'Call', 50, 950),
(2, 23, 9, 'Raise', 100, 900),
(3, 23, 10, 'Call', 100, 900),
(4, 23, 1, 'Fold', 0, 1000),
(5, 23, 2, 'Call', 100, 900),
-- Flop
(1, 24, 8, 'Check', 0, 950),
(2, 24, 9, 'Bet', 150, 750),
(3, 24, 10, 'Fold', 0, 900),
(4, 24, 2, 'Call', 150, 750),
-- Turn
(1, 25, 8, 'Check', 0, 950),
(2, 25, 9, 'Check', 0, 750),
-- River
(1, 26, 8, 'Bet', 200, 750),
(2, 26, 9, 'Fold', 0, 750),

-- Match 8
-- Pre-flop
(1, 27, 3, 'Raise', 100, 900),
(2, 27, 4, 'Call', 100, 900),
(3, 27, 5, 'Fold', 0, 1000),
(4, 27, 6, 'Call', 100, 900),
(5, 27, 7, 'Call', 100, 900),
(6, 27, 8, 'Call', 100, 900),
-- Flop
(1, 28, 3, 'Bet', 150, 750),
(2, 28, 4, 'Fold', 0, 900),
(3, 28, 6, 'Call', 150, 750),
(4, 28, 7, 'Fold', 0, 900),
(5, 28, 8, 'Call', 150, 750),
-- Turn
(1, 29, 3, 'Check', 0, 750),
(2, 29, 6, 'Bet', 200, 550),
(3, 29, 8, 'Call', 200, 550),
-- River
(1, 30, 3, 'Fold', 0, 750),
(2, 30, 6, 'Bet', 250, 300),
(3, 30, 8, 'Call', 250, 300),

-- Match 9
-- Pre-flop
(1, 31, 9, 'Call', 50, 950),
(2, 31, 10, 'Raise', 150, 850),
(3, 31, 1, 'Call', 150, 850),
(4, 31, 2, 'Fold', 0, 1000),
(5, 31, 3, 'Call', 150, 850),
-- Flop
(1, 32, 9, 'Check', 0, 950),
(2, 32, 10, 'Bet', 200, 650),
(3, 32, 1, 'Call', 200, 650),
(4, 32, 3, 'Fold', 0, 850),
-- Turn
(1, 33, 9, 'Check', 0, 950),
(2, 33, 10, 'Bet', 300, 350),
(3, 33, 1, 'Call', 300, 350),
-- River
(1, 34, 9, 'Fold', 0, 950),
(2, 34, 10, 'Check', 0, 350),

-- Match 10
-- Pre-flop
(1, 35, 4, 'Raise', 100, 900),
(2, 35, 5, 'Call', 100, 900),
(3, 35, 6, 'Call', 100, 900),
(4, 35, 7, 'Fold', 0, 1000),
(5, 35, 8, 'Call', 100, 900),
(6, 35, 9, 'Call', 100, 900),
-- Flop
(1, 36, 4, 'Bet', 200, 700),
(2, 36, 5, 'Fold', 0, 900),
(3, 36, 6, 'Call', 200, 700),
(4, 36, 8, 'Fold', 0, 900),
(5, 36, 9, 'Call', 200, 700),
-- Turn
(1, 37, 4, 'Check', 0, 700),
(2, 37, 6, 'Check', 0, 700),
(3, 37, 9, 'Bet', 300, 400),
(4, 37, 4, 'Call', 300, 400),
(5, 37, 6, 'Fold', 0, 700),
-- River
(1, 38, 4, 'Check', 0, 400),
(2, 38, 9, 'Check', 0, 400),

-- Match 11
-- Pre-flop
(1, 39, 10, 'Call', 50, 950),
(2, 39, 1, 'Raise', 100, 900),
(3, 39, 2, 'Call', 100, 900),
(4, 39, 3, 'Fold', 0, 1000),
(5, 39, 4, 'Call', 100, 900),
-- Flop
(1, 40, 10, 'Check', 0, 950),
(2, 40, 1, 'Bet', 150, 750),
(3, 40, 2, 'Call', 150, 750),
(4, 40, 4, 'Fold', 0, 900),
-- Turn
(1, 41, 10, 'Fold', 0, 950),
(2, 41, 1, 'Bet', 200, 550),
(3, 41, 2, 'Call', 200, 550),
-- River
(1, 42, 1, 'Check', 0, 550),
(2, 42, 2, 'Bet', 250, 300),
(3, 42, 1, 'Call', 250, 300),

-- Match 12
-- Pre-flop
(1, 43, 5, 'Raise', 100, 900),
(2, 43, 6, 'Call', 100, 900),
(3, 43, 7, 'Call', 100, 900),
(4, 43, 8, 'Fold', 0, 1000),
(5, 43, 9, 'Call', 100, 900),
-- Flop
(1, 44, 5, 'Check', 0, 900),
(2, 44, 6, 'Bet', 150, 750),
(3, 44, 7, 'Call', 150, 750),
(4, 44, 9, 'Fold', 0, 900),
-- Turn
(1, 45, 5, 'Fold', 0, 900),
(2, 45, 6, 'Check', 0, 750),
(3, 45, 7, 'Bet', 200, 550),
(4, 45, 6, 'Call', 200, 550),
-- River
(1, 46, 6, 'Bet', 300, 250),
(2, 46, 7, 'Call', 300, 250),

-- Match 13
-- Pre-flop
-- Pre-flop
(1, 47, 8, 'Call', 50, 950),
(2, 47, 9, 'Raise', 150, 850),
(3, 47, 10, 'Fold', 0, 1000),
(4, 47, 1, 'Call', 150, 850),
(5, 47, 2, 'Call', 150, 850),
(6, 47, 3, 'Call', 150, 850),
-- Flop
(1, 48, 8, 'Check', 0, 950),
(2, 48, 9, 'Bet', 200, 650),
(3, 48, 1, 'Fold', 0, 850),
(4, 48, 2, 'Call', 200, 650),
(5, 48, 3, 'Call', 200, 650),
-- Turn
(1, 49, 8, 'Fold', 0, 950),
(2, 49, 9, 'Check', 0, 650),
(3, 49, 2, 'Bet', 250, 400),
(4, 49, 3, 'Fold', 0, 650),
-- River
(1, 50, 9, 'Call', 250, 400),
(2, 50, 2, 'Check', 0, 400),

-- Match 14
-- Pre-flop
(1, 51, 4, 'Raise', 100, 900),
(2, 51, 5, 'Call', 100, 900),
(3, 51, 6, 'Fold', 0, 1000),
(4, 51, 7, 'Call', 100, 900),
(5, 51, 8, 'Call', 100, 900),
-- Flop
(1, 52, 4, 'Bet', 200, 700),
(2, 52, 5, 'Fold', 0, 900),
(3, 52, 7, 'Call', 200, 700),
(4, 52, 8, 'Fold', 0, 900),
-- Turn
(1, 53, 4, 'Check', 0, 700),
(2, 53, 7, 'Bet', 300, 400),
(3, 53, 4, 'Call', 300, 400),
-- River
(1, 54, 4, 'Check', 0, 400),
(2, 54, 7, 'Check', 0, 400),

-- Match 15
-- Pre-flop
(1, 55, 9, 'Call', 50, 950),
(2, 55, 10, 'Raise', 150, 850),
(3, 55, 1, 'Call', 150, 850),
(4, 55, 2, 'Fold', 0, 1000),
(5, 55, 3, 'Call', 150, 850),
-- Flop
(1, 56, 9, 'Check', 0, 950),
(2, 56, 10, 'Bet', 200, 650),
(3, 56, 1, 'Fold', 0, 850),
(4, 56, 3, 'Call', 200, 650),
-- Turn
(1, 57, 9, 'Check', 0, 950),
(2, 57, 10, 'Bet', 250, 400),
(3, 57, 3, 'Call', 250, 400),
-- River
(1, 58, 9, 'Fold', 0, 950),
(2, 58, 10, 'Check', 0, 400),

-- Match 16
-- Pre-flop
(1, 59, 4, 'Raise', 100, 900),
(2, 59, 5, 'Call', 100, 900),
(3, 59, 6, 'Call', 100, 900),
(4, 59, 7, 'Call', 100, 900),
(5, 59, 8, 'Fold', 0, 1000),
(6, 59, 9, 'Call', 100, 900),
-- Flop
(1, 60, 4, 'Bet', 200, 700),
(2, 60, 5, 'Fold', 0, 900),
(3, 60, 6, 'Call', 200, 700),
(4, 60, 7, 'Fold', 0, 900),
(5, 60, 9, 'Call', 200, 700),
-- Turn
(1, 61, 4, 'Check', 0, 700),
(2, 61, 6, 'Bet', 300, 400),
(3, 61, 9, 'Fold', 0, 700),
(4, 61, 4, 'Call', 300, 400),
-- River
(1, 62, 4, 'Bet', 400, 0),
(2, 62, 6, 'Call', 400, 0);

-- Inserts for Buy_in_cash_out
INSERT INTO Buy_in_cash_out (action_type, amount, match_id, player_id) VALUES
-- Match 1 Buy-ins
(1, 1000, 1, 1),
(1, 1000, 1, 2),
(1, 1000, 1, 3),
(1, 1000, 1, 4),
(1, 1000, 1, 5),

-- Match 2 Buy-ins
(1, 1000, 2, 6),
(1, 1000, 2, 7),
(1, 1000, 2, 8),
(1, 1000, 2, 9),
(1, 1000, 2, 10),

-- Cash-outs #1
(2, 1600, 3, 1),
(2, 700, 3, 2),
(2, 850, 3, 3),
(2, 1300, 3, 4),
(2, 800, 3, 5),
(2, 750, 3, 6),

-- Cash-outs #2
(2, 500, 4, 7),
(2, 1500, 4, 8),
(2, 950, 4, 9),
(2, 1000, 4, 10),
(2, 50, 4, 1);
