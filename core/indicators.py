def sma(v,n): return sum(v[-n:])/n if len(v)>=n else None
def ema(v,n):
    if len(v)<n: return None
    a=2/(n+1); x=sum(v[:n])/n
    for p in v[n:]: x=p*a+x*(1-a)
    return x
def rsi(v,n=14):
    if len(v)<n+1: return None
    d=[b-a for a,b in zip(v[-n-1:],v[-n:])]
    g=sum(max(x,0) for x in d)/n; l=sum(max(-x,0) for x in d)/n
    return 100.0 if l==0 else 100-(100/(1+g/l))
