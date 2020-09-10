---
layout: post
title: pwnable.kr - blackjack
---

## Prompt
Hey! check out this C implementation of blackjack game!
I found it online
* http://cboard.cprogramming.com/c-programming/114023-simple-blackjack-program.html

I like to give my flags to millionares.
how much money you got?


Running at : nc pwnable.kr 9009
## Analysis
We need to make $1,000,000. For this code review, let's consider our sources. We have control over how much we bet, so let's examine the betting logic:
```c
int betting() //Asks user amount to bet
{
 printf("\n\nEnter Bet: $");
 scanf("%d", &bet);
 
 if (bet > cash) //If player tries to bet more money than player has
 {
        printf("\nYou cannot bet more money than you have.");
        printf("\nEnter Bet: ");
        scanf("%d", &bet);
        return bet;
 }
 else return bet;
} // End Function
```
We cannot make a bet for more money than we have (`bet > cash`), but there is no additional check when you are asked again. There is also no lower limit on the bet, and we can bet negative numbers. Let's check how the winnings are totaled in the `play()` function:
```c
while(i<=21) //While loop used to keep asking user to hit or stay at most twenty-one times
                  //  because there is a chance user can generate twenty-one consecutive 1's
     {
         if(p==21) //If user total is 21, win
         {
             printf("\nUnbelievable! You Win!\n");
             won = won+1;
             cash = cash+bet;
             printf("\nYou have %d Wins and %d Losses. Awesome!\n", won, loss);
             dealer_total=0;
             askover();
         }
      
         if(p>21) //If player total is over 21, loss
         {
             printf("\nWoah Buddy, You Went WAY over.\n");
             loss = loss+1;
             cash = cash - bet;
             printf("\nYou have %d Wins and %d Losses. Awesome!\n", won, loss);
             dealer_total=0;
             askover();
         }
```
The win logic seems fine, but the lose logic doesn't account for negative bets. It looks like we just have to stay after the cards are dealt and our negative bet will be subtracted from our cash total (i.e. we make money).

## Solution
The negative/consistent/easiest option:
```
noble@heart:~$ nc pwnable.kr 9009
Y               # say yes to playing the game
1               # choose option 1 
-1000000        # bet a large negative sum
S               # choose to Stay
```
Unless the Dealer's total surpasses 21, you'll lose--and thus win! If you choose to play again, the flag will be printed out for you.