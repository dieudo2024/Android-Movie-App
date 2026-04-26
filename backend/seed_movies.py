import mysql.connector
from mysql.connector import Error
from app.db import connect
from app.config import DB_NAME

def seed_database():
    """
    Seeds the movie_db with an initial set of 35 movies.
    This fulfills the Deliverable #1 requirement of at least 20 items.
    """
    connection = None
    cursor = None

    # 1. Data formatted as a list of tuples for executemany
    # Structure: (title, category, director, year, rating, description, synopsis)
    movies_data = [
        ('The Chosen', 'Drama', 'Dallas Jenkins', 2017, 9.2, 
         'A multi-season series about the life of Jesus of Nazareth.', 
         'The life of Jesus Christ through the eyes of those who met him.'),
        
        ('Inception', 'Sci-Fi', 'Christopher Nolan', 2010, 8.8, 
         'A thief who steals corporate secrets through dream-sharing technology.', 
         'Dominic Cobb is a skilled thief in the art of extraction.'),
        
        ('The Shawshank Redemption', 'Drama', 'Frank Darabont', 1994, 9.3, 
         'Two imprisoned men bond over a number of years.', 
         'Andy Dufresne is sent to Shawshank Prison for a murder he did not commit.'),
        
        ('The Dark Knight', 'Action', 'Christopher Nolan', 2008, 9.0, 
         'When the Joker emerges, Batman must accept one of the greatest tests.', 
         'Batman raises the stakes in his war on crime.'),
        
        ('Pulp Fiction', 'Crime', 'Quentin Tarantino', 1994, 8.9, 
         'The lives of two mob hitmen, a boxer, and a gangster wife intertwine.', 
         'A series of incidents intertwines the lives of Los Angeles criminals.'),
        
        ('Forrest Gump', 'Drama', 'Robert Zemeckis', 1994, 8.8, 
         'The presidencies of Kennedy and Johnson seen through the eyes of a man.', 
         'A man with a low IQ has accomplished great things in his life.'),

        ('The Matrix', 'Sci-Fi', 'Lana Wachowski', 1999, 8.7, 
         'A computer hacker learns about the true nature of reality.', 
         'Neo discovers that the world is a simulated reality.'),

        ('Goodfellas', 'Biography', 'Martin Scorsese', 1990, 8.7, 
         'The story of Henry Hill and his life in the mob.', 
         'A young man grows up in the mob and works hard to advance.'),

        ('The Silence of the Lambs', 'Thriller', 'Jonathan Demme', 1991, 8.6, 
         'A young F.B.I. cadet must receive the help of an incarcerated cannibal.', 
         'Clarice Starling seeks the help of Dr. Hannibal Lecter.'),

        ('Saving Private Ryan', 'War', 'Steven Spielberg', 1998, 8.6, 
         'Following the Normandy Landings, a group of soldiers go behind enemy lines.', 
         'A group of U.S. soldiers go behind enemy lines to retrieve a paratrooper.'),

        ('Interstellar', 'Sci-Fi', 'Christopher Nolan', 2014, 8.6, 
         'A team of explorers travel through a wormhole in space.', 
         'A team of explorers travel through a wormhole to ensure humanity survival.'),

        ('Spirited Away', 'Animation', 'Hayao Miyazaki', 2001, 8.6, 
         'A young girl wanders into a world ruled by gods and spirits.', 
         'Chihiro enters a magical world where her parents are turned into pigs.'),

        ('The Green Mile', 'Crime', 'Frank Darabont', 1999, 8.6, 
         'The lives of guards on Death Row are affected by one of their charges.', 
         'Paul Edgecomb meets a prisoner with a mysterious gift.'),

        ('Parasite', 'Thriller', 'Bong Joon Ho', 2019, 8.6, 
         'Greed and class discrimination threaten a relationship.', 
         'A poor family schemes to become employed by a wealthy family.'),

        ('Gladiator', 'Action', 'Ridley Scott', 2000, 8.5, 
         'A former Roman General sets out to exact vengeance.', 
         'Maximus Decimus Meridius seeks revenge against the corrupt emperor.'),

        ('The Lion King', 'Animation', 'Roger Allers', 1994, 8.5, 
         'A Lion prince flees his kingdom only to learn responsibility.', 
         'Simba must take his place as king after his father is murdered.'),

        ('The Prestige', 'Mystery', 'Christopher Nolan', 2006, 8.5, 
         'Two stage magicians engage in a battle to create the ultimate illusion.', 
         'Two magicians in 1890s London compete for the ultimate trick.'),

        ('The Departed', 'Crime', 'Martin Scorsese', 2006, 8.5, 
         'An undercover cop and a mole in the police attempt to identify each other.', 
         'An undercover cop and a mole in the mob attempt to identify each other.'),

        ('Whiplash', 'Drama', 'Damien Chazelle', 2014, 8.5, 
         'A promising young drummer enrolls at a music conservatory.', 
         'Andrew Neiman is a jazz drummer pushed to the brink by his instructor.'),

        ('Alien', 'Horror', 'Ridley Scott', 1979, 8.5, 
         'A space merchant vessel receives an unknown transmission.', 
         'The crew of a spacecraft encounters a deadly extraterrestrial.'),

        ('Joker', 'Crime', 'Todd Phillips', 2019, 8.4, 
         'A mentally troubled comedian is disregarded by society.', 
         'Arthur Fleck becomes a criminal mastermind in Gotham City.'),

        ('The Shining', 'Horror', 'Stanley Kubrick', 1980, 8.4, 
         'A family heads to an isolated hotel for the winter.', 
         'Jack Torrance becomes the caretaker of an isolated hotel.'),

        ('Django Unchained', 'Western', 'Quentin Tarantino', 2012, 8.4, 
         'A freed slave sets out to rescue his wife with a bounty hunter.', 
         'Django travels across the South to free his wife from a plantation.'),

        ('Coco', 'Animation', 'Lee Unkrich', 2017, 8.4, 
         'Miguel faces his family ancestral ban on music.', 
         'A boy travels to the Land of the Dead to find his great-great-grandfather.'),

        ('WALL-E', 'Animation', 'Andrew Stanton', 2008, 8.4, 
         'A small waste-collecting robot embarks on a space journey.', 
         'A small robot in the future finds a new purpose in space.'),

        ('The Dark Knight Rises', 'Action', 'Christopher Nolan', 2012, 8.4, 
         'Batman is forced from his exile to save Gotham.', 
         'Eight years after the Joker, Batman returns to fight Bane.'),

        ('Spider-Man: Into the Spider-Verse', 'Animation', 'Bob Persichetti', 2018, 8.4, 
         'Teen Miles Morales becomes the Spider-Man of his universe.', 
         'Miles Morales teams up with other Spider-People from different dimensions.'),

        ('Avengers: Endgame', 'Action', 'Anthony Russo', 2019, 8.4, 
         'The Avengers assemble once more to restore order.', 
         'The Avengers take a final stand against Thanos.'),

        ('Oldboy', 'Action', 'Park Chan-wook', 2003, 8.4, 
         'A man is released after being imprisoned for fifteen years.', 
         'A man is kidnapped and imprisoned for 15 years for no reason.'),

        ('Braveheart', 'Biography', 'Mel Gibson', 1995, 8.3, 
         'William Wallace begins a revolt against King Edward I.', 
         'William Wallace leads the Scots in a war against the English.'),

        ('Toy Story', 'Animation', 'John Lasseter', 1995, 8.3, 
         'A cowboy doll is threatened when a new spaceman figure arrives.', 
         'Woody is a cowboy doll who becomes jealous of Buzz Lightyear.'),

        ('Inglourious Basterds', 'War', 'Quentin Tarantino', 2009, 8.3, 
         'A plan to assassinate Nazi leaders is hatched in occupied France.', 
         'A group of Jewish-American soldiers hunt Nazis in France.'),

        ('Good Will Hunting', 'Drama', 'Gus Van Sant', 1997, 8.3, 
         'A janitor at M.I.T. has a gift for mathematics.', 
         'A janitor at MIT is a genius who needs help from a therapist.'),

        ('Reservoir Dogs', 'Crime', 'Quentin Tarantino', 1992, 8.3, 
         'Surviving criminals suspect a police informant in their group.', 
         'Six criminals are hired to pull off a diamond heist.'),

        ('Up', 'Animation', 'Pete Docter', 2009, 8.3, 
         'A 78-year-old travels to Paradise Falls in a flying house.', 
         'Carl Fredricksen ties balloons to his house to fly to South America.'),

        ('Heat', 'Crime', 'Michael Mann', 1995, 8.3, 
         'A group of bank robbers start to feel the heat from police.', 
         'A professional bank robber is hunted by a detective.')
    ]

    # 2. Define the Query (Ensuring table name 'movies' matches SQL)
    query = """
    INSERT INTO movies (title, category, director, year, rating, description, synopsis)
    VALUES (%s, %s, %s, %s, %s, %s, %s)
    """

    try:
        connection = connect(database=DB_NAME)
        cursor = connection.cursor()
        
        # 3. Execute and Commit
        cursor.executemany(query, movies_data)
        connection.commit()
        
        print(f"Success: {cursor.rowcount} movies inserted into {DB_NAME}.")

    except Error as e:
        print(f"Error seeding database: {e}")
    
    finally:
        if cursor:
            cursor.close()
        if connection and connection.is_connected():
            connection.close()

if __name__ == "__main__":
    seed_database()