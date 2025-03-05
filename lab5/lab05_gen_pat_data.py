import os 
import random
import numpy as np
 
fin = open("input.txt", 'w')
fout = open("output.txt", 'w')

patnum = 100

fin.write(str(patnum)+'\n')
fout.write(str(patnum)+'\n')

for patcnt in range(patnum):
    fin.write(str(patcnt)+'\n')
    fout.write(str(patcnt)+'\n')

    mat_size_idx = random.randint(0,3)
    mat_size = pow(2,(mat_size_idx+1))
    fin.write(str(mat_size_idx)+'\n')

    mats = []
    for i in range(32):
        mat= []
        for j in range(mat_size):
            row = []
            for k in range(mat_size):
                ent = random.randint(-128,127)
                row.append(ent)
                if ent<0: ent = 256 + ent
                fin.write('{0:08b} '.format(ent))                
            mat.append(row)
        fin.write('\n')
        mats.append(mat)

    mats = np.array(mats)
    for i in range(10):
        mode = random.randint(0,3)
        fin.write('{0:02b} '.format(mode))
        idx1 = random.randint(0,31)
        idx2 = random.randint(0,31)
        idx3 = random.randint(0,31)
        fin.write('{0:05b} '.format(idx1))
        fin.write('{0:05b} '.format(idx2))
        fin.write('{0:05b} '.format(idx3))
        fin.write('\n')

        A = mats[idx1]
        B = mats[idx2]
        C = mats[idx3]

        if mode==1: A=A.transpose()
        elif mode==2: B=B.transpose()
        elif mode==3: C=C.transpose()
        
        mat_mult = np.matmul(np.matmul(A, B), C)
        golden = mat_mult.trace()
        # fout.write(str(golden)+'\n')
        if golden<0: golden = pow(2,50)+golden
        golden = int(golden)
        fout.write('{0:050b}\n'.format(golden))
        
        
        