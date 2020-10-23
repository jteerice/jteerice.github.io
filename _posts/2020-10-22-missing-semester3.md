---
layout: post
title: ./missing-semester - Data Wrangling - Exercises
---
Course located at: [missing.csail.mit.edu](https://missing.csail.mit.edu/)
## Exercises

1. Take this [short interactive regex tutorial](https://regexone.com/)
2. Find the number of words (in /usr/share/dict/words) that contain at least three `a`s and don’t have a `'s` ending. What are the three most common last two letters of those words? sed’s y command, or the tr program, may help you with case insensitivity. How many of those two-letter combinations are there? And for a challenge: which combinations do not occur?

```
$ sudo apt install wamerican-small

# Find the number of words that contain at least three `a`s and don’t have a `'s` ending.
$ cat /usr/share/dict/words | grep -E ".*a.*a.*a.*[^'s]$" | wc -l
117

# What are the three most common last two letters of those words?  
$ cat /usr/share/dict/words | tr "[:upper:]" "[:lower:]" | grep -E "(a.*){3,}[^'s]$" | sed -E 's/^.*(..$)/\1/' | sort | uniq -c | sort -nr | head -n3 | awk '{print $2}' | paste -sd','
al,ly,on

# How many two-letter combinations are there?
$ cat /usr/share/dict/words | tr "[:upper:]" "[:lower:]" | grep -E "(a.*){3,}[^'s]$" | sed -E 's/^.*(..$)/\1/' | sort | uniq | wc -l
31

# And for a challenge: which combinations do not occur?
$ cat /usr/share/dict/words | tr "[:upper:]" "[:lower:]" | grep -E "(a.*){3,}[^'s]$" | sed -E 's/^.*(..$)/\1/' | sort | uniq > occured
$ printf "%s\n" {a..z}{a..z} > all_two-letter
$ comm occured all_two-letter -3 | awk '{print $1}' | paste -sd,
aa,ab,ad,af,ag,ah,ai,aj,ak,ao,ap,aq,as,at,au,av,aw,ax,az,ba,bb,bc,bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr,cs,cu,cv,cw,cx,cy,cz,da,db,dc,dd,df,dg,dh,di,dj,dk,dl,dm,dn,do,dp,dq,dr,ds,dt,du,dv,dw,dx,dy,dz,ea,eb,ec,ee,ef,eg,eh,ei,ej,ek,el,em,en,eo,ep,eq,er,es,et,eu,ev,ew,ex,ey,ez,fa,fb,fc,fd,fe,ff,fg,fh,fi,fj,fk,fl,fm,fn,fo,fp,fq,fr,fs,ft,fu,fv,fw,fx,fy,fz,ga,gb,gc,gd,gf,gg,gh,gi,gj,gk,gl,gm,gn,go,gp,gq,gr,gs,gt,gu,gv,gw,gx,gy,gz,ha,hb,hc,hd,hf,hg,hh,hi,hj,hk,hl,hm,hn,ho,hp,hq,hr,hs,ht,hu,hv,hw,hx,hy,hz,ib,id,if,ig,ih,ii,ij,ik,il,im,in,io,ip,iq,ir,is,it,iu,iv,iw,ix,iy,iz,ja,jb,jc,jd,je,jf,jg,jh,ji,jj,jk,jl,jm,jn,jo,jp,jq,jr,js,jt,ju,jv,jw,jx,jy,jz,ka,kb,kc,kd,ke,kf,kg,kh,ki,kj,kk,kl,km,kn,ko,kp,kq,kr,ks,kt,ku,kv,kw,kx,ky,kz,la,lb,lc,ld,lf,lg,lh,li,lj,lk,ll,lm,ln,lo,lp,lq,lr,ls,lt,lu,lv,lw,lx,lz,ma,mb,mc,md,me,mf,mg,mh,mi,mj,mk,ml,mm,mn,mo,mp,mq,mr,ms,mt,mu,mv,mw,mx,my,mz,na,nb,nc,nd,nf,nh,ni,nj,nk,nl,nm,nn,no,np,nq,nr,ns,nu,nv,nw,nx,ny,nz,oa,ob,oc,od,oe,of,og,oh,oi,oj,ok,ol,om,oo,op,oq,os,ot,ou,ov,ow,ox,oy,oz,pa,pb,pc,pd,pe,pf,pg,pi,pj,pk,pl,pm,pn,po,pp,pq,pr,ps,pt,pu,pv,pw,px,py,pz,qa,qb,qc,qd,qe,qf,qg,qh,qi,qj,qk,ql,qm,qn,qo,qp,qq,qr,qs,qt,qu,qv,qw,qx,qy,qz,ra,rb,rc,re,rf,rg,rh,ri,rj,rl,rm,rn,ro,rp,rq,rr,rs,rt,ru,rv,rw,rx,rz,sa,sb,sc,sd,sf,sg,sh,si,sj,sk,sl,sn,so,sp,sq,sr,ss,st,su,sv,sw,sx,sy,sz,ta,tb,tc,td,tf,tg,th,ti,tj,tk,tl,tm,tn,to,tp,tq,tr,ts,tt,tu,tv,tw,tx,tz,ua,ub,uc,ud,ue,uf,ug,uh,ui,uj,uk,ul,um,un,uo,up,uq,ur,us,ut,uu,uv,uw,ux,uy,uz,va,vb,vc,vd,ve,vf,vg,vh,vi,vj,vk,vl,vm,vn,vo,vp,vq,vr,vs,vt,vu,vv,vw,vx,vy,vz,wa,wb,wc,wd,we,wf,wg,wh,wi,wj,wk,wl,wm,wn,wo,wp,wq,wr,ws,wt,wu,wv,ww,wx,wy,wz,xa,xb,xc,xd,xe,xf,xg,xh,xi,xj,xk,xl,xm,xn,xo,xp,xq,xr,xs,xt,xu,xv,xw,xx,xy,xz,ya,yb,yc,yd,ye,yf,yg,yh,yi,yj,yk,yl,ym,yn,yo,yp,yq,yr,ys,yt,yu,yv,yw,yx,yy,yz,za,zb,zc,zd,ze,zf,zg,zh,zi,zj,zk,zl,zm,zn,zo,zp,zq,zr,zs,zt,zu,zv,zw,zx,zy,zz
```

3. To do in-place substitution it is quite tempting to do something like `sed s/REGEX/SUBSTITUTION/ input.txt > input.txt`. However this is a bad idea, why? Is this particular to `sed`? Use `man sed` to find out how to accomplish this.

The processes in a pipeline are all started up in parallel and will truncate the input file before the process at the head of the pipeline has finished. This is not particular to `sed`. The `-i` option streams the edited content into a new file and then renames it behind the scenes.

4. Find your average, median, and max system boot time over the last ten boots. Use journalctl on Linux and log show on macOS, and look for log timestamps near the beginning and end of each boot.

```
$ sudo apt install r-base

$ journalctl | grep -e "userspace" | head -n 10 | sed -E 's/^.*= (.*)s\./\1/g' | R --slave -e 'x <- scan(file="stdin", quiet=TRUE); summary(x)'
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  11.44   12.64   13.26   18.11   15.25   59.60
```

5. Look for boot messages that are not shared between your past three reboots.

```
$ touch uniq_messages
$ journalctl -b | tail -n +2 | sed -E 's/^.*kali (.*)$/\1/' | sort | uniq | sort >> uniq_messages
$ journalctl -b -1 | tail -n +2 | sed -E 's/^.*kali (.*)$/\1/' | sort | uniq | sort >> uniq_messages
$ journalctl -b -2 | tail -n +2 | sed -E 's/^.*kali (.*)$/\1/' | sort | uniq | sort >> uniq_messages

# Shared
$ cat uniq_messages | sort | uniq -c | awk '{print $1}' | grep 3 | wc -l
658
# Not Shared
$ cat uniq_messages | sort | uniq -c | awk '{print $1}' | grep -v 3 | wc -l
7408

# All 7408 unshared lines
$ cat uniq_messages | sort | uniq -c | sort -n |awk '{$1=$1};1'| sed -nE 's/^[^3] (.*)$/\1/p'
```

6. Find an online data set. Fetch it using curl and extract out just two columns of numerical data. If you’re fetching HTML data, pup might be helpful. For JSON data, try jq. Find the min and max of one column in a single command, and the sum of the difference between the two columns in another.

```
$ wget -O india_historical_pop http://api.worldbank.org/v2/countries/IND/indicators/SP.POP.TOTL?per_page=5000&format=json

$ a=($(cat india_historical_pop | xq . | jq 'map(.["wb:data"][]["wb:value"])' | grep -o [0-9]* | sort -n | sed -n '1p;$p')); echo "min=${a[0]}, max=${a[1]}"
min=450547679, max=1366417754
$ a=($(cat india_historical_pop | xq . | jq 'map(.["wb:data"][]["wb:date"])' | grep -o [0-9]* | sort -n | sed -n '1p;$p')); echo "min=${a[0]}, max=${a
[1]}"
min=1960, max=2020

$ cat india_historical_pop | xq . | jq 'map(.["wb:data"][]["wb:value"])' | grep -o [0-9]* | paste -sd+ | bc -l
52835203044
$ cat india_historical_pop | xq . | jq 'map(.["wb:data"][]["wb:date"])' | grep -o [
0-9]* | paste -sd+ | bc -l
121390
$ a=$(cat india_historical_pop | xq . | jq 'map(.["wb:data"][]["wb:value"])' | grep -o [0-9]* | paste -sd+| bc -l); b=$(cat india_historical_pop | xq . | jq 'map(.["wb:data"][]["wb:date"])' | grep -o [0-9]* | paste -sd+ |bc -l); echo $a-$b | bc -l
52835081654
```
