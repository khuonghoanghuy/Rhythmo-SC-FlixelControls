package rhythmo.macros;

import sys.io.Process;

class Macros
{
	public static macro function getCommitId():haxe.macro.Expr.ExprOf<String>
	{
		#if !display
		try
		{
			var daProcess = new Process('git', ['log', '--format=%h', '-n', '1']);
			daProcess.exitCode(true);
			return macro $v{daProcess.stdout.readLine()};
		}
		catch (e:Dynamic) {}
		#end
		return macro $v{'-'};
	}

	public static macro function getCommitNumber():haxe.macro.Expr
	{
		#if !display
		try
		{
			var process:Process = new Process('git', ['rev-list', '--count', 'HEAD']);
			process.exitCode(true);
			return macro $v{Std.parseInt(process.stdout.readLine())};
		}
		catch (e:Dynamic) {}
		#end

		return macro $v{0};
	}

	public static macro function getDefines():haxe.macro.Expr
	{
		return macro $v{haxe.macro.Context.getDefines()};
	}
}
