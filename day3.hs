{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use camelCase" #-}
import Control.Applicative
import Data.Char
import System.IO
import Data.List (isPrefixOf)

-- Basic definitions

newtype Parser a = P (String -> [(a, String)])

parse :: Parser a -> String -> [(a, String)]
parse (P p) inp = p inp

item :: Parser Char
item =
  P
    ( \inp -> case inp of
        [] -> []
        (x : xs) -> [(x, xs)]
    )

-- Sequencing parsers

instance Functor Parser where
  -- fmap :: (a -> b) -> Parser a -> Parser b
  fmap g p =
    P
      ( \inp -> case parse p inp of
          [] -> []
          [(v, out)] -> [(g v, out)]
      )

instance Applicative Parser where
  -- pure :: a -> Parser a
  pure v = P (\inp -> [(v, inp)])

  -- <*> :: Parser (a -> b) -> Parser a -> Parser b
  pg <*> px =
    P
      ( \inp -> case parse pg inp of
          [] -> []
          [(g, out)] -> parse (fmap g px) out
      )

instance Monad Parser where
  -- (>>=) :: Parser a -> (a -> Parser b) -> Parser b
  p >>= f =
    P
      ( \inp -> case parse p inp of
          [] -> []
          [(v, out)] -> parse (f v) out
      )

-- Making choices

instance Alternative Parser where
  -- empty :: Parser a
  empty = P (\inp -> [])

  -- (<|>) :: Parser a -> Parser a -> Parser a
  p <|> q =
    P
      ( \inp -> case parse p inp of
          [] -> parse q inp
          [(v, out)] -> [(v, out)]
      )

-- Derived primitives

sat :: (Char -> Bool) -> Parser Char
sat p = do
  x <- item
  if p x then return x else empty

digit :: Parser Char
digit = sat isDigit

lower :: Parser Char
lower = sat isLower

upper :: Parser Char
upper = sat isUpper

letter :: Parser Char
letter = sat isAlpha

alphanum :: Parser Char
alphanum = sat isAlphaNum

char :: Char -> Parser Char
char x = sat (== x)

string :: String -> Parser String
string [] = return []
string (x : xs) = do
  char x
  string xs
  return (x : xs)

ident :: Parser String
ident = do
  x <- lower
  xs <- many alphanum
  return (x : xs)

nat :: Parser Int
nat = do
  xs <- some digit
  return (read xs)

int :: Parser Int
int =
  do
    char '-'
    n <- nat
    return (-n)
    <|> nat

-- Handling spacing

space :: Parser ()
space = do
  many (sat isSpace)
  return ()

token :: Parser a -> Parser a
token p = do
  space
  v <- p
  space
  return v

identifier :: Parser String
identifier = token ident

natural :: Parser Int
natural = token nat

integer :: Parser Int
integer = token int

symbol :: String -> Parser String
symbol xs = token (string xs)

look :: Parser String
look = P (\inp -> [(inp, inp)])

opDo = do
  string "do"
  char '('
  char ')'
  return True 

opDont = do
  string "don't"
  char '('
  char ')'
  return False

opMul = do
  string "mul"
  char '('
  x <- int
  char ','
  y <- int
  char ')'
  return (x * y)

skipUntil c = many (sat (/= c))

skipUntilSeq :: String -> Parser ()
skipUntilSeq seq = go
  where
    go = do
      input <- look
      if seq `isPrefixOf` input
        then pure ()
        else item *> go

skipAny :: Parser ()
skipAny = item *> pure ()

skipWithZero :: Parser Int
skipWithZero = item *> pure 0

skipWith v = item *> pure v

sumSegment :: String -> Int
sumSegment content = do
  let multiplications         = parse (many (tryParsingMul <|> skipWithZero)) content
  let flatten_multiplications = concat (map fst multiplications)
  sum flatten_multiplications
  where
    tryParsingMul = skipUntilSeq "mul" *> opMul

removeFirst :: [a] -> (Maybe a, [a])
removeFirst [] = (Nothing, [])
removeFirst (x:xs) = (Just x, xs)

main = do
   content <- readFile "day3.txt"

   print (sumSegment content)