# This quick/dirty python program will play the original Prolog chess program against a player making
# random moves.

from pyswip import Prolog
import random
plfile = "examples/games/GreedyChessOriginalProlog.pl"
prolog = Prolog()
print(prolog.consult(plfile))
# tiny helper to run a Prolog goal and realize any side effects (writes/prints)
def p(goal: str):
    return list(prolog.query(goal))
# 1) start the game (initializes board and prints instructions/board)
p("chess")
total_moves = 0
game_over = False
while game_over == False:
    p("g.")
    total_moves = total_moves + 1
    Move = False
    while Move == False and game_over == False:
        x = random.randint(1, 8)
        y = random.randint(1,3)
        command = "m(" + str(x) + "," + str(y) + "," + str(random.randint(1, 8)) + "," + str(random.randint(1,8)) + ")."
        Move = bool(p(command))
        if Move:
            print("Random move " + command)
            total_moves = total_moves + 1
    #game_over = prolog.query("guimessage(checkmate, _, _).")
    game_over = bool(p("guimessage(checkmate, _, _)"))
print("Total Moves>" + str(total_moves))
