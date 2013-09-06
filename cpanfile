# -*- mode: cperl -*-

requires 'Foo', '== 0.1';        # specific version
requires 'Foo', '0.1';           # minimum
requires 'Bar', '>= 0.1, < 0.4'; # min-max

# phase: configure, build, test, runtime(default), develop
on configure => sub {
    requires 'Module::Install';
    requires 'Module::Install::CPANfile';
};

on 'test' => sub {
    requires 'Test::More';
    requires 'Devel::Cover';
};
