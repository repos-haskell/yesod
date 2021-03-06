{-# LANGUAGE QuasiQuotes, TypeFamilies, OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TemplateHaskell #-}
import Yesod.Core
import Network.Wai.Handler.Warp (run)
import Data.Text (unpack)
import Text.Julius (julius)

data Subsite = Subsite String

type Strings = [String]

mkYesodSub "Subsite" [] [parseRoutes|
/ SubRootR GET
/multi/*Strings SubMultiR
|]

getSubRootR :: Yesod m => GHandler Subsite m RepPlain
getSubRootR = do
    Subsite s <- getYesodSub
    tm <- getRouteToMaster
    render <- getUrlRender
    $(logDebug) "I'm in SubRootR"
    return $ RepPlain $ toContent $ "Hello Sub World: " ++ s ++ ". " ++ unpack (render (tm SubRootR))

handleSubMultiR :: Yesod m => Strings -> GHandler Subsite m RepPlain
handleSubMultiR x = do
    Subsite y <- getYesodSub
    $(logInfo) "In SubMultiR"
    return . RepPlain . toContent . show $ (x, y)

data HelloWorld = HelloWorld { getSubsite :: String -> Subsite }
mkYesod "HelloWorld" [$parseRoutes|
/ RootR GET
/subsite/#String SubsiteR Subsite getSubsite
|]
instance Yesod HelloWorld where
    approot _ = ""
    yepnopeJs _ = Just $ Left "http://cdnjs.cloudflare.com/ajax/libs/modernizr/2.0.6/modernizr.min.js"

getRootR = do
    $(logOther "HAHAHA") "Here I am"
    defaultLayout $ do
        addScriptRemote "https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"
        toWidget [julius|$(function(){$("#mypara").css("color", "red")});|]
        [whamlet|<p #mypara>Hello World|]

main = toWaiApp (HelloWorld Subsite) >>= run 3000
