{-# LANGUAGE GeneralizedNewtypeDeriving #-}

import Control.Monad.Reader
import Control.Monad.Writer
import Control.Monad.State

type Stack   = [Int]
type Output  = [Int]
type Program = [Instr]

type VM a = ReaderT Program (WriterT Output (State Stack)) a

newtype Comp a = Comp { unComp :: ReaderT Program (WriterT Output (State Stack)) a }
  deriving (Monad, MonadReader Program, MonadWriter Output, MonadState Stack)

data Instr = Push Int | Pop | Puts

evalInstr :: Instr -> VM ()
evalInstr instr = case instr of
  Pop    -> modify tail
  Push n -> modify (n:)
  Puts   -> do
    val <- tos
    tell [val]

tos :: VM Int
tos = gets head

eval :: VM ()
eval = do
  instr <- ask
  case instr of
    []     -> return ()
    (i:is) -> evalInstr i >> local (const is) eval

execVM :: Program -> Output
execVM = flip evalState [] . execWriterT . runReaderT eval

program :: Program
program = [
     Push 42,
     Push 27,
     Puts,
     Pop,
     Puts,
     Pop
  ]

main :: IO ()
main = mapM_ print $ execVM program
