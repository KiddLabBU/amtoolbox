
tests_todo={ 'adaptloop', 'outermiddle', 'coefgtdrnl'};


total_tests_failed=0;
list_of_failed_tests={};

for ii=1:length(tests_todo)
  test_failed=feval(['test_',tests_todo{ii}]);
  total_tests_failed=total_tests_failed+test_failed;
  if test_failed>0
    list_of_failed_tests{end+1}=['test_',tests_todo{ii}];
  end;
end;

disp(' ');
if total_tests_failed==0
  disp('ALL TESTS PASSED');
else
  s=sprintf('%i TESTS FAILED',total_tests_failed);
  disp(s);
  disp('The following test scripts contained failed tests');
  for ii=1:length(list_of_failed_tests)
    disp(['   ',list_of_failed_tests{ii}]);
  end;
end;
