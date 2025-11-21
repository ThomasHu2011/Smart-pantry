n, m = map(int, input().split())
cow_heights = list(map(int, input().split()))
candy_heights = list(map(int, input().split()))

for candy in candy_heights:
    base = 0
    for i in range(n):
        reach = cow_heights[i]
        eat = max(0, min(reach, candy) - base)
        cow_heights[i] += eat
        base += eat
        if base >= candy:
            break


        
