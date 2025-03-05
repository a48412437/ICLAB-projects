import os 
import random
import numpy as np


def gcdExtended(a, b):
    # Base Case
    if a == 0 :
        return b,0,1
             
    gcd,x1,y1 = gcdExtended(b%a, a)
     
    # Update x and y using results of recursive
    # call
    x = y1 - (b//a) * x1
    y = x1
     
    return gcd,x,y

def is_prime(n):
    for i in range(2, n):
        if n % i == 0:  # 整除，i 是 n 的因數，所以 n 不是質數。
            return False
    return True     # 都沒有人能整除，所以 n 是質數。


bit_width = 7
fin = open("input_ip_7.txt", 'w')
fout = open("output_ip_7.txt", 'w')
max_num = pow(2,7) - 1


# print (max_num)
prime_num = []
for i in range(4,max_num):
    
    if is_prime(i):
        # print(i)
        prime_num.append(i)

patnum = 0

for i in prime_num:
    patnum += (i-1)
    

fin.write(str(patnum)+'\n')
fout.write(str(patnum)+'\n')

# print(prime_num)

for i in prime_num:
    for j in range(1,i):
        # print(i,j)
        rand = random.randint(0,1)
        if rand == 1:
            fin.write(str(i)+" ")                
            fin.write(str(j)+" ")
        else:
            fin.write(str(j)+" ")                
            fin.write(str(i)+" ")
                
        fin.write("\n")

        gcd, x, y = gcdExtended(i,j)

        while (y<0):
            y = y + i
        # print(i,j,y)
        if ((j*y) % i) != 1:
            print("false")
        
        fout.write(str(y))
        fout.write("\n")
                            


# for patcnt in range(patnum):
#     fin.write(str(patcnt)+'\n')
#     fout.write(str(patcnt)+'\n')

#     mat_size_idx = random.randint(0,3)
#     mat_size = pow(2,(mat_size_idx+1))
#     fin.write(str(mat_size_idx)+'\n')

#     mats = []
#     for i in range(32):
#         mat= []
#         for j in range(mat_size):
#             row = []
#             for k in range(mat_size):
#                 ent = random.randint(-128,127)
#                 row.append(ent)
#                 if ent<0: ent = 256 + ent
#                 fin.write('{0:08b} '.format(ent))                
#             mat.append(row)
#         fin.write('\n')
#         mats.append(mat)

#     mats = np.array(mats)
#     for i in range(10):
#         mode = random.randint(0,3)
#         fin.write('{0:02b} '.format(mode))
#         idx1 = random.randint(0,31)
#         idx2 = random.randint(0,31)
#         idx3 = random.randint(0,31)
#         fin.write('{0:05b} '.format(idx1))
#         fin.write('{0:05b} '.format(idx2))
#         fin.write('{0:05b} '.format(idx3))
#         fin.write('\n')

#         A = mats[idx1]
#         B = mats[idx2]
#         C = mats[idx3]

#         if mode==1: A=A.transpose()
#         elif mode==2: B=B.transpose()
#         elif mode==3: C=C.transpose()
        
#         mat_mult = np.matmul(np.matmul(A, B), C)
#         golden = mat_mult.trace()
#         # fout.write(str(golden)+'\n')
#         if golden<0: golden = pow(2,50)+golden
#         golden = int(golden)
#         fout.write('{0:050b}\n'.format(golden))
        
        
        