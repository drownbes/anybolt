{-# Language OverloadedStrings #-}

module Main where

import qualified Network.Socket as NS
import qualified Network.Socket.ByteString as NSB
import Network.URI
import Network.HTTP
import Data.ByteString.UTF8 (fromString, toString)
import Data.Aeson
import Data.Aeson.Types
import Control.Concurrent
import System.Posix.Types
import Control.Exception (finally)

uri = URI "" Nothing "/containers/json" "" ""

r = Request uri GET [
  Header HdrContentType "text/plain",
  Header HdrHost "localhost"] ""
strr = show r
btsr = fromString strr


data Container = Container { id :: String,  names :: [String]} deriving Show


myForkIO :: IO () -> IO (MVar ())
myForkIO io = do
  mvar <- newEmptyMVar
  forkIO (io `finally` putMVar mvar ())
  return mvar


unixConnect :: IO String
unixConnect = NS.withSocketsDo $ do
  soc <- NS.socket NS.AF_UNIX NS.Stream NS.defaultProtocol
  NS.connect soc $ NS.SockAddrUnix "/var/run/docker.sock"
  NSB.sendAll soc btsr
  desk <- NS.recvFd soc
  res <- NSB.recv soc 8024
  print res
  let strRes = toString res
  let body = last $ lines strRes
  print body
  -- print (decodeStrict (fromString body) :: Maybe [Container])
  let k = parseResponseHead $ lines strRes
  return body



main :: IO ()
main = do
  m <- myForkIO unixConnect
  takeMVar m
  putStrLn "Hello, Haskell! You're using a function from another package!"
