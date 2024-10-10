extends Node

func say(txt : String) -> LoggieMsg:
	return Loggie.msg(txt).info()
