
-module(longurl).
-export([expand_url/1]).

-define(BASE_URL, "http://api.longurl.org/v2/expand?format=xml&url=").


expand_url(Url) ->
	inets:start(),
	{ok, Request} = request(Url),
	parse(Request).

parse(Data) -> Data.

service_url(Url) ->
%% FIXME: add url encoding
	lists:append(?BASE_URL, Url).

request(Url) ->
	case http:request(get, {service_url(Url),
			[{"user_agent", "urlerlspander"}]},
			  [], [{sync, false}]) of
		{ok, RequestId} ->
			receive
				{http, {RequestId, Result}} ->
					{_Method, _Header, Content} = Result,
					{ok, Content} 
			after
			     50000 ->
				http:cancel_request(RequestId),
				{error, "Timeout reached"}
			end;
		{error, Reason} ->
			{error, Reason}
	end.
