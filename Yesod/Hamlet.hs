{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
module Yesod.Hamlet
    ( -- * Hamlet library
      module Text.Hamlet
      -- * Convert to something displayable
    , hamletToContent
    , hamletToRepHtml
      -- * Page templates
    , PageContent (..)
    )
    where

import Text.Hamlet
import Yesod.Content
import Yesod.Handler

-- | Content for a web page. By providing this datatype, we can easily create
-- generic site templates, which would have the type signature:
--
-- > PageContent url -> Hamlet url
data PageContent url = PageContent
    { pageTitle :: Html ()
    , pageHead :: Hamlet url
    , pageBody :: Hamlet url
    }

-- | Converts the given Hamlet template into 'Content', which can be used in a
-- Yesod 'Response'.
hamletToContent :: Hamlet (Route master) -> GHandler sub master Content
hamletToContent h = do
    render <- getUrlRender
    return $ toContent $ renderHamlet render h

-- | Wraps the 'Content' generated by 'hamletToContent' in a 'RepHtml'.
hamletToRepHtml :: Hamlet (Route master) -> GHandler sub master RepHtml
hamletToRepHtml = fmap RepHtml . hamletToContent
