# File-Copy-NoClobber

A File::Copy that renames copied files instead of overwriting destination names

    use File::Copy::NoClobber;

    copy( "file.txt", "elsewhere/" ); # elsewhere/file.txt
    copy( "file.txt", "elsewhere/" ); # elsewhere/file (01).txt

    # similar with move
    move( "file.txt", "elsewhere/" ); # elsewhere/file (02).txt
