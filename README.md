# OS3ILV WS23/24 Assignment
This repository hosts the description of the assignment for OS3ILV WS23/24


## Goal of the Assignment

Practice **Process Management** by creating a simple multi-process program in C in which each process performs a specific task.

To solve the assignment, you must implement process creation, scheduling, synchronization, and termination mechanisms.

## High-level Description of the Assignment

Your task is to implement a Multi-player Rock Paper Scissors platform.

The platform consists of:

- A central "server", i.e., a daemon process or service, that runs in background. It receives commands for creating new games, joining new games, making moves, creating reports, maintaining the leaderboard, etc. and executes them.
- A client component, i.e., a process, that communicates to the server and allows users to play (multiple) games at the same time and check the leaderboard.

    > Note: It should be possible to start multiple, concurrent instances of the client components on the same machine!

### The Gameplay

There are a few different ways to approach the rock paper scissor with multiple players. 

Informally, our approach works like this:

- Start a game by specifying how many players will play (N) and how many rounds (R) make up the game (the number of points that player can accumulate is defined by the number of rounds).
- After N players join the game on the RPS platform, the game can start.
- At each round, players submit their hand gesture (rock, paper, or scissors)
- When all the players submit their hand gestures, the system computes the points: Players get points when their hand gesture wins over other players.
- The game proceeds in rounds until all the rounds are played. The player(s) with the highest number of points win(s) the game.
- After the game ends, a game report is generated, and the leaderboard is updated (overall score, played matches, and matches won).

> Note: Clients cannot leave a game, and all the games must be played until the last round.

### The User Interface

The User Interface of the assignment is purely text based. The following examples illustrate how server and clients are supposed to be started, and how they should react to the various commands.

> Note: You must implement your code to respond to those commands

#### The Server

Starting the server is as simple as invoking the executable `main` with the flag ``--server`` (or `-s`):

```
main --server
```

or

```
main -s
```

Once the server starts, it outputs standard and error messages directly to the console.

The server can be killed by pressing `ctrl-d` or sending the `SIGTERM` signal using [https://www.commandlinux.com/man-page/man1/kill.1.html](kill).

> Note: Your code must be able to correct handle the `SIGTERM` signal and notify all the connected clients that it is going to shutdown. Consequently, all the clients must start their shutdown procedure.

#### The Client

Starting the client is as simple as invoking the executable `main` with the option ``--client`` (or `-c`) passing as input the `mandatory` ID of the client (`<CLIENT_ID>`). The ID of the client is a 5-char string containing only numbers and letters (no special symbols, no greek letter)

> Note: different clients cannot have the same <CLIENT_ID> (at the same time).

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
2 - Play a game
3 - Join a game
4 - Show leaderboard

q - Quit
```

##### Create a new game

Pressing `1` from the main menu will produce the following output:

```
2:10 - How many players will play the game? 2 - 10

b - Back
```

Pressing `b` takes the player back to the main menu, pressing any number between `2` and `10` will take the player to the next question:

```
3:10 - How many rounds will the game have? 3 - 10

b - Back
```

Pressing `b` takes the player back to the previous question, pressing any number between `3` and `10` will setup the game, i.e., the game is visible and allow players to join/play.

> Note: Players do not automatically join the games they create!

##### Play a game

Players can play more than one game at the same time and must specify which game they want to play before they can make a move.

Pressing `2` from the main menu will show all the active games the player had joined and will produce an output similar to:

```
Here's the list of games you can play:

1 - Game #1
2 - Game #4
3 - Game #10

b - Back
```

In case there are not games to play, the message is:

```
Here's the list of games you can play:

Sorry. There are no games you can play

b - Back
```

Pressing `b` takes the player back to the main menu, pressing any of the listed numbers will let the player submit moves into the corresponding game.
During the game play, the system shows the game metadata (ID and rounds), the moves done so far by each player, and the point accumulated by each player as follows:

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
>   - Numbers and gestures/moves (`r`, `p`, `s`) are aligned on the RIGHT (there's a white space before the column separator `|` 
>   - The columns width is defined by the username of the player
>   - There's an empty line (`\n`) before and after the banners showing the points

Pressing `b` takes the player back to the list of active games, while pressing P/R/S will submit the move for the current round. If the player already selected a move and s/he waiting for the other players to submit their move, the system shows a different message:

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

> Note: Only when the player submitted the move, the refresh command is enabled. The refresh command reloads the current page.


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

> Note: The list of winner follows the same order of the table header.

##### Join a game

Players can play a game only after joining it. 

Pressing `3` from the main menu will show all the active games **in which the player is not yet playing** and will produce an output similar to:

```
Here's the list of games you can join:

1 - Game #3
2 - Game #5

b - Back
```

In case there are not games to join, the message is:

```
Here's the list of games you can join:

Sorry. There are no games you can join

b - Back
```

Pressing `b` takes the player back to the main menu, pressing any of the listed numbers will let the player join the game. For instance, if the player joins the Game #3, the screen shows only the Game #5:

```
Here's the list of games you can join:

1 - Game #5

b - Back
```

##### Show leaderboard

During the game play, the server maintains records the history of the games. 

Pressing `4` from the main menu will show the leaderboard. 
The leader board reports the overall points accumulated so far 
and the number of matches played by the top 3 players.

> Note: if the ranking of the current player is below 5 the leaderboard
reports it at the bottom.

For instance, if players `boo` (ranked 10) shows the leaderboard;
the leaderboard will look like this:

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

Instead, if players `pino` (ranked 1) shows the leaderboard;
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

> Note: an `*` indicates the row corresponding to the current player.

##### Quitting the client

Pressing `q` from the main menu causes the client to quit.
Upon quitting the client must output the following message and return the value `0` indicating that client decides to quit.

```
Quitting !
```

> Note: if the server quits; then, all the clients must also quit.
> In this case, the quitting message is the same, but the return value is different (`1`) indicating that something unexpected happened.



## Potential (Abstract) Test Cases

You should write unit and system tests. A potential system test cases look like this:

- Start the central "server" 
- Pretend to or actually create some clients
- One client creates a game
- Many clients join the game
- Client concurrently play the game by sending some commands

While the test is running, the output of all the clients and the central "server" should be collected and stored to check the conformance of their behaviors

# Dependencies and Requirements

The assignment requires you to develop C code. The best way to approach this is to use a Linux or a Mac OS distribution, that come already equipped with `gcc` (to compile C) and `make` (to automate the building of the project).

In case you work in Windows, you can chose one of the following options:

1. VM. Install a system level virtualization system (VirtualBox, Parallels, VMWare, etc.), and create a Linux VM. Connect to the VM and work on it.
2. Container. Install docker and create a linux docker image. You can mount your disk into the running docker instance and write the code using your IDE as usual. But you must execute `make` from within the running docker instance (for example, using `docker exec`).
3. WSL. Install Windows Subsystem for Linux (WSL) and write the code using your IDE as usual. But you must execute `make` from within the running WSL. According to [this article](https://code.visualstudio.com/docs/remote/wsl) you can configure VisualStudio to run commands directly via WSL.

## External Libraries
The project should not rely on any external library besides those used for testing and code coverage.

For testing, you'll use the [Unity framework](http://www.throwtheswitch.org/unity) and for coverage you'll use (standard) `gcov`. Both those dependencies should be already handled by the given assignment (typing `make reps` should install them).

# Additional reading

If you are not familiar with developing and testing C programs you can google for any basic tutorial about it and start practicing **NOW**!

> Note: You can suggest any tutorial you have found useful to the lecturer so it can be included here. Please, open a pull request for doing so

## C Programming
Here some refs about C programming:

- [https://www.w3schools.com/c/](https://www.w3schools.com/c/)

## Make
Here some refs about `make`:

- [https://makefiletutorial.com/](https://makefiletutorial.com/)

## Unit testing and coverage
Here some refs about testing and computing coverage of C programs:

- [https://moderncprogramming.com/what-is-the-best-unit-testing-framework-in-c-for-you/](https://moderncprogramming.com/what-is-the-best-unit-testing-framework-in-c-for-you/)
- [https://moderncprogramming.com/what-is-the-best-unit-test-method-naming-convention-in-c/](https://moderncprogramming.com/what-is-the-best-unit-test-method-naming-convention-in-c/)
- [https://github.com/shenxianpeng/gcov-example](https://github.com/shenxianpeng/gcov-example)
- [https://medium.com/@kasra_mp/introduction-to-c-unit-testing-with-the-unity-framework-15903823ce8a](https://medium.com/@kasra_mp/introduction-to-c-unit-testing-with-the-unity-framework-15903823ce8a)