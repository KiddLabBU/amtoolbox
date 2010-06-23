function test_failed=test_adaptloop
%TEST_ADAPTLOOP  Test adaptloop
%
%  Test the adaptation loop implementation by comparing it to a reference
%  implementation.

if 0
  f  = greasy;
  L=length(f);
  f=[randn(L,1), f];
  fs = 16000;
else
  fs=100;
  L=500;
  f=randn(L,2);
end;

limitr = [0.5, 10];

minlvl=1e-5;

disp(' ===============  TEST_ADAPTLOOP ================');

disp('--- Used subroutines ---');

which comp_adaptloop

test_failed = 0;
for w=1:2
  for tauchoose=1:2
    switch(tauchoose)
     case 1
      tau=[0.005 0.050 0.129 0.253 0.500];
      tauname='DAU';
     case 2
      tau=linspace(0.005,0.5,5);
      tauname='BRE';
     case 3
      tau=[0.005 0.050 0.500];
      tauname='3RD';      
    end;
    
    for ii=1:length(limitr)
      
      limit=limitr(ii);
      
      slimit='     ';
      if limit>1
        slimit='LIMIT';
      end;
      
      % Compute the reference solution, this is nlal_lim 
      % nlal_lim cannot handle matrices, so we do it manually
      s1=zeros(L,w);
      for kk=1:w
        s1(:,kk)=nlal_lim(f(:,kk),fs,limit);    
      end;
      
      s2=adaptloop(f(:,1:w),fs,limit,'tau',tau);
      
      res=norm(s1(:)-s2(:))/norm(s1);
      [test_failed,fail]=amtdiditfail(res,test_failed);
      s=sprintf('ADAPTLOOP %s %s L: %3i W:%2i %0.5g %s',slimit,tauname,L,w,res,fail);
      disp(s);
      
      s3=ref_adaptloop_1(f(:,1:w),fs,limit,minlvl,tau);
      
      res=norm(s1(:)-s3(:))/norm(s1);
      [test_failed,fail]=amtdiditfail(res,test_failed);
      s=sprintf('REF_ADAPT %s %s L: %3i W:%2i %0.5g %s',slimit,tauname,L,w,res,fail);
      disp(s);
      
      state = adaptloop_init(w,fs,limit);
      s4    = zeros(L,w);
      part  = floor(L/2)+10;
      
      [s4(1:part,:),  state] = adaptloop_run(state,f(1:part,1:w));
      [s4(part+1:L,:),state] = adaptloop_run(state,f(part+1:L,1:w));
      
      res=norm(s1(:)-s4(:))/norm(s1);
      [test_failed,fail]=amtdiditfail(res,test_failed);
      s=sprintf('BLOCK     %s L: %3i W:%2i %0.5g %s',slimit,L,w,res,fail);
      disp(s);
      
    end;
  end;
end;
