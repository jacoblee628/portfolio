# Google Coding Challenge (Maze)

<img src="maze_example.png" width="200" height="130">

I received an invitation to the famous [Google Foo Bar Challenge](https://www.geeksforgeeks.org/google-foo-bar-challenge/) and got this problem.

Here's a paraphrased version of the prompt:

## Question:
You are given a 2d matrix that represents a maze. The top left corner is the entrance, and the bottom right corner is the exit. 0's in the matrix represent walkable paths, and 1's represent walls. You have the ability to break *one* wall. The maze will always be solveable, but you may need to break a wall to do so. What is the shortest path out of the maze?

```
Example input:
[[0, 1, 0, 0],
 [0, 0, 0, 0],
 [0, 0, 1, 1],
 [0, 1, 1, 0],
 [0, 1, 1, 0]]

Output: 8 (after breaking a wall)
```

## My Solution
I first implemented a simple Breadth-First Search (BFS) algorithm as a general pathfinder. That's the "find_distances()" function in the Maze class.

1. Starting from the entrance, BFS your way to the exit.
    * For each open space you encounter, keep track of its distance from the entrance.
    * For now, we'll call this **Search "X"**
2. Starting from the exit, BFS your way to the entrance.
    * Again, keeping track of the distances (separate from X)
    * Call this **Search "Y"**

Now we check if there is a wall worth breaking.

3. For each wall in the maze, check the spaces around it for open spaces.
    * If there are two open spaces around the wall, and these two spaces have been explored by both X and Y, then the wall may be worth breaking.
    * Calculate the new total distance if the wall is broken.
4. Return the lowest total distance


## Conclusion
Simple, right?

It took me 10 hours to write (I did sleep for part of it).

## Contact
Email: sglee@andrew.cmu.edu
