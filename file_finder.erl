-module(file_finder).
-include_lib("kernel/include/file.hrl").
-export([find_files/2, start/0]).

find_files(Dir, Ext) ->
    find_files_recursive(Dir, Ext).

find_files_recursive(Dir, Ext) ->
    case file:list_dir(Dir) of
        {ok, Files} ->
            lists:foreach(
                fun(File) ->
                    FullPath = filename:join(Dir, File),
                    case file:read_file_info(FullPath) of
                        {ok, FileInfo} ->
                            check_file_type(FileInfo, FullPath, Ext);
                        {error, _} ->
                            ok
                    end
                end,
                Files
            );
        {error, _Reason} ->
            ok
    end.

check_file_type(FileInfo, FullPath, Ext) ->
    case FileInfo#file_info.type of
        directory -> find_files_recursive(FullPath, Ext);
        regular ->
            % Check the file extension outside the case
            check_extension(FullPath, Ext);
        _ -> ok
    end.

check_extension(FullPath, Ext) ->
    % Now we can check the extension before using it in a guard or case.
    case filename:extension(FullPath) =:= Ext of
        true -> io:format("Found file: ~s~n", [FullPath]);
        false -> ok
    end.

start() ->
    DirInput = io:get_line("Enter directory to search: "),
    Dir = string:trim(DirInput),

    ExtInput = io:get_line("Enter file extension (e.g. .erl): "),
    Ext = string:trim(ExtInput),

    io:format("Searching in ~s for *~s files...~n", [Dir, Ext]),
    find_files(Dir, Ext).




