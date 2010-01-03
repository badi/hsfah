{-# LANGUAGE
  EmptyDataDecls
  , FlexibleInstances
  , MultiParamTypeClasses
  , Rank2Types
  #-}

module FaH.Types where

import Data.Convertible
import Data.Tagged

import Database.HDBC (IConnection)


data PRun
data PClone
data PFrame
data PProjArea
data PWorkArea
data PTrajPath
data PStructId


-- in case these need to be change, alias them here
type RunType = Int
type CloneType = Int

-- I shouldn't be able to treat runs and clones as the same.
-- Same goes for the workarea/project paths
type Run      = Tagged PRun Int
type Clone    = Tagged PClone Int
type Frame    = Tagged PFrame Integer
type WorkArea = Tagged PWorkArea FilePath
type ProjArea = Tagged PProjArea FilePath
type TrajPath = Tagged PTrajPath FilePath
type StructId = Tagged PStructId String


-- these are used to control the database interactions
newtype TableCreate = TableCreate String deriving Show -- ^ passed to HDBC to create the table
newtype DBName      = DBName String      deriving Show
newtype TableName   = TableName String   deriving Show
newtype ColName     = ColName String     deriving Show
newtype ColDesc     = ColDesc String     deriving Show -- ^ used in the creation of a table
newtype ColComment  = ColComment String  deriving Show
newtype TableDesc   = TableDesc String   deriving Show -- ^ 'create table <name> ( <desc> )'"

-- | Used to choose either the sql 'MAX' or 'MIN' function in 'SELECT'
data SqlOrd = Max | Min deriving Show


instance Convertible b c => Convertible (Tagged a b) c where
    safeConvert = safeConvert . unTagged

-- The info that a tool has access to
data ToolInfo = ToolInfo {
      run         :: Run
    , clone       :: Clone
    , workarea    :: WorkArea
    , projectArea :: ProjArea
    }



type Stat a = Either String a
type Status = Stat ()

type Action = IO Status

type Tool = ToolInfo -> Action

class Apply a b c where apply :: a -> b -> c

type DBTool = IConnection c => c -> Tool




data ProjectParameters = ProjectParameters {
      runs :: RunType
    , clones :: CloneType
    , location :: ProjArea
    }
