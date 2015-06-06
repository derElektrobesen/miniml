{-# OverloadedStrings #-}

module Main
       ( main
       ) where

import Control.Monad
import Control.Monad.State
import System.IO
import Text.ParserCombinators.Parsec hiding (State)
import qualified Data.Map as M
import Data.Aeson.Encode.Pretty
import qualified Data.ByteString.Lazy as B

import Syntax
import Lexer
import Parser (toplevelCmdP)
import TypeCheck
import Emit

import Debug.Trace

parseFile :: String -> IO ToplevelCmd
parseFile file = do
  program  <- readFile file
  putStr program
  case parse toplevelCmdP "" program of
   Left e  -> print e >> fail "parse error"
   Right r -> return r

-- shows type only
exec :: ToplevelCmd -> State Ctx String
exec (Def var e) = do
  ctx <- get
  let ty = typeOf ctx e
  put $ M.insert var ty ctx
  return $ var ++ " : " ++ show ty
exec (Expr e) = do
  ctx <- get
  let ty = typeOf ctx e
  return $ "- : " ++ show ty
    
shell :: IO ()
shell = do
  putStrLn "MiniML. Press Ctrl-C or Ctrl-D to exit."
  shell' (M.empty :: Ctx)

shell' :: Ctx ->  IO ()
shell' ctx = do
  putStr "MiniML> "
  hFlush stdout
  cmd <- getLine
  case parse toplevelCmdP "" cmd of
   Left e -> print e >> shell' ctx
   Right ast -> putStrLn str >> (B.putStrLn $ encodePretty ast) >> shell' ctx'
     where
       (str, ctx') = runState (exec ast) ctx

main :: IO ()
main = do
  ast <- parseFile "tests/let.miniml" 
  B.putStrLn $ encodePretty ast
  ast <- parseFile "tests/if.miniml"
  B.putStrLn $ encodePretty ast
  ast <- parseFile "tests/fun.miniml"
  B.putStrLn $ encodePretty ast
  ast <- parseFile "tests/apply.miniml"
  B.putStrLn $ encodePretty ast
  ast <- parseFile "tests/bool.miniml"
  B.putStrLn $ encodePretty ast
  ast <- parseFile "tests/minus.miniml"
  B.putStrLn $ encodePretty ast
  shell
