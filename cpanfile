requires 'perl', '5.010001';

on configure => sub {
    requires 'ExtUtils::MakeMaker', '6.30';
};

on test => sub {
    requires 'File::Temp';
    requires 'Test::More';
    requires 'Test::Output';
    requires 'parent';
};

on develop => sub {
    requires 'Test::LeakTrace';
    requires 'Test::Perl::Critic';
};
