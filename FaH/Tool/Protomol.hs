{-# LANGUAGE
  NoMonomorphismRestriction
  #-}

module FaH.Tool.Protomol where

import FaH.Tool.Protomol.VMD.RMSD hiding (_name,addLog',testrmsd)
import Control.Concurrent
import FaH.Logging


import FaH.Types
import FaH.Archive
import FaH.Util
import FaH.Exceptions

import Control.Applicative ((<$>))
import Control.Monad.Error
import Control.Monad.State
import Control.Monad.List
import Control.Monad.Reader

import Data.List (sort)
import Data.Tagged

import System.FilePath
import System.FilePath.Glob
import System.Directory

import Text.Printf

_name = "FaH.Tool.Protomol"
_results_glob = "results-???.tar.bz2"
addLog' = addLog . printf "[%s] %s" _name

llocal = lift local
handle_tarball :: Tool a -> FilePath -> Tarball -> Tool a
handle_tarball tool target tball = do
  tinfo <- getToolInfo

  addLog' $ ((printf "handling %s" tball) :: String)

  safeLiftIO $ createDirectoryIfMissing True target
  safeLiftIO $ sys_extract_tarbz2 tball target

  useToolInfo (\ti -> ti { workArea = workArea ti <//> Tagged target }) tool


joinWorkArea :: WorkArea -> WorkArea -> WorkArea
joinWorkArea wa1 wa2 = Tagged $ unTagged wa1 </> unTagged wa2
(<//>) = joinWorkArea

tarballs :: TrajArea -> IO [Tarball]
tarballs tra = sort <$> globDir1 (compile _results_glob) (unTagged tra)


expand_dir wa = combine (unTagged wa) . takeFileName . dropExtension . dropExtension

protomol :: Tool a -> Tool [a]
protomol tool = do 
  tinfo <- getToolInfo

  addLog' $ (printf "starting run %d clone %d" (unTagged . run $ tinfo) (unTagged . clone $ tinfo) :: String)

  tarballs <- safeLiftIO $ tarballs (trajArea tinfo)

  mapM_ (addLog' . (++) "Found " . takeFileName . show) tarballs

  let target = expand_dir (workArea tinfo)
  

  ret <- mapM (\tb -> handle_tarball tool (target tb) tb)  tarballs

  safeLiftIO $ mapM_ (removeDirectoryRecursive . target) tarballs


  return ret

  


testp = let ti = ToolInfo (Tagged 808) (Tagged 1) (Tagged "/tmp/wa/") (Tagged "/home/badi/Research/fah/test/data/PROJ10000/RUN0/CLONE0")
        in do removeDirectoryRecursive "/tmp/hsfah/wa"
              createDirectory "/tmp/hsfah/wa"
              (l,_,chan) <- newLogger
              r <- runTool (protomol testrmsd) (Tool l ti)
              threadDelay 100000
              return r

testrmsd = let ti = ToolInfo r c wa undefined 
               r = Tagged 1
               c = Tagged 2
               wa = Tagged "/tmp/hsfah/wa"
               fileinfo = FileInfo { vmd_bin = "vmd"
                                   , psfpath = "/tmp/hsfah/ww.psf"
                                   , foldedpath = "/tmp/hsfah/ww_folded.pdb"
                                   , scriptname = "rmsd.tcl"
                                   , resultsname = "rmsd.out"
                                   , dcdname = "ww.dcd"
                                   , atomselect = Tagged "all"
                                   , screenoutput = DevNull
                                   }
               genparams = genParams fileinfo
               remove ps = [script ps, outfile ps]
           in do rmsd genparams remove
