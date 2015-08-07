-module(stripe_util).

%% copied from mochiweb_util

-export([urlencode/1, as_list/1]).

-define(PERCENT, 37).  % $\%
-define(FULLSTOP, 46). % $\.
-define(QS_SAFE(C), ((C >= $a andalso C =< $z) orelse
                     (C >= $A andalso C =< $Z) orelse
                     (C >= $0 andalso C =< $9) orelse
                     (C =:= ?FULLSTOP orelse C =:= $- orelse C =:= $~ orelse
                      C =:= $_))).




hexdigit(C) when C < 10 -> $0 + C;
hexdigit(C) when C < 16 -> $A + (C - 10).

revjoin([], _Separator, Acc) ->
    Acc;
revjoin([S | Rest], Separator, []) ->
    revjoin(Rest, Separator, [S]);
revjoin([S | Rest], Separator, Acc) ->
    revjoin(Rest, Separator, [S, Separator | Acc]).

%% @spec quote_plus(atom() | integer() | string()) -> string()
%% @doc URL safe encoding of the given term.
quote_plus(Atom) when is_atom(Atom) ->
    quote_plus(atom_to_list(Atom));
quote_plus(Int) when is_integer(Int) ->
    quote_plus(integer_to_list(Int));
quote_plus(Bin) when is_binary(Bin) ->
    quote_plus(binary_to_list(Bin));
quote_plus(String) ->
    quote_plus(String, []).

quote_plus([], Acc) ->
    lists:reverse(Acc);
quote_plus([C | Rest], Acc) when ?QS_SAFE(C) ->
    quote_plus(Rest, [C | Acc]);
quote_plus([$\s | Rest], Acc) ->
    quote_plus(Rest, [$+ | Acc]);
quote_plus([C | Rest], Acc) ->
    <<Hi:4, Lo:4>> = <<C>>,
    quote_plus(Rest, [hexdigit(Lo), hexdigit(Hi), ?PERCENT | Acc]).

%% @spec urlencode([{Key, Value}]) -> string()
%% @doc URL encode the property list.
urlencode(Props) ->
    RevPairs = lists:foldl(fun ({K, V}, Acc) ->
                                   [[quote_plus(K), $=, quote_plus(V)] | Acc]
                           end, [], Props),
    lists:flatten(revjoin(RevPairs, $&, [])).


as_list(Value) when is_binary(Value) ->
    binary_to_list(Value);
as_list(Value) when is_list(Value) ->
    Value.
