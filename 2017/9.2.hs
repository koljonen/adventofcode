removeCancelled :: ([Char], [Char], Bool) -> [Char]
removeCancelled (str, "", False) = str
removeCancelled (str, '!':input, False) = removeCancelled(str, input, True)
removeCancelled (str, x:input, False) = removeCancelled(str ++ [x], input, False)
removeCancelled (str, _:input, True) = removeCancelled(str, input, False)
countGarbage :: (Integer, [Char], Bool) -> Integer
countGarbage (count, "", False) = count
countGarbage (count, '<':input, False) = countGarbage(count, input, True)
countGarbage (count, _:input, False) = countGarbage(count, input, False)
countGarbage (count, '>':input, True) = countGarbage(count, input, False)
countGarbage (count, _:input, True) = countGarbage(count + 1, input, True)
getAns :: [Char] -> Integer
getAns str = countGarbage(0, removeCancelled("", str, False), False)
main = do
    input <- readFile("9.input")
    return (getAns(input))
