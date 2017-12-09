removeCancelled :: ([Char], [Char], Bool) -> [Char]
removeCancelled (str, "", False) = str
removeCancelled (str, '!':input, False) = removeCancelled(str, input, True)
removeCancelled (str, x:input, False) = removeCancelled(str ++ [x], input, False)
removeCancelled (str, _:input, True) = removeCancelled(str, input, False)
removeGarbage :: ([Char], [Char], Bool) -> [Char]
removeGarbage (str, "", False) = str
removeGarbage (str, '<':input, False) = removeGarbage(str, input, True)
removeGarbage (str, x:input, False) = removeGarbage(str ++ [x], input, False)
removeGarbage (str, '>':input, True) = removeGarbage(str, input, False)
removeGarbage (str, _:input, True) = removeGarbage(str, input, True)
getScore :: ([Char], Integer, Integer) -> Integer
getScore ("", score, 0) = score
getScore ('{':input, score, depth) = getScore(input, score, depth + 1)
getScore ('}':input, score, depth) = getScore(input, score + depth, depth - 1)
getScore (_:input, score, depth) = getScore(input, score, depth)
getAns :: [Char] -> Integer
getAns str = getScore(removeGarbage("", removeCancelled("", str, False), False), 0, 0)
main = do
    input <- readFile("9.input")
    return (getAns(input))
