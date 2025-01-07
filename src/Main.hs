import System.IO (stdin, hReady, hSetEcho, hSetBuffering, BufferMode ( NoBuffering ) )
import Control.Monad (when)

-- Simple menu controller
main :: IO ()
main = do
  hSetBuffering stdin NoBuffering
  hSetEcho stdin False
  key <- getKey
  when (key /= "\ESC") $ do
    case key of
      "\ESC[A" -> putStr "↑"
      "\ESC[B" -> putStr "↓"
      "\ESC[C" -> putStr "→"
      "\ESC[D" -> putStr "←"
      "\n"     -> putStr "⎆"
      "\DEL"   -> putStr "⎋"
      _        -> return ()
    main

getKey :: IO [Char]
getKey = reverse <$> getKey' ""
  where getKey' chars = do
          char <- getChar
          more <- hReady stdin
          (if more then getKey' else return) (char:chars)
