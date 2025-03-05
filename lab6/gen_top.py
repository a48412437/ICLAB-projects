
import random
pat_num = 100000

def isPrime(x):
    count = 0
    for i in range(int(x/2)):
        if x % (i+1) == 0:
            count = count+1
    return count == 1

in_path = './input.txt'
out_path = './output.txt'

fin = open(in_path, 'w')
fout = open(out_path, 'w')

fin.write(str(pat_num)+'\n')
fout.write(str(pat_num)+'\n')

pat_cnt = 0
while pat_cnt!=pat_num:
  ##################################
  ### INPUT
  ##################################

  primes = [i for i in range(4, 63) if isPrime(i)]
  in_prime = random.choice(primes) 

  Q_x = random.randint(0,in_prime-1)
  P_x = random.randint(0,in_prime-1)
  Q_y = random.randint(0,in_prime-1)
  P_y = random.randint(0,in_prime-1)
  # print(in_prime)
  in_a = 0
  in_b = 0
  found = 0
  for i in range(0, in_prime):
    for j in range(0, in_prime):
      if ((Q_y*Q_y) %in_prime) == ((Q_x*Q_x*Q_x + i*Q_x + j) % in_prime) and ((P_y*P_y) %in_prime) == ((P_x*P_x*P_x + i*P_x + j) % in_prime):
        in_a = i
        in_b = j
        found = 1
      if found: break
    if found: break
    
  if found==0: continue
  if Q_x==P_x and Q_y!=P_y: continue
  if Q_x==P_x and Q_y==P_y and Q_y==0: continue
  if (Q_y+P_y)%in_prime==0: continue

  fin.write(str(pat_cnt)+'\n')
  fin.write('{0:06b}\n'.format(in_prime))  
  fin.write('{0:06b}\n'.format(Q_x))  
  fin.write('{0:06b}\n'.format(Q_y))  
  fin.write('{0:06b}\n'.format(P_x))  
  fin.write('{0:06b}\n'.format(P_y))  
  fin.write('{0:06b}\n'.format(in_a))  
  fin.write('{0:06b}\n'.format(in_b))  

  ##################################
  ### OUTPUT
  ##################################

  if P_x==Q_x and P_y==Q_y:
    numer = 3*P_x*P_x + in_a
    denom = 2*P_y
  else:
    numer = Q_y - P_y
    denom = Q_x - P_x

  if numer >= 0: numer = numer % in_prime
  else: numer = numer + in_prime
  if denom >= 0: denom = denom % in_prime
  else: denom = denom + in_prime

  # find inv 
  for i in range(1, in_prime):
    if (i * denom)%in_prime==1:
      inv = i
      break
  s = numer * inv % in_prime
  R_x = (s*s - P_x - Q_x) % in_prime
  R_y = (s * (P_x - R_x) - P_y) % in_prime
  
  fout.write(str(pat_cnt)+'\n')
  fout.write('{0:06b}\n'.format(R_x))  
  fout.write('{0:06b}\n'.format(R_y)) 
  
  pat_cnt += 1
