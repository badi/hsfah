
module FaH.Tool.Protomol.Output.DB ( formatAll
                                   , formatAll'

                                   , formatRunCloneGen
                                   , formatRunCloneGen'
                                   ) where

import FaH.Types
import FaH.Tool.Protomol.Generation

import Data.List (intercalate)
import Text.Printf


_name = "FaH.Tool.Output.DB"

addLog' :: Log m => String -> m ()
addLog' = addLog . printf "[%s] %s" _name

format :: Char -> Int -> String -> String
format c n fmt = let c' = [c]
           in intercalate c' $ replicate n fmt

formatAll' :: Char -> [String] -> Tool String
formatAll' sep vals = do
  rcg <- formatRunCloneGen' sep
  let rest = intercalate [sep] vals
  return $ printf "%s%c%s" rcg sep rest


formatRunCloneGen' :: Char -> Tool String
formatRunCloneGen' sep = do
  r <- getRunVal
  c <- getCloneVal
  g <- generation

  addLog' $ show (r,c,g)

  return $ printf (format sep 3 "%d") r c g

formatRunCloneGen = formatRunCloneGen' '|'
formatAll = formatAll' '|'