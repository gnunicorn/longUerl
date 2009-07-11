
-module(longurl).
-export([expand_url/1]).

-define(BASE_URL, "http://api.longurl.org/v2/expand?format=xml&url=").


expand_url(Url) ->
	inets:start(),
	{ok, Request} = request(Url),
	parse(Request).

parse(Data) ->
	{XML, _Rest} = xmerl_scan:string(Data),
	Name = "long-url",
	%% Why doesn't using Name work here after?
	{response, [], [_Content_A,  {_Name, [], [Long_url]}, _Content_B]} =
		xmerl_lib:simplify_element(XML),
	Long_url.

service_url(Url) ->
%% FIXME: add url encoding
	lists:append(?BASE_URL, Url).

request(Url) ->
	case http:request(get, {service_url(Url),
			[{"user_agent", "urlerlspander"}]},
				  [], [{sync, false}, {body_format, string}]) of
		{ok, RequestId} ->
			receive
				{http, {RequestId, Result}} ->
					{_Method, _Header, Content} = Result,
					{ok, binary_to_list(Content)}
			after
			     50000 ->
				http:cancel_request(RequestId),
				{error, "Timeout reached"}
			end;
		{error, Reason} ->
			{error, Reason}
	end.
