PROJECT = stripe
DEPS = jsx

dep_jsx = git https://github.com/talentdeficit/jsx master

include erlang.mk

run: app
	erl -pa ebin deps/*/ebin -name erl_rethink@localhost -s inets -s ssl
