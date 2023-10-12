# OS3ILV WS23/24 Assignment
This repository hosts the description of the assignment for OS3ILV WS23/24


## Goal of the Assignment

Practice **Process Management** by creating a simple multi-process program in C in which each process performs a specific task.

You must implement process creation, scheduling, synchronization, and termination mechanisms to solve the assignment.

## High-level Description of the Assignment

Your task is to implement a Multi-player Rock Paper Scissors platform.

The platform consists of:

- A central "server", i.e., a daemon process or service, that runs in the background. It receives commands for creating new games, joining new games, making moves, creating reports, maintaining the leaderboard, etc., and executes them.
- A client component, i.e., a process, that communicates to the server and allows users to play (multiple) games at the same time and check the leaderboard.

    > Note: It should be possible to start multiple concurrent instances of the client components on the same machine!

### The Gameplay

There are a few different ways to approach the rock-paper-scissors game with multiple players. 

Informally, our approach works like this:

- Start a game by specifying how many players will play (N) and how many rounds (R) make up the game (the number of points that a player can accumulate is defined by the number of rounds).
- The game can start after N players join the game on the RPS platform.
- At each round, players submit their hand gesture (rock, paper, or scissors)
- When all the players submit their hand gestures, the system computes the points: Players get points when their hand gesture wins over other players.
- The game proceeds in rounds until all the rounds are played. The player or players with the highest number of points win the game.
- After the game ends, a game report is generated, and the leaderboard is updated (overall score, played matches, and matches won).

> Note: Clients cannot leave a game; all the games must be played until the last round.

### The User Interface

The User Interface of the assignment is purely text-based. The following examples illustrate how the server and clients are supposed to be started, and how they should react to the various commands and signals.

> Note: You must implement your code to respond to those commands

#### The Server

Starting the server requires to invoke the executable `main` with the flag ``--server`` (or `-s`):

```
main --server
```

or

```
main -s
```

Once the server starts, it outputs standard and error messages directly to the console.

> Note: use the `getopt` function to parse command line arguments (see [https://www.gnu.org/software/libc/manual/html_node/Example-of-Getopt.html](https://www.gnu.org/software/libc/manual/html_node/Example-of-Getopt.html) or [https://www.geeksforgeeks.org/getopt-function-in-c-to-parse-command-line-arguments/](https://www.geeksforgeeks.org/getopt-function-in-c-to-parse-command-line-arguments/))

The server can be killed by pressing `ctrl-d` or sending the `SIGTERM` signal using [https://www.commandlinux.com/man-page/man1/kill.1.html](kill).

> Note: Your code must be able to correctly handle the `SIGTERM` signal and notify all the connected clients that it is going to shut down. Consequently, all the clients must start their shutdown procedure.

#### The Client

Starting the client is as simple as invoking the executable `main` with the option ``--client`` (or `-c`) passing as input the `mandatory` ID of the client (`<CLIENT_ID>`). The ID of the client is a 5-char string containing only numbers and letters (no special symbols, no Greek letters, etc.)

> Note: different clients cannot have the same <CLIENT_ID> (at the same time). In case of errors, like missing or wrong input, the `main` must return a positive value.

```
main --client <CLIENT_ID>
```

or

```
main -c <CLIENT_ID>
```

After the client starts, it shows the following main menu:

```
1 - Create a new game
2 - Current games
3 - Waiting room
4 - Show leaderboard

q - Quit
```

##### Create a new game

Pressing `1` from the main menu will produce the following output:

```
2:5 - How many players will play the game? min: 2 - max: 5

b - Back
```

Pressing `b` takes the player back to the main menu, whereas pressing any number between `2` and `5` will take the player to the next question:

```
3:5 - How many rounds will the game have? min: 3 - max: 5

b - Back
```

Pressing `b` takes the player back to the previous question, whereas pressing any number between `3` and `5` will set up the game, i.e., the game becomes visible in the waiting room.

> Note: Players do not automatically join the games they create!

##### Current games

Players can play more than one game simultaneously; thus, they must specify which game they want to play before making a move.

Pressing `2` from the main menu will show all the current games the player can play:

```
Here's the list of games you can play:

1 - Game #1
2 - Game #4
3 - Game #10

b - Back
```

In case there are no games to play, the message is:

```
Here's the list of games you can play:

Sorry. There are no games you can play

b - Back
```

Pressing `b` takes the player back to the main menu, whereas pressing any of the listed numbers will let the player submit moves into the corresponding game.
During the gameplay, the system shows the game metadata (ID and rounds), the moves done so far by each player, and the points accumulated by each player as follows:

```
Game #1 - Next Round 3/4

------------------------------------
| Round | foooo | bar | baz | pino |
------------------------------------
|     1 |     r |   s |   p |    p |
------------------------------------
|     2 |     r |   r |   r |    p |
------------------------------------

------------------------------------
|  Pts  |     1 |   2 |   1 |    4 |
------------------------------------

p - Choose "Paper"
r - Choose "Rock"
s - Choose "Scissor"

b - Back

```

> Notes:
> 
>   - The order in which the players are reported is the order in which they joined the game.
>   - Numbers and gestures/moves (`r`, `p`, `s`) are aligned on the RIGHT (there's a white space before the column separator `|`.
>   - The column width is defined by the username of the player.
>   - There's an empty line (`\n`) before and after the banners showing the points.

Pressing `b` takes the player back to the list of active games, whereas pressing `p`/`r`/`s` will submit the move for the current round.
If the player has already submitted a move for this game, s/he must wait for the other players to submit their moves. 
In this case, the system shows a different message:

```
Game #1 - Next Round 3/4

------------------------------------
| Round | foooo | bar | baz | pino |
------------------------------------
|     1 |     r |   s |   p |    p |
------------------------------------
|     2 |     r |   r |   r |    p |
------------------------------------

------------------------------------
|  Pts  |     1 |   2 |   1 |    4 |
------------------------------------

>>> You have chosen paper <<<

r - Refresh
b - Back
```

When all the players submit their moves, the game moves on, but the player does not automatically see any update until s/he refreshes the screen by pressing `r`.
The refresh command reloads the current page.

> Note: The refresh command is enabled only when the player submits the move. 


```
Game #1 - Next Round 4/4

------------------------------------
| Round | foooo | bar | baz | pino |
------------------------------------
|     1 |     r |   s |   p |    p |
------------------------------------
|     2 |     r |   r |   r |    p |
------------------------------------
|     3 |     p |   p |   p |    p |
------------------------------------

------------------------------------
|  Pts  |     1 |   2 |   1 |    4 |
------------------------------------

p - Choose "Paper"
r - Choose "Rock"
s - Choose "Scissor"

b - Back
```

When the game ends, the system shows a game report with all the moves, the points, and the winners.

```
Game #1 - Finished

------------------------------------
| Round | foooo | bar | baz | pino |
------------------------------------
|     1 |     r |   s |   p |    p |
------------------------------------
|     2 |     r |   r |   r |    p |
------------------------------------
|     3 |     p |   p |   p |    p |
------------------------------------
|     4 |     p |   p |   s |    p |
------------------------------------

------------------------------------
|  Pts  |     1 |   2 |   4 |    4 |
------------------------------------

>>> Game over! Winner(s): baz, pino <<<

b - Back
```

> Note: The list of winners follows the same order as the table header. After pressing `b`, the user will not be allowed anymore to see the finished game.

##### Waiting room

Players can play a game only after joining it; the waiting room lists all the games that the player can join. That is, all the active games that are waiting for players, but the current player has not (yet) joined.

Pressing `3` from the main menu will show all the waiting games:

```
Here's the list of games you can join:

1 - Game #3
2 - Game #5
3 - Game #6

b - Back
```

In case there are no waiting games, the message is:

```
Here's the list of games you can join:

Sorry. There are no games you can join

b - Back
```

Pressing `b` takes the player back to the main menu, whereas pressing any of the listed numbers will let the player join the corresponding game.
Assuming that the player presses `1`, the system will refresh the list of waiting games and show a confirmation message as follows:

```
Here's the list of games you can join:

1 - Game #5
2 - Game #6

>>> You joined Game #3 <<<

b - Back
```

Because many players are concurrently joining games, it might happen that the player tries to join a game that is not available anymore. In this case, 
the system refreshes the list of waiting games and shows an error message:
For instance, if the player presses `2` to join Game #6, but Game #6 is not available anymore the system could show the following output:

```
Here's the list of games you can join:

1 - Game #5

>>> You cannot join Game #6 <<<

b - Back
```

##### Show leaderboard

During the gameplay, the server records the history of each game. 

Pressing `4` from the main menu will show the leaderboard. 
The leaderboard reports the overall points accumulated by the top 3 players
and the number of matches they have played so far.

Players are ranked by the overall score, and, in case of a tie, they are ranked by ID.
We use the ASCII code of the characters forming the client ID to sort them.

> Note: if the ranking of the current player is below 3, the leaderboard
reports an additional row at the bottom, showing the player's info.

For instance, if the current player has id `boo` and is ranked 10, the leaderboard
will look like this:

```
----------------------------------
| Rank | Player | Score | Matches |
----------------------------------
|    1 |   pino |   100 |      10 |
-----------------------------------
|    2 |    foo |    90 |      10 |
-----------------------------------
|    3 |    bar |    80 |       8 |
-----------------------------------
-----------------------------------
|*  10 |    boo |    10 |       8 |
-----------------------------------
```

Instead, if the current player has id `pino` (which is ranked 1st),
the leaderboard will look like this:

```
----------------------------------
| Rank | Player | Score | Matches |
----------------------------------
|*   1 |   pino |   100 |      10 |
-----------------------------------
|    2 |    foo |    90 |      10 |
-----------------------------------
|    3 |    bar |    80 |       8 |
-----------------------------------
```

> Note: an `*` on the left side of the first column (no space before it!) indicates the row corresponding to the current player.

##### Quitting the client

Pressing `q` from the main menu causes the client to quit.
Upon quitting, the client must output the following message and return the value `0`, indicating that the client decides to quit.

```
Quitting!
```

> Note: if the server quits, all the clients must also automatically quit.
> In this case, the quitting message is the same, but the return value is different (a positive value)
>  indicating that something unexpected happened.



## Potential (Abstract) Test Cases

You should write unit and system tests. A potential system test case look like this:

- Start the central "server" 
- Pretend to or actually create some clients
- One client creates a game
- Many clients join the game
- Client concurrently plays the game by sending some commands

While the test is running, the output of all the clients and the central "server" should be collected and stored to check the conformance of their behaviors

# Dependencies and Requirements

The assignment requires you to develop C code. The best way to approach this is to use a Linux or a Mac OS distribution, that comes already equipped with `gcc` (to compile C) and `make` (to automate the building of the project).

In case you work in Windows, you can choose one of the following options:

1. VM. Install a system-level virtualization system (VirtualBox, Parallels, VMWare, etc.) and create a Linux VM. Connect to the VM and work on it.
2. Container. Install docker and create a Linux docker image. As usual, you can mount your disk into the running docker instance and write the code using your IDE. But you must execute `make` from within the running docker instance (for example, using `docker exec`).
3. WSL. Install Windows Subsystem for Linux (WSL) and write the code using your IDE as usual. But you must execute `make` from within the running WSL. According to [this article](https://code.visualstudio.com/docs/remote/wsl), you can configure VisualStudio to run commands directly via WSL.

## External Libraries
The project should not rely on any external library besides those used for testing and code coverage.

For testing, you'll use the [Unity framework](http://www.throwtheswitch.org/unity), and for coverage, you'll use (standard) `gcov`.
Both those dependencies should be already handled by the given assignment (typing `make reps` should install them).

# Additional reading

If you are not familiar with developing and testing C programs, you can google for any basic tutorial about it and start practicing **NOW**!

> Note: You can suggest any tutorial you have found useful to the lecturer or post it to MSTeams so it can be included here.

## C Programming
Here are some refs about C programming:

- [https://www.w3schools.com/c/](https://www.w3schools.com/c/)

## Make
Here are some refs about `make`:

- [https://makefiletutorial.com/](https://makefiletutorial.com/)

## Unit testing and coverage
Here are some refs about testing and computing coverage of C programs:

- [https://moderncprogramming.com/what-is-the-best-unit-testing-framework-in-c-for-you/](https://moderncprogramming.com/what-is-the-best-unit-testing-framework-in-c-for-you/)
- [https://moderncprogramming.com/what-is-the-best-unit-test-method-naming-convention-in-c/](https://moderncprogramming.com/what-is-the-best-unit-test-method-naming-convention-in-c/)
- [https://github.com/shenxianpeng/gcov-example](https://github.com/shenxianpeng/gcov-example)
- [https://medium.com/@kasra_mp/introduction-to-c-unit-testing-with-the-unity-framework-15903823ce8a](https://medium.com/@kasra_mp/introduction-to-c-unit-testing-with-the-unity-framework-15903823ce8a)
