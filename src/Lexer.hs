module Lexer
       ( reserved
       , identifier
       , reservedOp
       , integer
       , aOperators
       , parens
       ) where

import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Expr
import Text.ParserCombinators.Parsec.Language (emptyDef)
import qualified Text.ParserCombinators.Parsec.Token as Token

import Syntax

miniMLDef =
  emptyDef { Token.identStart      = letter
           , Token.identLetter     = letter
           , Token.reservedNames   = [ "if"
                                     , "then"
                                     , "else"
                                     , "true"
                                     , "false"
                                     ]
           , Token.reservedOpNames = [ "+"
                                     , "-"
                                     , "*"
                                     , "="
                                     , "<"
                                     ]
           }

lexer = Token.makeTokenParser miniMLDef

identifier = Token.identifier lexer -- parses an identifier
reserved   = Token.reserved   lexer -- parses a reserved name
reservedOp = Token.reservedOp lexer -- parses an operator
parens     = Token.parens     lexer -- parses surrounding parenthesis:
                                    -- parens p
                                    -- takes care of the parenthesis and
                                    -- uses p to parse what's inside them
integer    = Token.integer    lexer -- parses an integer
semi       = Token.semi       lexer -- parses a semicolon
whiteSpace = Token.whiteSpace lexer -- parses whitespace

aOperators = [ [Infix  (reservedOp "*"   >> return (Times)) AssocLeft]
             , [Infix  (reservedOp "+"   >> return (Plus )) AssocLeft,
                Infix  (reservedOp "-"   >> return (Minus)) AssocLeft]
             ]