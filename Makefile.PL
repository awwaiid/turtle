use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'App::turtleshell',
    VERSION_FROM      => 'bin/turtleshell', # finds $VERSION
    PREREQ_PM         => {
      SDLx::Coro::REPL => 0,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'bin/turtleshell', # retrieve abstract from module
       AUTHOR         => 'awwaiid <awwaiid@thelackthereof.org>') : ()),
    EXE_FILES => [ 'bin/turtleshell' ],
);
