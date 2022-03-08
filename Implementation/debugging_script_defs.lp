#script(python)
import clingo
def str_format(template_str: clingo.Symbol, *arguments: clingo.Symbol) -> clingo.Symbol:
    template_str = template_str.string
    arguments = (symbol.string if symbol.type == clingo.SymbolType.String else symbol for symbol in arguments)
    return clingo.String(template_str.format(*arguments))

def function_signature(symbol: clingo.Symbol) -> clingo.Symbol:
    return clingo.String(f'{symbol.name}/{len(symbol.arguments)}')
#end.
