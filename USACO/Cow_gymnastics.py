
# def number_pairs(cows):
#     total_cows = 0
#     for i in range(cows,0,-1):
#         total_cows = total_cows + i
#     return total_cows

# num = list(map(int,input().split()))
# cows = {}
# for i in range(num[0]):
#     cows[i]= list(map(int,input().split()))
# pairs = []

# for x in range(num[1]):
#     for y in range(num[1]-1):
#         pairs.append((cows[0][x],cows[0][y]))

# for z in range(1,num[0]):
#     for x in range(num[1]):
#         for y in range(num[1]-1):
#             new_pairs = (cows[z][x],cows[z][y])
#             for a in range(number_pairs(num[1])):
#                 if new_pairs != pairs[a]:
#                     pairs.remove(a)

# print(len(pairs))
                


def number_pairs(num):
    pairs = {}
    pairs{for i in range } = list(map(int,input().split()))